class Notion < ApplicationRecord
  # --- RELATIONS ---
  # Une notion possède plusieurs verbes (ex: "La matérialité" possède "Texturer", "Solliciter"...)
  has_many :verbs, dependent: :destroy
  
  # On peut accéder aux oeuvres via les verbes
  has_many :oeuvres, through: :verbs

  # --- VALIDATIONS ---
  validates :name, presence: true, uniqueness: { case_sensitive: false }
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