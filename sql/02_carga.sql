-- =============================================================================
-- 02_carga.sql
-- Projeto Final — LABORATÓRIO DE BANCO DE DADOS
-- Carga de dados diversificada e aderente às Regras de Negócio (RN09, RN15, RN16)
-- Volumetria mínima garantida: 40 principais / 100 movimento
-- =============================================================================
USE locadora_equipamentos;

-- -----------------------------------------------------------------------------
-- 1. FORMA DE PAGAMENTO 
-- -----------------------------------------------------------------------------
INSERT INTO forma_pagamento (nome_forma) VALUES 
('PIX'), ('Cartão de crédito'), ('Cartão de débito'), ('Dinheiro'), ('Boleto');

-- -----------------------------------------------------------------------------
-- 2. CATEGORIA
-- -----------------------------------------------------------------------------
INSERT INTO categoria (nome_categoria) VALUES 
('Concretagem e Argamassa'), ('Terraplanagem'), ('Furação e Demolição'), ('Acesso e Elevação');

-- -----------------------------------------------------------------------------
-- 3. MODELO_EQUIPAMENTO
-- -----------------------------------------------------------------------------
INSERT INTO modelo_equipamento (id_categoria, nome, marca, valor_diaria_padrao) VALUES 
(1, 'Betoneira 400L', 'Menegotti', 150.00),
(3, 'Martelete Rompedor 15kg', 'Bosch', 95.00),
(2, 'Retroescavadeira 4x4', 'CAT', 900.00),
(4, 'Andaime Tubular 1x1.5m', 'Locaforte', 15.00),
(3, 'Furadeira de Impacto', 'Makita', 45.00);

-- -----------------------------------------------------------------------------
-- 4. PESSOA 
-- -----------------------------------------------------------------------------
INSERT INTO pessoa (nome, doc_cpf_cnpj, email, telefone) VALUES 
('Carlos Almeida Silva', '111.111.111-11', 'carlos.gerencia@locadora.fake', '(11) 99999-1111'),
('Mariana Souza Santos', '222.222.222-22', 'mariana.atend@locadora.fake', NULL),
('Construtora Alfa Ltda', '33.333.333/0001-33', 'compras@alfa.fake', '(11) 3333-3333'),
('Roberto de Oliveira Eng.', '444.444.444-44', 'roberto.eng@email.fake', '(11) 98888-4444'),
('Reformas Express ME', '55.555.555/0001-55', 'contato@express.fake', NULL),
('Ana Beatriz Costa', '000.000.000-06', 'ana.costa@email.com', '(11) 97777-6666'),
('Pedro Henrique Souza', '000.000.000-07', 'pedro.h@email.com', '(11) 98888-7777'),
('Lucas Pereira Alves', '000.000.000-08', 'lucas.p@email.com', NULL),
('Carla Mendes', '000.000.000-09', 'carla.mendes@email.com', NULL),
('Marcos Rocha', '000.000.000-10', 'marcos.r@email.com', '(21) 96666-5555'),
('TechConstruções S/A', '12.345.678/0001-11', 'contato@techconst.com', '(11) 4002-8922'),
('Juliana Lima', '000.000.000-12', 'juliana.lima@email.com', NULL),
('Felipe Martins', '000.000.000-13', 'felipe.martins@email.com', NULL),
('Empreiteira Silva', '98.765.432/0001-14', 'contato@empreiteirasilva.com', '(31) 3333-4444'),
('Camila Rodrigues', '000.000.000-15', 'camila.r@email.com', NULL),
('Thiago Fernandes', '000.000.000-16', 'thiago.f@email.com', NULL),
('Bruno Gomes', '000.000.000-17', 'bruno.g@email.com', NULL),
('Renata Castro', '000.000.000-18', 'renata.c@email.com', NULL),
('Igor Ribeiro', '000.000.000-19', 'igor.r@email.com', NULL),
('Amanda Carvalho', '000.000.000-20', 'amanda.c@email.com', NULL),
('Vitor Barbosa', '000.000.000-21', 'vitor.b@email.com', NULL),
('Obras Rápidas Ltda', '11.222.333/0001-22', 'vendas@obrasrapidas.com', NULL),
('Larissa Nogueira', '000.000.000-23', 'larissa.n@email.com', NULL),
('Diego Monteiro', '000.000.000-24', 'diego.m@email.com', NULL),
('Patrícia Nunes', '000.000.000-25', 'patricia.n@email.com', NULL),
('Rodrigo Azevedo', '000.000.000-26', 'rodrigo.a@email.com', NULL),
('Vanessa Pires', '000.000.000-27', 'vanessa.p@email.com', NULL),
('Edificações Master', '44.555.666/0001-28', 'financeiro@masteredific.com', NULL),
('Guilherme Melo', '000.000.000-29', 'guilherme.m@email.com', NULL),
('Letícia Cardoso', '000.000.000-30', 'leticia.c@email.com', NULL),
('Rafael Teixeira', '000.000.000-31', 'rafael.t@email.com', NULL),
('Marina Cavalcante', '000.000.000-32', 'marina.c@email.com', NULL),
('Sérgio Moraes', '000.000.000-33', 'sergio.m@email.com', NULL),
('Tatiana Farias', '000.000.000-34', 'tatiana.f@email.com', NULL),
('Alexandre Duarte', '000.000.000-35', 'alexandre.d@email.com', NULL),
('Construtora Base', '99.888.777/0001-36', 'sac@base.com', NULL),
('Daniela Viana', '000.000.000-37', 'daniela.v@email.com', NULL),
('Eduardo Machado', '000.000.000-38', 'eduardo.m@email.com', NULL),
('Fernanda Borges', '000.000.000-39', 'fernanda.b@email.com', NULL),
('Ricardo Lemos', '000.000.000-40', 'ricardo.l@email.com', NULL);

