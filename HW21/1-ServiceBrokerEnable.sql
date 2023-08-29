ALTER TABLE Sales.Invoices
ADD InvoiceConfirmedForProcessing DATETIME;


USE master
go
ALTER DATABASE WideWorldImporters SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; --NO WAIT --prod
go
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;
go
ALTER AUTHORIZATION ON DATABASE::WideWorldImporters TO [sa];
go

--An exception occurred while enqueueing a message in the target queue. Error: 33009, State: 2. 
--The database owner SID recorded in the master database differs from the database owner SID recorded in database 'WideWorldImporters'. 
--You should correct this situation by resetting the owner of database 'WideWorldImporters' using the ALTER AUTHORIZATION statement.
--Create Message Types for Request and Reply messages
USE WideWorldImporters
-- For Request--Создаем тип сообщения для отправки--------
CREATE MESSAGE TYPE [//WWI/SB/RequestMessage] VALIDATION=WELL_FORMED_XML;
-- For Reply --Создаем тип сообщения для ответа--------
CREATE MESSAGE TYPE [//WWI/SB/ReplyMessage] VALIDATION=WELL_FORMED_XML; 
GO
---Создаем контракт------------------
CREATE CONTRACT [//WWI/SB/Contract] 
	([//WWI/SB/RequestMessage]  SENT BY INITIATOR,
	[//WWI/SB/ReplyMessage]     SENT BY TARGET
    );
GO
--Содаем очередь----------
CREATE QUEUE TargetQueueWWI;
GO

CREATE SERVICE [//WWI/SB/TargetService]  ON QUEUE TargetQueueWWI ([//WWI/SB/Contract]);
GO

CREATE QUEUE InitiatorQueueWWI;
GO
CREATE SERVICE [//WWI/SB/InitiatorService] ON QUEUE InitiatorQueueWWI ([//WWI/SB/Contract]);
GO
----Создадим новую таблицу для отчетов---------
Create Table HW.Reports(
CustomerID int,
Orders int,
StartReport date,
EndReport date
);

































Create Procedure HW.Get_Customer
@CustomerID int
AS
IF NOT EXISTS (Select  * From Sales.Customers as SC Where SC.CustomerID = @CustomerID)   
   BEGIN  
       --PRINT 'ERROR: This ID does not exist!' 
	   --RAISERROR ( 'ERROR: This ID does not exist',1,1) 
	   RAISERROR (15600,-1,10, 'HW.Get_Customer')--  15600 Код ошибки; 
												-- - 1 severity Уровень серьезности читать документацию; 
												-- 10- статус (Целое число от 0 до 255)
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