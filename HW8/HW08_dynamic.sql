Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/
Declare @CustomerName NVARCHAR(max),
		@command NVARCHAR(4000)

;WITH CTE1 (InvoiceMonth, name,ord) AS 
	(
	Select FORMAT(DATEFROMPARTS(Year(Inv.InvoiceDate),Month(Inv.InvoiceDate),01),'dd.MM.yyyy')
	, Cust.CustomerName 
	, Count(Inv.OrderID) 
	From Sales.Invoices as Inv 
	Join Sales.Customers as Cust ON Inv.CustomerID = Cust.CustomerID
	Where Cust.CustomerID BETWEEN 2 and 6
	Group by Year(Inv.InvoiceDate),Month(Inv.InvoiceDate),Cust.CustomerName
	)
,CTE2 (colname) as
	(
	Select Distinct CTE1.name From CTE1 
	)
Select @CustomerName = ISNULL(@CustomerName + ', ','') + QUOTENAME(colname) FROM CTE2;

SET @command =N'SELECT *
	FROM 
	( 
	SELECT FORMAT(DATEFROMPARTS(Year(Inv.InvoiceDate),Month(Inv.InvoiceDate),01),''dd.MM.yyyy'')as InvoiceMonth 
	, Cust.CustomerName as name
	, Count(Inv.OrderID) as ord
	FROM 
	Sales.Invoices as Inv 
	Join Sales.Customers as Cust ON Inv.CustomerID = Cust.CustomerID
	Where Cust.CustomerID BETWEEN 2 and 6
	Group by Year(Inv.InvoiceDate),Month(Inv.InvoiceDate),Cust.CustomerName) as piv
	PIVOT ( MAX(ord) FOR name IN (' + @CustomerName + ') )as PVT 
	Order by Year(InvoiceMonth),Month(InvoiceMonth)' 
			
SELECT @command;
EXEC sp_executesql @command;

