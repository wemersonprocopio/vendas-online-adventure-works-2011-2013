-- =====================================================================
-- Projeto: Vendas Online da Adventure Works Cycles (2011 a 2013)
-- Banco:   AdventureWorksDW2014 (SQL Server)
-- View:    dbo.vendas_online_da_adventure_works_cycles_2011_2013
-- =====================================================================


-- 1. Indicadores do projeto
--
-- Página Análise
--   i)    Receita Total
--   ii)   Quantidade Vendida
--   iii)  Total de Categorias de Produtos
--   iv)   Quantidade de Clientes
--   v)    Receita Total e Lucro Total por Mês
--   vi)   Margem de Lucro
--   vii)  Quantidade Vendida por Mês
--   viii) Lucro por País
--
-- Página Clientes
--   i)    Vendas por País
--   ii)   Clientes por País
--   iii)  Vendas por Gênero
--   iv)   Vendas por Categoria


-- 2. Tabelas e colunas usadas
--
-- SalesOrderNumber                (FactInternetSales)
-- OrderDate                       (FactInternetSales)
-- EnglishProductCategoryName      (DimProductCategory)  *
-- CustomerKey                     (FactInternetSales)
-- FirstName + ' ' + LastName      (DimCustomer)
-- Gender                          (DimCustomer)
-- EnglishCountryRegionName        (DimGeography)        **
-- OrderQuantity                   (FactInternetSales)
-- SalesAmount                     (FactInternetSales)
-- TotalProductCost                (FactInternetSales)
-- SalesAmount - TotalProductCost  (FactInternetSales)
--
-- *  relacionamento em cadeia: FactInternetSales > DimProduct
--    > DimProductSubcategory > DimProductCategory
-- ** país do cliente: DimCustomer > DimGeography
--
-- Categorias e países traduzidos para português na própria view (CASE).
--
-- Período: 01/01/2011 a 31/12/2013 (três anos completos).
-- A FactInternetSales vai de 29/12/2010 a 28/01/2014; as pontas
-- incompletas ficam de fora para que a comparação entre anos seja justa.


-- 3. Criando a view

USE AdventureWorksDW2014;
GO

CREATE OR ALTER VIEW dbo.vendas_online_da_adventure_works_cycles_2011_2013 AS
SELECT
    fis.SalesOrderNumber                    AS [Nº PEDIDO],
    fis.OrderDate                           AS [DATA PEDIDO],
    CASE dpc.EnglishProductCategoryName
        WHEN 'Bikes'       THEN N'Bicicletas'
        WHEN 'Accessories' THEN N'Acessórios'
        WHEN 'Clothing'    THEN N'Roupas'
        ELSE dpc.EnglishProductCategoryName
    END                                     AS [CATEGORIA PRODUTO],
    fis.CustomerKey                         AS [ID CLIENTE],
    dc.FirstName + ' ' + dc.LastName        AS [NOME CLIENTE],
    CASE dc.Gender
        WHEN 'M' THEN 'Masculino'
        WHEN 'F' THEN 'Feminino'
        ELSE N'Não informado'
    END                                     AS [SEXO],
    CASE dg.EnglishCountryRegionName
        WHEN 'United States'  THEN N'Estados Unidos'
        WHEN 'Australia'      THEN N'Austrália'
        WHEN 'United Kingdom' THEN N'Reino Unido'
        WHEN 'Germany'        THEN N'Alemanha'
        WHEN 'France'         THEN N'França'
        WHEN 'Canada'         THEN N'Canadá'
        ELSE dg.EnglishCountryRegionName
    END                                     AS [PAÍS],
    fis.OrderQuantity                       AS [QTD. VENDIDA],
    fis.SalesAmount                         AS [RECEITA VENDA],
    fis.TotalProductCost                    AS [CUSTO VENDA],
    fis.SalesAmount - fis.TotalProductCost  AS [LUCRO VENDA]
FROM dbo.FactInternetSales AS fis
INNER JOIN dbo.DimProduct AS dp
    ON fis.ProductKey = dp.ProductKey
INNER JOIN dbo.DimProductSubcategory AS dps
    ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory AS dpc
    ON dps.ProductCategoryKey = dpc.ProductCategoryKey
INNER JOIN dbo.DimCustomer AS dc
    ON fis.CustomerKey = dc.CustomerKey
INNER JOIN dbo.DimGeography AS dg
    ON dc.GeographyKey = dg.GeographyKey
WHERE fis.OrderDate >= '2011-01-01'
  AND fis.OrderDate <  '2014-01-01';
GO


-- 4. Conferência
-- Esperado: 58.414 linhas e receita de 29.269.561,46

SELECT
    COUNT(*)              AS linhas,
    MIN([DATA PEDIDO])    AS primeira_venda,
    MAX([DATA PEDIDO])    AS ultima_venda,
    SUM([RECEITA VENDA])  AS receita,
    SUM([LUCRO VENDA])    AS lucro
FROM dbo.vendas_online_da_adventure_works_cycles_2011_2013;

-- Por ano
SELECT
    YEAR([DATA PEDIDO])   AS ano,
    COUNT(*)              AS linhas,
    SUM([RECEITA VENDA])  AS receita
FROM dbo.vendas_online_da_adventure_works_cycles_2011_2013
GROUP BY YEAR([DATA PEDIDO])
ORDER BY ano;
