-- ============================================================
-- PrimazIA — Migration 003: Seed Data (opcional)
-- Execute após as migrations 001 e 002
-- Este arquivo é OPCIONAL — contém dados de exemplo
-- ============================================================

-- Ministérios padrão
INSERT INTO ministries (name, description, is_active) VALUES
  ('Louvor',          'Ministério de música e adoração',         true),
  ('Ensino',          'Escola bíblica e discipulado',            true),
  ('Infantil',        'Ministério para crianças',                true),
  ('Diáconos',        'Serviço e administração',                 true),
  ('Evangelismo',     'Missões e evangelismo local',             true),
  ('Jovens',          'Ministério de jovens',                    true),
  ('Mulheres',        'Ministério de mulheres',                  true),
  ('Homens',          'Ministério de homens',                    true)
ON CONFLICT DO NOTHING;

-- Categorias financeiras adicionais (caso não existam)
INSERT INTO financial_categories (name, type, description) VALUES
  ('Dízimos',        'income',  'Dízimos dos membros'),
  ('Ofertas',        'income',  'Ofertas livres'),
  ('Inscrições',     'income',  'Inscrições em eventos e cursos'),
  ('Doações',        'income',  'Doações específicas'),
  ('Aluguel',        'expense', 'Aluguel do espaço'),
  ('Utilidades',     'expense', 'Água, luz, internet'),
  ('Manutenção',     'expense', 'Manutenção do espaço'),
  ('Equipamentos',   'expense', 'Compra de equipamentos')
ON CONFLICT DO NOTHING;

-- Nota: NÃO crie usuários diretamente neste seed.
-- Crie usuários pela interface de autenticação do Supabase
-- ou pelo formulário de cadastro da aplicação.
-- O primeiro superadmin deve ser promovido manualmente no
-- Table Editor: profiles → altere role para 'super_admin'
