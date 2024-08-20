class Country < ApplicationRecord
  validates :country, uniqueness: true
  has_many :designers

  def name
    country
  end
end
