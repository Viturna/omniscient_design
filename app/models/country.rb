class Country < ApplicationRecord
  validates :country, uniqueness: true
  has_many :designer_countries
  has_many :designers, through: :designer_countries

  has_many :studio_countries, dependent: :destroy
  has_many :studios, through: :studio_countries

  def name
    country
  end
end
