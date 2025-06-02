# This file should ensure the existence of records required to run the application in every environment (production,
# development, test).

require 'json'
require 'benchmark'
require 'uri'

seed_file = 'recipes-en.json'

def parse_seed_file(filename, number_of_lines = nil)
  file = Rails.root.join('db', filename)
  recipes_data = JSON.parse(File.read(file))

  number_of_lines.nil? ? recipes_data : recipes_data[0..number_of_lines-1]
end

def seed_data(recipes, batch_size = 100)
  recipes.each_slice(batch_size).with_index do |batch, batch_index|
    # Speed up inserts by inserting batches of data in transactions
    ActiveRecord::Base.transaction do
      data_line = nil

      batch.each_with_index do |data, i|
        data_line = data
        data["author"] = data["author"].to_s.downcase.include?("deleteduser") ? nil : data["author"]
        author = data["author"].to_s.strip.present? ? Author.find_or_create_by!(name: data["author"]) : nil
        category = data["category"].to_s.strip.present? ? Category.find_or_create_by!(name: data["category"]) : nil
        cuisine = data["cuisine"].to_s.strip.present? ? Cuisine.find_or_create_by!(name: data["cuisine"]) : nil

        recipe = Recipe.create!(
          title: data["title"],
          cook_time: data["cook_time"],
          prep_time: data["prep_time"],
          ratings: data["ratings"],
          image_url: decoded_image_url(data["image"]),
          author:,
          category:,
          cuisine:
        )

        data["ingredients"].each do |ingredient_line|
          Ingredient.create!(
            recipe:,
            raw_text: ingredient_line
          )
        end

        recipes_inserted = batch_index * batch_size + i + 1
        puts "→ Inserted #{recipes_inserted} recipes..." if recipes_inserted % batch_size == 0
      end
    rescue ActiveRecord::RecordInvalid => e
      puts "⚠️ Error in batch #{batch_index + 1}, skipping..."
      puts "Line to insert:\n\n#{data_line}\n\n"
      puts e.message
    end
  end
end

def decoded_image_url(image_url)
  uri = URI(image_url)

  # It's a proxy URL with ?url=... , with fallback to original if no 'url' param
  if uri.query&.include?("url=")
    params = URI.decode_www_form(uri.query).to_h
    params["url"] || image_url
  else
    image_url
  end
rescue StandardError => e
  puts "⚠️ Error decoding image from URL: #{image_url}"
  raise e
end

data = parse_seed_file(seed_file)

puts "ℹ️ Seeding #{data.size} recipes..."

time = Benchmark.measure do
  # Speed up inserts by silencing logger on insert
  ActiveRecord::Base.logger.silence do
    seed_data(data)
  end
end

puts "✅ Done seeding."
puts "⏱️ Seeding completed in #{time.real.round(2)} seconds."
