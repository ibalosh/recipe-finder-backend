class Recipe < ApplicationRecord
  belongs_to :author, optional: true
  belongs_to :category, optional: true
  belongs_to :cuisine, optional: true
  has_many :ingredients

  def author_name
    author&.name || "deleted-user"
  end

  def cuisine_name
    cuisine&.name || ""
  end
end
