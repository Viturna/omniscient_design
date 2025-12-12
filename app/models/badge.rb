class Badge < ApplicationRecord
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges

  # Catégories
  enum :category, {
    special: "special",         # Omniscient User, Early Adopter, Noctambule...
    donor: "donor",             # Donateur
    contributor: "contributor", # Contributeur (Refs)
    ambassador: "ambassador",   # Ambassadeur (Parrainage)
    investigator: "investigator" # Investigateur (Feedback/Bugs)
  }

  # Niveaux
  enum :level, { 
    standard: "standard",
    bronze: "bronze", 
    silver: "silver", 
    gold: "gold",
    platinum: "platinum"
  }

  validates :name, presence: true, uniqueness: true
  validates :image_name, presence: true
end