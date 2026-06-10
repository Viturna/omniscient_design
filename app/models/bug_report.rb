class BugReport < ApplicationRecord
  belongs_to :user, optional: true

  attribute :status, :integer, default: :a_faire

  enum :status, {
    a_faire: 0,
    en_cours: 1,
    corrige: 2
  }

  validates :description, presence: true
  validates :url,
            format: {
              with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
              message: 'doit être une URL HTTP ou HTTPS valide'
            },
            allow_blank: true
end
