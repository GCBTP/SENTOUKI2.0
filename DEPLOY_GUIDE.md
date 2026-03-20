# 🚀 SENTOUKI - Guide Déploiement Production

**Date:** 20 mars 2026  
**Version:** 1.0.0

---

## ⚠️ CHECKLIST PRÉ-DÉPLOIEMENT

### 🔒 Sécurité (CRITIQUE)

- [ ] **Régénérer clés Supabase**
  ```
  Dashboard → Settings → API → Reset anon key
  Dashboard → Settings → API → Reset service_role key
  ```

- [ ] **Activer RLS sur toutes tables**
  ```sql
  ALTER TABLE buses ENABLE ROW LEVEL SECURITY;
  ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
  ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
  ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
  ALTER TABLE seats ENABLE ROW LEVEL SECURITY;
  ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
  ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
  ALTER TABLE users ENABLE ROW LEVEL SECURITY;
  ```

- [ ] **Policies Anonymous (temporaire)**
  ```sql
  -- Permettre réservations anonymous
  DROP POLICY IF EXISTS "Users can create own reservations" ON reservations;
  CREATE POLICY "Allow anonymous bookings" ON reservations FOR INSERT WITH CHECK (true);
  
  DROP POLICY IF EXISTS "Users can read own reservations" ON reservations;
  CREATE POLICY "Public can read reservations" ON reservations FOR SELECT USING (true);
  ```

- [ ] **Vérifier .env.local PAS dans Git**
  ```bash
  git status # .env.local ne doit PAS apparaître
  ```

- [ ] **Supprimer scripts avec clés**
  ```bash
  rm -f scripts/apply-rls.mjs
  ```

### 🧪 Tests

- [ ] Build local réussi
  ```bash
  npm run build
  ```

- [ ] Tester réservation (dev)
  ```bash
  npm run dev
  # Faire une réservation complète
  ```

- [ ] Vérifier RLS fonctionne
  ```sql
  -- Dans Supabase SQL Editor
  SELECT tablename, rowsecurity FROM pg_tables 
  WHERE schemaname = 'public';
  -- Toutes les tables doivent avoir rowsecurity = true
  ```

---

## 📦 ÉTAPE 1: Git

### Initialiser Git (si pas fait)

```bash
cd ~/Desktop/sentouki

# Init repo
git init

# Ajouter tous les fichiers
git add .

# Commit initial
git commit -m "feat: SENTOUKI v1.0 - Application production-ready

- Design startup africaine moderne
- Validation serveur prix
- Protection RLS Supabase
- Rate limiting API
- Responsive mobile-first
- SEO optimisé
"
```

### Créer Repo GitHub

```bash
# 1. Aller sur https://github.com/new
# 2. Nom: sentouki
# 3. Public ou Private: Private (recommandé)
# 4. NE PAS initialiser avec README (on a déjà du code)
# 5. Créer

# Lier au repo local
git remote add origin https://github.com/TON_USERNAME/sentouki.git

# Push
git branch -M main
git push -u origin main
```

---

## 🚀 ÉTAPE 2: Vercel

### Installation CLI (si besoin)

```bash
npm install -g vercel
```

### Déploiement

```bash
cd ~/Desktop/sentouki

# Login Vercel
vercel login

# Premier déploiement
vercel

# Questions Vercel:
# - Set up and deploy? → Yes
# - Which scope? → Ton compte
# - Link to existing project? → No
# - Project name? → sentouki
# - Directory? → ./
# - Override settings? → No

# Déploiement production
vercel --prod
```

### Variables d'Environnement Vercel

**Dashboard Vercel → Project Settings → Environment Variables**

Ajouter:

```env
# Supabase (NOUVELLES CLÉS RÉGÉNÉRÉES)
NEXT_PUBLIC_SUPABASE_URL=https://vgosyoaxwldxuopjslll.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=nouvelle_cle_anon_regeneree

# App URL
NEXT_PUBLIC_APP_URL=https://sentouki.vercel.app

# Environnement
NODE_ENV=production
```

**⚠️ Important:**
- Utiliser les **NOUVELLES clés** (régénérées)
- Ne JAMAIS copier `.env.local` → risque d'exposer anciennes clés

