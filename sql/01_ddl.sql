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
-- 1. PESSOA (superclasse da generalização Pessoa -> Cliente / Funcionario)
-- -----------------------------------------------------------------------------
CREATE TABLE pessoa (
    id_pessoa       INT AUTO_INCREMENT,
    nome            VARCHAR(150)  NOT NULL,                 
    doc_cpf_cnpj    VARCHAR(18)   NOT NULL,                 
    email           VARCHAR(100)  NOT NULL,                 
    telefone        VARCHAR(18)   NULL,                     
    CONSTRAINT pk_pessoa PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_pessoa_documento UNIQUE (doc_cpf_cnpj), 
    CONSTRAINT uq_pessoa_email UNIQUE (email)                    
);

-- -----------------------------------------------------------------------------
-- 2. CLIENTE (subclasse de Pessoa)
-- -----------------------------------------------------------------------------
CREATE TABLE cliente (
    id_pessoa       INT        NOT NULL,
    limite_credito  NUMERIC(10,2) NOT NULL,                      
    CONSTRAINT pk_cliente PRIMARY KEY (id_pessoa),
    CONSTRAINT ck_cliente_limite_credito CHECK (limite_credito >= 0) 
);

-- -----------------------------------------------------------------------------
-- 3. FUNCIONARIO (subclasse de Pessoa, com autorrelacionamento de supervisão)
-- -----------------------------------------------------------------------------
CREATE TABLE funcionario (
    id_pessoa      INT        NOT NULL,
    salario        NUMERIC(10,2) NOT NULL,                       
    cargo          VARCHAR(80)   NOT NULL,
    id_supervisor  INT        NULL,                           
    CONSTRAINT pk_funcionario PRIMARY KEY (id_pessoa),
    CONSTRAINT ck_funcionario_salario CHECK (salario > 0)        
);
-- Especialização de Pessoa. id_supervisor implementa a hierarquia "Supervisiona" (RN05)

-- -----------------------------------------------------------------------------
-- 4. CATEGORIA
-- -----------------------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria    INT AUTO_INCREMENT,
    nome_categoria  VARCHAR(60) NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria)
);

-- -----------------------------------------------------------------------------
-- 5. MODELO_EQUIPAMENTO (catálogo)
-- -----------------------------------------------------------------------------
CREATE TABLE modelo_equipamento (
    id_modeloE           INT AUTO_INCREMENT,
    id_categoria         INT        NOT NULL,                 
    nome                 VARCHAR(60)   NOT NULL,
    marca                VARCHAR(60)   NULL,
    valor_diaria_padrao  NUMERIC(10,2) NOT NULL,                 
    CONSTRAINT pk_modelo_equipamento PRIMARY KEY (id_modeloE),
    CONSTRAINT ck_modelo_equip_valor_diaria CHECK (valor_diaria_padrao > 0) 
);

-- -----------------------------------------------------------------------------
-- 6. EQUIPAMENTO (unidade física)
-- -----------------------------------------------------------------------------
CREATE TABLE equipamento (
    id_equipamento           INT AUTO_INCREMENT,
    id_modeloE               INT      NOT NULL,
    numero_serie             VARCHAR(60) NOT NULL,                
    status                   VARCHAR(20) NOT NULL DEFAULT 'Disponível', 
    CONSTRAINT pk_equipamento PRIMARY KEY (id_equipamento),
    CONSTRAINT uq_equipamento_serie UNIQUE (numero_serie), 
    CONSTRAINT ck_equipamento_status CHECK (status IN ('Disponível', 'Alugado', 'Inativo')) 
);

