# Checklist de Testes — PrimazIA MVP

## ✅ Autenticação

- [ ] Cadastro com e-mail válido
- [ ] E-mail de confirmação enviado
- [ ] Confirmação de e-mail funciona
- [ ] Login com credenciais corretas
- [ ] Erro exibido em login incorreto
- [ ] Recuperação de senha por e-mail
- [ ] Redefinição de senha pelo link
- [ ] Logout encerra a sessão
- [ ] Sessão persiste ao recarregar
- [ ] Usuário desativado é bloqueado no login

## ✅ Permissões e Rotas

- [ ] `/protected/financeiro` bloqueado para membro
- [ ] `/protected/atas` bloqueado para membro
- [ ] `/protected/admin` bloqueado para pastor
- [ ] Acesso direto por URL sem permissão redireciona para dashboard
- [ ] Membro não vê menu financeiro
- [ ] Pai vê somente suas crianças
- [ ] Professor vê somente suas turmas
- [ ] Ata confidencial invisível para membro (testado via Supabase API)

## ✅ Dashboard

- [ ] Métricas carregam para admin
- [ ] Aviso da semana exibido
- [ ] Botão editar aviso visível para admin
- [ ] Botão editar aviso invisível para membro
- [ ] Log de ações exibido para admin

## ✅ Membros

- [ ] Listar membros
- [ ] Buscar por nome
- [ ] Filtrar por status
- [ ] Filtrar por ministério
- [ ] Criar novo membro
- [ ] Editar membro existente
- [ ] Arquivar membro (soft delete)
- [ ] Exportar CSV

## ✅ Visitantes

- [ ] Registrar visitante com todos os campos
- [ ] Listar visitantes
- [ ] Buscar visitante
- [ ] Filtrar por culto
- [ ] Gráfico por culto renderiza
- [ ] Gráfico por origem renderiza
- [ ] Arquivar visitante
- [ ] Exportar CSV

## ✅ Eventos

- [ ] Criar evento (admin)
- [ ] Publicar/ocultar evento
- [ ] Inscrever-se em evento (membro)
- [ ] Limite de vagas respeitado no banco
- [ ] Lista de inscritos (admin)
- [ ] Check-in manual
- [ ] Atualizar status da inscrição
- [ ] Exportar inscritos
- [ ] Arquivar evento
- [ ] Evento publicado aparece na área pública

## ✅ Cursos

- [ ] Criar curso
- [ ] Criar módulo dentro do curso
- [ ] Adicionar aula com URL de vídeo
- [ ] Vídeo reproduz corretamente
- [ ] Inscrever-se no curso (membro)
- [ ] Aluno sem matrícula não vê aulas pagas
- [ ] Aulas gratuitas visíveis sem matrícula
- [ ] Progresso salvo

## ✅ Ministério Infantil

- [ ] Criar turma
- [ ] Vincular professor à turma
- [ ] Cadastrar criança com responsável
- [ ] Consentimento LGPD registrado
- [ ] Professor vê somente sua turma
- [ ] Criar relatório/feedback para criança
- [ ] Visibilidade "privado" não aparece para pais
- [ ] Visibilidade "responsáveis" aparece para pais
- [ ] Pai vê somente suas crianças (não outras)
- [ ] Pai não vê campo "notas privadas"
- [ ] Log de acesso ao módulo registrado

## ✅ Agenda Pastoral

- [ ] Pastor informa disponibilidade
- [ ] Horários livres aparecem para agendamento
- [ ] Membro solicita agendamento
- [ ] Conflito de horário impedido
- [ ] Pastor confirma agendamento
- [ ] Pastor recusa agendamento
- [ ] Pastor marca como realizado
- [ ] Admin vê todos os agendamentos

## ✅ Atas Pastorais

- [ ] Criar ata não-confidencial
- [ ] Criar ata confidencial
- [ ] Ata confidencial bloqueada para não-pastor (testado via API)
- [ ] Editar ata
- [ ] Exportar ata em PDF
- [ ] Arquivar ata
- [ ] Log de visualização registrado

## ✅ Financeiro

- [ ] Criar lançamento de entrada
- [ ] Criar lançamento de saída
- [ ] Filtrar por tipo
- [ ] Filtrar por categoria
- [ ] Filtrar por período
- [ ] Cancelar lançamento (sem excluir)
- [ ] Lançamento cancelado não some da tabela
- [ ] Exportar CSV com filtros
- [ ] Saldo calculado corretamente
- [ ] Módulo bloqueado para membro (testado via API)

## ✅ Administração

- [ ] Listar usuários
- [ ] Editar perfil de usuário
- [ ] Desativar usuário
- [ ] Ativar usuário
- [ ] Não é possível desativar a própria conta
- [ ] Aprovar solicitação de perfil
- [ ] Rejeitar solicitação de perfil
- [ ] Solicitação aprovada atualiza perfil do usuário
- [ ] Criar aviso
- [ ] Editar aviso
- [ ] Ativar/desativar aviso
- [ ] Log de auditoria exibido
- [ ] Exportar CSV de usuários

## ✅ Área Pública (landing)

- [ ] Página carrega sem login
- [ ] Informações da igreja exibidas
- [ ] Horários dos cultos exibidos
- [ ] Eventos públicos listados
- [ ] Avisos públicos exibidos
- [ ] Botão "Criar conta" funciona
- [ ] Botão "Entrar" funciona

## ✅ Área Pública (dentro do app)

- [ ] Admin pode editar informações
- [ ] Admin pode adicionar horário de culto
- [ ] Admin pode remover horário de culto
- [ ] Membro visualiza sem editar
- [ ] Preview reflete as mudanças

## ✅ Responsividade

- [ ] 375px — iPhone SE: sidebar vira drawer
- [ ] 390px — iPhone 14: layout OK
- [ ] 430px — iPhone Plus: layout OK
- [ ] 768px — iPad: sidebar visível
- [ ] 1024px — Desktop pequeno: OK
- [ ] 1280px — Desktop: OK
- [ ] Tabelas têm rolagem horizontal no mobile
- [ ] Modais ocupam tela cheia no mobile
- [ ] Botões não ficam cortados
- [ ] Formulários confortáveis no celular

## ✅ Performance

- [ ] Dashboard carrega em < 3s
- [ ] Páginas com listas carregam em < 2s
- [ ] Loading states visíveis durante carregamento
- [ ] Erro tratado graciosamente

## ✅ Segurança

- [ ] Senhas não visíveis no código
- [ ] `.env.local` no `.gitignore`
- [ ] RLS habilitado em todas as tabelas
- [ ] `service_role_key` nunca no frontend
- [ ] Logs de auditoria para ações sensíveis
- [ ] Dados de crianças protegidos por RLS
- [ ] Dados financeiros protegidos por RLS
