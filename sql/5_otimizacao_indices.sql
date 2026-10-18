-- =============================================================================
-- 05_otimizacao_indices.sql
-- Projeto Final — LABORATÓRIO DE BANCO DE DADOS
-- Parte 4: Desempenho e Otimização (Pessoa 4 - Gabriel)
-- =============================================================================

USE locadora_equipamentos;

-- -----------------------------------------------------------------------------
-- CONSULTA A: EMPRÉSTIMOS FINALIZADOS
-- -----------------------------------------------------------------------------
-- 1. Execução ANTES da otimização
EXPLAIN ANALYZE
SELECT id_emprestimo, data_emissao, status_emprestimo
FROM emprestimo
WHERE status_emprestimo = 'Finalizado'
ORDER BY data_emissao DESC;

-- 2. Criação do Índice
-- Justificativa: Índice composto para cobrir a cláusula WHERE (status) e o ORDER BY (data).
-- Isso elimina a necessidade de varredura completa (Table Scan) e ordenação em memória (Filesort).
CREATE INDEX idx_emp_status_data ON emprestimo (status_emprestimo, data_emissao);

-- 3. Execução DEPOIS da otimização
EXPLAIN ANALYZE
SELECT id_emprestimo, data_emissao, status_emprestimo
FROM emprestimo
WHERE status_emprestimo = 'Finalizado'
ORDER BY data_emissao DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA B: BUSCA DE PESSOAS POR NOME
-- -----------------------------------------------------------------------------
-- 1. Execução ANTES da otimização
EXPLAIN ANALYZE
SELECT nome, email
FROM pessoa
WHERE nome LIKE 'Carlos%' OR nome LIKE 'Construtora%'
ORDER BY nome ASC;

-- 2. Criação do Índice
-- Justificativa: Índices B-Tree são altamente eficientes para buscas textuais prefixadas (LIKE 'Texto%').
-- Além de acelerar o WHERE, o índice já armazena os dados em ordem alfabética, otimizando o ORDER BY.
CREATE INDEX idx_pessoa_nome ON pessoa (nome);

-- 3. Execução DEPOIS da otimização
EXPLAIN ANALYZE
SELECT nome, email
FROM pessoa
WHERE nome LIKE 'Carlos%' OR nome LIKE 'Construtora%'
ORDER BY nome ASC;


-- -----------------------------------------------------------------------------
-- CONSULTA C: DETECÇÃO DE IMUNIDADE A REAJUSTES
-- -----------------------------------------------------------------------------
-- 1. Execução ANTES da otimização
EXPLAIN ANALYZE
SELECT m.nome, ie.valor_diaria_aplicado, m.valor_diaria_padrao
FROM equipamento e
INNER JOIN modelo_equipamento m ON e.id_modeloE = m.id_modeloE
INNER JOIN item_emprestimo ie ON e.id_equipamento = ie.id_equipamento
WHERE ie.valor_diaria_aplicado < m.valor_diaria_padrao;

-- 2. Criação do Índice
-- Justificativa: A tabela item_emprestimo é a maior do sistema (tabela transacional). 
-- Criar um índice no valor aplicado permite que o SGBD filtre rapidamente os itens antes do JOIN pesado.
CREATE INDEX idx_item_valor_aplicado ON item_emprestimo (valor_diaria_aplicado);

-- 3. Execução DEPOIS da otimização
EXPLAIN ANALYZE
SELECT m.nome, ie.valor_diaria_aplicado, m.valor_diaria_padrao
FROM equipamento e
INNER JOIN modelo_equipamento m ON e.id_modeloE = m.id_modeloE
INNER JOIN item_emprestimo ie ON e.id_equipamento = ie.id_equipamento
WHERE ie.valor_diaria_aplicado < m.valor_diaria_padrao;