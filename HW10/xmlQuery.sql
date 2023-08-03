/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/
--OPENXML:
DECLARE @xmlDocument XML;
-- Считываем XML-файл в переменную
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'D:\SQL\HW7\StockItems-188-1fb5df.xml', 
 SINGLE_CLOB)
AS data;
-- Проверяем, что в @xmlDocument
SELECT @xmlDocument AS [@xmlDocument];
DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;
	--Создадим таблицу
	DROP TABLE IF EXISTS #StockItems;
	CREATE TABLE #StockItems(
	[StockItemName] [nvarchar](100) ,
	[SupplierID] [int] NOT NULL,
	[UnitPackageID] [int] NOT NULL,
	[OuterPackageID] [int] NOT NULL,
	[QuantityPerOuter] [int] NOT NULL,
	[IsChillerStock] [bit] DEFAULT 0,
	[LastEditedBy] [int] DEFAULT 1,
	[LeadTimeDays] [int] NOT NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[TypicalWeightPerUnit] [decimal](18, 3) NOT NULL
);
--вставить результат в temp таблицу
INSERT INTO #StockItems ([StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[QuantityPerOuter],[TypicalWeightPerUnit],[LeadTimeDays],[IsChillerStock],[TaxRate],[UnitPrice])
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName] NVARCHAR(100)  '@Name',
	[SupplierID] INT 'SupplierID',
	[UnitPackageID] INT 'Package/UnitPackageID',
	[OuterPackageID] INT 'Package/OuterPackageID',
	[QuantityPerOuter] INT 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] NUMERIC(18,3) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] INT 'LeadTimeDays',
	[IsChillerStock] bit 'IsChillerStock',
	[TaxRate] NUMERIC(18,3) 'TaxRate',
	[UnitPrice] NUMERIC(18,2) 'UnitPrice'
	);
	Select * from #StockItems
	-- Надо удалить handle
EXEC sp_xml_removedocument @docHandle;

Update Warehouse.StockItems
SET [StockItemName] = S.[StockItemName],
[SupplierID] = S.[SupplierID],
[UnitPackageID] =  S.[UnitPackageID],
[OuterPackageID] = S.[OuterPackageID],
[QuantityPerOuter] = S.[QuantityPerOuter],
[TypicalWeightPerUnit] = S.[TypicalWeightPerUnit],
[LeadTimeDays] = S.[LeadTimeDays], 
[IsChillerStock] = S.[IsChillerStock],
[TaxRate] = S.[TaxRate],
[UnitPrice] = S.[UnitPrice]
From Warehouse.StockItems 
JOIN #StockItems as S ON Warehouse.StockItems.StockItemName = S.StockItemName COLLATE DATABASE_DEFAULT;

Insert into Warehouse.StockItems([StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[QuantityPerOuter],[IsChillerStock],[TypicalWeightPerUnit],[LeadTimeDays],[TaxRate],[UnitPrice],[LastEditedBy]) 
Select S.StockItemName,S.SupplierID, S.UnitPackageID,S.OuterPackageID,S.QuantityPerOuter,S.IsChillerStock,S.TypicalWeightPerUnit,S.LeadTimeDays,S.TaxRate,S.UnitPrice,S.LastEditedBy
From #StockItems as S
WHERE  NOT EXISTS (Select * From Warehouse.StockItems 
WHERE S.StockItemName = Warehouse.StockItems.StockItemName COLLATE DATABASE_DEFAULT);

DROP TABLE IF EXISTS #StockItems;
GO
-- XQUERY
	Drop table if exists #StockItems;
GO
	--Создадим таблицу
	DROP TABLE IF EXISTS #StockItems;
	CREATE TABLE #StockItems(
	[StockItemName] [nvarchar](100) ,
	[SupplierID] [int] NOT NULL,
	[UnitPackageID] [int] NOT NULL,
	[OuterPackageID] [int] NOT NULL,
	[QuantityPerOuter] [int] NOT NULL,
	[IsChillerStock] [bit] DEFAULT 0,
	[LastEditedBy] [int] DEFAULT 1,
	[LeadTimeDays] [int] NOT NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[TypicalWeightPerUnit] [decimal](18, 3) NOT NULL
);

