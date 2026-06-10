class Notion < ApplicationRecord
  # --- RELATIONS ---
  # Une notion possède plusieurs references via la table notions_references
  has_and_belongs_to_many :references

  # --- VALIDATIONS ---
  validates :name, presence: true, uniqueness: { scope: :theme, case_sensitive: false }
  validates :theme, presence: true

  # --- SCOPES (Utilisés dans la vue) ---

  # Tri par défaut : par nom
  scope :ordered, -> { order(:name) }

  # Filtre pour récupérer les notions d'un thème précis
  scope :by_theme, ->(theme_name) { where(theme: theme_name) }

  # --- MÉTHODES DE CLASSE (Celle qui manque) ---

  # Retourne la liste des thèmes uniques (ex: ["CONCEPTION...", "USAGE..."])
  # Utilisé pour générer les colonnes du méga-menu
  def self.unique_themes
    distinct.pluck(:theme).compact.sort
  end
end
