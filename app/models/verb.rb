class Verb < ApplicationRecord
  belongs_to :notion
  has_and_belongs_to_many :oeuvres

  validates :name, presence: true
end