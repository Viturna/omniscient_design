# 📋 Guide de Migration: Oeuvres → References

## ✅ Ce qui a été fait

### 1. **Base de données**

Deux migrations créées:

- `20260306000001_rename_oeuvres_to_references.rb` - Renomme les tables
- `20260306000002_rename_oeuvre_columns_to_references.rb` - Renomme les colonnes

### 2. **Routes avec redirections 301**

- Anciennes URLs `/oeuvres/...` redirigent vers `/references/...` (status 301 = permanent)
- Les recherches `/frise/oeuvres` redirigent vers `/frise/references`
- Les routes admin adaptées

### 3. **Fichiers renommés**

✓ Contrôleurs: `oeuvres_controller.rb` → `references_controller.rb`
✓ Modèles: `oeuvre.rb` → `reference.rb`
✓ Vues: `app/views/oeuvres/` → `app/views/references/`
✓ Helpers: `oeuvres_helper.rb` → `references_helper.rb`
✓ Tests: `oeuvres_controller_test.rb` → `references_controller_test.rb`
✓ JavaScript: `oeuvres_counter_controller.js` → `references_counter_controller.js`

### 4. **Relations de base de données renommées**

Tables renommées:

- `oeuvres` → `references`
- `oeuvre_images` → `reference_images`
- `oeuvre_studios` → `reference_studios`
- `oeuvres_domaines` → `references_domaines`
- `oeuvres_verbs` → `references_verbs`
- `designers_oeuvres` → `designers_references`
- `lists_oeuvres` → `lists_references`
- `notions_oeuvres` → `notions_references`
- `rejected_oeuvres` → `rejected_references`

## 🚀 Étapes de déploiement

### 1. Test local

\`\`\`bash
cd /Users/thomasriq/omniscient_design

# Vérifier la syntaxe Rails

rails db:migrate --verbose

# Tester le serveur

rails s
\`\`\`

### 2. Vérifier les erreurs

\`\`\`bash

# Chercher les références restantes

grep -r "class Oeuvre" app/
grep -r "def oeuvre" app/
grep -r "@oeuvre" app/ --include="\*.rb"
\`\`\`

### 3. Générer les assets

\`\`\`bash
rails assets:precompile
\`\`\`

### 4. Déployer

\`\`\`bash
git add .
git commit -m "Refactor: Rename oeuvres to references with 301 redirects"
git push production main
\`\`\`

## 🔗 Redirections SEO (301)

Les anciennes URLs restent accessibles avec une redirection **301 Moved Permanently** qui indique aux moteurs de recherche que le contenu a été déplacé _définitivement_. Cela préserve le SEO:

### Exemples de redirections:

- `/fr/oeuvres` → `/fr/references` ✓ SEO préservé
- `/en/oeuvres/mon-slug` → `/en/references/mon-slug` ✓ SEO préservé
- `/admin/oeuvres/verbs` → `/admin/references/verbs` ✓ SEO préservé

### Dans `config/routes.rb`:

\`\`\`ruby

# Les anciennes routes redirigent avec status 301

get '/oeuvres', to: redirect { |params, req|
req.original_fullpath.gsub(/\/oeuvres/, '/references')
}, status: :moved_permanently

get '/oeuvres/:slug', to: redirect { |params, req|
"/#{params[:locale] || 'fr'}/references/#{params[:slug]}"
}, status: :moved_permanently
\`\`\`

## ⚠️ Points à vérifier après déploiement

1. **Contrôler les logs d'erreurs**
   \`\`\`bash
   tail -f log/production.log | grep -i "oeuvre\\|reference"
   \`\`\`

2. **Tester les anciennes URLs**
   - Visitez: `http://site.com/fr/oeuvres`
   - Doit rediriger vers: `http://site.com/fr/references` (status 301)

3. **Vérifier la console d'admin Google Search Console**
   - Les redirections 301 doivent être acceptées
   - URL inspection pour valider les redirects

4. **Mettre à jour les sitemaps** (si vous avez xml-sitemap)
   \`\`\`bash
   rake sitemap:refresh
   \`\`\`

## 🛠️ Scripts d'aide créés

\`\`\`
/migrate_oeuvres_to_references.sh # Script principal
/migrate_oeuvres_to_references_phase2.sh # Corrections de phase 2
/migrate_final.sh # Corrections finales
\`\`\`

## 🐛 Dépannage

### Erreur: "uninitialized constant Reference"

Cause: Une classe n'a pas été renommée correctement
Solution:
\`\`\`bash
grep -r "Oeuvre\." app/ --include="\*.rb" | grep -v ".old" | head -20
\`\`\`

### Erreur: "table references doesn't exist"

Cause: La migration n'a pas été exécutée
Solution:
\`\`\`bash
rails db:migrate
rails db:migrate:status
\`\`\`

### Les redirections ne fonctionnent pas

Vérifier dans `config/routes.rb` que les routes de redirection sont **avant** les autres routes.

## 🎯 Résumé des bénéfices

✓ Nomenclature plus cohérente en anglais
✓ SEO préservé avec redirections 301
✓ Anciennes URLs restent accessibles pour les links externes
✓ Moteurs de recherche mettent à jour leurs index automatiquement
✓ Zéro impact sur les utilisateurs
