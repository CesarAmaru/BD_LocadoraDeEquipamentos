-- =============================================================================
-- 01_ddl.sql
-- Projeto Final — LABORATÓRIO DE BANCO DE DADOS (GPE17M40053)
-- Domínio: Locadora de Equipamentos para Construção Civil
-- SGBD alvo: MySQL 8+
--
-- Convenção de nomes de restrições: pk_, uq_, fk_, ck_, idx_
-- =============================================================================

CREATE DATABASE IF NOT EXISTS locadora_equipamentos 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE locadora_equipamentos;

-- -----------------------------------------------------------------------------
-- 1. PESSOA (superclasse da generalização Pessoa -> Cliente / Funcionario)[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE pessoa (
    id_pessoa       BIGINT AUTO_INCREMENT,
    nome            VARCHAR(150)  NOT NULL,                 
    doc_cpf_cnpj    VARCHAR(18)   NOT NULL COMMENT 'RN01 - CPF ou CNPJ, único no sistema (UNIQUE, NOT NULL)',                 
    email           VARCHAR(100)  NOT NULL COMMENT 'RN02 - email único no sistema (UNIQUE)',                 
    telefone        VARCHAR(18)   NULL,                     
    CONSTRAINT pk_pessoa PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_pessoa_documento UNIQUE (doc_cpf_cnpj), 
    CONSTRAINT uq_pessoa_email UNIQUE (email)                    
) COMMENT = 'Superclasse cadastral (RN01, RN02). Estratégia de generalização: tabela por subclasse.';

-- -----------------------------------------------------------------------------
-- 2. CLIENTE (subclasse de Pessoa)[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE cliente (
    id_pessoa       BIGINT        NOT NULL,
    limite_credito  NUMERIC(10,2) NOT NULL,                      
    CONSTRAINT pk_cliente PRIMARY KEY (id_pessoa),
    CONSTRAINT ck_cliente_limite_credito CHECK (limite_credito >= 0) 
) COMMENT = 'Especialização de Pessoa. id_pessoa é PK e, ao mesmo tempo, FK para pessoa (RN03).';

-- -----------------------------------------------------------------------------
-- 3. FUNCIONARIO (subclasse de Pessoa, com autorrelacionamento de supervisão)[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE funcionario (
    id_pessoa      BIGINT        NOT NULL,
    salario        NUMERIC(10,2) NOT NULL,                       
    cargo          VARCHAR(80)   NOT NULL,
    id_supervisor  BIGINT        NULL COMMENT 'RN05 - um funcionário só pode ser supervisionado por outro funcionário já cadastrado',                           
    CONSTRAINT pk_funcionario PRIMARY KEY (id_pessoa),
    CONSTRAINT ck_funcionario_salario CHECK (salario > 0)        
) COMMENT = 'Especialização de Pessoa. id_supervisor implementa a hierarquia "Supervisiona" (RN05).';

-- -----------------------------------------------------------------------------
-- 4. CATEGORIA[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria    BIGINT AUTO_INCREMENT,
    nome_categoria  VARCHAR(60) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
);

-- -----------------------------------------------------------------------------
-- 5. MODELO_EQUIPAMENTO (catálogo)[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE modelo_equipamento (
    id_modeloE           BIGINT AUTO_INCREMENT,
    id_categoria         BIGINT        NOT NULL COMMENT 'RN06 - todo modelo pertence a exatamente uma categoria (FK NOT NULL)',                 
    nome                 VARCHAR(60)   NOT NULL,
    marca                VARCHAR(60)   NULL,
    valor_diaria_padrao  NUMERIC(10,2) NOT NULL,                 
    CONSTRAINT pk_modelo_equipamento PRIMARY KEY (id_modeloE),
    CONSTRAINT ck_modelo_equip_valor_diaria CHECK (valor_diaria_padrao > 0) 
);

-- -----------------------------------------------------------------------------
-- 6. EQUIPAMENTO (unidade física)[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE equipamento (
    id_equipamento           BIGINT AUTO_INCREMENT,
    id_modeloE               BIGINT      NOT NULL,
    numero_serie             VARCHAR(60) NOT NULL COMMENT 'RN08 - número de série/patrimônio único (UNIQUE, NOT NULL)',                
    status                   VARCHAR(20) NOT NULL DEFAULT 'Disponível' COMMENT 'RN09 - somente Disponivel, Alugado ou Inativo', 
    CONSTRAINT pk_equipamento PRIMARY KEY (id_equipamento),
    CONSTRAINT uq_equipamento_serie UNIQUE (numero_serie), 
    CONSTRAINT ck_equipamento_status CHECK (status IN ('Disponível', 'Alugado', 'Inativo')) 
);

-- -----------------------------------------------------------------------------
-- 7. FORMA_PAGAMENTO[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE forma_pagamento (
    id_formaPgmt   BIGINT AUTO_INCREMENT,
    nome_forma     VARCHAR(30) NOT NULL,
    CONSTRAINT pk_forma_pagamento PRIMARY KEY (id_formaPgmt),
    CONSTRAINT uq_forma_pagamento_descricao UNIQUE (nome_forma),
    CONSTRAINT ck_forma_pagamento_descricao CHECK (
        nome_forma IN ('PIX', 'Cartão de crédito', 'Cartão de débito', 'Dinheiro', 'Boleto')
    )
);

-- -----------------------------------------------------------------------------
-- 8. EMPRESTIMO (entidade transacional central)[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE emprestimo (
    id_emprestimo             BIGINT AUTO_INCREMENT,
    id_cliente                BIGINT        NOT NULL,             
    id_funcionario            BIGINT        NOT NULL,             
    id_formaPgmt              BIGINT        NOT NULL,             
    data_emissao              DATE          NOT NULL DEFAULT (CURRENT_DATE),
    data_prevista_devolucao   DATE          NOT NULL COMMENT 'RN12 - não pode ser anterior à data de emissão',
    valor_total               NUMERIC(10,2) NULL COMMENT 'Atributo derivado da soma dos itens (RN16); consolidado pela aplicação',                 
    status_emprestimo         VARCHAR(20)   NOT NULL DEFAULT 'Em Aberto', 
    CONSTRAINT pk_emprestimo PRIMARY KEY (id_emprestimo),
    CONSTRAINT ck_emprestimo_datas CHECK (data_prevista_devolucao >= data_emissao), 
    CONSTRAINT ck_emprestimo_status CHECK (status_emprestimo IN ('Em Aberto', 'Finalizado', 'Cancelado')) 
);

-- -----------------------------------------------------------------------------
-- 9. ITEM_EMPRESTIMO (associativa N:N Emprestimo x Equipamento, com atributo próprio)[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE item_emprestimo (
    id_emprestimo          BIGINT        NOT NULL,
    id_equipamento         BIGINT        NOT NULL,
    valor_diaria_aplicado  NUMERIC(10,2) NOT NULL COMMENT 'RN13 - congela o valor da diária no momento da transação',                
    CONSTRAINT pk_item_emprestimo PRIMARY KEY (id_emprestimo, id_equipamento),
    CONSTRAINT ck_item_emprestimo_valor CHECK (valor_diaria_aplicado > 0)
);

-- -----------------------------------------------------------------------------
-- 10. PAGAMENTO[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE pagamento (
    id_pagamento    BIGINT AUTO_INCREMENT,
    id_emprestimo   BIGINT        NOT NULL COMMENT 'RN17 - todo pagamento deve estar vinculado a um empréstimo (FK NOT NULL)',                       
    valor_total     NUMERIC(10,2) NOT NULL,
    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
    CONSTRAINT ck_pagamento_valor CHECK (valor_total > 0)
);

-- -----------------------------------------------------------------------------
-- 11. PARCELA_PAGAMENTO (entidade fraca, identificada por dependência)[cite: 1]
-- -----------------------------------------------------------------------------
CREATE TABLE parcela_pagamento (
    id_pagamento     BIGINT        NOT NULL,
    num_parcela      SMALLINT      NOT NULL,
    data_vencimento  DATE          NOT NULL,
    valor_parcela    NUMERIC(10,2) NOT NULL,
    CONSTRAINT pk_parcela_pagamento PRIMARY KEY (id_pagamento, num_parcela), 
    CONSTRAINT ck_parcela_num CHECK (num_parcela > 0),
    CONSTRAINT ck_parcela_valor CHECK (valor_parcela > 0)
) COMMENT = 'Entidade fraca (RN18): identificador parcial num_parcela + FK do pagamento pai.';

-- =============================================================================
-- CHAVES ESTRANGEIRAS[cite: 1]
-- =============================================================================

ALTER TABLE cliente
    ADD CONSTRAINT fk_cliente_pessoa
    FOREIGN KEY (id_pessoa) REFERENCES pessoa (id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE funcionario
    ADD CONSTRAINT fk_funcionario_pessoa
    FOREIGN KEY (id_pessoa) REFERENCES pessoa (id_pessoa)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE funcionario
    ADD CONSTRAINT fk_funcionario_supervisor
    FOREIGN KEY (id_supervisor) REFERENCES funcionario (id_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE modelo_equipamento
    ADD CONSTRAINT fk_modelo_equip_categoria
    FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE equipamento
    ADD CONSTRAINT fk_equipamento_modelo
    FOREIGN KEY (id_modeloE) REFERENCES modelo_equipamento (id_modeloE)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE emprestimo
    ADD CONSTRAINT fk_emprestimo_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente (id_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE emprestimo
    ADD CONSTRAINT fk_emprestimo_funcionario
    FOREIGN KEY (id_funcionario) REFERENCES funcionario (id_pessoa)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE emprestimo
    ADD CONSTRAINT fk_emprestimo_forma_pgmt
    FOREIGN KEY (id_formaPgmt) REFERENCES forma_pagamento (id_formaPgmt)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE item_emprestimo
    ADD CONSTRAINT fk_item_emprestimo_emprestimo
    FOREIGN KEY (id_emprestimo) REFERENCES emprestimo (id_emprestimo)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE item_emprestimo
    ADD CONSTRAINT fk_item_emprestimo_equipamento
    FOREIGN KEY (id_equipamento) REFERENCES equipamento (id_equipamento)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE pagamento
    ADD CONSTRAINT fk_pagamento_emprestimo
    FOREIGN KEY (id_emprestimo) REFERENCES emprestimo (id_emprestimo)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE parcela_pagamento
    ADD CONSTRAINT fk_parcela_pagamento
    FOREIGN KEY (id_pagamento) REFERENCES pagamento (id_pagamento)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- =============================================================================
-- ÍNDICES DE APOIO ÀS CHAVES ESTRANGEIRAS[cite: 1]
-- =============================================================================
CREATE INDEX idx_funcionario_supervisor    ON funcionario (id_supervisor);
CREATE INDEX idx_modelo_equip_categoria    ON modelo_equipamento (id_categoria);
CREATE INDEX idx_equipamento_modelo        ON equipamento (id_modeloE);
CREATE INDEX idx_emprestimo_cliente        ON emprestimo (id_cliente);
CREATE INDEX idx_emprestimo_funcionario    ON emprestimo (id_funcionario);
CREATE INDEX idx_emprestimo_forma_pgmt     ON emprestimo (id_formaPgmt);
CREATE INDEX idx_item_emprestimo_equip     ON item_emprestimo (id_equipamento);
CREATE INDEX idx_pagamento_emprestimo      ON pagamento (id_emprestimo);

-- =============================================================================
-- GATILHOS DE REGRA DE NEGÓCIO[cite: 1]
-- =============================================================================

DELIMITER //

CREATE TRIGGER trg_item_emprestimo_status
AFTER INSERT ON item_emprestimo
FOR EACH ROW
BEGIN
    UPDATE equipamento
       SET status = 'Alugado'
     WHERE id_equipamento = NEW.id_equipamento;
END //

CREATE TRIGGER trg_parcela_valida_vencimento_ins
BEFORE INSERT ON parcela_pagamento
FOR EACH ROW
BEGIN
    DECLARE v_data_emissao DATE;

    SELECT e.data_emissao INTO v_data_emissao
      FROM pagamento p
      JOIN emprestimo e ON e.id_emprestimo = p.id_emprestimo
     WHERE p.id_pagamento = NEW.id_pagamento;

    IF NEW.data_vencimento < v_data_emissao THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'RN19 violada: data_vencimento anterior a data_emissao do emprestimo';
    END IF;
END //

CREATE TRIGGER trg_parcela_valida_vencimento_upd
BEFORE UPDATE ON parcela_pagamento
FOR EACH ROW
BEGIN
    DECLARE v_data_emissao DATE;

    SELECT e.data_emissao INTO v_data_emissao
      FROM pagamento p
      JOIN emprestimo e ON e.id_emprestimo = p.id_emprestimo
     WHERE p.id_pagamento = NEW.id_pagamento;

    IF NEW.data_vencimento < v_data_emissao THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'RN19 violada: data_vencimento anterior a data_emissao do emprestimo';
    END IF;
END //

DELIMITER ;