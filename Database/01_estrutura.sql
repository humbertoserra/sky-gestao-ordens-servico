/*===============================================================================
  PROJETO   : SKY — Gestão de Ordens de Serviço.
  ARQUIVO   : 01_estrutura.sql
  ------------------------------------------------------------------------------
  DESCRIÇÃO : Script de criação do banco de dados e da estrutura inicial.
              Compatível com Firebird 2.5, Dialeto SQL 3 e Charset UTF8.

              Deve ser executado pelo utilitário ISQL em uma nova sessão,
              sem banco conectado.

              Antes da execução:
              - Criar a pasta de destino no servidor Firebird.
              - Ajustar o caminho do arquivo .FDB no CREATE DATABASE.
              - Informar as credenciais locais, substituindo SUA_SENHA.
              - Não versionar este arquivo contendo senhas reais.

              Este script deve ser executado uma única vez para criação
              de um novo banco de dados.
              Não executar sobre um SKY.FDB existente.
              Não excluir ou substituir banco existente para reutilizá-lo.

              As chaves primárias utilizam Generators e Triggers para
              compatibilidade com Firebird 2.5.

              Clientes, ordens e itens utilizam o campo ATIVO para exclusão
              lógica, preservando registros e relacionamentos para consulta.

              O cliente ID 1 e reservado: AO CONSUMIDOR.
              A aplicação impede sua alteração e inativação.  
  ------------------------------------------------------------------------------
  CAMADA    : Banco de Dados / Estrutura Inicial
  ------------------------------------------------------------------------------
  CRIADO EM : 09/2026
  ------------------------------------------------------------------------------
  © 2026 Humberto F. Serra
  RESPONSÁVEL TÉCNICO : Humberto F. Serra
===============================================================================*/

SET SQL DIALECT 3;

CREATE DATABASE 'localhost:D:\Desenvolvimento\Projects\Sky\Database\SKY.FDB'
USER 'SYSDBA' PASSWORD 'SUA_SENHA'
PAGE_SIZE 4096
DEFAULT CHARACTER SET UTF8;

CREATE TABLE CLIENTE (
    ID              INTEGER NOT NULL,
    NOME            VARCHAR(120) NOT NULL,
    DOCUMENTO       VARCHAR(20),
    EMAIL           VARCHAR(120),
    TELEFONE        VARCHAR(30),
    DATA_CADASTRO   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ATIVO           SMALLINT DEFAULT 1 NOT NULL,

    CONSTRAINT PK_CLIENTE PRIMARY KEY (ID),
    CONSTRAINT CK_CLIENTE_ATIVO CHECK (ATIVO IN (0, 1))
);

CREATE GENERATOR GEN_CLIENTE_ID;

SET TERM ^ ;

CREATE TRIGGER BI_CLIENTE FOR CLIENTE
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
    IF (NEW.ID IS NULL) THEN
        NEW.ID = GEN_ID(GEN_CLIENTE_ID, 1);
END^

SET TERM ; ^

CREATE TABLE ORDEM_SERVICO (
    ID              INTEGER NOT NULL,
    CLIENTE_ID      INTEGER NOT NULL,
    DATA_ABERTURA   DATE NOT NULL,
    DATA_PREVISTA   DATE NOT NULL,
    DATA_FECHAMENTO DATE,
    STATUS          VARCHAR(15) DEFAULT 'Aberta' NOT NULL,
    DESCRICAO_PROBLEMA VARCHAR(500),
    VALOR_TOTAL     NUMERIC(15,2) DEFAULT 0 NOT NULL,
    ATIVO           SMALLINT DEFAULT 1 NOT NULL,

    CONSTRAINT PK_ORDEM_SERVICO PRIMARY KEY (ID),
    CONSTRAINT FK_ORDEM_SERVICO_CLIENTE FOREIGN KEY (CLIENTE_ID) REFERENCES CLIENTE (ID),
    CONSTRAINT CK_ORDEM_SERVICO_ATIVO CHECK (ATIVO IN (0, 1)),
    CONSTRAINT CK_ORDEM_SERVICO_STATUS CHECK (STATUS IN ('Aberta', 'Em Andamento', 'Concluida', 'Cancelada')),
    CONSTRAINT CK_ORDEM_SERVICO_PREVISAO CHECK (DATA_PREVISTA >= DATA_ABERTURA),
    CONSTRAINT CK_ORDEM_SERVICO_VALOR CHECK (VALOR_TOTAL >= 0)
);

