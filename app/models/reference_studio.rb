class ReferenceStudio < ApplicationRecord
  belongs_to :reference
  belongs_to :studio

  validates :reference_id, uniqueness: { scope: :studio_id }
end