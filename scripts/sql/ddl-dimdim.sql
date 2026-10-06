/*
  Projeto DimDim - Web App + Azure SQL
  DDL das tabelas CLIENTES e TRANSACOES (Azure SQL / T-SQL)
  Grupo: Doletas
  Integrantes:
    RM562822 - Matheus Moya de Oliveira
    RM562145 - Ana Carolina Pereira Fontes
    RM563403 - Luisa Ganasevici de Abreu
*/

/* DROPS - a filha (transacoes) antes da mãe (clientes) */
DROP TABLE IF EXISTS transacoes;
DROP TABLE IF EXISTS clientes;

/* DDL */

-- Tabela CLIENTES
CREATE TABLE clientes (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    cpf            VARCHAR(11)  NOT NULL,
    email          VARCHAR(150) NOT NULL,
    telefone       VARCHAR(20),
    data_cadastro  DATETIME2 NOT NULL
                   DEFAULT (SYSDATETIMEOFFSET() AT TIME ZONE 'E. South America Standard Time'),
    CONSTRAINT uk_clientes_cpf   UNIQUE (cpf),
    CONSTRAINT uk_clientes_email UNIQUE (email)
);

-- Tabela TRANSACOES (N transações para 1 cliente)
CREATE TABLE transacoes (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    descricao       VARCHAR(255)  NOT NULL,
    tipo            VARCHAR(20)   NOT NULL,
    valor           DECIMAL(10,2) NOT NULL,
    data_transacao  DATETIME2 NOT NULL
                    DEFAULT (SYSDATETIMEOFFSET() AT TIME ZONE 'E. South America Standard Time'),
    cliente_id      INT NOT NULL,
    CONSTRAINT ck_transacoes_tipo
        CHECK (tipo IN ('DEPOSITO', 'SAQUE', 'PIX', 'TRANSFERENCIA', 'PAGAMENTO')),
    CONSTRAINT ck_transacoes_valor CHECK (valor > 0),
    CONSTRAINT fk_transacoes_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

/* INSERTS - dados fictícios */
INSERT INTO clientes (nome, cpf, email, telefone) VALUES
  ('Ana Souza',    '11122233344', 'ana.souza@dimdim.com',    '11988887777'),
  ('Bruno Lima',   '22233344455', 'bruno.lima@dimdim.com',   '11977776666'),
  ('Carla Mendes', '33344455566', 'carla.mendes@dimdim.com', '11966665555');

INSERT INTO transacoes (descricao, tipo, valor, cliente_id) VALUES
  ('Depósito salário',       'DEPOSITO',  3500.00, 1),
  ('PIX para aluguel',       'PIX',       1200.00, 1),
  ('Pagamento conta de luz', 'PAGAMENTO',  180.50, 2),
  ('Saque caixa eletrônico', 'SAQUE',      300.00, 3);

/* Verificações */
SELECT * FROM clientes;
SELECT * FROM transacoes;

-- Transações com o nome do cliente (mostra o relacionamento funcionando)
SELECT t.id, c.nome AS cliente, t.tipo, t.valor, t.data_transacao
FROM transacoes t
INNER JOIN clientes c ON c.id = t.cliente_id;