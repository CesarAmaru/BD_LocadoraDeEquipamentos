-- =============================================================================
-- 04_testes_transacionais.sql
-- SGBD: MySQL 8.0+ 
-- =============================================================================

USE locadora_equipamentos;

-- =============================================================================
-- TESTE 1: EXECUÇÃO COMPLETA DE TRANSAÇÃO (COMMIT)
-- Operação atômica abrangendo emprestimo, item_emprestimo, pagamento e parcela_pagamento.
-- =============================================================================

START TRANSACTION;

-- 1. Criação do cabeçalho do empréstimo para o Cliente ID 4 e Funcionário ID 2
INSERT INTO emprestimo (id_cliente, id_funcionario, data_emissao, data_prevista_devolucao, status_emprestimo)
VALUES (4, 2, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'Em Aberto');

-- 2. Recupera o ID gerado para a locação atual
SET @id_emp_novo = LAST_INSERT_ID();

-- 3. Inserção do equipamento ID 1
-- (A trigger 'trg_item_emprestimo_after_insert' atualiza o status do equipamento para 'Alugado' e grava no histórico)
INSERT INTO item_emprestimo (id_emprestimo, id_equipamento, valor_diaria_aplicado)
VALUES (@id_emp_novo, 1, 150.00);

-- 4. Registro do pagamento associado
INSERT INTO pagamento (id_emprestimo, valor_total)
VALUES (@id_emp_novo, 1500.00);

SET @id_pag_novo = LAST_INSERT_ID();

-- 5. Geração da parcela correspondente
INSERT INTO parcela_pagamento (id_pagamento, num_parcela, data_vencimento, valor_parcela)
VALUES (@id_pag_novo, 1, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 1500.00);
rollback;
-- Efetivação completa de todas as alterações
COMMIT;

-- Verificação da integridade gerada
SELECT * FROM emprestimo WHERE id_emprestimo = @id_emp_novo;
SELECT * FROM item_emprestimo WHERE id_emprestimo = @id_emp_novo;
SELECT * FROM equipamento WHERE id_equipamento = 1;


-- =============================================================================
-- TESTE 2: SIMULAÇÃO DE FALHA E REVERSÃO (ROLLBACK)
-- Demonstra que nenhuma alteração parcial é mantida caso ocorra falha.
-- =============================================================================

START TRANSACTION;

-- Passo A: Inserção do cabeçalho do empréstimo
INSERT INTO emprestimo (id_cliente, id_funcionario, data_emissao, data_prevista_devolucao, status_emprestimo)
VALUES (6, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'Em Aberto');

SET @id_emp_falha = LAST_INSERT_ID();

-- Passo B: Inserção parcial do item
INSERT INTO item_emprestimo (id_emprestimo, id_equipamento, valor_diaria_aplicado)
VALUES (@id_emp_falha, 2, 120.00);

-- Simulação de detecção de erro na aplicação ou violação de regra de negócio
-- Cancela e reverte todas as operações realizadas desde o START TRANSACTION
ROLLBACK;

-- Verificação de garantia da atomicidade (nenhum registro deve ser retornado)
SELECT * FROM emprestimo WHERE id_emprestimo = @id_emp_falha;


-- =============================================================================
-- TESTE 3: CONCORRÊNCIA E CONTROLE DE BLOQUEIOS (DUAS SESSÕES)
-- Instruções para execução manual em duas abas/conexões do MySQL Workbench/CLI.
-- =============================================================================


   -- SESSÃO A (Aba / Conexão 1)
   USE locadora_equipamentos;
   START TRANSACTION;
   
   -- Reserva/vincula o equipamento ID 4 na Sessão A
   INSERT INTO item_emprestimo (id_emprestimo, id_equipamento, valor_diaria_aplicado) 
   VALUES (1, 4, 150.00);
   -- (A Sessão A obtém o bloqueio exclusivo de linha / row lock sobre o equipamento 4)


   -- SESSÃO B (Aba / Conexão 2 - Executar ao mesmo tempo)
   USE locadora_equipamentos;
   START TRANSACTION;
   
   -- Tenta alugar o mesmo equipamento ID 4 na Sessão B
   INSERT INTO item_emprestimo (id_emprestimo, id_equipamento, valor_diaria_aplicado) 
   VALUES (2, 4, 150.00);
   -- RESULTADO NA SESSÃO B: Fica em estado de ESPERA (Lock wait timeout / Bloqueada)


   -- CONCLUINDO O EXPERIMENTO:
   -- 1. Na Sessão A, execute:
   COMMIT; 
   -- (Os bloqueios são liberados e o aluguel da Sessão A é confirmado)

   -- 2. Na Sessão B, a instrução desbloqueia e retorna erro de violação/indisponibilidade. Execute:
   ROLLBACK;
