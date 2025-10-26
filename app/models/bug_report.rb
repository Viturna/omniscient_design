# app/models/bug_report.rb

class BugReport < ApplicationRecord
  belongs_to :user

  # 1. Définissez l'attribut, son type et son défaut D'ABORD.
  # C'est ce qui garantit que :a_faire (soit 0) sera utilisé si
  # la valeur est absente lors du .new.
  attribute :status, :integer, default: :a_faire

  # 2. Appliquez l'enum ENSUITE.
  # L'enum va maintenant "décorer" l'attribut qui a déjà un défaut.
  enum :status, {
    a_faire: 0,
    en_cours: 1,
    corrige: 2
  }

  validates :description, presence: true
  # La validation d'inclusion est gérée par l'enum
  validates :url,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              message: "doit être une URL HTTP ou HTTPS valide"
            },
            allow_blank: true
end