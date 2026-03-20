#!/bin/bash
# Script d'application des protections de sécurité

echo "🔒 Application des protections de sécurité SENTOUKI..."
echo ""

echo "📋 Étapes à suivre:"
echo ""
echo "1️⃣  Activer RLS Supabase (CRITIQUE)"
echo "   → Ouvrir: https://vgosyoaxwldxuopjslll.supabase.co"
echo "   → SQL Editor → New Query"
echo "   → Copier-coller: supabase/rls-policies.sql"
echo "   → Exécuter (Run)"
echo ""

echo "2️⃣  Régénérer clés Supabase"
echo "   → Settings → API"
echo "   → Reset anon key"
echo "   → Copier nouvelle clé dans .env.local"
echo ""

echo "3️⃣  Activer Supabase Auth"
echo "   → Authentication → Providers"
echo "   → Activer Email (Magic Link ou Password)"
echo "   → Configurer redirect URLs"
echo ""

echo "4️⃣  Vérifier build"
echo "   → npm run build"
echo "   → Tester réservation"
echo ""

echo "✅ Fichiers créés:"
echo "   - lib/auth/session.ts"
echo "   - lib/api/auth-middleware.ts"
echo "   - lib/validations/admin.ts"
echo "   - supabase/rls-policies.sql"
echo "   - SECURITY_GUIDE.md"
echo ""

echo "⚠️  IMPORTANT:"
echo "   RLS doit être activé AVANT déploiement production!"
echo "   Sinon → Base de données ouverte à tous"
echo ""

read -p "Appuyer sur Entrée pour continuer..."
