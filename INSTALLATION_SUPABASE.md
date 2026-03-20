# 🚀 INSTALLATION SUPABASE - 4 ÉTAPES SIMPLES

## ✅ Ton projet Supabase existe déjà
URL: `https://vgosyoaxwldxuopjslll.supabase.co`

**Problème:** Les tables existent partiellement → il faut tout nettoyer et recommencer proprement.

---

## 📋 ÉTAPE 0: Nettoyer la base de données (IMPORTANT!)

⚠️ **Cette étape supprime toutes les tables existantes**

1. **Ouvre le dashboard Supabase:**
   👉 https://supabase.com/dashboard/project/vgosyoaxwldxuopjslll

2. **Va dans SQL Editor** (menu gauche)

3. **Clique sur "+ New query"**

4. **Copie-colle le fichier `supabase/00-reset-database.sql`** (TOUT le contenu)

5. **Clique sur "Run"** (bouton en bas à droite)

✅ Tu verras le message: "✅ BASE DE DONNÉES NETTOYÉE"

---

## 📋 ÉTAPE 1: Créer les tables

1. **Ouvre le dashboard Supabase:**
   👉 https://supabase.com/dashboard/project/vgosyoaxwldxuopjslll

2. **Va dans SQL Editor** (menu gauche)

3. **Clique sur "+ New query"**

4. **Copie-colle le fichier `supabase/schema.sql`** (TOUT le contenu)

5. **Clique sur "Run"** (bouton en bas à droite)

✅ Attends que ça se termine (environ 5-10 secondes)

---

---

## 📋 ÉTAPE 2: Insérer les données (villes, bus, trajets)

1. **Dans SQL Editor, clique à nouveau sur "+ New query"**

2. **Copie-colle le fichier `supabase/seed.sql`** (TOUT le contenu)

3. **Clique sur "Run"**

✅ Attends (5 secondes)

---

---

## 📋 ÉTAPE 3: Désactiver RLS (pour le développement)

⚠️ **IMPORTANT:** RLS (Row Level Security) bloque l'accès aux données en dev

1. **Dans SQL Editor, "+ New query"**

2. **Copie-colle le fichier `supabase/fix-rls-policies.sql`** (TOUT)

3. **Clique sur "Run"**

✅ Tu verras un message: "RLS DÉSACTIVÉ SUR TOUTES LES TABLES"

---

---

## ✅ VÉRIFICATION

Après les 4 étapes:

1. **Va dans "Table Editor"** (menu gauche)

2. **Tu devrais voir 8 tables:**
   - cities
   - users
   - buses
   - trips
   - seats
   - reservations
   - payments
   - tickets

3. **Clique sur "cities"** → tu devrais voir 40+ villes du Sénégal

---

---

## 🚀 RELANCER L'APPLICATION

Une fois les 4 étapes faites:

```bash
cd ~/Desktop/sentouki
npm run dev
```

Ouvre http://localhost:3000

✅ **Les erreurs devraient disparaître!**

---

## 🐛 Si problème persiste

Envoie-moi:
1. Screenshot de l'erreur dans la console
2. Screenshot de tes tables dans "Table Editor"

---

**C'est tout! Ça va prendre 3-4 minutes max 🎯**
