#!/bin/bash
# Script de déploiement rapide SENTOUKI

echo "🚀 SENTOUKI - Déploiement Production"
echo ""

# Vérifications
echo "📋 Vérifications pré-déploiement..."
echo ""

# 1. Build local
echo "1️⃣  Test build local..."
if npm run build > /dev/null 2>&1; then
  echo "   ✅ Build OK"
else
  echo "   ❌ Build échoué - Arrêt"
  exit 1
fi
echo ""

# 2. .env.local pas dans Git
echo "2️⃣  Vérification .env.local..."
if git ls-files .env.local 2>/dev/null | grep -q .; then
  echo "   ❌ .env.local est dans Git! Arrêt"
  echo "   → Exécuter: git rm --cached .env.local"
  exit 1
else
  echo "   ✅ .env.local ignoré"
fi
echo ""

# 3. Git status
echo "3️⃣  État Git..."
git status --short
echo ""

# 4. Commit
read -p "Commit les changements? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git add .
  git commit -m "feat: Ready for production deployment"
  echo "   ✅ Commit créé"
fi
echo ""

# 5. Push
read -p "Push vers GitHub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git push origin main
  echo "   ✅ Pushed to GitHub"
fi
echo ""

# 6. Vercel
read -p "Déployer sur Vercel? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  vercel --prod
  echo "   ✅ Déployé sur Vercel"
fi
echo ""

echo "✅ Déploiement terminé!"
echo ""
echo "⚠️  N'oublie pas:"
echo "   1. Régénérer clés Supabase"
echo "   2. Configurer variables env Vercel"
echo "   3. Tester https://sentouki.vercel.app"
echo ""
