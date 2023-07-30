USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.
Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.
Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT| Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2       |     2
01.02.2013   |      7             |        3           |      4      |      2       |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
WITH CTE1 AS 
(
  Select FORMAT(DATEFROMPARTS(Year(Inv.InvoiceDate),Month(Inv.InvoiceDate),01),'dd.MM.yyyy')as InvoiceMonth
 , Substring(Cust.CustomerName,(Charindex('(',Cust.CustomerName)+1),(Charindex(')',Cust.CustomerName) -(Charindex('(',Cust.CustomerName)+1) ) ) as name
 , Count(Inv.OrderID) as ord
 From Sales.Invoices as Inv 
 Join Sales.Customers as Cust ON Inv.CustomerID = Cust.CustomerID
 Where Cust.CustomerID BETWEEN 2 and 6
 Group by Year(Inv.InvoiceDate),Month(Inv.InvoiceDate),Cust.CustomerName
)
SELECT *
FROM 
	CTE1
 PIVOT (
 MAX(ord)
 FOR name IN ([Peeples Valley, AZ],[Medicine Lodge, KS],[Gasport, NY],[Sylvanite, MT], [Jessie, ND])
)as PVT
Order by Year(InvoiceMonth),  Month(InvoiceMonth)
/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.
Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
Select CustomerName,AddressLine
FROM(
SELECT  CustomerName 
		,DeliveryAddressLine1 
		,DeliveryAddressLine2 
  FROM Sales.Customers 
  where CustomerName LIKE 'Tailspin Toys%' 
) as C
UNPIVOT(AddressLine FOR CustomerName1 IN(DeliveryAddressLine1
                                        ,DeliveryAddressLine2
										)) AS upvt
/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.
Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/
Select CountryId,CountryName,Code
FROM(
SELECT CountryID 
      ,CountryName 
      ,IsoAlpha3Code 
	  ,CAST(IsoNumericCode as nvarchar (3))as IsoNumericCode
  FROM Application.Countries  
) as C
UNPIVOT(Code FOR CountryName1 IN(IsoAlpha3Code
                                 ,IsoNumericCode)
		) AS upvt

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
;WITH CTE1 (CustomerID,CustomerName,StockItemID, Description,UnitPrice,InvoiceDate,DenseRnk) AS
(
Select  cust.CustomerID,cust.CustomerName,InvLines.StockItemID, InvLines.Description,InvLines.UnitPrice, Invoices.InvoiceDate,
DENSE_RANK() OVER (PARTITION BY cust.CustomerName ORDER BY InvLines.UnitPrice desc) AS DenseRnk
From Sales.Invoices as Invoices
	JOIN Sales.InvoiceLines as InvLines ON Invoices.InvoiceID = InvLines.InvoiceID
	JOIN Sales.CustomerTransactions as trans ON Invoices.InvoiceID = trans.InvoiceID AND Invoices.CustomerID = trans.CustomerID
	JOIN Sales.Customers as cust ON trans.CustomerID = cust.CustomerID
)
,CTE2 AS
(
SELECT C.CustomerID, O.*
FROM Sales.Customers C
CROSS APPLY (SELECT O.CustomerName,O.StockItemID, O.Description,O.UnitPrice,O.InvoiceDate,O.DenseRnk
                FROM CTE1 O
                WHERE O.CustomerID = C.CustomerID and O.DenseRnk IN (1,2)	
				) AS O
)
SELECT CTE2.CustomerID,CTE2.CustomerName,MAX(CTE2.StockItemID) as StockItemID,MAX(CTE2.Description) as Description,CTE2.UnitPrice,MAX(CTE2.InvoiceDate) as InvoiceDate
From CTE2 
Group by CTE2.CustomerID,CTE2.CustomerName,CTE2.UnitPrice, CTE2.DenseRnk
Order by CustomerID,UnitPrice desc




