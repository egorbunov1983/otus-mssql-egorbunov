/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
USE WideWorldImporters
SET STATISTICS IO, TIME ON
;With cte1 (InvoiceID,CustomerName,InvoiceDate,DayTotal) AS 
(
	Select SI.InvoiceID,CustomerName, InvoiceDate,SUM(SIL.Quantity*SIL.UnitPrice)as DayTotal
	From Sales.Customers as SC
	JOIN Sales.Invoices as SI  ON SC.CustomerID = SI.CustomerID
	JOIN Sales.InvoiceLines as SIL ON SI.InvoiceID = SIL.InvoiceID
	WHERE YEAR (InvoiceDate)>='2015'
	GROUP BY SI.InvoiceID,CustomerName, InvoiceDate
)
, cte2 (M,MonthSum) AS
(	Select  Month(cte1.InvoiceDate) as M, SUM(DayTotal) as MonthSum
	From cte1
	Group By Month(cte1.InvoiceDate)
)
, cte3 (M,MonthSum,MonthTotal) AS
(
	Select T1.M, T1.MonthSum, SUM(T2.MonthSum)  as MonthTotal
	From cte2 as T1
	JOIN cte2 as T2 ON T2.M <= T1.M
	Group by T1.M, T1.MonthSum
)
Select cte1.InvoiceID,cte1.CustomerName,cte1.InvoiceDate,cte1.DayTotal,
cte3.MonthTotal
From cte1 
Left join cte3 ON Month(cte1.InvoiceDate) = cte3.M
order by cte1.InvoiceDate 
/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
Select Distinct SI.InvoiceID,CustomerName, InvoiceDate,
Sum(Quantity*UnitPrice) OVER( Partition by SI.InvoiceID) AS DayTotal,
Sum(Quantity*UnitPrice) OVER( ORDER BY Year(InvoiceDate),Month(InvoiceDate)RANGE BETWEEN unbounded preceding and current row) AS MonthTotal
From Sales.Customers as SC
 JOIN Sales.Invoices as SI  ON SC.CustomerID = SI.CustomerID
 JOIN Sales.InvoiceLines as SIL ON SI.InvoiceID = SIL.InvoiceID
WHERE YEAR (InvoiceDate)>='2015'
ORDER BY InvoiceDate 
/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
;WITH CTE1 (Month, Description,SumQ) AS 
(Select	distinct Month(InvoiceDate) as Month, Description ,
SUM(Quantity) OVER (Partition by Description ORDER BY Month(InvoiceDate) ) as SumQ
From [Sales].[Invoices]  as T1
JOIN [Sales].[InvoiceLines] AS T2 ON T1.[InvoiceID] = T2.[InvoiceID]
WHERE YEAR(T1.InvoiceDate)='2016'
)
,CTE2 (Month, Description,SumQ, Rn) AS
(
Select  CTE1.Month, CTE1.Description,CTE1.SumQ
,ROW_NUMBER() OVER (Partition by CTE1.Month ORDER BY CTE1.Month ) AS Rn
From CTE1
)
Select CTE2.Month, CTE2.Description, CTE2.SumQ--, CTE2.Rn
From CTE2
Where CTE2.Rn<=2 
Order by  Month, SumQ desc
/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт 

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/
Select StockItemID, StockItemName, Brand, UnitPrice,
ROW_NUMBER() OVER (Partition by Left(StockItemName,1) ORDER BY StockItemName ) AS Rn,
Count(*) OVER () as Total,
Count(*) OVER (Order by Left(StockItemName,1)) as TotalLetter,
LEAD(StockItemID) OVER (ORDER BY StockItemName) AS lead_id,
LAG(StockItemID) OVER (ORDER BY StockItemName) AS lag_id,
IIF(LAG(StockItemName,2) OVER (ORDER BY StockItemName) is NULL, 'No items', LAG(StockItemName,2) OVER (ORDER BY StockItemName)) as  lag_str,
NTILE(30) OVER ( ORDER BY TypicalWeightPerUnit) AS GroupNumber
FROM Warehouse.StockItems as T1
Order by StockItemName asc
/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
;WITH CTE1 (SalespersonPersonID, FullName, CustomerID, CustomerName, TransactionDate, TransactionAmount,LastSale) AS
(
SELECT *
FROM 
	(
	SELECT Invoices.SalespersonPersonID, people.FullName, cust.CustomerID, cust.CustomerName,  trans.TransactionDate, trans.TransactionAmount,
		ROW_NUMBER() OVER (PARTITION BY Invoices.SalespersonPersonID ORDER BY trans.TransactionDate DESC) AS LastSale
	FROM Sales.Invoices as Invoices
	JOIN Sales.CustomerTransactions as trans ON Invoices.InvoiceID = trans.InvoiceID AND Invoices.CustomerID = trans.CustomerID
	JOIN Sales.Customers as cust ON trans.CustomerID = cust.CustomerID
	JOIN Application.People as people ON Invoices.SalespersonPersonID = people.PersonID
	) AS tbl
WHERE LastSale = 1
)
Select SalespersonPersonID, FullName, CustomerID, CustomerName, TransactionDate, TransactionAmount
From CTE1
Order by SalespersonPersonID
/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
;WITH CTE1 (CustomerID,CustomerName,StockItemID, Description,UnitPrice) AS
(
Select  Distinct cust.CustomerID,cust.CustomerName,InvLines.StockItemID, InvLines.Description,InvLines.UnitPrice
From Sales.Invoices as Invoices
	JOIN Sales.InvoiceLines as InvLines ON Invoices.InvoiceID = InvLines.InvoiceID
	JOIN Sales.CustomerTransactions as trans ON Invoices.InvoiceID = trans.InvoiceID AND Invoices.CustomerID = trans.CustomerID
	JOIN Sales.Customers as cust ON trans.CustomerID = cust.CustomerID
)
,CTE2 (CustomerID,CustomerName,StockItemID, Description,UnitPrice,Rn) AS
	(
	SELECT CTE1.CustomerID,CTE1.CustomerName,CTE1.StockItemID,CTE1.Description ,CTE1.UnitPrice,
		ROW_NUMBER() OVER (PARTITION BY CTE1.CustomerID ORDER BY CTE1.UnitPrice DESC) AS Rn
	FROM CTE1
	)
,CTE3 (CustomerID,CustomerName,StockItemID,Description,UnitPrice) AS (
SELECT CTE2.CustomerID,CTE2.CustomerName,CTE2.StockItemID, CTE2.Description,CTE2.UnitPrice
From CTE2 
WHERE CTE2.Rn <= 2
)
Select  cust.CustomerID,cust.CustomerName,InvLines.StockItemID, InvLines.Description,InvLines.UnitPrice, Invoices.InvoiceDate
From Sales.Invoices as Invoices
	JOIN Sales.InvoiceLines as InvLines ON Invoices.InvoiceID = InvLines.InvoiceID
	JOIN Sales.CustomerTransactions as trans ON Invoices.InvoiceID = trans.InvoiceID AND Invoices.CustomerID = trans.CustomerID
	JOIN Sales.Customers as cust ON trans.CustomerID = cust.CustomerID
	JOIN CTE3 ON cust.CustomerID = CTE3.CustomerID and InvLines.StockItemID = CTE3.StockItemID and 
	InvLines.Description = CTE3.Description and  InvLines.UnitPrice = CTE3.UnitPrice
Order by cust.CustomerID