-- -----------------------------------------------------------------------------
-- 7. FORMA_PAGAMENTO
-- -----------------------------------------------------------------------------
CREATE TABLE forma_pagamento (
    id_formaPgmt   INT AUTO_INCREMENT,
    nome_forma     VARCHAR(30) NOT NULL,
    CONSTRAINT pk_forma_pagamento PRIMARY KEY (id_formaPgmt),
    CONSTRAINT uq_forma_pagamento_descricao UNIQUE (nome_forma),
    CONSTRAINT ck_forma_pagamento_descricao CHECK (
        nome_forma IN ('PIX', 'Cartão de crédito', 'Cartão de débito', 'Dinheiro', 'Boleto')
    )
);

-- -----------------------------------------------------------------------------
-- 8. EMPRESTIMO (entidade transacional central)
-- -----------------------------------------------------------------------------
CREATE TABLE emprestimo (
    id_emprestimo             INT AUTO_INCREMENT,
    id_cliente                INT        NOT NULL,             
    id_funcionario            INT        NOT NULL,             
    data_emissao              DATE          NOT NULL DEFAULT (CURRENT_DATE),
    data_prevista_devolucao   DATE          NOT NULL,
    status_emprestimo         VARCHAR(20)   NOT NULL DEFAULT 'Em Aberto', 
    CONSTRAINT pk_emprestimo PRIMARY KEY (id_emprestimo),
    CONSTRAINT ck_emprestimo_datas CHECK (data_prevista_devolucao >= data_emissao), 
    CONSTRAINT ck_emprestimo_status CHECK (status_emprestimo IN ('Em Aberto', 'Finalizado', 'Cancelado')) 
);

-- -----------------------------------------------------------------------------
-- 9. ITEM_EMPRESTIMO (associativa N:N Emprestimo x Equipamento, com atributo próprio)
-- -----------------------------------------------------------------------------
CREATE TABLE item_emprestimo (
    id_emprestimo          INT        NOT NULL,
    id_equipamento         INT        NOT NULL,
    valor_diaria_aplicado  NUMERIC(10,2) NOT NULL,                
    CONSTRAINT pk_item_emprestimo PRIMARY KEY (id_emprestimo, id_equipamento),
    CONSTRAINT ck_item_emprestimo_valor CHECK (valor_diaria_aplicado > 0)
);

-- -----------------------------------------------------------------------------
-- 10. EMPRESTIMO_FORMA_PAGAMENTO (associativa N:N para múltiplas formas)
-- -----------------------------------------------------------------------------
CREATE TABLE emprestimo_forma_pagamento (
    id_emprestimo  INT           NOT NULL,
    id_formaPgmt   INT           NOT NULL,
    valor_alocado  NUMERIC(10,2) NOT NULL,
    CONSTRAINT pk_emprestimo_forma_pgmt PRIMARY KEY (id_emprestimo, id_formaPgmt),
    CONSTRAINT ck_valor_alocado_pos CHECK (valor_alocado > 0)
);

-- -----------------------------------------------------------------------------
-- 11. PAGAMENTO
-- -----------------------------------------------------------------------------
CREATE TABLE pagamento (
    id_pagamento    INT AUTO_INCREMENT,
    id_emprestimo   INT        NOT NULL,                       
    valor_total     NUMERIC(10,2) NOT NULL,
    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
    CONSTRAINT ck_pagamento_valor CHECK (valor_total > 0),
    CONSTRAINT uq_pagamento_emprestimo UNIQUE (id_emprestimo)
);

-- -----------------------------------------------------------------------------
-- 12. PARCELA_PAGAMENTO (entidade fraca, identificada por dependência)
-- -----------------------------------------------------------------------------
CREATE TABLE parcela_pagamento (
    id_pagamento     INT        NOT NULL,
    num_parcela      SMALLINT      NOT NULL,
    data_vencimento  DATE          NOT NULL,
    valor_parcela    NUMERIC(10,2) NOT NULL,
    CONSTRAINT pk_parcela_pagamento PRIMARY KEY (id_pagamento, num_parcela), 
    CONSTRAINT ck_parcela_num CHECK (num_parcela > 0),
    CONSTRAINT ck_parcela_valor CHECK (valor_parcela > 0)
);

