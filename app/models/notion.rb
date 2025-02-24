class Notion < ApplicationRecord
  has_many :notions_oeuvres, class_name: 'NotionsOeuvre', dependent: :destroy
  has_many :oeuvres, through: :notions_oeuvres
end