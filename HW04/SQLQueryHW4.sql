/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/
USE WideWorldImporters
Select DISTINCT(PersonID),FullName
From [Application].[People] as People
 JOIN [Sales].[Invoices] as Invoices ON People.PersonID = Invoices.SalespersonPersonID
Where [IsSalesperson] = 1 AND [InvoiceDate] <> '2015-07-04'
 --
SELECT	PersonId, FullName 
FROM Application.People
WHERE IsSalesperson = 1 AND EXISTS (
    SELECT PersonID,FullName
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID
	and InvoiceDate <> '2015-07-04')
/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
--v1
Select Distinct(StockItemID), Description,UnitPrice 
From Sales.OrderLines
Where UnitPrice IN (Select MIN(UnitPrice) From Sales.OrderLines)
--v2
SELECT  top 1
	ord.StockItemID, 
	ord.Description,
	ord.UnitPrice
FROM Sales.OrderLines ord
order by UnitPrice asc
-- CTE 
USE WideWorldImporters
;WITH MinCTE ([StockItemID], [Description],[UnitPrice]) AS 
(
	SELECT Distinct([StockItemID]), [Description],[UnitPrice] 
	FROM [Sales].[OrderLines]
	WHERE [UnitPrice] IN (Select MIN([UnitPrice]) From [Sales].[OrderLines]) 
)
SELECT	[StockItemID], [Description],[UnitPrice] 
FROM MinCTE
/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
USE WideWorldImporters
Select Distinct TOP 5 CstTr.CustomerID,CustomerName, TransactionAmount
From [Sales].[CustomerTransactions] as CstTr
 JOIN Sales.Customers as Cst ON CstTr.CustomerID = Cst.CustomerID
Order by [TransactionAmount] desc
--
Select CstTr.CustomerID,CustomerName, TransactionAmount
From [Sales].[CustomerTransactions] as CstTr
 JOIN [Sales].[Customers] as Cst ON CstTr.CustomerID = Cst.CustomerID
Where TransactionAmount IN (Select TOP 5 TransactionAmount FROM [Sales].[CustomerTransactions] Order BY TransactionAmount desc)
Order by TransactionAmount desc
--CTE
;WITH Max5CTE (CustomerID,TransactionAmount) AS 
(
	SELECT TOP 5 CstTr.CustomerID, TransactionAmount 
	FROM [Sales].[CustomerTransactions] as CstTr
	Order by TransactionAmount desc
)
Select Max5CTE.CustomerID,CustomerName,TransactionAmount
From Max5CTE 
 JOIN [Sales].[Customers] as Cst ON Max5CTE.CustomerID = Cst.CustomerID
/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/
USE WideWorldImporters
GO
SET STATISTICS IO, TIME ON
GO
Select  Distinct CityID,CityName,FullName
From [Application].[Cities] as C
JOIN [Sales].[Customers] as Cst ON C.CityID = Cst.DeliveryCityID
JOIN [Sales].[Orders] as O ON Cst.CustomerID = O.CustomerID
JOIN [Sales].[OrderLines] as OL ON O.OrderID = OL.OrderID
JOIN [Application].[People] as P ON O.PickedByPersonID = P.PersonID
Where UnitPrice IN (Select Distinct TOP 3 UnitPrice
						From [Sales].[OrderLines]
						Order by UnitPrice desc
					)
ORDER BY CityID
--CTE
;WITH MaxPriceCTE(Price) AS 
(
	Select Distinct TOP 3 [UnitPrice]
						From [Sales].[OrderLines]
						Order by [UnitPrice] desc
)
Select  Distinct CityID,CityName, FullName
From [Application].[Cities] as C
JOIN [Sales].[Customers] as Cst ON C.CityID = Cst.DeliveryCityID
JOIN [Sales].[Orders] as O ON Cst.CustomerID = O.CustomerID
JOIN [Sales].[OrderLines] as OL ON O.OrderID = OL.OrderID
JOIN [Application].[People] as P ON O.PickedByPersonID = P.PersonID
Where UnitPrice IN (Select Price From MaxPriceCTE)
-- ---------------------------------------------------------------------------