DECLARE @xmlDocument XML;
Set @xmlDocument = (Select * From OPENROWSET (BULK 'D:\SQL\HW7\StockItems-188-1fb5df.xml',  SINGLE_CLOB) AS data);
	--вставить результат в temp таблицу
INSERT INTO #StockItems ([StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[QuantityPerOuter],[TypicalWeightPerUnit],[LeadTimeDays],[IsChillerStock],[TaxRate],[UnitPrice])
Select
	t.Items.value('@Name[1]', 'NVARCHAR(100)') as StockItemName,
	t.Items.value('SupplierID[1]', 'INT') as SupplierID,
	cr.I.value('UnitPackageID[1]', 'INT')as UnitPackageID,
	cr.I.value('OuterPackageID[1]', 'INT')as OuterPackageID,
	cr.I.value('QuantityPerOuter[1]', 'INT')as QuantityPerOuter,
	cr.I.value('TypicalWeightPerUnit[1]', 'NUMERIC(18,3)')as TypicalWeightPerUnit,
	t.Items.value('LeadTimeDays[1]', 'INT')as LeadTimeDays,
	t.Items.value('IsChillerStock[1]', 'bit')as IsChillerStock,
	t.Items.value('TaxRate[1]', 'NUMERIC(18,3)')as TaxRate,
	t.Items.value('UnitPrice[1]', 'NUMERIC(18,2)') as UnitPrice
 From @xmlDocument.nodes('StockItems/Item') as t(Items)
 Cross apply t.Items.nodes('Package') as cr(I);

Update Warehouse.StockItems
SET [StockItemName] = S.[StockItemName],
[SupplierID] = S.[SupplierID],
[UnitPackageID] =  S.[UnitPackageID],
[OuterPackageID] = S.[OuterPackageID],
[QuantityPerOuter] = S.[QuantityPerOuter],
[TypicalWeightPerUnit] = S.[TypicalWeightPerUnit],
[LeadTimeDays] = S.[LeadTimeDays], 
[IsChillerStock] = S.[IsChillerStock],
[TaxRate] = S.[TaxRate],
[UnitPrice] = S.[UnitPrice]
From Warehouse.StockItems 
JOIN #StockItems as S ON Warehouse.StockItems.StockItemName = S.StockItemName COLLATE DATABASE_DEFAULT;

Insert into Warehouse.StockItems([StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[QuantityPerOuter],[IsChillerStock],[TypicalWeightPerUnit],[LeadTimeDays],[TaxRate],[UnitPrice],[LastEditedBy]) 
Select S.StockItemName,S.SupplierID, S.UnitPackageID,S.OuterPackageID,S.QuantityPerOuter,S.IsChillerStock,S.TypicalWeightPerUnit,S.LeadTimeDays,S.TaxRate,S.UnitPrice,S.LastEditedBy
From #StockItems as S
WHERE  NOT EXISTS (Select * From Warehouse.StockItems 
WHERE S.StockItemName = Warehouse.StockItems.StockItemName COLLATE DATABASE_DEFAULT);

Select *
From Warehouse.StockItems
Order by StockItemID Desc;

Drop table if exists #StockItems;
GO
/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/
 -- FOR XML PATH
SELECT 
	StockItemName AS  [@Name],
	SupplierID AS [SupplierID],
	UnitPackageID AS [Package/UnitPackageID],
	OuterPackageID AS [Package/OuterPackageID],
	QuantityPerOuter AS [Package/QuantityPerOuter],
	TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit],
	LeadTimeDays AS [LeadTimeDays],
	IsChillerStock AS [IsChillerStock],
	TaxRate AS [TaxRate],
	UnitPrice AS [UnitPrice]
	FROM Warehouse.StockItems
FOR XML PATH('Items'), ROOT('StockItems');
GO
/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/
SELECT
    StockItemID,
	StockItemName,
    JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
	JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
 FROM Warehouse.StockItems;

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.
*/
SELECT
    StockItemID
	,StockItemName
   , JSON_QUERY(CustomFields, '$.Tags') AS tags
FROM Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') tags
WHERE tags.value = 'Vintage'

;