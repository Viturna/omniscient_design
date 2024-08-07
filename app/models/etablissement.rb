class Etablissement < ApplicationRecord
  validates :name, uniqueness: true
  has_many :users
  def all_info
    "#{city} | #{name}, #{address}, Académie de #{academy}"
  end
end
