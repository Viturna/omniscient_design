class Reference < ApplicationRecord
  self.table_name = 'references'
  extend FriendlyId

  has_many :reference_images, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :reference_images, allow_destroy: true, 
                                reject_if: proc { |attributes| attributes['file'].blank? }, 
                                limit: 3
  friendly_id :nom_reference, use: :slugged

  def should_generate_new_friendly_id?
    nom_reference_changed?
  end

  validates :nom_reference, uniqueness: true, presence: true
    
  has_many :references_domaines, dependent: :destroy
  has_many :domaines, through: :references_domaines


  has_many :list_items, as: :listable
  has_many :lists, through: :list_items
  belongs_to :user, optional: true
  belongs_to :validated_by_user, class_name: 'User', foreign_key: 'validated_by_user_id', optional: true

  has_many :designers_references, dependent: :destroy
  has_many :designers, through: :designers_references

  has_many :reference_studios, dependent: :destroy
  has_many :studios, through: :reference_studios

  has_and_belongs_to_many :verbs
  has_many :notions, -> { distinct }, through: :verbs

  attr_accessor :rejection_reason

  attribute :source, :json, default: []

  
  def validated?
    validation == true
  end

end