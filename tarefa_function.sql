USE MASTER
GO
DROP DATABASE IF EXISTS tarefa_function
GO
CREATE DATABASE tarefa_function
GO
USE tarefa_function
 
/*
Exercícios UDF:
Fazer em SQL Server:
Criar uma database, criar as tabelas abaixo, definindo o tipo de dados e a relação PK/FK 
e popular com alguma massa de dados de teste (Suficiente para testar UDFs)
1) Funcionário (Código, Nome, Salário)
2) Dependendente (Código_Funcionário, Nome_Dependente, Salário_Dependente)
Código no Github ou Pastebin de uma Function que Retorne uma tabela:
(Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)
Código no Github ou Pastebin de uma Scalar Function que Retorne a soma dos Salários dos dependentes, mais a do funcionário.
*/
 
CREATE TABLE funcionarios(
	codigo	INT			  NOT NULL,
	nome	VARCHAR(100)  NOT NULL,
	salario	DECIMAL(7, 2) NOT NULL
 
	PRIMARY KEY(codigo)
);
GO
 
CREATE TABLE dependentes(
	codigo_funcionario	INT			  NOT NULL,
	nome_dependente		VARCHAR(100)  NOT NULL,
	salario_dependente	DECIMAl(7, 2) NOT NULL,
 
	PRIMARY KEY(codigo_funcionario, nome_dependente),
	FOREIGN KEY(codigo_funcionario) REFERENCES funcionarios(codigo) ON DELETE CASCADE 
);
GO
 
CREATE PROCEDURE sp_inserir_FD
AS
BEGIN
	DECLARE @cont INT = 1
	WHILE @cont < 10
		BEGIN
			INSERT INTO funcionarios(codigo, nome, salario) 
			VALUES (@cont, CONCAT(@cont, 'Funcionario '), @cont * 1200)
 
			INSERT INTO dependentes(codigo_funcionario, nome_dependente, salario_dependente)
			VALUES(@cont, CONCAT(@cont, 'Dependente '), @cont * 900)
			SET @cont = @cont +1
		END
END
GO
 
EXEC sp_inserir_FD
GO
 
SELECT * FROM funcionarios
GO
SELECT * FROM dependentes
GO
 
/*Function que Retorne uma tabela:
(Nome_Funcionário, Nome_Dependente, 
Salário_Funcionário,Salário_Dependente)
 
Scalar Function que Retorne a soma 
dos Salários dos dependentes,mais a do funcionário.
*/
 
CREATE FUNCTION fn_funcionarioDependente ()
	RETURNS @table TABLE(
		nome_funcionario	VARCHAR(100),
		nome_dependente		VARCHAR(100),
		salario_funcionario	DECIMAL(7, 2),
		salario_dependente	DECIMAL(7, 2)
	)
	AS
	BEGIN
		INSERT INTO @table(nome_funcionario, nome_dependente, salario_funcionario, salario_dependente)
			   SELECT nome, nome_dependente, salario, salario_dependente
			   FROM funcionarios, dependentes
 
		RETURN
	END
GO

SELECT * FROM fn_funcionarioDependente()
GO


CREATE FUNCTION fn_somaSalarios (@codigo INT)
RETURNS DECIMAL(7, 2)
AS
BEGIN
	DECLARE @salarioFuncionario DECIMAL(7, 1),
			@salarioDependente DECIMAL(7, 1),
			@soma DECIMAL(7, 1)

	SELECT @salarioFuncionario = salario, 
		   @salarioDependente = salario_dependente
	FROM funcionarios, dependentes
	WHERE codigo = @codigo AND codigo_funcionario = @codigo

	SET @soma = @salarioFuncionario + @salarioDependente

	RETURN @soma
END
GO

SELECT dbo.fn_somaSalarios(1) 