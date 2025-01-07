class Country < ApplicationRecord
  validates :country, uniqueness: true
  has_many :designer_countries
  has_many :designers, through: :designer_countries

  def name
    country
  end
end
