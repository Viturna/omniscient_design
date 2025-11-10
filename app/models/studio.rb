class Studio < ApplicationRecord
  extend FriendlyId
  friendly_id :nom, use: :slugged

  validates :nom, presence: true


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

  attribute :source, :json, default: []

  attr_accessor :rejection_reason

    def validated?
    validation == true
  end
    validates :slug, uniqueness: true, presence: true
end
