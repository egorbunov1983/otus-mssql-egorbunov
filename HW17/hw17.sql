/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".
*/
USE WideWorldImporters;
/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/
/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
Create SCHEMA [HW] AUTHORIZATION [dbo]
GO
IF OBJECT_ID ('HW.GetMaxPrice','IF') is not null
DROP FUNCTION HW.GetMaxPrice
GO

Create Function HW.GetMaxPrice (@In int)
Returns Table
AS 
RETURN 
(
Select TOP(@In) SC.CustomerID, SC.CustomerName, Sum(Quantity*UnitPrice) as Purchase
From Sales.Customers as SC
Join Sales.Invoices as SI ON SC.CustomerID = SI.CustomerID
Join Sales.InvoiceLines as SIL ON SI.InvoiceID = SIL.InvoiceID
Group by SC.CustomerID, SC.CustomerName,SIL.InvoiceID
Order by Purchase desc
);
GO
Select * From HW.GetMaxPrice (1);
/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

IF OBJECT_ID ('HW.Get_Customer','P') is not null
DROP PROCEDURE HW.Get_Customer
GO

Create Procedure HW.Get_Customer
@CustomerID int
AS
IF NOT EXISTS (Select  * From Sales.Customers as SC Where SC.CustomerID = @CustomerID)   
   BEGIN  
       PRINT 'ERROR: This ID does not exist!'  
       RETURN
   END  
ELSE  
   BEGIN  
   Select  SC.CustomerID, SC.CustomerName, Sum(Quantity*UnitPrice) as Purchase
	From Sales.Customers as SC
	Join Sales.Invoices as SI ON SC.CustomerID = SI.CustomerID
	Join Sales.InvoiceLines as SIL ON SI.InvoiceID = SIL.InvoiceID
	Where SC.CustomerID = @CustomerID
	Group by SC.CustomerID, SC.CustomerName     
   END 

Declare @ID int
Set @ID = 3
EXEC HW.Get_Customer @ID ;

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
--Создадим функцию выводящую сумму покупки по клиенту
IF OBJECT_ID ('HW.Get_CustomerFunc','IF') is not null
DROP FUNCTION HW.Get_CustomerFunc
GO
Create Function HW.Get_CustomerFunc (@CustomerID int)
Returns Table
AS 
RETURN 
(
Select  SC.CustomerID, SC.CustomerName, Sum(Quantity*UnitPrice) as Purchase
From Sales.Customers as SC
Join Sales.Invoices as SI ON SC.CustomerID = SI.CustomerID
Join Sales.InvoiceLines as SIL ON SI.InvoiceID = SIL.InvoiceID
Where SC.CustomerID = @CustomerID
Group by SC.CustomerID, SC.CustomerName
);
GO
IF OBJECT_ID ('HW.Get_CustomerSP','P') is not null
DROP PROCEDURE HW.Get_Customer
GO
--Создадим ХП выводящую сумму покупки по клиенту
Create Procedure HW.Get_CustomerSP
@CustomerID int
AS
   Select  SC.CustomerID, SC.CustomerName, Sum(Quantity*UnitPrice) as Purchase
	From Sales.Customers as SC
	Join Sales.Invoices as SI ON SC.CustomerID = SI.CustomerID
	Join Sales.InvoiceLines as SIL ON SI.InvoiceID = SIL.InvoiceID
	Where SC.CustomerID = @CustomerID
	Group by SC.CustomerID, SC.CustomerName     
GO
SET STATISTICS IO, TIME ON
GO
Select * From HW.Get_CustomerFunc (3);

EXEC HW.Get_CustomerSP 3;

-- Особой разницы в производительности не заметил: план дает по 50 % и по времени примерно одинаковые.. 
---------------Для функции-----------------------
/* Время работы SQL Server:
   Время ЦП = 16 мс, затраченное время = 37 мс.
*/
---------------Для ХП-------------------------
/*
   Время работы SQL Server:
   Время ЦП = 16 мс, затраченное время = 41 мс..
   */
/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
IF OBJECT_ID ('HW.Purchase','IF') is not null
DROP FUNCTION HW.Purchase
GO
--Создадим табличную функцию выводящую сумму покупки по клиенту
Create Function HW.Purchase (@CustomerID int)
Returns Table
AS 
RETURN 
(
   Select  Sum(Quantity*UnitPrice) as Purchase
	From Sales.Customers as SC
	Join Sales.Invoices as SI ON SC.CustomerID = SI.CustomerID
	Join Sales.InvoiceLines as SIL ON SI.InvoiceID = SIL.InvoiceID
	Where SC.CustomerID = @CustomerID
	Group by SC.CustomerID  
);
GO
--Каждого CustomerID выведем сумму покупки отдельным столбцом.
Select  *
From Sales.Customers as SC
	Cross Apply HW.Purchase (SC.CustomerID)
/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
