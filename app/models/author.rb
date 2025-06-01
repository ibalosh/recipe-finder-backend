class Author < ApplicationRecord
  has_many :recipes

  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
end
