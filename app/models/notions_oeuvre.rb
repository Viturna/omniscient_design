class NotionsOeuvre < ApplicationRecord
  belongs_to :oeuvre
  belongs_to :notion

  attr_accessor :attribute
  before_save :set_default_notion

  def set_default_notion
    self.attribute = 'pas de notions associées' if self.attribute.blank?
  end
end