CREATE GENERATOR GEN_ORDEM_SERVICO_ID;

SET TERM ^ ;

CREATE TRIGGER BI_ORDEM_SERVICO FOR ORDEM_SERVICO
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
    IF (NEW.ID IS NULL) THEN
        NEW.ID = GEN_ID(GEN_ORDEM_SERVICO_ID, 1);
END^

SET TERM ; ^

CREATE TABLE ITEM_ORDEM (
    ID              INTEGER NOT NULL,
    ORDEM_ID        INTEGER NOT NULL,
    DESCRICAO       VARCHAR(200) NOT NULL,
    QUANTIDADE      NUMERIC(12,2) NOT NULL,
    VALOR_UNITARIO  NUMERIC(15,2) NOT NULL,
    ATIVO           SMALLINT DEFAULT 1 NOT NULL,

    CONSTRAINT PK_ITEM_ORDEM PRIMARY KEY (ID),
    CONSTRAINT FK_ITEM_ORDEM_OS FOREIGN KEY (ORDEM_ID) REFERENCES ORDEM_SERVICO (ID),
    CONSTRAINT CK_ITEM_ORDEM_QUANTIDADE CHECK (QUANTIDADE > 0),
    CONSTRAINT CK_ITEM_ORDEM_VALOR CHECK (VALOR_UNITARIO >= 0),
    CONSTRAINT CK_ITEM_ORDEM_ATIVO CHECK (ATIVO IN (0, 1))
);

CREATE GENERATOR GEN_ITEM_ORDEM_ID;

SET TERM ^ ;

CREATE TRIGGER BI_ITEM_ORDEM FOR ITEM_ORDEM
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
    IF (NEW.ID IS NULL) THEN
        NEW.ID = GEN_ID(GEN_ITEM_ORDEM_ID, 1);
END^

SET TERM ; ^

CREATE INDEX IDX_OS_STATUS
ON ORDEM_SERVICO (STATUS);

CREATE INDEX IDX_OS_DATA_ABERTURA
ON ORDEM_SERVICO (DATA_ABERTURA);

-- Cadastro inicial do cliente reservado.
INSERT INTO CLIENTE (ID, NOME, ATIVO)
VALUES (1, 'AO CONSUMIDOR', 1);

-- O próximo ID gerado para cliente será 2.
SET GENERATOR GEN_CLIENTE_ID TO 1;

CREATE OR ALTER VIEW VW_OS_RESUMO (
    ID,
    CLIENTE_ID,
    CLIENTE_NOME,
    DATA_ABERTURA,
    DATA_PREVISTA,
    DATA_FECHAMENTO,
    STATUS,
    VALOR_TOTAL,
    EM_ATRASO
)
AS
SELECT
    O.ID,
    O.CLIENTE_ID,
    C.NOME,
    O.DATA_ABERTURA,
    O.DATA_PREVISTA,
    O.DATA_FECHAMENTO,
    O.STATUS,
    O.VALOR_TOTAL,
    CASE
        WHEN O.STATUS NOT IN ('Concluida', 'Cancelada')
         AND O.DATA_PREVISTA IS NOT NULL
         AND CURRENT_DATE > O.DATA_PREVISTA
        THEN 1
        ELSE 0
    END
FROM ORDEM_SERVICO O
INNER JOIN CLIENTE C ON C.ID = O.CLIENTE_ID
WHERE O.ATIVO = 1;

COMMIT;

