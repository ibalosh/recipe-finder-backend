FactoryBot.define do
  factory :recipe do
    title { "Test Recipe" }
    cook_time { 10 }
    prep_time { 5 }
    image_url { Faker::Internet.url }

    transient do
      ingredients { [] }
    end

    after(:create) do |recipe, evaluator|
      evaluator.ingredients.each do |ingredient|
        recipe.ingredients.create!(raw_text: ingredient)
      end
    end
  end
end
