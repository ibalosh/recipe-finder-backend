class Author < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
end
