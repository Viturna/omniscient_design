class Etablissement < ApplicationRecord
  validates :name, uniqueness: { message: I18n.t('errors.messages.name_already_taken') }

  has_many :users

  def all_info
    "#{city} | #{name}, #{address}, #{I18n.t('etablissement.academy_prefix')} #{academy}"
  end
end
