-- =============================================================================
-- 03_consultas.sql
-- Projeto Final — LABORATÓRIO DE BANCO DE DADOS (GPE17M40053)
-- Domínio: Locadora de Equipamentos para Construção Civil
-- SGBD alvo: MySQL 8+
-- =============================================================================

-- =============================================================================
-- CATEGORIA 1: BÁSICAS (Projeção, WHERE, Ordenação, LIKE, BETWEEN, IN, NULL)
-- =============================================================================

-- Pergunta de negócio 1: Quais são os nomes e e-mails de todas as pessoas cadastradas cujo nome começa com "Carlos", ordenados alfabeticamente?
-- Exigência atendida: Projeção, WHERE, LIKE, Ordenação (ORDER BY).
SELECT nome, email 
  FROM pessoa 
 WHERE nome LIKE 'Carlos%' 
 ORDER BY nome ASC;

-- Pergunta de negócio 2: Quais são os identificadores e números de série dos equipamentos físicos que estão com status "Disponível" ou "Inativo"?
-- Exigência atendida: Uso do operador IN.
SELECT id_equipamento, numero_serie, status 
  FROM equipamento 
 WHERE status IN ('Disponível', 'Inativo') 
 ORDER BY id_equipamento;

-- Pergunta de negócio 3: Quais modelos de equipamento possuem o valor da diária padrão entre R$ 100,00 e R$ 500,00?
-- Exigência atendida: Uso do operador BETWEEN.
SELECT nome, valor_diaria_padrao 
  FROM modelo_equipamento 
 WHERE valor_diaria_padrao BETWEEN 100.00 AND 500.00 
 ORDER BY valor_diaria_padrao DESC;

-- Pergunta de negócio 4: Quais pessoas cadastradas na base de dados não forneceram um número de telefone para contato?
-- Exigência atendida: Tratamento de NULL (IS NULL).
SELECT id_pessoa, nome, doc_cpf_cnpj 
  FROM pessoa 
 WHERE telefone IS NULL 
 ORDER BY nome;

-- Pergunta de negócio 5: Quais empréstimos estão com o status finalizado, organizados do mais recente para o mais antigo?
-- Exigência atendida: Seleção direta com WHERE e ordenação decrescente de datas.
SELECT id_emprestimo, data_emissao, data_prevista_devolucao 
  FROM emprestimo 
 WHERE status_emprestimo = 'Finalizado' 
 ORDER BY data_emissao DESC;

-- =============================================================================
-- CATEGORIA 2: JUNÇÕES E AGREGAÇÃO (LEFT JOIN, Três Tabelas, GROUP BY, HAVING)
-- =============================================================================

-- Pergunta de negócio 6: Qual é o limite de crédito aprovado para cada cliente (exibindo o nome real do cliente)?
-- Exigência atendida: Junção interna básica (INNER JOIN entre 2 tabelas).
SELECT p.nome, c.limite_credito 
  FROM cliente c 
 INNER JOIN pessoa p ON c.id_pessoa = p.id_pessoa 
 ORDER BY c.limite_credito DESC;

-- Pergunta de negócio 7: Quais são todos os modelos de equipamentos do catálogo e, caso já existam unidades compradas, quais os números de série desses equipamentos físicos?
-- Exigência atendida: Uso de LEFT JOIN (mostra modelos mesmo que não tenham equipamento físico).
SELECT m.nome AS modelo, e.numero_serie, e.status 
  FROM modelo_equipamento m 
  LEFT JOIN equipamento e ON m.id_modeloE = e.id_modeloE 
 ORDER BY m.nome;

-- Pergunta de negócio 8: Qual o nome do cliente, o número de série do equipamento alugado e a data da transação para todos os itens já emprestados?
-- Exigência atendida: Junção com mais de três tabelas (emprestimo, cliente, pessoa, item_emprestimo, equipamento).
SELECT p.nome AS nome_cliente, eq.numero_serie, emp.data_emissao 
  FROM emprestimo emp 
 INNER JOIN cliente c ON emp.id_cliente = c.id_pessoa 
 INNER JOIN pessoa p ON c.id_pessoa = p.id_pessoa 
 INNER JOIN item_emprestimo ie ON emp.id_emprestimo = ie.id_emprestimo 
 INNER JOIN equipamento eq ON ie.id_equipamento = eq.id_equipamento 
 ORDER BY emp.data_emissao DESC;

