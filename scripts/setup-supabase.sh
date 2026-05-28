#!/bin/bash
# ============================================================
# PrimazIA — Script de configuração do Supabase
# Execute: chmod +x scripts/setup-supabase.sh && ./scripts/setup-supabase.sh
# ============================================================

set -e

echo "🚀 PrimazIA — Setup do Supabase"
echo "================================"

# Verificar se supabase CLI está instalado
if ! command -v supabase &> /dev/null; then
  echo "⚠️  Supabase CLI não encontrado. Instale com:"
  echo "   npm install -g supabase"
  echo ""
  echo "Ou execute as migrations manualmente no SQL Editor do Supabase."
  exit 1
fi

echo ""
echo "📋 Passos para configuração manual (via painel Supabase):"
echo ""
echo "1. Acesse https://supabase.com e crie um novo projeto"
echo ""
echo "2. No SQL Editor, execute os arquivos em ordem:"
echo "   → supabase/migrations/001_schema_inicial.sql"
echo "   → supabase/migrations/002_row_level_security.sql"
echo "   → supabase/migrations/003_seed_data.sql (opcional)"
echo ""
echo "3. No Storage, crie os buckets:"
echo "   → public (público)"
echo "   → courses (privado)"
echo "   → finance (privado)"
echo "   → meeting-minutes (privado)"
echo "   → children (privado)"
echo "   → admin (privado)"
echo ""
echo "4. Execute as políticas de storage:"
echo "   → supabase/policies/storage_policies.sql"
echo ""
echo "5. Configure Authentication:"
echo "   → Site URL: https://seu-app.vercel.app"
echo "   → Redirect URL: https://seu-app.vercel.app/auth/callback"
echo ""
echo "6. Copie as credenciais para .env.local:"
echo "   → Project URL"
echo "   → anon key"
echo "   → service_role key"
echo ""
echo "7. Após o primeiro cadastro, promova o usuário a super_admin:"
echo "   No Table Editor → profiles → altere role para 'super_admin'"
echo ""
echo "✅ Setup concluído!"
