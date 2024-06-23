-- DESAFIO TRANSAÇÕES, BACKUP E RECOVERY
-- AUTOR: GRASIELE ALVES       
-- DATA ATUALIZAÇÃO: 23/06/24


USE ecommerce;

-- desativa autocommit 
--
SET @@autocommit = 0;
SELECT @@autocommit;

-- insere novo estoque e dá rollback 
--
START TRANSACTION;
INSERT INTO estoque (Estoque_Local, Estoque_Quantidade) 
VALUES ('Centro Principal',550);
SELECT * FROM estoque;
ROLLBACK;

SELECT * FROM estoque;

-- transação com procedure
--
DELIMITER //
CREATE PROCEDURE insere_dados()
BEGIN 
DECLARE erro TINYINT DEFAULT FALSE;
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET erro = TRUE;

START TRANSACTION;
	INSERT INTO estoque (Estoque_Local, Estoque_Quantidade) 
VALUES ('Centro Principal',550);
	INSERT INTO estoque (Estoque_Local, Estoque_Quantidade) 
VALUES ('Centro de Distribuição Sudeste',350);

	IF erro = FALSE THEN
		COMMIT;
        SELECT 'inserção concluída com sucesso' AS Resultado;
	ELSE
		ROLLBACK;
		SELECT 'Ocorreu um erro na inserção' AS Resultado;
    END IF;

END//
DELIMITER ;

CALL insere_dados;