---

## 🔧 ÉTAPE 3: Configuration Supabase Production

### URL Autorisées

**Dashboard Supabase → Authentication → URL Configuration**

Ajouter:
```
Site URL: https://sentouki.vercel.app
Redirect URLs:
  - https://sentouki.vercel.app/*
  - https://sentouki.vercel.app/auth/callback
```

### RLS Policies Production

**Important:** Les policies anonymous sont temporaires!

**Pour production réelle:**
1. Activer Supabase Auth
2. Remplacer policies anonymous par policies authentifiées
3. Forcer login avant réservation

---

## 🧪 ÉTAPE 4: Tests Production

### Après déploiement:

1. **Test SEO**
   ```
   https://sentouki.vercel.app/sitemap.xml
   https://sentouki.vercel.app/robots.txt
   ```

2. **Test Réservation**
   - Rechercher trajet
   - Sélectionner siège
   - Remplir formulaire
   - Confirmer réservation
   - Vérifier ticket généré

3. **Test Mobile**
   - Ouvrir sur téléphone
   - Vérifier responsive
   - Tester réservation mobile

4. **Test Performance**
   ```
   https://pagespeed.web.dev/
   # Tester: https://sentouki.vercel.app
   # Objectif: Score > 90
   ```

---

## 🐛 TROUBLESHOOTING

### Build échoue sur Vercel

```bash
# Vérifier build local
npm run build

# Si erreur TypeScript
npm run lint

# Si erreur dépendances
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Erreur 500 en production

**Logs Vercel:**
```
Dashboard → Deployments → Latest → Function Logs
```

**Logs Supabase:**
```
Dashboard → Logs → API Logs (filtrer "500")
```

### RLS bloque tout

```sql
-- Vérifier policies
SELECT tablename, policyname FROM pg_policies 
WHERE schemaname = 'public';

-- Temporairement désactiver
ALTER TABLE nom_table DISABLE ROW LEVEL SECURITY;
```

---

## 📊 MONITORING POST-DÉPLOIEMENT

### Vercel Analytics

```bash
# Dashboard Vercel → Project → Analytics
# Activer Vercel Analytics (gratuit)
```

### Supabase Monitoring

```bash
# Dashboard Supabase → Reports
# Surveiller:
# - API Requests
# - Database Size
# - Errors
```

---

## 🔐 SÉCURITÉ POST-DÉPLOIEMENT

### À faire IMMÉDIATEMENT après deploy:

1. **Tester avec Burp Suite / OWASP ZAP**
   - Injection SQL
   - XSS
   - CSRF

2. **Monitoring Erreurs**
   ```bash
   # Installer Sentry
   npm install @sentry/nextjs
   npx @sentry/wizard -i nextjs
   ```

3. **Rate Limiting Production**
   ```bash
   # Migrer vers Redis (Upstash)
   npm install @upstash/redis
   ```

4. **Activer HTTPS uniquement**
   - Vercel le fait automatiquement ✅

---

## 📝 CHECKLIST FINALE

Avant de dire "C'est en prod":

- [ ] ✅ Build Vercel réussi
- [ ] ✅ Tests réservation OK
- [ ] ✅ RLS activé partout
- [ ] ✅ Nouvelles clés Supabase
- [ ] ✅ Variables env Vercel configurées
- [ ] ✅ Sitemap/Robots accessible
- [ ] ✅ Mobile responsive testé
- [ ] ✅ Performance > 80 (Lighthouse)
- [ ] ⏳ Monitoring activé (Sentry/Vercel Analytics)
- [ ] ⏳ Backup DB configuré

---

## 🎯 PROCHAINES ÉTAPES

### Semaine 1
- Monitoring erreurs (Sentry)
- Analytics utilisateurs
- Feedback premiers users

### Semaine 2-4
- Authentification Supabase
- Paiement Wave/Orange Money
- Dashboard admin

### Mois 2
- Tests automatisés (Jest/Playwright)
- CI/CD GitHub Actions
- A/B testing

---

**Bon déploiement! 🚀**

*En cas de problème: vérifie logs Vercel + Supabase*
