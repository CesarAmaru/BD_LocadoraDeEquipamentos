-- =============================================================================
-- 03_seguranca_sem_alterar_codigo.sql
-- Projeto Final — Etapa 2 — Banco de dados, segurança e auditoria
-- VERSÃO QUE NÃO EXIGE ALTERAR NENHUM CÓDIGO ENTREGUE (.java, 01_ddl, 02_carga).
-- SGBD: MySQL 8+ | Executar DEPOIS de 01_ddl.sql e 02_carga.sql, como administrador.
--
-- Como funciona sem mexer no Java: os DAOs enviam SQL com os nomes das tabelas
-- (pessoa, funcionario, ...). Cada perfil conecta em um SCHEMA próprio, cheio de
-- visões com esses mesmos nomes, já com os dados sensíveis mascarados. A troca
-- de perfil é só mudar db.url / db.user / db.password no config.properties:
--     gerente   -> jdbc:mysql://localhost:3306/locadora_equipamentos  (app_gerente)
--     atendente -> jdbc:mysql://localhost:3306/locadora_atendente     (app_atendente)
--     consulta  -> jdbc:mysql://localhost:3306/locadora_consulta      (app_consulta)
-- =============================================================================
USE locadora_equipamentos;

-- =============================================================================
-- PARTE 1 — RN19 (novo trigger; não altera nenhum objeto existente)
-- =============================================================================
-- 1.2 RN19 (estava só documentada, sem implementação):
-- data_vencimento da parcela não pode ser anterior à data_emissao do empréstimo.
-- CHECK não consegue olhar outra tabela, por isso a regra vira trigger.
-- Obs.: a carga original tem 7 parcelas que violam a regra (já gravadas antes
-- deste trigger). Ver docs/seguranca-auditoria.md para a correção sugerida.
DELIMITER $$

CREATE TRIGGER trg_parcela_before_insert
BEFORE INSERT ON parcela_pagamento
FOR EACH ROW
BEGIN
    DECLARE v_emissao DATE;
    SELECT e.data_emissao INTO v_emissao
      FROM pagamento p
      JOIN emprestimo e ON e.id_emprestimo = p.id_emprestimo
     WHERE p.id_pagamento = NEW.id_pagamento;
    IF NEW.data_vencimento < v_emissao THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN19: vencimento da parcela anterior à emissão do empréstimo';
    END IF;
END$$

CREATE TRIGGER trg_parcela_before_update
BEFORE UPDATE ON parcela_pagamento
FOR EACH ROW
BEGIN
    DECLARE v_emissao DATE;
    SELECT e.data_emissao INTO v_emissao
      FROM pagamento p
      JOIN emprestimo e ON e.id_emprestimo = p.id_emprestimo
     WHERE p.id_pagamento = NEW.id_pagamento;
    IF NEW.data_vencimento < v_emissao THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'RN19: vencimento da parcela anterior à emissão do empréstimo';
    END IF;
END$$

DELIMITER ;

-- =============================================================================
-- PARTE 2 — AUDITORIA (tabela + 2 gatilhos)
-- =============================================================================

CREATE TABLE IF NOT EXISTS auditoria_log (
    id_auditoria  BIGINT       NOT NULL AUTO_INCREMENT,
    tabela        VARCHAR(64)  NOT NULL,
    operacao      VARCHAR(10)  NOT NULL,
    id_registro   VARCHAR(40)  NOT NULL,
    usuario_db    VARCHAR(100) NOT NULL,          -- conta que fez a alteração
    data_hora     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dados_antes   JSON         NULL,
    dados_depois  JSON         NULL,
    CONSTRAINT pk_auditoria_log PRIMARY KEY (id_auditoria),
    CONSTRAINT ck_auditoria_operacao CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);
CREATE INDEX idx_auditoria_tabela_data ON auditoria_log (tabela, data_hora);

DELIMITER $$

