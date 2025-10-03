class DesignerCountry < ApplicationRecord
  belongs_to :designer
  belongs_to :country

  validates :country_id,
            uniqueness: { scope: :designer_id,
                          message: I18n.t('errors.messages.country_already_associated') }
end
