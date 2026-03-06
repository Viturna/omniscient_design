class NotionsReference < ApplicationRecord
  belongs_to :reference
  belongs_to :notion

  attr_accessor :attribute
  before_save :set_default_notion

   def set_default_notion
    self.attribute = I18n.t('notions_reference.no_association') if self.attribute.blank?
  end
end