-- GATILHO 1: alteração do limite de crédito do cliente (dado financeiro sensível).
-- USER() devolve a conta de quem conectou (CURRENT_USER() devolveria o definer).
CREATE TRIGGER trg_aud_cliente_limite
AFTER UPDATE ON cliente
FOR EACH ROW
BEGIN
    IF NOT (OLD.limite_credito <=> NEW.limite_credito) THEN
        INSERT INTO auditoria_log (tabela, operacao, id_registro, usuario_db, dados_antes, dados_depois)
        VALUES ('cliente', 'UPDATE', NEW.id_pessoa, USER(),
                JSON_OBJECT('limite_credito', OLD.limite_credito),
                JSON_OBJECT('limite_credito', NEW.limite_credito));
    END IF;
END$$

-- GATILHO 2: alteração de empréstimo (status, datas, cliente ou atendente).
CREATE TRIGGER trg_aud_emprestimo_update
AFTER UPDATE ON emprestimo
FOR EACH ROW
BEGIN
    IF NOT (OLD.status_emprestimo       <=> NEW.status_emprestimo)
    OR NOT (OLD.data_prevista_devolucao <=> NEW.data_prevista_devolucao)
    OR NOT (OLD.data_emissao            <=> NEW.data_emissao)
    OR NOT (OLD.id_cliente              <=> NEW.id_cliente)
    OR NOT (OLD.id_funcionario          <=> NEW.id_funcionario) THEN
        INSERT INTO auditoria_log (tabela, operacao, id_registro, usuario_db, dados_antes, dados_depois)
        VALUES ('emprestimo', 'UPDATE', NEW.id_emprestimo, USER(),
                JSON_OBJECT('status', OLD.status_emprestimo,
                            'data_emissao', OLD.data_emissao,
                            'data_prevista_devolucao', OLD.data_prevista_devolucao,
                            'id_cliente', OLD.id_cliente,
                            'id_funcionario', OLD.id_funcionario),
                JSON_OBJECT('status', NEW.status_emprestimo,
                            'data_emissao', NEW.data_emissao,
                            'data_prevista_devolucao', NEW.data_prevista_devolucao,
                            'id_cliente', NEW.id_cliente,
                            'id_funcionario', NEW.id_funcionario));
    END IF;
END$$

DELIMITER ;

-- =============================================================================
-- PARTE 3 — VISÕES PARA RESTRINGIR DADOS VISÍVEIS
-- SQL SECURITY DEFINER (padrão): quem consulta a visão não precisa de acesso
-- à tabela-base. É isso que permite negar SELECT em pessoa/funcionario.
-- =============================================================================

-- Funcionários sem salário e sem documento.
CREATE OR REPLACE SQL SECURITY DEFINER VIEW vw_funcionario_publico AS
SELECT f.id_pessoa AS id_funcionario,
       p.nome,
       f.cargo,
       f.id_supervisor
FROM funcionario f
JOIN pessoa p ON p.id_pessoa = f.id_pessoa;

-- Clientes com CPF/CNPJ mascarado (só os 2 últimos caracteres) e e-mail parcial.
-- Sem limite de crédito: esse dado fica restrito ao gerente.
CREATE OR REPLACE SQL SECURITY DEFINER VIEW vw_cliente_mascarado AS
SELECT c.id_pessoa AS id_cliente,
       p.nome,
       CONCAT(REPEAT('*', CHAR_LENGTH(p.doc_cpf_cnpj) - 2), RIGHT(p.doc_cpf_cnpj, 2)) AS doc_mascarado,
       CONCAT(LEFT(p.email, 2), '***@', SUBSTRING_INDEX(p.email, '@', -1))          AS email_parcial,
       p.telefone
FROM cliente c
JOIN pessoa p ON p.id_pessoa = c.id_pessoa;

-- =============================================================================
-- PARTE 4 — SCHEMAS DE VISÕES POR PERFIL (mesmos nomes de tabela do Java)
-- SQL SECURITY DEFINER: o usuário do perfil não precisa de acesso ao schema base.
-- =============================================================================
DROP DATABASE IF EXISTS locadora_atendente;
DROP DATABASE IF EXISTS locadora_consulta;
CREATE DATABASE locadora_atendente CHARACTER SET utf8mb4;
CREATE DATABASE locadora_consulta  CHARACTER SET utf8mb4;

