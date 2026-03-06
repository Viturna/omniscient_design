#!/bin/bash
# Deuxième passe de migration - corrections fines

cd /Users/thomasriq/omniscient_design

echo "🔧 Deuxième passe: corrections précises..."

# Fonction pour remplacer avec plus de précision
replace_careful() {
  local search="$1"
  local replace="$2"
  echo "   Remplaçant: $search → $replace"
  find app config db test lib -type f \( -name '*.rb' -o -name '*.erb' -o -name '*.js' \) \
    ! -path "*/node_modules/*" \
    ! -path "*/vendor/*" \
    -exec sed -i '' "s/$search/$replace/g" {} +
}

# Remplacer les noms de méthodes et variables qui ont survécu
replace_careful "set_oeuvre" "set_reference"
replace_careful "saved_oeuvres" "saved_references"
replace_careful "Oeuvre\." "Reference\."
replace_careful "Oeuvre\[" "Reference\["
replace_careful "Oeuvre\(" "Reference\("
replace_careful "oeuvre\." "reference\."
replace_careful " Oeuvre " " Reference "
replace_careful "('Oeuvre')" "('Reference')"
replace_careful '("Oeuvre")' '("Reference")'

# Dans les vues et helpers
replace_careful "nom_oeuvre" "nom_reference"
replace_careful "date_oeuvre" "date_reference"

# Modèles et associations
replace_careful "has_many :oeuvres" "has_many :references"
replace_careful "belongs_to :oeuvre" "belongs_to :reference"
replace_careful "add_oeuvre" "add_reference"
replace_careful "remove_oeuvre" "remove_reference"

echo "✅ Corrections appliquées!"
