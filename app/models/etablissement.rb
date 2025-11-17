class Etablissement < ApplicationRecord
  validates :name, uniqueness: { message: I18n.t('errors.messages.name_already_taken') }

  has_many :users

 def all_info
    name_with_status = [
      name,
      (statut_public_prive.present? ? "(#{statut_public_prive})" : nil)
    ].compact.join(' ')
    
    details = [
      address,
      (academy.present? ? "#{I18n.t('etablissement.academy_prefix', default: 'Académie :')} #{academy}" : nil)
    ].compact_blank.join(', ') 

    [city, name_with_status, details].compact_blank.join(' | ')
  end
end