-- -----------------------------------------------------------------------------
-- 5. FUNCIONARIO 
-- -----------------------------------------------------------------------------
INSERT INTO funcionario (id_pessoa, salario, cargo, id_supervisor) VALUES 
(1, 6500.00, 'Gerente de Operações', NULL), 
(2, 2800.00, 'Atendente Comercial', 1);

-- -----------------------------------------------------------------------------
-- 6. CLIENTE 
-- -----------------------------------------------------------------------------
INSERT INTO cliente (id_pessoa, limite_credito) VALUES 
(3, 50000.0), (4, 15000.0), (5, 5000.0), (6, 2000.0), (7, 3000.0), (8, 4500.0), (9, 2500.0), (10, 10000.0),
(11, 80000.0), (12, 1200.0), (13, 2000.0), (14, 30000.0), (15, 4000.0), (16, 1500.0), (17, 3000.0), (18, 5000.0),
(19, 2000.0), (20, 1800.0), (21, 6000.0), (22, 25000.0), (23, 1000.0), (24, 7000.0), (25, 3000.0), (26, 4000.0),
(27, 2500.0), (28, 40000.0), (29, 3500.0), (30, 2000.0), (31, 1500.0), (32, 3000.0), (33, 5000.0), (34, 4500.0),
(35, 6000.0), (36, 100000.0), (37, 2000.0), (38, 1000.0), (39, 3500.0), (40, 4000.0);

-- -----------------------------------------------------------------------------
-- 7. EQUIPAMENTO 
-- -----------------------------------------------------------------------------
INSERT INTO equipamento (id_modeloE, numero_serie, status) VALUES 
(1, 'BET-001', 'Disponível'), (2, 'MAR-001', 'Alugado'), (3, 'RET-001', 'Inativo'), (4, 'AND-001', 'Disponível'), (5, 'FUR-001', 'Alugado'),
(1, 'BET-002', 'Alugado'), (2, 'MAR-002', 'Disponível'), (3, 'RET-002', 'Disponível'), (4, 'AND-002', 'Inativo'), (5, 'FUR-002', 'Disponível'),
(1, 'BET-003', 'Disponível'), (2, 'MAR-003', 'Disponível'), (3, 'RET-003', 'Alugado'), (4, 'AND-003', 'Disponível'), (5, 'FUR-003', 'Alugado'),
(1, 'BET-004', 'Inativo'), (2, 'MAR-004', 'Alugado'), (3, 'RET-004', 'Disponível'), (4, 'AND-004', 'Disponível'), (5, 'FUR-004', 'Disponível'),
(1, 'BET-005', 'Disponível'), (2, 'MAR-005', 'Disponível'), (3, 'RET-005', 'Disponível'), (4, 'AND-005', 'Alugado'), (5, 'FUR-005', 'Inativo'),
(1, 'BET-006', 'Alugado'), (2, 'MAR-006', 'Disponível'), (3, 'RET-006', 'Disponível'), (4, 'AND-006', 'Disponível'), (5, 'FUR-006', 'Disponível'),
(1, 'BET-007', 'Disponível'), (2, 'MAR-007', 'Inativo'), (3, 'RET-007', 'Alugado'), (4, 'AND-007', 'Disponível'), (5, 'FUR-007', 'Disponível'),
(1, 'BET-008', 'Disponível'), (2, 'MAR-008', 'Disponível'), (3, 'RET-008', 'Disponível'), (4, 'AND-008', 'Inativo'), (5, 'FUR-008', 'Alugado'),
(1, 'BET-009', 'Disponível');

