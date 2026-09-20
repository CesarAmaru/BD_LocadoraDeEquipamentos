-- =============================================================================
-- 02_carga.sql
-- Projeto Final — LABORATÓRIO DE BANCO DE DADOS (GPE17M40053)
-- Domínio: Locadora de Equipamentos para Construção Civil
-- SGBD alvo: MySQL 8+

-- =============================================================================
USE locadora_equipamentos;
-- -----------------------------------------------------------------------------
-- 1. FORMA DE PAGAMENTO (Domínio estático)
-- -----------------------------------------------------------------------------
INSERT INTO forma_pagamento (nome_forma) VALUES 
('PIX'), 
('Cartão de crédito'), 
('Cartão de débito'), 
('Dinheiro'), 
('Boleto');

-- -----------------------------------------------------------------------------
-- 2. CATEGORIA (Catálogo base)
-- -----------------------------------------------------------------------------
INSERT INTO categoria (nome_categoria) VALUES 
('Concretagem e Argamassa'),
('Terraplanagem'),
('Furação e Demolição'),
('Acesso e Elevação');

-- -----------------------------------------------------------------------------
-- 3. PESSOA (Superclasse - Clientes e Funcionários)
-- -----------------------------------------------------------------------------
-- Dados fictícios de pessoas físicas e jurídicas.
-- Pessoas 1 e 2 serão funcionários; Pessoas 3, 4 e 5 serão clientes.
INSERT INTO pessoa (nome, doc_cpf_cnpj, email, telefone) VALUES 
('Carlos Almeida Silva', '111.111.111-11', 'carlos.gerencia@locadora.fake', '(11) 99999-1111'),
('Mariana Souza Santos', '222.222.222-22', 'mariana.atend@locadora.fake', NULL), -- Caso de contorno: telefone NULL
('Construtora Alfa Ltda', '33.333.333/0001-33', 'compras@alfa.fake', '(11) 3333-3333'),
('Roberto de Oliveira', '444.444.444-44', 'roberto.eng@email.fake', '(11) 98888-4444'),
('Reformas Express ME', '55.555.555/0001-55', 'contato@express.fake', NULL); -- Caso de contorno: telefone NULL

-- -----------------------------------------------------------------------------
-- 4. FUNCIONARIO (Subclasse com hierarquia / RN05)
-- -----------------------------------------------------------------------------
-- O funcionário 1 é o Gerente (não tem supervisor).
-- A funcionária 2 é Atendente (supervisionada pelo funcionário 1).
INSERT INTO funcionario (id_pessoa, salario, cargo, id_supervisor) VALUES 
(1, 6500.00, 'Gerente de Operações', NULL), -- Caso de contorno: Topo da hierarquia
(2, 2800.00, 'Atendente Comercial', 1);

-- -----------------------------------------------------------------------------
-- 5. CLIENTE (Subclasse)
-- -----------------------------------------------------------------------------
INSERT INTO cliente (id_pessoa, limite_credito) VALUES 
(3, 50000.00), -- Cliente corporativo alto limite
(4, 5000.00),  -- Pessoa física limite padrão
(5, 0.00);     -- Caso de contorno: Cliente bloqueado ou sem limite pré-aprovado

-- -----------------------------------------------------------------------------
-- 6. MODELO_EQUIPAMENTO (Catálogo)
-- -----------------------------------------------------------------------------
-- Inserindo modelos associados às categorias (1=Concretagem, 2=Terraplanagem, 3=Furação)
INSERT INTO modelo_equipamento (id_categoria, nome, marca, valor_diaria_padrao) VALUES 
(1, 'Betoneira 400L', 'Menegotti', 150.00),
(3, 'Martelete Rompedor 15kg', 'Bosch', 95.00),
(2, 'Retroescavadeira 4x4', NULL, 900.00); -- Caso de contorno: Equipamento sem marca documentada

-- -----------------------------------------------------------------------------
-- 7. EQUIPAMENTO (Instâncias Físicas)
-- -----------------------------------------------------------------------------
INSERT INTO equipamento (id_modeloE, numero_serie, status) VALUES 
(1, 'BET-2024-001', 'Disponível'),
(1, 'BET-2024-002', 'Inativo'),      -- Caso de contorno: Máquina em manutenção/inativa
(2, 'MAR-2023-105', 'Disponível'),
(3, 'RET-2022-088', 'Disponível');

-- -----------------------------------------------------------------------------
-- 8. EMPRESTIMO (Transacional)
-- -----------------------------------------------------------------------------
-- Empréstimo 1: Finalizado, histórico no passado. (Cliente 3, Func 2, PG: PIX = ID 1)
-- Empréstimo 2: Em Aberto. (Cliente 4, Func 2, PG: Cartão Créd = ID 2)
-- Empréstimo 3: Cancelado (Caso de contorno). (Cliente 5, Func 1, PG: Dinheiro = ID 4)
INSERT INTO emprestimo (id_cliente, id_funcionario, id_formaPgmt, data_emissao, data_prevista_devolucao, valor_total, status_emprestimo) VALUES 
(3, 2, 1, '2026-08-01', '2026-08-05', 1225.00, 'Finalizado'),
(4, 2, 2, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY), 665.00, 'Em Aberto'),
(5, 1, 4, '2026-08-15', '2026-08-20', 0.00, 'Cancelado'); -- Cancelado antes da entrega

-- -----------------------------------------------------------------------------
-- 9. ITEM_EMPRESTIMO (Associativa com histórico de preço - RN13 / Gatilho RN14)
-- -----------------------------------------------------------------------------
-- Para o Empréstimo 1 (Finalizado)
INSERT INTO item_emprestimo (id_emprestimo, id_equipamento, valor_diaria_aplicado) VALUES 
(1, 1, 150.00), -- Valor padrão
(1, 3, 95.00);  -- Valor padrão

-- Para o Empréstimo 2 (Em Aberto) -> *O GATILHO RN14 vai alterar o status do equipamento 4 para 'Alugado' automaticamente.
INSERT INTO item_emprestimo (id_emprestimo, id_equipamento, valor_diaria_aplicado) VALUES 
(2, 4, 850.00); -- Caso de contorno: Negociação de preço com desconto aplicado (-R$50 da diária)

-- -----------------------------------------------------------------------------
-- 10. PAGAMENTO (Financeiro principal)
-- -----------------------------------------------------------------------------
-- Empréstimo 1 gerou Pagamento 1
INSERT INTO pagamento (id_emprestimo, valor_total) VALUES 
(1, 1225.00);

-- Empréstimo 2 gerou Pagamento 2
INSERT INTO pagamento (id_emprestimo, valor_total) VALUES 
(2, 665.00);

-- -----------------------------------------------------------------------------
-- 11. PARCELA_PAGAMENTO (Entidade Fraca - Gatilho RN19)
-- -----------------------------------------------------------------------------
-- Pagamento 1 (PIX à vista, vencimento no dia da emissão do empréstimo)
INSERT INTO parcela_pagamento (id_pagamento, num_parcela, data_vencimento, valor_parcela) VALUES 
(1, 1, '2026-08-01', 1225.00);

-- Pagamento 2 (Cartão de Crédito dividido em 2x, vencimento 30 e 60 dias após)
INSERT INTO parcela_pagamento (id_pagamento, num_parcela, data_vencimento, valor_parcela) VALUES 
(2, 1, DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY), 332.50),
(2, 2, DATE_ADD(CURRENT_DATE, INTERVAL 60 DAY), 332.50);
