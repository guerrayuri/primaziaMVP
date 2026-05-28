# Guia de Deploy — PrimazIA

## Deploy rápido (15 minutos)

### Pré-requisitos
- Conta GitHub
- Conta Supabase (gratuita)
- Conta Vercel (gratuita)

---

## Passo 1 — Supabase

1. Acesse [supabase.com](https://supabase.com) → **New Project**
2. Escolha nome, senha forte e região (ex: South America - São Paulo)
3. Aguarde a criação (1-2 minutos)

### Executar o banco de dados

No painel Supabase → **SQL Editor**:

```sql
-- Cole e execute o arquivo 001_schema_inicial.sql
-- Cole e execute o arquivo 002_row_level_security.sql
-- Cole e execute o arquivo 003_seed_data.sql (opcional)
```

### Criar buckets de storage

No painel Supabase → **Storage** → **New bucket**:

| Nome | Tipo |
|------|------|
| `public` | Público |
| `courses` | Privado |
| `finance` | Privado |
| `meeting-minutes` | Privado |
| `children` | Privado |
| `admin` | Privado |

### Configurar autenticação

No painel Supabase → **Authentication** → **URL Configuration**:
- **Site URL**: `https://seu-app.vercel.app`
- **Redirect URLs**: `https://seu-app.vercel.app/auth/callback`

### Copiar credenciais

No painel Supabase → **Settings** → **API**:
- Copie a **Project URL**
- Copie a **anon public key**
- Copie a **service_role key** (guarde em segredo)

---

## Passo 2 — GitHub

```bash
git init
git add .
git commit -m "feat: PrimazIA MVP inicial"
git branch -M main
git remote add origin https://github.com/seu-usuario/primazia.git
git push -u origin main
```

---

## Passo 3 — Vercel

1. Acesse [vercel.com](https://vercel.com) → **New Project**
2. Importe o repositório do GitHub
3. Configure as **Environment Variables**:

| Variável | Valor |
|----------|-------|
| `NEXT_PUBLIC_SUPABASE_URL` | URL do projeto Supabase |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | service_role key |
| `NEXT_PUBLIC_APP_URL` | https://seu-app.vercel.app |

4. Clique em **Deploy**

---

## Passo 4 — Primeiro superadmin

1. Acesse a URL do deploy
2. Cadastre-se com seu e-mail
3. Confirme o e-mail (verifique sua caixa de entrada)
4. No Supabase → **Table Editor** → **profiles**
5. Encontre sua linha e altere `role` para `super_admin`
6. Faça logout e login novamente

---

## Atualizar a aplicação

```bash
# Após fazer alterações no código
git add .
git commit -m "fix: descrição da alteração"
git push

# A Vercel detecta automaticamente e faz o redeploy
```

---

## Variáveis de ambiente — Resumo

```env
# .env.local (nunca suba para o Git)
NEXT_PUBLIC_SUPABASE_URL=https://abc123.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
NEXT_PUBLIC_APP_URL=https://primazia.vercel.app
```

---

## Domínio customizado

Na Vercel → seu projeto → **Settings** → **Domains**:
1. Adicione seu domínio (ex: gestao.suaigreja.org)
2. Configure o DNS no seu provedor
3. Atualize o **Site URL** no Supabase Auth com o novo domínio

---

## Backup

O Supabase faz backup automático diário. Para exportar manualmente:

**Supabase** → **Database** → **Backups** → **Download**

Ou execute no SQL Editor:
```sql
-- Exportar configurações da igreja
SELECT * FROM church_settings;

-- Exportar membros
SELECT * FROM members WHERE deleted_at IS NULL;
```

---

## Monitoramento

- **Supabase Dashboard** → logs de banco de dados em tempo real
- **Vercel Dashboard** → logs de função e deploy
- **PrimazIA Admin** → Log de auditoria interno em Administração → Log de Ações

---

## Suporte

- Documentação Supabase: [docs.supabase.com](https://docs.supabase.com)
- Documentação Next.js: [nextjs.org/docs](https://nextjs.org/docs)
- Documentação Vercel: [vercel.com/docs](https://vercel.com/docs)
