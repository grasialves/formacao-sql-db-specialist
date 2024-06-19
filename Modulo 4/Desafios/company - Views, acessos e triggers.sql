-- Views, acessos e triggers
-- Data de atualização: 16/06

USE company_constraints;

SHOW TABLES;
select * from departament;
select * from employee;
select * from works_on;
select * from project;

-- ------- VIEWS --------
	-- Número de empregados por departamento e localidade 

CREATE VIEW N_empregados_dept_local AS
SELECT COUNT(*) AS Numero_funcionarios, d.Dname, dl.Dlocation
FROM employee e
JOIN
departament d ON d.Dnumber=e.Dno
JOIN 
dept_locations dl ON e.Dno=dl.Dnumber
GROUP BY d.Dname, dl.Dlocation
ORDER BY Numero_funcionarios;


	-- Lista de departamentos e seus gerentes 

CREATE VIEW gerente_dept AS
SELECT d.Dname AS departamento, CONCAT(e.Fname,' ',e.Minit,' ',e.Lname) AS gerente
FROM departament d
JOIN
employee e ON d.Mgr_ssn=e.Ssn
GROUP BY d.Dname, gerente;


	-- Projetos com maior número de empregados (ex: por ordenação desc) 
    
CREATE VIEW N_empregados_projetos AS
SELECT p.Pname AS projeto, COUNT(*) AS n_empregados
FROM project p
JOIN
works_on w ON w.Pno=p.Pnumber 
JOIN
employee e ON w.Essn=e.Ssn
GROUP BY p.Pname
ORDER BY n_empregados desc;


	-- Lista de projetos, departamentos e gerentes 
CREATE VIEW project_dept_empregado AS    
SELECT p.Pname AS projeto, d.Dname AS departamento, CONCAT(e.Fname,' ',e.Minit,' ',e.Lname) AS gerente
FROM project p
JOIN
departament d ON d.Dnumber=p.Dnum 
JOIN
employee e ON d.Mgr_ssn=e.Ssn;


	-- Quais empregados possuem dependentes e se são gerentes 
    
 CREATE VIEW gerentes_dependentes AS
 SELECT CONCAT(e.Fname,' ',e.Minit,' ',e.Lname) AS gerente, d.Dname AS departamento, Dependent_name AS dependente
 FROM departament d
 JOIN 
 employee e ON d.Mgr_ssn=e.Ssn
 JOIN 
 dependent dpt ON dpt.Essn=e.Ssn;
 
 
 -- ------- USUÁRIOS --------
CREATE USER 'employee departamento'@'host' IDENTIFIED BY 'gerente123';
CREATE USER 'employee'@'host' IDENTIFIED BY 'employee';


-- -------- PERMISSÕES -----
GRANT SELECT ON company_constraints.N_empregados_dept_local
TO 'employee departamento'@'host';

GRANT SELECT ON company_constraints.gerente_dept
TO 'employee departamento'@'host';

GRANT SELECT ON company_constraints.N_empregados_projetos
TO 'employee departamento'@'host';

GRANT SELECT ON company_constraints.project_dept_empregado
TO 'employee departamento'@'host';

GRANT SELECT ON gerentes_dependentes
TO 'employee'@'host';


-- ------- TRIGGERS -------

	-- Guarda as informações dos usuários excluídos em uma tabela

CREATE TABLE employee_delete(
	nome_completo VARCHAR(70),
    Ssn char(9), 
    Bdate date,
    Address varchar(30),
    Sex char(1),
    Salary FLOAT,
    Super_ssn char(9),
    data_exclusão DATE,
    usuario VARCHAR(70)
);

DELIMITER //
CREATE TRIGGER registra_exclusoes
BEFORE DELETE ON employee
FOR EACH ROW

BEGIN
	INSERT INTO employee_delete (
    nome_completo,
    Ssn, 
    Bdate,
    Address,
    Sex,
    Salary,
    Super_ssn,
    data_exclusão,
    usuario)
    
    VALUES (
    CONCAT(OLD.Fname,' ', OLD.Minit,' ', OLD.Lname),
    OLD.Ssn,
	OLD.Bdate,
    OLD.Address,
    OLD.Sex,
    OLD.Salary,
    OLD.Super_ssn,
    current_timestamp(),
    current_user());
END //

DELIMITER ;
    

DELETE FROM employee WHERE Ssn='123456789';

SELECT * FROM employee_delete;


-- Inserção de novos colaboradores e atualização do salário base. 

DELIMITER //

CREATE TRIGGER before_salary_update
BEFORE UPDATE ON employee
FOR EACH ROW
BEGIN
    -- Verifica se o departamento é 'Sales' e se o salário está sendo atualizado
    IF NEW.Dno = 1 AND NEW.salary <> OLD.salary THEN
        -- Aumenta o salário em 10%
        SET NEW.salary = NEW.salary * 1.20;
    END IF;
END //

DELIMITER ;
