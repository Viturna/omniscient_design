# 🔗 Redirections SEO 301 - Explications complètes

## Pourquoi les redirections 301?

Quand vous changez une URL, Google et les autres moteurs de recherche:

- Ont besoin d'être informés que le contenu a été **déplacé définitivement**
- Doivent transférer le "jus" SEO (valeur) vers la nouvelle URL
- Doivent mettre à jour leur index

Une **redirection 301 (Moved Permanently)** dit:

> ✅ "Ce contenu a déménagé ici définitivement. Mettez votre cache à jour."

## Ce qui a été implémenté

### 1. Redirections pour les URLs publiques

**Avant la migration:**

```
GET /fr/oeuvres/mon-oeuvre → Reference affichée
```

**Après la migration:**

```
GET /fr/oeuvres/mon-oeuvre → 301 Redirect → /fr/references/mon-oeuvre
GET /fr/references/mon-oeuvre → Reference affichée (.new URL)
```

### 2. Routes de redirection dans `config/routes.rb`

```ruby
scope "(:locale)", locale: /fr|en/ do
  # NOUVELLES routes (principales)
  resources :references, param: :slug do
    # ... actions ...
  end

  # ANCIENNES routes (redirections SEO 301)
  get '/oeuvres', to: redirect do |params, req|
    req.original_fullpath.gsub(/\/oeuvres/, '/references')
  end, status: :moved_permanently

  get '/oeuvres/:slug', to: redirect do |params, req|
    "/#{params[:locale] || 'fr'}/references/#{params[:slug]}"
  end, status: :moved_permanently
end
```

## Comment ça fonctionne exactement?

### Exemple 1: Page principale

```
Client fait:   GET /fr/oeuvres
                ↓
Rails répond:  301 Moved Permanently
               Location: /fr/references
                ↓
Client fait:   GET /fr/references
                ↓
Rails répond:  200 OK + Page
```

### Exemple 2: Reference spécifique

```
Ancienne URL:  /fr/oeuvres/joconde-leonard-de-vinci
                ↓
Redirection:   301 → /fr/references/joconde-leonard-de-vinci
                ↓
Nouvelle URL:  /fr/references/joconde-leonard-de-vinci
```

## Impact sur le SEO

| Aspect        | Avant          | Après             | Impact |
| ------------- | -------------- | ----------------- | ------ |
| URL           | `/oeuvres/:id` | `/references/:id` | ✅ Bon |
| Redirects 301 | N/A            | Activées          | ✅ Bon |
| Page Rank     | Préservé       | Transféré (301)   | ✅ Bon |
| Indexation    | Existante      | Mise à jour       | ✅ Bon |
| Backlinks     | Ancienne URL   | Redirigés         | ✅ Bon |

## Vérifier que ça fonctionne

### 1. En local

```bash
curl -I http://localhost:3000/fr/oeuvres
# Doit retourner: HTTP/1.1 301 Moved Permanently
# Location: /fr/references

curl -I http://localhost:3000/fr/oeuvres/mon-slug
# Doit retourner: HTTP/1.1 301 Moved Permanently
# Location: /fr/references/mon-slug
```

### 2. Avec Google Chrome DevTools

1. Ouvrir DevTools (F12)
2. Aller à l'onglet "Network"
3. Visiter `/fr/oeuvres`
4. Voir la requête → Status: 301
5. Voir "Location: /fr/references"

### 3. Avec Google Search Console

1. Aller à [Google Search Console](https://search.google.com/search-console)
2. Tester l'URL: `/fr/oeuvres/ma-reference`
3. Google doit montrer qu'il redirige vers la nouvelle URL

## Autres redirections incluses

```ruby
# Admin
get 'oeuvres/verbs'          → redirect → get 'references/verbs'
patch 'oeuvres/:id/update'   → redirect → patch 'references/:id/update'

# Recherche
get 'frise/oeuvres'          → redirect → get 'frise/references'

# Listes
post 'add_oeuvre'            → redirect → post 'add_reference'
delete 'remove_oeuvre'       → redirect → delete 'remove_reference'
get 'load_more_oeuvres'      → redirect → get 'load_more_references'
```

## Timeline attendue de Google

| Temps       | Événement                | Description                     |
| ----------- | ------------------------ | ------------------------------- |
| Immédiat    | Crawl de l'ancienne URL  | Google voit le 301              |
| 1-7 jours   | Récrawlage (reindex)     | Google met à jour l'index       |
| 7-30 jours  | Stabilisation du ranking | SEO peut fluctuer               |
| 30-90 jours | Consolidation du SEO     | Nouveau URL établi dans l'index |

⚠️ **Pendant cette période:** Les anciennes URLs restent visibles en résultats de recherche mais redirigent correctement.

## Optimisations supplémentaires recommandées

### 1. Mettre à jour le sitemap XML

```ruby
# Générer le sitemap avec les nouvelles routes
rake sitemap:refresh
```

### 2. Mettre à jour les liens internes (lentement)

Au lieu de tout changer d'un coup:

- Les links via `link_to` fonctionnent automatiquement (Rails helpers)
- Les hardcoded links devraient pointer vers `/references`

### 3. Mettre à jour Google Analytics

1. GA → Admin → Property Settings
2. Ajouter la nouvelle URL comme domain
3. Configurer les URL-rewrites si nécessaire

### 4. Notifier les sites externes qui linken vers vous

Si vous avez des backlinks importants, prévenez:

- Médias partenaires
- Répertoires
- Sites d'annuaire

## FAQ

**Q: Pendant combien de temps garder les redirections?**
R: Indéfiniment, c'est presque gratuit. Garder `status: :moved_permanently` indique que c'est permanent.

**Q: Est-ce que ça fait baisser le ranking?**
R: Non, une 301 préserve le SEO. C'est utilisé par tous les grands sites lors de migrations.

**Q: Et si quelqu'un visite l'ancienne URL directement?**
R: Le navigateur le redirige automatiquement vers la nouvelle URL invisible pour l'utilisateur.

**Q: Qu'est-ce qui se passe si je supprime les redirection après 1 ans?**
R: Google affichera une 404 à la place de la redirection. **Ne pas faire.**

**Q: Comment monitor les redirections?**
R: Dans Google Search Console → Coverage → vérifier les "Redirected" URLs.

## Commandes utiles

```bash
# Vérifier toutes les redirections 301
grep -r "301\|moved_permanently" config/routes.rb

# Tester une URL spécifique
curl -I -L https://monsite.com/fr/oeuvres/test
# -I = headers only
# -L = follow redirects
# -L deux fois montre le chemin complet

# Monitor les erreurs de redirection
tail -f log/production.log | grep -i "redirect\|301"
```

## Checklist avant le déploiement

- [ ] Migrations de BD testées localement
- [ ] Redirections 301 configurées
- [ ] Assets compilés
- [ ] Tests passent
- [ ] Google Search Console notifiée
- [ ] Sitemap mis à jour
- [ ] Analytics configuré
- [ ] Backups de BD effectués
- [ ] Plan de rollback en place

## Support

Si vous avez besoin d'annuler:

```bash
# Annuler les migrations
rails db:rollback STEP=2

# Supprimer les redirections du routes.rb
# Revenir à 'resources :oeuvres'

# Renommer les fichiers de nouveau
# (Utiliser git pour l'historique)
```

---

✅ **Vous êtes prêt pour le déploiement!**
