class NotionsOeuvre < ApplicationRecord
  belongs_to :oeuvre
  belongs_to :notion

  attr_accessor :attribute
  before_save :set_default_notion

   def set_default_notion
    self.attribute = I18n.t('notions_oeuvre.no_association') if self.attribute.blank?
  end
end