-- -----------------------------------------------------------------------------
-- 8. EMPRESTIMO 
-- -----------------------------------------------------------------------------
INSERT INTO emprestimo (id_cliente, id_funcionario, id_formaPgmt, data_emissao, data_prevista_devolucao, valor_total, status_emprestimo) VALUES 
(3, 2, 1, '2026-08-01', '2026-08-05', 0, 'Finalizado'), 
(4, 2, 2, '2026-08-10', '2026-08-15', 0, 'Em Aberto'),  
(5, 2, 3, '2026-08-12', '2026-08-14', 0, 'Finalizado'), 
(6, 1, 4, '2026-08-20', '2026-08-25', 0, 'Cancelado'),  
(7, 2, 5, '2026-08-01', '2026-08-10', 0, 'Finalizado'), 
(8, 2, 1, '2026-09-01', '2026-09-05', 0, 'Em Aberto'),
(9, 1, 2, '2026-09-02', '2026-09-07', 0, 'Em Aberto'),
(10, 2, 3, '2026-09-03', '2026-09-08', 0, 'Em Aberto'),
(11, 2, 4, '2026-07-01', '2026-07-05', 0, 'Finalizado'),
(12, 1, 5, '2026-09-10', '2026-09-15', 0, 'Cancelado'),
(13, 2, 1, '2026-08-15', '2026-08-20', 0, 'Finalizado'),
(14, 2, 2, '2026-09-05', '2026-09-12', 0, 'Em Aberto'),
(15, 1, 3, '2026-09-06', '2026-09-10', 0, 'Em Aberto'),
(16, 2, 4, '2026-06-10', '2026-06-15', 0, 'Finalizado'),
(17, 2, 5, '2026-09-20', '2026-09-25', 0, 'Cancelado'),
(18, 1, 1, '2026-09-07', '2026-09-14', 0, 'Em Aberto'),
(19, 2, 2, '2026-09-08', '2026-09-12', 0, 'Em Aberto'),
(20, 2, 3, '2026-08-25', '2026-08-30', 0, 'Finalizado'),
(21, 1, 4, '2026-09-01', '2026-09-05', 0, 'Cancelado'),
(22, 2, 5, '2026-09-09', '2026-09-16', 0, 'Em Aberto'),
(23, 2, 1, '2026-09-10', '2026-09-15', 0, 'Em Aberto'),
(24, 1, 2, '2026-07-15', '2026-07-20', 0, 'Finalizado'),
(25, 2, 3, '2026-09-11', '2026-09-18', 0, 'Em Aberto'),
(26, 2, 4, '2026-08-05', '2026-08-10', 0, 'Finalizado'),
(27, 1, 5, '2026-09-15', '2026-09-20', 0, 'Cancelado'),
(28, 2, 1, '2026-09-12', '2026-09-17', 0, 'Em Aberto'),
(29, 2, 2, '2026-09-13', '2026-09-19', 0, 'Em Aberto'),
(30, 1, 3, '2026-05-10', '2026-05-15', 0, 'Finalizado'),
(31, 2, 4, '2026-09-14', '2026-09-20', 0, 'Em Aberto'),
(32, 2, 5, '2026-09-15', '2026-09-21', 0, 'Em Aberto'),
(33, 1, 1, '2026-04-20', '2026-04-25', 0, 'Finalizado'),
(34, 2, 2, '2026-09-16', '2026-09-22', 0, 'Em Aberto'),
(35, 2, 3, '2026-09-17', '2026-09-23', 0, 'Em Aberto'),
(36, 1, 4, '2026-08-10', '2026-08-15', 0, 'Finalizado'),
(37, 2, 5, '2026-09-18', '2026-09-24', 0, 'Em Aberto'),
(38, 2, 1, '2026-09-19', '2026-09-25', 0, 'Em Aberto'),
(39, 1, 2, '2026-03-01', '2026-03-05', 0, 'Finalizado'),
(40, 2, 3, '2026-09-20', '2026-09-26', 0, 'Em Aberto'),
(3, 2, 4, '2026-09-21', '2026-09-27', 0, 'Em Aberto'),
(4, 1, 5, '2026-09-25', '2026-09-30', 0, 'Cancelado');

