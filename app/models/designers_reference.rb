class DesignersReference < ApplicationRecord
  belongs_to :designer
  belongs_to :reference

   validates :designer_id,
            uniqueness: {
              scope: :reference_id,
              message: I18n.t('errors.messages.designer_already_associated')
            }
end
