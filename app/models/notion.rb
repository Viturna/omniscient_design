class Notion < ApplicationRecord
  has_many :notion_oeuvres
  has_many :oeuvres, through: :notion_oeuvres
end