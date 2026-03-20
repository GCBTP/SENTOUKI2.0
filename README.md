# SENTOUKI 🚌

Plateforme professionnelle de réservation de bus inter-région au Sénégal.

## 📋 Description

SENTOUKI est une plateforme moderne de réservation de bus inspirée par Yango, permettant aux voyageurs de rechercher, réserver et acheter des billets de bus pour des trajets inter-régions au Sénégal.

## 🎯 Fonctionnalités

### Espace Client
- ✅ Recherche de trajets par ville et date
- ✅ Visualisation des horaires et disponibilités
- ✅ Réservation de sièges
- ✅ Achat de billets en ligne
- ✅ Historique des réservations
- ✅ Réception de tickets numériques avec QR code

### Espace Administrateur
- ✅ Gestion des bus (ajout, modification, statut)
- ✅ Gestion des villes et régions
- ✅ Gestion des trajets et horaires
- ✅ Suivi des réservations en temps réel
- ✅ Gestion des passagers
- ✅ Rapports et statistiques

## 🛠️ Stack Technique

- **Framework:** Next.js 14 (App Router)
- **Langage:** TypeScript
- **Styling:** Tailwind CSS
- **Base de données:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth
- **Hébergement:** Vercel (recommandé)

## 📁 Architecture du Projet

```
sentouki/
├── app/
│   ├── (admin)/          # Routes administration
│   ├── (client)/         # Routes client public
│   ├── api/              # API routes
│   ├── layout.tsx        # Layout racine
│   └── page.tsx          # Page d'accueil
├── components/
│   ├── admin/            # Composants admin
│   ├── client/           # Composants client
│   └── shared/           # Composants partagés
├── lib/
│   ├── supabase/         # Configuration Supabase
│   ├── utils/            # Utilitaires
│   └── types/            # Types TypeScript
├── public/               # Assets statiques
└── README.md
```

## 🗄️ Modèle de Données

### Tables Principales

1. **cities** - Villes et régions
2. **buses** - Flotte de bus
3. **routes** - Trajets disponibles
4. **trips** - Voyages programmés
5. **passengers** - Informations passagers
6. **bookings** - Réservations
7. **tickets** - Tickets numériques

## 🚀 Installation

### Prérequis
- Node.js 18+ 
- npm ou yarn
- Compte Supabase

### Étapes

1. **Installer les dépendances**
```bash
npm install
```

2. **Configurer les variables d'environnement**
```bash
cp .env.local.example .env.local
```

Remplir les valeurs:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

3. **Créer les tables Supabase** (voir prochaine étape)

4. **Lancer le serveur de développement**
```bash
npm run dev
```

Ouvrir [http://localhost:3000](http://localhost:3000)

## 📦 Dépendances Installées

### Production
- `next` - Framework React
- `react` & `react-dom` - Bibliothèque React
- `@supabase/supabase-js` - Client Supabase
- `@supabase/ssr` - Supabase pour SSR
- `tailwindcss` - Framework CSS

### Développement
- `typescript` - Typage statique
- `@types/node`, `@types/react`, `@types/react-dom` - Types TypeScript
- `eslint` & `eslint-config-next` - Linter
- `@tailwindcss/postcss` - PostCSS pour Tailwind

## 🎨 Design System

- **Couleurs principales:** À définir
- **Police:** System fonts (Inter recommandé)
- **Composants:** Custom + Tailwind
- **Responsive:** Mobile-first approach

## 🔐 Sécurité

- Authentication Supabase (JWT)
- Row Level Security (RLS) sur toutes les tables
- Validation des données côté serveur
- HTTPS obligatoire en production

## 📝 Prochaines Étapes

1. ✅ Configuration initiale (FAIT)
2. ⏳ Création du schéma de base de données Supabase
3. ⏳ Mise en place de l'authentification
4. ⏳ Interface de recherche de trajets
5. ⏳ Système de réservation
6. ⏳ Dashboard administrateur
7. ⏳ Génération de tickets QR
8. ⏳ Intégration paiement
9. ⏳ Notifications email/SMS
10. ⏳ Déploiement production

## 👥 Équipe

- **Développeur:** Mohaly (via @Grevitbot)
- **Client:** GUINDO

## 📄 Licence

Propriétaire - SENTOUKI © 2026

---

**Statut:** ✅ Phase 1 - Structure initiale complétée
**Prochaine étape:** Configuration de la base de données Supabase
