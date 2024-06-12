-- VIEWS, ACESSOS E TRIGGER
-- DATA DE ATUALIZAÇÃO: 10/06/24

-- VIEWS
		-- Retorna o status do pedido de acordo com a sua data de criação. Um pedido maior que 36 dias que não foi atendido é expirado.
CREATE VIEW Pedidos_nao_atendidos as        
SELECT IdPedido, CONCAT(C.PNome, ' ', C.MNome, ' ', C.UNome) AS Nome_do_Emissor, Data_Criação,
       DATEDIFF(CURDATE(), Data_Criação) AS Dias_Desde_Criação,
       CASE 
           WHEN DATEDIFF(CURDATE(), Data_Criação) > 36 THEN 'Expirado'
           ELSE 'Aguardando Processamento'
       END AS Status
FROM Pedido, Cliente C
WHERE IdCliente=Pedido_IdCliente
ORDER BY CONCAT(C.PNome, ' ', C.MNome, ' ', C.UNome);

SELECT * FROM Pedidos_nao_atendidos;


		-- Consultar o status de cada pedido e o nome do cliente
CREATE VIEW Pedido_Status AS 
SELECT DISTINCT P.IdPedido, P.Pedido_IdCliente AS IdCliente, CONCAT(C.PNome, ' ', C.MNome, ' ', C.UNome) AS Nome_do_Emissor, P.Pedido_Status
FROM Pedido P
INNER JOIN Cliente C ON P.Pedido_IdCliente = C.IdCliente;

SELECT * FROM Pedido_Status;


		-- Retorna apenas os pedidos expirados
CREATE VIEW Pedidos_expirados as  
SELECT 
    C.IdCliente, 
    CONCAT(C.PNome, ' ', C.MNome, ' ', C.UNome) AS Nome_do_Cliente,
    P.IdPedido,
    P.Data_criação,
    DATEDIFF(CURDATE(), P.Data_criação) AS DiasDesde,
    CASE 
        WHEN DATEDIFF(CURDATE(), P.Data_criação) > 36 THEN 'Expirado'
        ELSE 'Aguardando Processamento'
    END AS Status
FROM 
    Pedido P
JOIN 
    Cliente C ON P.Pedido_IdCliente = C.IdCliente
GROUP BY 
    C.IdCliente, P.IdPedido
HAVING 
    DiasDesde > 36;
    
SELECT * FROM Pedidos_expirados;

-- ----------------------------------------------------------------------
-- USUÁRIOS

CREATE USER 'gerente logística'@'host' IDENTIFIED BY 'adminlog';
CREATE USER 'gerente comercial'@'host' IDENTIFIED BY 'admincom';
CREATE USER 'analista comercial'@'host' IDENTIFIED BY 'admincom2';

-- PERMISSÕES

GRANT SELECT ON ecommerce.Pedido_Status TO 'gerente logística'@'host';
GRANT SELECT ON ecommerce.Pedidos_expirados TO 'gerente comercial'@'host';
GRANT SELECT ON ecommerce.Pedidos_nao_atendidos TO 'gerente comercial'@'host', 'analista comercial'@'host';

-- TRIGGERS

		-- Criação de uma trigger que registra clientes excluídos, bem como a data da exclusão e o usuário que deletou

CREATE TABLE clientes_anteriores (
		IdCliente INT auto_increment PRIMARY KEY,
        Pnome VARCHAR(45) NOT NULL,
        Mnome VARCHAR(3),
        Unome VARCHAR(15) NOT NULL,
        CPF CHAR(11) NOT NULL,
        Rua VARCHAR(45) NOT NULL,
        Cidade VARCHAR(15) NOT NULL,
        UF CHAR(2) NOT NULL,
        Data_nascimento DATE,
        Data_da_exclusao DATE,
        Usuario VARCHAR(50),
        CONSTRAINT Cliente_CPF_UN UNIQUE(CPF)
        );

DELIMITER //
CREATE trigger clientes_excluidos
BEFORE DELETE ON Cliente
FOR EACH ROW
	BEGIN
		INSERT INTO clientes_anteriores (Pnome, Mnome, Unome, CPF, Rua, Cidade, UF, Data_nascimento, Data_da_exclusao, Usuario)
        VALUES (OLD.Pnome, OLD.Mnome, OLD.Unome, OLD.CPF, OLD.Rua, OLD.Cidade, OLD.UF, OLD.Data_nascimento, current_timestamp(), current_user());
	END //
DELIMITER ;

DELETE FROM Cliente WHERE IdCliente=1;

select * from clientes_anteriores;


		-- Criação de uma trigger que calcula o orçamento do cliente

    CREATE table orcamento (
    Cliente VARCHAR(60),
    IdCliente INT,
    Valor_unidade FLOAT,
    Quantidade INT,
    Valor_pedido FLOAT,
    Valor_frete FLOAT,
    Valor_Total FLOAT)


DELIMITER //
CREATE TRIGGER Calcula_orcamento 
BEFORE INSERT ON Pedido 
FOR EACH ROW
BEGIN 
    DECLARE Cliente_var VARCHAR(255); -- Ajuste o tamanho conforme necessário
    
    -- Consulta para buscar o nome concatenado do cliente através do id 
    SELECT CONCAT(Pnome,' ',Mnome,' ',Unome) INTO Cliente_var FROM Cliente WHERE IdCliente = NEW.Pedido_IdCliente;
    
    -- Inserção na tabela orcamento
    INSERT INTO orcamento (Cliente, IdCliente, Valor_unidade, Quantidade, Valor_pedido, Valor_frete, Valor_Total)
    VALUES (Cliente_var, NEW.Pedido_IdCliente, NEW.Valor_unidade, NEW.Quantidade, NEW.Quantidade * NEW.Valor_unidade, NEW.Quantidade * NEW.Valor_unidade * 0.05, NEW.Quantidade * NEW.Valor_unidade + NEW.Quantidade * NEW.Valor_unidade * 0.05);
END //
DELIMITER ;

-- insere dados para teste
INSERT INTO Pedido (Pedido_IdCliente, Valor_unidade, Quantidade, IdPagamento, Descrição, Data_criação, Pedido_Status, Frete) 
VALUES (2, 40.50, 10, 1001, 'Compra de maçãs', '2024-05-01', 'Em processamento', 5.00);


select * from orcamento
  