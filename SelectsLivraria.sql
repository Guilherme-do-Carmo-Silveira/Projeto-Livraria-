CREATE DATABASE ex9
GO
USE ex9
GO
CREATE TABLE editora (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
site			VARCHAR(40)		NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
biografia		VARCHAR(100)	NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo			INT				NOT NULL,
nome			VARCHAR(100)	NOT NULL	UNIQUE,
quantidade		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL	CHECK(valor > 0.00),
codEditora		INT				NOT NULL,
codAutor		INT				NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo			INT				NOT NULL,
codEstoque		INT				NOT NULL,
qtdComprada		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL,
dataCompra		DATE			NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civilização Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Marília Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matemática da UFRS e da PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Lingüística Aplicada e Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ciências da Computacão pelo MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos ',4,108.00,1,101),
(10002,'A Arte da Política',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de Física I',26,68.00,4,104),
(10005,'Geometria Analítica',1,95.00,3,105),
(10006,'Gramática Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de Física III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00,'04/07/2021'),
(15051,10008,1,95.00,'04/07/2021'),
(15051,10004,1,68.00,'04/07/2021'),
(15051,10007,1,78.00,'04/07/2021'),
(15052,10006,1,49.00,'05/07/2021'),
(15052,10002,3,165.00,'05/07/2021'),
(15053,10001,1,108.00,'05/07/2021'),
(15054,10003,1,79.00,'06/08/2021'),
(15054,10008,1,95.00,'06/08/2021')

GO
	
/* 1) Consultar nome, valor unitário, nome da editora 
e nome do autor dos livros do estoque que foram vendidos. 
Não podem haver repetições.
*/

SELECT DISTINCT e.nome, e.valor, ed.nome, a.nome  
FROM autor a, estoque e, editora ed, compra c
WHERE a.codigo = e.codAutor
	  AND e.codigo = c.codEstoque
	  AND ed.codigo = e.codEditora

/*
2) Consultar nome do livro, quantidade comprada e valor de compra da compra 15051
*/

SELECT e.nome, c.qtdComprada, c.valor
FROM estoque e, compra c 
WHERE e.codigo = c.codEstoque
	  AND c.codigo = 15051


/*
3) Consultar Nome do livro e site da editora dos livros da Makron books (Caso o site tenha mais de 10 dígitos, remover o www.).	
*/

SELECT e.nome, 
	   CASE WHEN (LEN(ed.site) > 10)
			THEN
					SUBSTRING(ed.site,5, LEN(ed.site))
			ELSE	
					ed.site
			END AS siteEditora
FROM estoque e, editora ed
WHERE ed.codigo = e.codEditora
	  AND ed.nome = 'Makron books'

/*
4) Consultar nome do livro e Breve Biografia do David Halliday
*/

SELECT e.nome, a.biografia
FROM estoque e, autor a
WHERE a.codigo = e.codAutor
	  AND a.nome = 'David Halliday'

/*
5) Consultar código de compra e quantidade comprada do livro Sistemas Operacionais Modernos	
*/

SELECT c.codigo, c.qtdComprada
FROM compra c, estoque e
WHERE e.codigo = c.codEstoque
	  AND e.nome = 'Sistemas Operacionais Modernos'
/*
6) Consultar quais livros não foram vendidos
*/

SELECT e.nome
FROM estoque e LEFT OUTER JOIN compra c ON e.codigo = c.codEstoque
WHERE c.codigo is null


/*
7) Consultar quais livros foram vendidos e não estão cadastrados
*/

SELECT e.nome
FROM estoque e LEFT OUTER JOIN compra c ON e.codigo = c.codEstoque
WHERE e.codigo is null


/*
8) Consultar Nome e site da editora que não tem Livros no estoque (Caso o site tenha mais de 10 dígitos, remover o www.)	
*/

SELECT ed.nome,
	   CASE WHEN (LEN(ed.site) > 10)
			THEN
					SUBSTRING(ed.site,5, LEN(ed.site))
			ELSE	
					ed.site
			END AS siteEditora
FROM editora ed LEFT OUTER JOIN estoque e ON ed.codigo = e.codEditora
WHERE e.nome is null

/*
9) Consultar Nome e biografia do autor que não tem Livros no estoque (Caso a biografia inicie com Doutorado, substituir por Ph.D.)
*/

SELECT a.nome,
	   Case WHEN SUBSTRING(A.biografia,1,9) = 'Doutorado'
			THEN
				'Ph.D. ' + SUBSTRING(a.biografia, 10, LEN(a.biografia))
			ELSE
				A.biografia
			END AS Biografia
FROM autor a LEFT OUTER JOIN estoque e ON a.codigo = e.codAutor
WHERE e.nome IS NULL

/*
10) Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor descendente	
*/

SELECT a.nome,
	   MAX(e.valor) AS MaisCaro
FROM autor a, estoque e
WHERE a.codigo = e.codAutor
GROUP BY a.nome
ORDER BY MaisCaro DESC

/*
11) Consultar o código da compra, o total de livros comprados e a soma dos valores gastos. Ordenar por Código da Compra ascendente.	
*/

SELECT c.codigo, SUM(c.qtdComprada) SomaLivros, SUM(c.valor) AS SomaValores
FROM compra c
GROUP BY c.codigo
ORDER BY c.codigo ASC

/*
12) Consultar o nome da editora e a média de preços dos livros em estoque.Ordenar pela Média de Valores ascendente.	
*/

SELECT ed.nome,
	   CAST(AVG(e.valor) AS decimal(7,2))AS mediaPrecos
FROM editora ed, estoque e
WHERE ed.codigo = e.codEditora
GROUP BY ed.nome
ORDER BY mediaPrecos ASC

/*
13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da editora (Caso o site tenha mais de 10 dígitos, remover o www.), criar uma coluna status onde:	
	Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
	Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
	Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
	A Ordenação deve ser por Quantidade ascendente
*/

SELECT e.nome, e.quantidade, ed.nome,
	   CASE WHEN (LEN(ed.site) > 10)
			THEN
				SUBSTRING(ed.site,5, LEN(ed.site))
			ELSE	
				ed.site
			END AS SiteEditora,
		
		CASE WHEN (e.quantidade < 5)
			THEN
				'produto em ponto de pedido'
			WHEN (e.quantidade > 5 AND e.quantidade < 10)
				THEN
					'Produto Acabando'
				ELSE
					'Estoque Suficiente'
				END AS Status_
FROM estoque e, editora ed 
WHERE ed.codigo = e.codEditora
ORDER BY Status_ ASC

/*
14) Para montar um relatório, é necessário montar uma consulta com a seguinte saída: Código do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site) de todos os livros	
	Só pode concatenar sites que não são nulos
*/

SELECT e.codigo, e.nome, a.nome,
	   CASE WHEN (ed.site is not null) 
			THEN
				ed.nome + ' ' + ed.site
			END AS InfoEditora
FROM estoque e, autor a, editora ed
WHERE a.codigo = e.codAutor
	  AND ed.codigo = e.codEditora

/*
15) Consultar Codigo da compra, quantos dias da compra até hoje e quantos meses da compra até hoje	
*/

SELECT c.codigo,
	   DATEDIFF(DAY, C.dataCompra, GETDATE()) AS TempoDiasCompra,
	   DATEDIFF(MONTH, c.dataCompra, GETDATE()) AS TempoMesesCompra
FROM compra c


/*		
16) Consultar o código da compra e a soma dos valores gastos das compras que somam mais de 200.00	
*/

SELECT c.codigo, SUM(c.valor) AS SomaValores
FROM compra c
GROUP BY c.codigo
HAVING SUM(c.valor) > 200


	
select * from compra
select * from estoque
select * from  autor




