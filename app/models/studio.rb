class Studio < ApplicationRecord
  extend FriendlyId
  friendly_id :nom, use: :slugged

  validates :nom, presence: true

   def should_generate_new_friendly_id?
    nom_changed?
  end

  has_many :studio_images, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :studio_images, allow_destroy: true, 
                                reject_if: proc { |attributes| attributes['file'].blank? }, 
                                limit: 3

  has_many :studios_domaines, dependent: :destroy
  has_many :domaines, through: :studios_domaines
  has_many :studio_countries, dependent: :destroy
  
  has_many :countries, through: :studio_countries
  validates :countries, length: { maximum: 3,
                                  message: I18n.t('errors.messages.max_countries') }

  has_many :list_items, as: :listable
  has_many :lists, through: :list_items
  
  belongs_to :user, optional: true
  belongs_to :validated_by_user, class_name: 'User', optional: true

  has_many :designer_studios, dependent: :destroy
  has_many :designers, through: :designer_studios

  accepts_nested_attributes_for :designer_studios, 
                                allow_destroy: true, 
                                reject_if: proc { |attributes| attributes['designer_id'].blank? },
                                limit: 10

  validates :designers, length: { 
    maximum: 10, 
    message: "ne peut pas dépasser 10 designers." 
  }
  
  has_many :oeuvres, through: :designers


  attribute :source, :json, default: []

  attr_accessor :rejection_reason

    def validated?
    validation == true
  end
    validates :slug, uniqueness: true, presence: true
end