-- ---- ATENDENTE: dados completos de pessoa/cliente (precisa cadastrar), mas
-- ---- funcionario sem salário. As demais tabelas são passagem direta.
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.categoria AS SELECT * FROM locadora_equipamentos.categoria;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.modelo_equipamento AS SELECT * FROM locadora_equipamentos.modelo_equipamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.forma_pagamento AS SELECT * FROM locadora_equipamentos.forma_pagamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.equipamento AS SELECT * FROM locadora_equipamentos.equipamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.emprestimo AS SELECT * FROM locadora_equipamentos.emprestimo;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.item_emprestimo AS SELECT * FROM locadora_equipamentos.item_emprestimo;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.pagamento AS SELECT * FROM locadora_equipamentos.pagamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.parcela_pagamento AS SELECT * FROM locadora_equipamentos.parcela_pagamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.emprestimo_forma_pagamento AS SELECT * FROM locadora_equipamentos.emprestimo_forma_pagamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.historico_status_equipamento AS SELECT * FROM locadora_equipamentos.historico_status_equipamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.pessoa AS SELECT * FROM locadora_equipamentos.pessoa;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.cliente AS SELECT * FROM locadora_equipamentos.cliente;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.funcionario AS
SELECT id_pessoa, CAST(NULL AS DECIMAL(10,2)) AS salario, cargo, id_supervisor
FROM locadora_equipamentos.funcionario;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_atendente.vw_modelos_mais_alugados AS
SELECT * FROM locadora_equipamentos.vw_modelos_mais_alugados;

-- ---- CONSULTA: somente leitura, com pessoa mascarada, sem salário e sem limite.
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.categoria AS SELECT * FROM locadora_equipamentos.categoria;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.modelo_equipamento AS SELECT * FROM locadora_equipamentos.modelo_equipamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.forma_pagamento AS SELECT * FROM locadora_equipamentos.forma_pagamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.equipamento AS SELECT * FROM locadora_equipamentos.equipamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.emprestimo AS SELECT * FROM locadora_equipamentos.emprestimo;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.item_emprestimo AS SELECT * FROM locadora_equipamentos.item_emprestimo;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.pagamento AS SELECT * FROM locadora_equipamentos.pagamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.parcela_pagamento AS SELECT * FROM locadora_equipamentos.parcela_pagamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.emprestimo_forma_pagamento AS SELECT * FROM locadora_equipamentos.emprestimo_forma_pagamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.historico_status_equipamento AS SELECT * FROM locadora_equipamentos.historico_status_equipamento;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.pessoa AS
SELECT id_pessoa,
       nome,
       CONCAT(REPEAT('*', CHAR_LENGTH(doc_cpf_cnpj) - 2), RIGHT(doc_cpf_cnpj, 2)) AS doc_cpf_cnpj,
       CONCAT(LEFT(email, 2), '***@', SUBSTRING_INDEX(email, '@', -1))            AS email,
       CASE WHEN telefone IS NULL THEN NULL
            ELSE CONCAT(REPEAT('*', GREATEST(CHAR_LENGTH(telefone) - 4, 0)), RIGHT(telefone, 4)) END AS telefone
FROM locadora_equipamentos.pessoa;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.cliente AS
SELECT id_pessoa, CAST(NULL AS DECIMAL(10,2)) AS limite_credito FROM locadora_equipamentos.cliente;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.funcionario AS
SELECT id_pessoa, CAST(NULL AS DECIMAL(10,2)) AS salario, cargo, id_supervisor
FROM locadora_equipamentos.funcionario;
CREATE OR REPLACE SQL SECURITY DEFINER VIEW locadora_consulta.vw_modelos_mais_alugados AS
SELECT * FROM locadora_equipamentos.vw_modelos_mais_alugados;

-- =============================================================================
-- PARTE 5 — PERFIS (ROLES) E USUÁRIOS
-- Troque as senhas antes de usar fora do ambiente de estudo.
-- =============================================================================
DROP ROLE IF EXISTS perfil_gerente, perfil_atendente, perfil_consulta;
CREATE ROLE perfil_gerente, perfil_atendente, perfil_consulta;

