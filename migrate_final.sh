#!/bin/bash
# Script final de correction - passe aagressive sur les fichiers clés

cd /Users/thomasriq/omniscient_design

echo "🔨 Passe finale agressive de correction..."

# Fonction de remplacement agressif
aggressive_replace() {
  local file="$1"
  local search="$2"
  local replace="$3"
  
  if [ -f "$file" ]; then
    sed -i '' "s/$search/$replace/g" "$file"
    echo "  ✓ Fixed $file"
  fi
}

# Corriger le contrôleur références
aggressive_replace "app/controllers/references_controller.rb" "|oeuvre|" "|reference|"
aggressive_replace "app/controllers/references_controller.rb" " oeuvre," " reference,"
aggressive_replace "app/controllers/references_controller.rb" "@reference\.oeuvre_images" "@reference\.reference_images"
aggressive_replace "app/controllers/references_controller.rb" "oeuvre_params" "reference_params"
aggressive_replace "app/controllers/references_controller.rb" "RejectedReference" "RejectedReference"
aggressive_replace "app/controllers/references_controller.rb" "edit_oeuvre_path" "edit_reference_path"
aggressive_replace "app/controllers/references_controller.rb" "Oeuvre\.joins" "Reference\.joins"
aggressive_replace "app/controllers/references_controller.rb" "RejectedReference" "RejectedReference"

# Corriger le contrôleur admin references
aggressive_replace "app/controllers/admin/references_controller.rb" "|oeuvre|" "|reference|"
aggressive_replace "app/controllers/admin/references_controller.rb" " oeuvre " " reference "
aggressive_replace "app/controllers/admin/references_controller.rb" "oeuvre_id" "reference_id"

# Corriger le modèle Reference
aggressive_replace "app/models/reference.rb" "has_many :oeuvres_domaines" "has_many :references_domaines"
aggressive_replace "app/models/reference.rb" "has_many :oeuvre_images" "has_many :reference_images"
aggressive_replace "app/models/reference.rb" "has_many :oeuvre_studios" "has_many :reference_studios"
aggressive_replace "app/models/reference.rb" "has_many :notions_oeuvres" "has_many :notions_references"
aggressive_replace "app/models/reference.rb" "has_many :designers_oeuvres" "has_many :designers_references"

# Corriger les références dans les associations des autres modèles
aggressive_replace "app/models/list.rb" "has_many :lists_oeuvres" "has_many :lists_references"
aggressive_replace "app/models/list.rb" "through: :lists_oeuvres" "through: :lists_references"
aggressive_replace "app/models/list.rb" ":oeuvres" ":references"

aggressive_replace "app/models/designer.rb" "has_many :designers_oeuvres" "has_many :designers_references"
aggressive_replace "app/models/designer.rb" "through: :designers_oeuvres" "through: :designers_references"
aggressive_replace "app/models/designer.rb" ":oeuvres" ":references"

aggressive_replace "app/models/user.rb" "has_many :saved_oeuvres" "has_many :saved_references"
aggressive_replace "app/models/user.rb" "through: :oeuvres" "through: :references"

# Corriger les noms de méthodes dans les helpers
aggressive_replace "app/helpers/references_helper.rb" "def oeuvre_link" "def reference_link"
aggressive_replace "app/helpers/references_helper.rb" "@oeuvre" "@reference"

echo "✅ Corrections finales appliquées!"