-- =============================================================================
-- CHAVES ESTRANGEIRAS
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

-- -----------------------------------------------------------------------------
-- 13. HISTORICO_STATUS_EQUIPAMENTO (Rastreabilidade de status)
-- -----------------------------------------------------------------------------
CREATE TABLE historico_status_equipamento (
    id_historico_eqp INT AUTO_INCREMENT,
    id_equipamento   INT          NOT NULL,
    data_alteracao   DATE         NOT NULL DEFAULT (CURRENT_DATE),
    status_anterior  VARCHAR(20)  NULL,
    status_novo      VARCHAR(20)  NOT NULL,
    observacao       VARCHAR(255) NULL,
    CONSTRAINT pk_historico_status_eqp PRIMARY KEY (id_historico_eqp),
    CONSTRAINT ck_hist_status_ant CHECK (status_anterior IN ('Disponível', 'Alugado', 'Inativo')),
    CONSTRAINT ck_hist_status_novo CHECK (status_novo IN ('Disponível', 'Alugado', 'Inativo'))
);


ALTER TABLE emprestimo_forma_pagamento
    ADD CONSTRAINT fk_efp_emprestimo
    FOREIGN KEY (id_emprestimo) REFERENCES emprestimo (id_emprestimo)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE emprestimo_forma_pagamento
    ADD CONSTRAINT fk_efp_forma_pgmt
    FOREIGN KEY (id_formaPgmt) REFERENCES forma_pagamento (id_formaPgmt)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE historico_status_equipamento
    ADD CONSTRAINT fk_hist_eqp_equipamento
    FOREIGN KEY (id_equipamento) REFERENCES equipamento (id_equipamento)
    ON DELETE CASCADE ON UPDATE CASCADE;


-- =============================================================================
-- TRIGGERS E REGRAS ATIVAS
-- =============================================================================
DELIMITER $$

-- TRIGGER 1: RN21 - Registrar histórico ao inserir um novo equipamento
CREATE TRIGGER trg_equipamento_after_insert
AFTER INSERT ON equipamento
FOR EACH ROW
BEGIN
    INSERT INTO historico_status_equipamento (id_equipamento, status_anterior, status_novo, observacao)
    VALUES (NEW.id_equipamento, NULL, NEW.status, 'Cadastro inicial de equipamento');
END$$

-- TRIGGER 2: RN21 - Registrar histórico ao alterar o status de um equipamento
CREATE TRIGGER trg_equipamento_after_update
AFTER UPDATE ON equipamento
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO historico_status_equipamento (id_equipamento, status_anterior, status_novo, observacao)
        VALUES (NEW.id_equipamento, OLD.status, NEW.status, 'Atualização de status');
    END IF;
END$$

-- TRIGGER 3: RN14 - Mudar status do equipamento para "Alugado" ao inserir Item de Empréstimo
CREATE TRIGGER trg_item_emprestimo_after_insert
AFTER INSERT ON item_emprestimo
FOR EACH ROW
BEGIN
    UPDATE equipamento
    SET status = 'Alugado'
    WHERE id_equipamento = NEW.id_equipamento;
END$$

DELIMITER ;




-- =============================================================================
-- ÍNDICES (Otimização de Consultas)
-- =============================================================================
-- Índices para buscas textuais frequentes
CREATE INDEX idx_pessoa_nome ON pessoa(nome);
CREATE INDEX idx_modelo_nome ON modelo_equipamento(nome);

-- Índices para agrupamentos e filtros temporais/status
CREATE INDEX idx_emprestimo_datas ON emprestimo(data_emissao, data_prevista_devolucao);
CREATE INDEX idx_emprestimo_status ON emprestimo(status_emprestimo);
CREATE INDEX idx_equipamento_status ON equipamento(status);
CREATE INDEX idx_historico_data ON historico_status_equipamento(data_alteracao);
CREATE INDEX idx_pagamento_valor ON pagamento(valor_total);
