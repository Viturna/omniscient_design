#!/bin/bash
# Script de migration oeuvres → references
# Ce script renomme automatiquement tous les fichiers et références

set -e  # Stop à la première erreur
cd /Users/thomasriq/omniscient_design

echo "🚀 Démarrage de la migration oeuvres → references..."

# ===== RENOMMER LES FICHIERS =====
echo "📁 Renommage des fichiers..."

# Contrôleurs
mv -v app/controllers/oeuvres_controller.rb app/controllers/references_controller.rb 2>/dev/null || true
mv -v app/controllers/admin/oeuvres_controller.rb app/controllers/admin/references_controller.rb 2>/dev/null || true

# Dossiers de vues
mv -v app/views/oeuvres app/views/references 2>/dev/null || true
mv -v app/views/admin/oeuvres app/views/admin/references 2>/dev/null || true

# Helpers
mv -v app/helpers/oeuvres_helper.rb app/helpers/references_helper.rb 2>/dev/null || true

# Models
mv -v app/models/oeuvre.rb app/models/reference.rb 2>/dev/null || true
mv -v app/models/oeuvre_image.rb app/models/reference_image.rb 2>/dev/null || true
mv -v app/models/oeuvre_studio.rb app/models/reference_studio.rb 2>/dev/null || true
mv -v app/models/oeuvres_domaine.rb app/models/references_domaine.rb 2>/dev/null || true
mv -v app/models/notions_oeuvre.rb app/models/notions_reference.rb 2>/dev/null || true
mv -v app/models/designers_oeuvre.rb app/models/designers_reference.rb 2>/dev/null || true
mv -v app/models/rejected_oeuvre.rb app/models/rejected_reference.rb 2>/dev/null || true

# JavaScript
mv -v app/javascript/controllers/oeuvres_counter_controller.js app/javascript/controllers/references_counter_controller.js 2>/dev/null || true

# Tests
mv -v test/controllers/oeuvres_controller_test.rb test/controllers/references_controller_test.rb 2>/dev/null || true
mv -v test/fixtures/oeuvres.yml test/fixtures/references.yml 2>/dev/null || true

# ===== REMPLACER LE CONTENU DES FICHIERS =====
echo "🔄 Mise à jour du contenu des fichiers..."

# Fonction pour remplacer récursivement
replace_in_all_files() {
  local search="$1"
  local replace="$2"
  echo "   Remplacemant: $search → $replace"
  
  # Fichiers Ruby
  find app config db test lib -type f \( -name '*.rb' -o -name '*.erb' -o -name '*.js' \) -exec sed -i '' "s/$search/$replace/g" {} + 2>/dev/null || true
}

# Remplacer les noms de classes principales
replace_in_all_files "class Oeuvre" "class Reference"
replace_in_all_files "class OeuvresController" "class ReferencesController"
replace_in_all_files "class OeuvresHelper" "class ReferencesHelper"
replace_in_all_files "class OeuvreImage" "class ReferenceImage"
replace_in_all_files "class OeuvreStudio" "class ReferenceStudio"
replace_in_all_files "class OeuvresDomaine" "class ReferencesDomaine"
replace_in_all_files "class NotionsOeuvre" "class NotionsReference"
replace_in_all_files "class DesignersOeuvre" "class DesignersReference"
replace_in_all_files "class RejectedOeuvre" "class RejectedReference"
replace_in_all_files "class OeuvresCounter" "class ReferencesCounter"

# Remplacer les variables et références
replace_in_all_files "@oeuvre" "@reference"
replace_in_all_files "@oeuvres" "@references"
replace_in_all_files ":oeuvre" ":reference"
replace_in_all_files "oeuvre_id" "reference_id"

# Remplacer dans les chemins/dossiers
replace_in_all_files "oeuvres/" "references/"
replace_in_all_files "oeuvres#" "references#"
replace_in_all_files "oeuvres_helper" "references_helper"
replace_in_all_files "oeuvres_counter" "references_counter"

# Remplacer les noms de paramètres et associations
replace_in_all_files ":oeuvres" ":references"
replace_in_all_files "'oeuvres" "'references"
replace_in_all_files "\"oeuvres" "\"references"

# Remplacer dans les noms de fichiers/ressources locales
replace_in_all_files "frise_oeuvres" "frise_references"
replace_in_all_files "oeuvres_verbs" "references_verbs"

# Remplacer les pluriels dans helper/view
replace_in_all_files "oeuvres" "references"

echo "✅ Migration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Vérifier les fichiers de contrôleur (sinon erreur: Oeuvre vs Reference)"
echo "2. Lancer: rails db:migrate"
echo "3. Tester en local: rails s"
echo ""
echo "💡 Conseil: Cherchez 'Oeuvre' ou 'oeuvre' pour trouver les références manquées"
