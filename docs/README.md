# PrimazIA — Documentação do MVP

Plataforma de gestão ministerial para igrejas.  
Stack: **Next.js 14 · TypeScript · Tailwind CSS · Supabase**

---

## Índice

1. [Requisitos](#requisitos)
2. [Instalação local](#instalação-local)
3. [Configuração do Supabase](#configuração-do-supabase)
4. [Deploy na Vercel](#deploy-na-vercel)
5. [Primeiro acesso](#primeiro-acesso)
6. [Perfis de acesso](#perfis-de-acesso)
7. [Módulos disponíveis](#módulos-disponíveis)
8. [Estrutura do projeto](#estrutura-do-projeto)
9. [Segurança](#segurança)
10. [Checklist de testes](#checklist-de-testes)

---

## Requisitos

- Node.js 18+
- npm ou pnpm
- Conta Supabase (gratuita em supabase.com)
- Conta Vercel (gratuita em vercel.com)

---

## Instalação local

```bash
# 1. Clonar o repositório
git clone https://github.com/sua-org/primazia.git
cd primazia

# 2. Instalar dependências
npm install

# 3. Configurar variáveis de ambiente
cp .env.local.example .env.local
# Edite .env.local com suas credenciais do Supabase

# 4. Rodar em desenvolvimento
npm run dev

# Acesse http://localhost:3000
```

---

## Configuração do Supabase

### 1. Criar projeto

1. Acesse [supabase.com](https://supabase.com) e crie um novo projeto
2. Anote a **Project URL** e as chaves **anon** e **service_role**

### 2. Executar migrations

No painel do Supabase, vá em **SQL Editor** e execute os arquivos em ordem:

```
supabase/migrations/001_schema_inicial.sql
supabase/migrations/002_row_level_security.sql
```

### 3. Configurar autenticação

No painel do Supabase:
- **Authentication → Settings → Site URL**: `https://seu-dominio.vercel.app`
- **Authentication → Settings → Redirect URLs**: adicione `https://seu-dominio.vercel.app/auth/callback`
- **Authentication → Email Templates**: personalize os templates de confirmação e recuperação de senha

### 4. Configurar variáveis

Edite `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://SEU_PROJETO.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sua_anon_key
SUPABASE_SERVICE_ROLE_KEY=sua_service_role_key
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## Deploy na Vercel

```bash
# 1. Instalar Vercel CLI
npm i -g vercel

# 2. Fazer login
vercel login

# 3. Deploy
vercel --prod
```

**Configurar variáveis de ambiente na Vercel:**

No painel da Vercel → seu projeto → Settings → Environment Variables, adicione:

| Nome | Valor |
|------|-------|
| `NEXT_PUBLIC_SUPABASE_URL` | URL do seu projeto Supabase |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Chave anon do Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | Chave service_role (apenas servidor) |
| `NEXT_PUBLIC_APP_URL` | URL da Vercel (ex: https://primazia.vercel.app) |

---

## Primeiro acesso

### Criar o primeiro superadministrador

1. Acesse a aplicação em produção
2. Clique em **Criar conta** e registre-se normalmente
3. No **Supabase → Table Editor → profiles**, encontre seu usuário
4. Altere o campo `role` de `member` para `super_admin`
5. Faça logout e login novamente

A partir disso, use o painel de **Administração** para gerenciar outros usuários.

### Configurar a igreja

1. Faça login como superadministrador
2. Acesse **Área Pública** no menu lateral
3. Preencha as informações da igreja e horários dos cultos
4. Acesse **Administração → Avisos** para criar os primeiros comunicados

---

## Perfis de acesso

| Perfil | Acesso |
|--------|--------|
| **Superadministrador** | Tudo, incluindo gestão de usuários e configurações |
| **Administrador** | Membros, visitantes, eventos, cursos, área pública, avisos |
| **Adm. Financeiro** | Apenas módulo financeiro |
| **Pastor** | Visitantes, membros, atas, agenda pastoral, ministério infantil |
| **Coordenador** | Ministério infantil completo, eventos, cursos |
| **Professor** | Suas turmas, registro de presença e relatórios |
| **Pai/Responsável** | Apenas dados das próprias crianças vinculadas |
| **Membro** | Eventos, cursos, minha área |
| **Aluno** | Cursos nos quais está matriculado e liberado |
| **Visitante** | Área pública apenas |

### Solicitar mudança de perfil

Qualquer usuário pode solicitar elevação de perfil em **Minha Área → Solicitar mudança de perfil**. O administrador aprova ou rejeita na seção **Administração → Solicitações**.

---

## Módulos disponíveis

### 🏠 Dashboard
- Métricas por perfil
- Flyer de avisos da semana
- Links rápidos

### 👤 Minha Área
- Editar perfil e senha
- Inscrições em eventos e cursos
- Solicitar mudança de perfil

### 🌐 Área Pública
- Informações da igreja editáveis
- Horários dos cultos
- Preview em tempo real

### 👥 Membros
- Cadastro completo
- Filtros por ministério e status
- Exportação CSV

### 👋 Visitantes
- Formulário detalhado (gênero, idade, como conheceu, etc.)
- Gráficos por culto e origem
- Exportação CSV

### 📅 Eventos
- Criar, editar, publicar eventos
- Inscrições com status (inscrito, confirmado, pago, presente)
- Check-in manual
- Lista de inscritos com exportação

### 🎓 Cursos & Aulas
- Interface estilo Netflix
- Módulos e aulas por vídeo (YouTube embed ou MP4)
- Controle de acesso por matrícula
- Progresso por aluno

### ❤️ Ministério Infantil
- Turmas com professores responsáveis
- Cadastro de crianças com responsáveis (LGPD)
- Registro de presença
- Relatórios e feedbacks individuais
- Visibilidade controlada (privado, pais, equipe)

### 🏛️ Ministérios
- Visão geral por ministério
- Lista de membros por área

### 📅 Agenda Pastoral
- Pastor informa disponibilidade
- Membros solicitam agendamento
- Pastor confirma/recusa/marca como realizado
- Sem conflito de horários

### 📝 Atas Pastorais
- Criar, editar, arquivar atas
- Atas confidenciais (protegidas no banco via RLS)
- Encaminhamentos e tarefas
- Exportação em PDF

### 💰 Financeiro
- Lançamentos de entrada e saída
- Categorias personalizáveis
- Comprovantes e referências
- Filtros por período, tipo e categoria
- Exportação CSV
- Cancelamento sem exclusão definitiva

### 🛡️ Administração
- Gerenciar usuários (ativar/desativar, trocar perfil)
- Aprovar/rejeitar solicitações de perfil
- Gerenciar avisos do dashboard
- Log de auditoria completo

---

## Estrutura do projeto

```
primazia/
├── src/
│   ├── app/
│   │   ├── page.tsx                    # Área pública (landing)
│   │   ├── auth/                       # Login, cadastro, recuperação de senha
│   │   ├── protected/                  # Área autenticada
│   │   │   ├── layout.tsx              # Shell com sidebar
│   │   │   ├── dashboard/
│   │   │   ├── minha-area/
│   │   │   ├── publica/
│   │   │   ├── membros/
│   │   │   ├── visitantes/
│   │   │   ├── eventos/
│   │   │   ├── cursos/
│   │   │   ├── infantil/
│   │   │   ├── ministerios/
│   │   │   ├── gabinete/
│   │   │   ├── atas/
│   │   │   ├── financeiro/
│   │   │   └── admin/
│   │   └── api/
│   │       └── admin/export-users/
│   ├── components/
│   │   ├── layout/AppShell.tsx         # Sidebar + topbar responsivo
│   │   └── ui/Modal.tsx, Badge.tsx...
│   ├── lib/
│   │   ├── supabase/client.ts          # Cliente browser
│   │   ├── supabase/server.ts          # Cliente servidor
│   │   ├── hooks/useAuth.ts
│   │   ├── types/database.ts           # Todos os tipos TypeScript
│   │   └── utils/
│   │       ├── permissions.ts          # Hierarquia de perfis
│   │       ├── audit.ts                # Log de auditoria
│   │       └── export.ts              # CSV, Excel, PDF
│   └── middleware.ts                   # Proteção de rotas
├── supabase/
│   └── migrations/
│       ├── 001_schema_inicial.sql      # 30+ tabelas
│       └── 002_row_level_security.sql  # Políticas RLS
└── docs/
    └── README.md
```

---

## Segurança

### Row Level Security (RLS)
Todas as tabelas têm RLS habilitado. Os dados são filtrados **no banco de dados**, não apenas no frontend. Mesmo que alguém descubra a URL de uma API, não conseguirá acessar dados de outros usuários.

### Proteção de rotas
O middleware Next.js verifica a sessão e o perfil do usuário **antes** de renderizar qualquer página protegida.

### Dados sensíveis
- **Financeiro**: acessível apenas por `super_admin` e `financial_admin`
- **Atas confidenciais**: protegidas por RLS, visíveis apenas para `pastor+`
- **Dados de crianças**: protegidos por RLS, cada pai vê apenas seus filhos
- **Senhas**: nunca armazenadas — gerenciadas pelo Supabase Auth (bcrypt)

### Auditoria
Todas as ações sensíveis são registradas na tabela `audit_logs` com usuário, ação, módulo, dados anteriores e novos, e timestamp.

---

## Checklist de testes

### Autenticação
- [ ] Cadastro com e-mail válido funciona
- [ ] E-mail de confirmação é enviado
- [ ] Login com credenciais corretas funciona
- [ ] Login com credenciais erradas exibe erro
- [ ] Recuperação de senha funciona
- [ ] Usuário desativado não consegue acessar

### Permissões
- [ ] Membro não vê financeiro
- [ ] Membro não vê atas
- [ ] Pai vê apenas suas crianças
- [ ] Professor vê apenas suas turmas
- [ ] Acesso direto por URL é bloqueado sem permissão
- [ ] Ata confidencial não aparece para membro

### Módulos
- [ ] Cadastrar visitante funciona
- [ ] Gráficos de visitantes são gerados
- [ ] Criar evento e inscrever-se funciona
- [ ] Check-in manual funciona
- [ ] Criar curso com módulos e aulas funciona
- [ ] Vídeo de aula é reproduzido
- [ ] Lançamento financeiro é registrado
- [ ] Cancelamento financeiro funciona (sem excluir)
- [ ] Criar ata e exportar PDF funciona
- [ ] Agenda pastoral sem conflito de horários
- [ ] Cadastrar criança com responsável funciona
- [ ] Relatório infantil com visibilidade funciona

### Responsividade
- [ ] Funciona em 375px (iPhone SE)
- [ ] Sidebar vira drawer no mobile
- [ ] Tabelas com rolagem horizontal no mobile
- [ ] Modais ocupam tela toda no mobile
- [ ] Formulários confortáveis no mobile

### Exportações
- [ ] CSV de visitantes
- [ ] CSV de membros
- [ ] CSV de financeiro
- [ ] CSV de inscritos em evento
- [ ] PDF de ata pastoral

---

## Suporte

Para dúvidas ou problemas, abra uma issue no repositório ou entre em contato com o administrador do sistema.

**PrimazIA** — Gestão Ministerial com propósito.
