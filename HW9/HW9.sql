/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
INSERT INTO Sales.Customers (
		[CustomerName]
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]
	  )
Select TOP 5 CAST(CONCAT(CustomerName,CustomerID)  as  nvarchar(100))
      ,[BillToCustomerID]
      ,[CustomerCategoryID]
      ,[BuyingGroupID]
      ,[PrimaryContactPersonID]
      ,[AlternateContactPersonID]
      ,[DeliveryMethodID]
      ,[DeliveryCityID]
      ,[PostalCityID]
      ,[CreditLimit]
      ,[AccountOpenedDate]
      ,[StandardDiscountPercentage]
      ,[IsStatementSent]
      ,[IsOnCreditHold]
      ,[PaymentDays]
      ,[PhoneNumber]
      ,[FaxNumber]
      ,[DeliveryRun]
      ,[RunPosition]
      ,[WebsiteURL]
      ,[DeliveryAddressLine1]
      ,[DeliveryAddressLine2]
      ,[DeliveryPostalCode]
      ,[DeliveryLocation]
      ,[PostalAddressLine1]
      ,[PostalAddressLine2]
      ,[PostalPostalCode]
      ,[LastEditedBy]

From Sales.Customers as C --Where C.CustomerID > 1056 and C.CustomerID <1062;
Select @@ROWCOUNT;
/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/
Delete from Sales.Customers where [CustomerID] = (Select MAX(CustomerID) from Sales.Customers);
Select @@ROWCOUNT;
/*
3. Изменить одну запись, из добавленных через UPDATE
*/
Update Sales.Customers
SET [CustomerName] = CAST(CONCAT(CustomerName,'NEW')  as  nvarchar(100))
Where CustomerID = (Select MAX(CustomerID) from Sales.Customers);
Select @@ROWCOUNT;
/*
4. Написать MERGE, который вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
Declare @var decimal(18, 3); 
Set @var = 99.999;
--Select @var;
Merge Sales.Customers as target
USING (SELECT CAST(CONCAT(CustomerName,'MER_ADD')as  nvarchar(100)) as CustomerName
		 --CustomerName
		,BillToCustomerID, CustomerCategoryID,PrimaryContactPersonID,DeliveryMethodID
		,DeliveryCityID, PostalCityID,AccountOpenedDate,@var as StandardDiscountPercentage--StandardDiscountPercentage
		,IsStatementSent,IsOnCreditHold,PaymentDays,PhoneNumber,FaxNumber,DeliveryRun
      ,RunPosition,WebsiteURL,DeliveryAddressLine1,DeliveryAddressLine2,DeliveryPostalCode
      ,DeliveryLocation,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,LastEditedBy
      ,ValidFrom,ValidTo
From Sales.Customers
		Where CustomerID = (Select MAX(CustomerID) from Sales.Customers)
		) as source
ON (target.CustomerName = source.CustomerName)
When matched
	Then Update set CustomerName  = source.CustomerName,
					BillToCustomerID = source.BillToCustomerID,
					CustomerCategoryID = source.CustomerCategoryID,
					PrimaryContactPersonID = source.PrimaryContactPersonID,
					DeliveryMethodID = source.DeliveryMethodID,
					DeliveryCityID = source.DeliveryCityID,
					PostalCityID = source.PostalCityID,
					AccountOpenedDate = source.AccountOpenedDate,
					StandardDiscountPercentage = source.StandardDiscountPercentage,
					IsStatementSent = source.IsStatementSent,
					IsOnCreditHold = source.IsOnCreditHold,
					PaymentDays = source.PaymentDays,PhoneNumber = source.PhoneNumber,
					FaxNumber = source.FaxNumber,DeliveryRun = source.DeliveryRun,
					RunPosition = source.RunPosition,WebsiteURL = source.WebsiteURL,
					DeliveryAddressLine1 = source.DeliveryAddressLine1, DeliveryAddressLine2 = source.DeliveryAddressLine2,
					DeliveryPostalCode = source.DeliveryPostalCode, DeliveryLocation = source.DeliveryLocation, PostalAddressLine1 = source.PostalAddressLine1,
					PostalAddressLine2 = source.PostalAddressLine2, PostalPostalCode = source.PostalPostalCode, LastEditedBy = source.LastEditedBy
					--,ValidFrom = source.ValidFrom, ValidTo = source.ValidTo
When not matched 
	Then insert (CustomerName,BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID
				,DeliveryMethodID,DeliveryCityID,PostalCityID,AccountOpenedDate,StandardDiscountPercentage
				,IsStatementSent,IsOnCreditHold,PaymentDays,PhoneNumber,FaxNumber,DeliveryRun
				,RunPosition,WebsiteURL,DeliveryAddressLine1,DeliveryAddressLine2,DeliveryPostalCode
				,DeliveryLocation,PostalAddressLine1,PostalAddressLine2,PostalPostalCode,LastEditedBy
				--,ValidFrom,ValidTo
				)
	Values (source.CustomerName, source.BillToCustomerID, source.CustomerCategoryID, source.PrimaryContactPersonID
	, source.DeliveryMethodID, source.DeliveryCityID, source.PostalCityID, source.AccountOpenedDate,source.StandardDiscountPercentage
	,source.IsStatementSent,source.IsOnCreditHold,source.PaymentDays,source.PhoneNumber,source.FaxNumber,source.DeliveryRun
				,source.RunPosition,source.WebsiteURL,source.DeliveryAddressLine1,source.DeliveryAddressLine2,source.DeliveryPostalCode
				,source.DeliveryLocation,source.PostalAddressLine1,source.PostalAddressLine2,source.PostalPostalCode,source.LastEditedBy
				--,source.ValidFrom,source.ValidTo
	)
	Output deleted.*,inserted.*;
	Select * From Sales.Customers Order by CustomerID Desc;
/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/
-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO 
SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.InvoiceLines" out  "D:\SQL\HW10\InvoiceLines.txt" -T -w -t"@eu&$1&" -S VIC-DESKTOP-UTPO3SR\SQL2023'	

drop table if exists [Sales].[InvoiceLines_BulkDemo]

CREATE TABLE [Sales].[InvoiceLines_BulkDemo](
	[InvoiceLineID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Sales_InvoiceLines_BulkDemo] PRIMARY KEY CLUSTERED 
(
	[InvoiceLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [USERDATA]
) ON [USERDATA]
----

	BULK INSERT [WideWorldImporters].[Sales].[InvoiceLines_BulkDemo]
				   FROM "D:\SQL\HW10\InvoiceLines1.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '@eu&$1&',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );

select Count(*) from [Sales].[InvoiceLines_BulkDemo];

TRUNCATE TABLE [Sales].[InvoiceLines_BulkDemo];