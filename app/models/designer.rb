class Designer < ApplicationRecord
  extend FriendlyId
  friendly_id :nom_designer, use: :slugged

  # after_commit :reindex_searchkick, if: :validated?
  # after_destroy :remove_from_searchkick


  validates :nom, presence: true
  validate :valid_death_year, if: -> { date_deces.present? }
  validate :valid_birth_year

  has_and_belongs_to_many :oeuvres, dependent: :destroy
  has_many :designer_countries, dependent: :destroy
  has_many :countries, through: :designer_countries
  validates :countries, length: { maximum: 3,
                                  message: I18n.t('errors.messages.max_countries') }

  has_many :designers_domaines, dependent: :destroy
  has_many :domaines, through: :designers_domaines
  
  has_many :list_items, as: :listable
  has_many :lists, through: :list_items
  belongs_to :user, optional: true
  belongs_to :validated_by_user, class_name: 'User', foreign_key: 'validated_by_user_id', optional: true

  serialize :source, Array, coder: JSON
  attr_accessor :rejection_reason

  def nom_designer
    prenom.present? ? "#{prenom} #{nom}" : nom
  end

  def validated?
    validation == true
  end

  private

  def reindex_searchkick
    reindex
  end
  def remove_from_searchkick
    self.class.search_index.remove(self)
  end

  def valid_birth_year
    if date_naissance.present?
      year = date_naissance.to_i
      current_year = Date.current.year
      if year < 0 || year > current_year
      errors.add(:date_naissance,
                 I18n.t('errors.messages.birth_year_invalid',
                        current_year: current_year))
      end
    end
  end

  def valid_death_year
    if date_deces.present?
      year = date_deces.to_i
      current_year = Date.current.year
      if year < 0 || year > current_year
        errors.add(:date_deces,
                 I18n.t('errors.messages.death_year_invalid',
                        current_year: current_year))
      end
    end
  end

  validates :slug, uniqueness: true, presence: true
end
