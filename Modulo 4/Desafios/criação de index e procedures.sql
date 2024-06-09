-- INDEX E PROCEDURES
-- DATA ATUALIZAÇÃO: 09/06/24

SELECT * FROM employee;

-- qual o departamento com o maior número de funcionários?
alter table employee add index idx_Dno (Dno); 
SHOW index from employee;

		-- QUERY 

SELECT Dno, COUNT(*) AS Numero_funcionarios
FROM employee
GROUP BY Dno
ORDER BY Numero_funcionarios
LIMIT 1;

		-- PROCEDURE
DELIMITER //
CREATE PROCEDURE N_funcionários()
BEGIN
	SELECT Dno, COUNT(*) AS Numero_funcionarios
	FROM employee
	GROUP BY Dno
	ORDER BY Numero_funcionarios
	LIMIT 1;
END //
DELIMITER ;

CALL N_funcionários();

-- Quais são os departamentos por cidade?
alter table dept_locations add index idx_Dnumber (Dnumber); 
SHOW index from dept_locations;

		-- PROCEDURE 
DELIMITER //
	CREATE PROCEDURE Dept_Cidade()
	BEGIN
		SELECT d.Dnumber, d.Dname, dl.Dlocation 
        FROM dept_locations dl, departament d
        WHERE d.Dnumber=dl.Dnumber;
	END //
DELIMITER ;

CALL Dept_Cidade();


-- Relação de empregados por departamento 
alter table employee add index idx_Name (Fname, Minit, Lname); 
SHOW index from employee;

		-- PROCEDURE
DELIMITER //
CREATE PROCEDURE R_Employee_Dept()
BEGIN 
	SELECT CONCAT(Fname, ' ', Minit,' ', Lname) AS Nome_Funcionario, e.Dno, d.Dname
    FROM employee e, departament d
    WHERE d.Dnumber=e.Dno;
END //
DELIMITER ;

CALL R_Employee_Dept();