-- Pergunta de negócio 9: Qual é a quantidade total de equipamentos físicos existentes na empresa, agrupada por status (Disponível, Alugado, Inativo)?
-- Exigência atendida: Uso de GROUP BY e funções de agregação (COUNT).
SELECT status, COUNT(id_equipamento) AS total_equipamentos 
  FROM equipamento 
 GROUP BY status 
 ORDER BY total_equipamentos DESC;

-- Pergunta de negócio 10: Quais categorias de catálogo possuem estritamente mais de 1 modelo de equipamento vinculado a elas?
-- Exigência atendida: Uso combinado de GROUP BY e HAVING.
SELECT c.nome_categoria, COUNT(m.id_modeloE) AS qtd_modelos 
  FROM categoria c 
 INNER JOIN modelo_equipamento m ON c.id_categoria = m.id_categoria 
 GROUP BY c.id_categoria, c.nome_categoria 
HAVING COUNT(m.id_modeloE) > 1 
 ORDER BY qtd_modelos DESC;

-- =============================================================================
-- CATEGORIA 3: AVANÇADAS (Subconsulta correlacionada, EXISTS, Pergunta Não Trivial)
-- =============================================================================

-- Pergunta de negócio 11: Quais modelos de equipamento possuem uma diária padrão superior à diária média dos modelos pertencentes exclusivamente à sua própria categoria?
-- Exigência atendida: Subconsulta correlacionada.
SELECT m1.nome, c.nome_categoria, m1.valor_diaria_padrao 
  FROM modelo_equipamento m1
 INNER JOIN categoria c ON m1.id_categoria = c.id_categoria
 WHERE m1.valor_diaria_padrao > (
       SELECT AVG(m2.valor_diaria_padrao) 
         FROM modelo_equipamento m2 
        WHERE m2.id_categoria = m1.id_categoria
 )
 ORDER BY c.nome_categoria, m1.valor_diaria_padrao DESC;

-- Pergunta de negócio 12: Quais clientes (nome e documento) possuem pelo menos um empréstimo já registrado no histórico da locadora?
-- Exigência atendida: Uso da cláusula EXISTS.
SELECT p.nome, p.doc_cpf_cnpj 
  FROM pessoa p 
 INNER JOIN cliente c ON p.id_pessoa = c.id_pessoa 
 WHERE EXISTS (
       SELECT 1 
         FROM emprestimo e 
        WHERE e.id_cliente = c.id_pessoa
 )
 ORDER BY p.nome;

-- Pergunta de negócio 13: Pergunta não trivial: Considerando os contratos já fechados, qual foi o volume financeiro real (receita consolidada) gerado por cada forma de pagamento aceita, desconsiderando empréstimos cancelados?
-- Exigência atendida: Resposta a pergunta de negócio analítica não trivial do domínio.
SELECT fp.nome_forma, SUM(pg.valor_total) AS receita_consolidada 
  FROM forma_pagamento fp 
 INNER JOIN emprestimo emp ON fp.id_formaPgmt = emp.id_formaPgmt 
 INNER JOIN pagamento pg ON emp.id_emprestimo = pg.id_emprestimo 
 WHERE emp.status_emprestimo != 'Cancelado' 
 GROUP BY fp.nome_forma 
 ORDER BY receita_consolidada DESC;

-- Pergunta de negócio 14: Quais itens de locação provam a imunidade a reajustes (RN13), ou seja, onde o valor cobrado do cliente no contrato está atualmente mais barato do que o valor de tabela oficial do modelo?
-- Exigência atendida: Consulta analítica avançada comparando valores de transação passada com catálogo atual.
SELECT eq.numero_serie, m.nome AS modelo, ie.valor_diaria_aplicado AS valor_cobrado, m.valor_diaria_padrao AS tabela_atual 
  FROM item_emprestimo ie 
 INNER JOIN equipamento eq ON ie.id_equipamento = eq.id_equipamento 
 INNER JOIN modelo_equipamento m ON eq.id_modeloE = m.id_modeloE 
 WHERE ie.valor_diaria_aplicado < m.valor_diaria_padrao;

-- Pergunta de negócio 15: Quais categorias do sistema não possuem absolutamente nenhum modelo de equipamento associado a elas atualmente?
-- Exigência atendida: Uso do operador NOT EXISTS para buscar entidades órfãs.
SELECT c.id_categoria, c.nome_categoria 
  FROM categoria c 
 WHERE NOT EXISTS (
       SELECT 1 
         FROM modelo_equipamento m 
        WHERE m.id_categoria = c.id_categoria
 );