-- -----------------------------------------------------------------------------
-- 9. ITEM_EMPRESTIMO
-- -----------------------------------------------------------------------------
INSERT INTO item_emprestimo (id_emprestimo, id_equipamento, valor_diaria_aplicado) VALUES 
(1, 1, 150), (1, 2, 95), (1, 3, 900), 
(2, 4, 15), (2, 5, 45), (2, 6, 150), 
(3, 7, 95), (3, 8, 900), (3, 9, 15), 
(4, 10, 45), (4, 11, 150), (4, 12, 95), 
(5, 13, 900), (5, 14, 15), (5, 15, 45), 
(6, 16, 150), (6, 17, 95), (6, 18, 900), 
(7, 19, 15), (7, 20, 45), (7, 21, 150), 
(8, 22, 95), (8, 23, 900), (8, 24, 15), 
(9, 25, 45), (9, 26, 150), (9, 27, 95), 
(10, 28, 900), (10, 29, 15), (10, 30, 45), 
(11, 31, 150), (11, 32, 95), (11, 33, 900), 
(12, 34, 15), (12, 35, 45), (12, 36, 150), 
(13, 37, 95), (13, 38, 900), (13, 39, 15), 
(14, 40, 45), (14, 41, 150), (14, 1, 95), 
(15, 2, 900), (15, 3, 15), (15, 4, 45), 
(16, 5, 150), (16, 6, 95), (16, 7, 900), 
(17, 8, 15), (17, 9, 45), (17, 10, 150), 
(18, 11, 95), (18, 12, 900), (18, 13, 15), 
(19, 14, 45), (19, 15, 150), (19, 16, 95), 
(20, 17, 900), (20, 18, 15), (20, 19, 45), 
(21, 20, 150), (21, 21, 95), (21, 22, 900), 
(22, 23, 15), (22, 24, 45), (22, 25, 150), 
(23, 26, 95), (23, 27, 900), (23, 28, 15), 
(24, 29, 45), (24, 30, 150), (24, 31, 95), 
(25, 32, 900), (25, 33, 15), (25, 34, 45), 
(26, 35, 150), (26, 36, 95), (26, 37, 900), 
(27, 38, 15), (27, 39, 45), (27, 40, 150), 
(28, 41, 95), (28, 1, 900), (28, 2, 15), 
(29, 3, 45), (29, 4, 150), (29, 5, 95), 
(30, 6, 900), (30, 7, 15), (30, 8, 45), 
(31, 9, 150), (31, 10, 95), (31, 11, 900), 
(32, 12, 15), (32, 13, 45), (32, 14, 150), 
(33, 15, 95), (33, 16, 900), (33, 17, 15), 
(34, 18, 45), (34, 19, 150), (34, 20, 95), 
(35, 21, 900), (35, 22, 15), (35, 23, 45), 
(36, 24, 150), (36, 25, 95), (36, 26, 900), 
(37, 27, 15), (37, 28, 45), (37, 29, 150), 
(38, 30, 95), (38, 31, 900), (38, 32, 15), 
(39, 33, 45), (39, 34, 150), (39, 35, 95), 
(40, 36, 900), (40, 37, 15), (40, 38, 45);

-- -----------------------------------------------------------------------------
-- 10. PAGAMENTO e PARCELAS
-- -----------------------------------------------------------------------------
INSERT INTO pagamento (id_emprestimo, valor_total) VALUES 
(1, 1000.00), (2, 500.00), (3, 1200.00), (5, 800.00), (11, 2000.00);

INSERT INTO parcela_pagamento (id_pagamento, num_parcela, data_vencimento, valor_parcela) VALUES 
(1, 1, '2026-08-01', 1000.00), 
(2, 1, '2026-09-10', 250.00), (2, 2, '2026-10-10', 250.00), 
(3, 1, '2026-08-12', 1200.00), 
(4, 1, '2026-08-05', 800.00), 
(5, 1, '2026-07-05', 2000.00);