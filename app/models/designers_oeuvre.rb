class DesignersOeuvre < ApplicationRecord
  belongs_to :designer
  belongs_to :oeuvre

   validates :designer_id,
            uniqueness: {
              scope: :oeuvre_id,
              message: I18n.t('errors.messages.designer_already_associated')
            }
end
