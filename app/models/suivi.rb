class Suivi < ApplicationRecord
  belongs_to :user

  validates :nb_references_emises, :nb_references_validees, :nb_references_non_validees, :nb_references_refusees, numericality: { greater_than_or_equal_to: 0 }
end
