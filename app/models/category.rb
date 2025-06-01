class Category < ApplicationRecord
  has_many :recipes

  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
end