-- ---- GERENTE: usa o schema base. CRUD no negócio; só LÊ as trilhas de auditoria.
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.pessoa TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.cliente TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.funcionario TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.categoria TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.modelo_equipamento TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.forma_pagamento TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.equipamento TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.emprestimo TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.item_emprestimo TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.pagamento TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.parcela_pagamento TO perfil_gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON locadora_equipamentos.emprestimo_forma_pagamento TO perfil_gerente;
GRANT SELECT ON locadora_equipamentos.historico_status_equipamento TO perfil_gerente;
GRANT SELECT ON locadora_equipamentos.auditoria_log            TO perfil_gerente;
GRANT SELECT ON locadora_equipamentos.vw_modelos_mais_alugados TO perfil_gerente;
GRANT SELECT ON locadora_equipamentos.vw_cliente_mascarado     TO perfil_gerente;
GRANT SELECT ON locadora_equipamentos.vw_funcionario_publico   TO perfil_gerente;

-- ---- ATENDENTE: schema locadora_atendente. Cadastra e atende; nunca apaga.
GRANT SELECT ON locadora_atendente.categoria                   TO perfil_atendente;
GRANT SELECT ON locadora_atendente.modelo_equipamento          TO perfil_atendente;
GRANT SELECT ON locadora_atendente.forma_pagamento             TO perfil_atendente;
GRANT SELECT ON locadora_atendente.equipamento                 TO perfil_atendente;
GRANT UPDATE (status) ON locadora_atendente.equipamento        TO perfil_atendente;
GRANT SELECT ON locadora_atendente.historico_status_equipamento TO perfil_atendente;
GRANT SELECT, INSERT ON locadora_atendente.pessoa              TO perfil_atendente;
GRANT SELECT, INSERT ON locadora_atendente.cliente             TO perfil_atendente;
GRANT SELECT ON locadora_atendente.funcionario                 TO perfil_atendente;
GRANT SELECT, INSERT, UPDATE ON locadora_atendente.emprestimo  TO perfil_atendente;
GRANT SELECT, INSERT ON locadora_atendente.item_emprestimo     TO perfil_atendente;
GRANT SELECT, INSERT ON locadora_atendente.pagamento           TO perfil_atendente;
GRANT SELECT, INSERT ON locadora_atendente.parcela_pagamento   TO perfil_atendente;
GRANT SELECT, INSERT ON locadora_atendente.emprestimo_forma_pagamento TO perfil_atendente;
GRANT SELECT ON locadora_atendente.vw_modelos_mais_alugados    TO perfil_atendente;

-- ---- CONSULTA: schema locadora_consulta. Somente leitura, dados mascarados.
GRANT SELECT ON locadora_consulta.categoria          TO perfil_consulta;
GRANT SELECT ON locadora_consulta.modelo_equipamento TO perfil_consulta;
GRANT SELECT ON locadora_consulta.forma_pagamento    TO perfil_consulta;
GRANT SELECT ON locadora_consulta.equipamento        TO perfil_consulta;
GRANT SELECT ON locadora_consulta.pessoa             TO perfil_consulta;
GRANT SELECT ON locadora_consulta.cliente            TO perfil_consulta;
GRANT SELECT ON locadora_consulta.funcionario        TO perfil_consulta;
GRANT SELECT ON locadora_consulta.emprestimo         TO perfil_consulta;
GRANT SELECT ON locadora_consulta.item_emprestimo    TO perfil_consulta;
GRANT SELECT ON locadora_consulta.vw_modelos_mais_alugados TO perfil_consulta;

DROP USER IF EXISTS 'app_gerente'@'%', 'app_atendente'@'%', 'app_consulta'@'%';
CREATE USER 'app_gerente'@'%'   IDENTIFIED BY 'Gerente@2026';
CREATE USER 'app_atendente'@'%' IDENTIFIED BY 'Atendente@2026';
CREATE USER 'app_consulta'@'%'  IDENTIFIED BY 'Consulta@2026';
GRANT perfil_gerente   TO 'app_gerente'@'%';
GRANT perfil_atendente TO 'app_atendente'@'%';
GRANT perfil_consulta  TO 'app_consulta'@'%';
SET DEFAULT ROLE perfil_gerente   TO 'app_gerente'@'%';
SET DEFAULT ROLE perfil_atendente TO 'app_atendente'@'%';
SET DEFAULT ROLE perfil_consulta  TO 'app_consulta'@'%';
FLUSH PRIVILEGES;
