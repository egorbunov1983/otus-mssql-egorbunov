/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/
Use [WideWorldImporters];
Select StockItemID, StockItemName FROM Warehouse.StockItems
Where StockItemName like '%urgent%' OR StockItemName like 'Animal%';
/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/
Use [WideWorldImporters];
Select Purchasing.Suppliers.SupplierID, Purchasing.Suppliers.SupplierName From Purchasing.Suppliers
left Join Purchasing.PurchaseOrders ON Purchasing.Suppliers.SupplierID=Purchasing.PurchaseOrders.SupplierID
where [OrderDate] is NULL;
/*
3. Заказы (Orders) с товарами ценой (UnitPrice) более 100$
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ (10.01.2011)
* название месяца, в котором был сделан заказ (используйте функцию FORMAT или DATENAME)
* номер квартала, в котором был сделан заказ (используйте функцию DATEPART)
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.
Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).
Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
Use [WideWorldImporters];
Select Sales.Orders.OrderID, FORMAT(OrderDate, 'dd/MM/yyyy')as OrderDate, DATENAME(month,OrderDate) as Month, DATEPART(quarter,OrderDate) as Quarter, 
		CASE WHEN ROUND(DATEPART(month,OrderDate), 0) < 5 THEN '1'
			 WHEN ROUND(DATEPART(month,OrderDate), 0) < 9 THEN '2'
			 WHEN ROUND(DATEPART(month,OrderDate), 0) > 8 THEN '3' 
		END	 as ТретьГода, CustomerName 
From Sales.OrderLines JOIN Sales.Orders ON Sales.OrderLines.OrderID = Sales.Orders.OrderID
JOIN Sales.Customers ON Sales.Orders.CustomerID = Sales.Customers.CustomerID
Where UnitPrice > 100 OR (Quantity > 20 AND [Sales].[OrderLines].PickingCompletedWhen IS NOT NULL)
Order by Quarter,ТретьГода, OrderDate;
--v2
Use [WideWorldImporters];
Select Sales.Orders.OrderID, FORMAT(OrderDate, 'dd/MM/yyyy')as OrderDate, DATENAME(month,OrderDate) as Month, DATEPART(quarter,OrderDate) as Quarter, 
CASE WHEN ROUND(DATEPART(month,OrderDate), 0) < 5 THEN '1'
	 WHEN ROUND(DATEPART(month,OrderDate), 0) < 9 THEN '2'
	 WHEN ROUND(DATEPART(month,OrderDate), 0) > 8 THEN '3' 
END	 as ТретьГода, CustomerName 
From Sales.OrderLines JOIN Sales.Orders ON Sales.OrderLines.OrderID = Sales.Orders.OrderID
JOIN Sales.Customers ON Sales.Orders.CustomerID = Sales.Customers.CustomerID
Where UnitPrice > 100 OR (Quantity > 20 AND [Sales].[OrderLines].PickingCompletedWhen IS NOT NULL)
Order by Quarter,ТретьГода, OrderDate
Offset 1000 Rows FETCH FIRST 100 ROWS ONLY;
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
Use [WideWorldImporters];
Select DeliveryMethodName, ExpectedDeliveryDate, SupplierName, FullName as ContactPerson   
FROM   [Application].[People]
RIGHT JOIN [Purchasing].[PurchaseOrders] ON [Application].[People].[PersonID] =  [Purchasing].[PurchaseOrders].[ContactPersonID]
LEFT JOIN [Purchasing].[Suppliers] ON [Purchasing].[PurchaseOrders].[SupplierID] = [Purchasing].[Suppliers].[SupplierID]
LEFT JOIN [Application].[DeliveryMethods] ON [Purchasing].[PurchaseOrders].[DeliveryMethodID]=[Application].[DeliveryMethods].[DeliveryMethodID]
WHERE Datepart(month,ExpectedDeliveryDate) = 01 AND Datepart(year,ExpectedDeliveryDate) = 2013 
AND (DeliveryMethodName LIKE 'Air Freight' OR DeliveryMethodName LIKE 'Refrigerated Air Freight') AND IsOrderFinalized = 1;
/*
5. Десять последних продаж (по дате продажи - InvoiceDate) с именем клиента (клиент - CustomerID) и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
Вывести: ИД продажи (InvoiceID), дата продажи (InvoiceDate), имя заказчика (CustomerName), имя сотрудника (SalespersonFullName)
Таблицы: Sales.Invoices, Sales.Customers, Application.People.
*/
Use [WideWorldImporters];
Select TOP 10 InvoiceID ,InvoiceDate,CustomerName,FullName From [Application].[People]
RIGHT JOIN [Sales].[Invoices] ON [Application].[People].[PersonID] = [Sales].[Invoices].[ContactPersonID]
LEFT JOIN [Sales].[Customers] ON [Sales].[Invoices].CustomerID = [Sales].[Customers].CustomerID
Order by InvoiceDate desc
/*
6. Все ид и имена клиентов (клиент - CustomerID) и их контактные телефоны (PhoneNumber),
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems, имена клиентов и их контакты в таблице Sales.Customers.
Таблицы: Sales.Invoices, Sales.InvoiceLines, Sales.Customers, Warehouse.StockItems.
*/
Use [WideWorldImporters];
Select Distinct[Sales].[Customers].[CustomerID],[Sales].[Customers].[CustomerName],[PhoneNumber] From [Warehouse].[StockItems]
JOIN [Sales].[InvoiceLines] ON [Warehouse].[StockItems].StockItemID = [Sales].[InvoiceLines].StockItemID
JOIN [Sales].[Invoices] ON [Sales].[InvoiceLines].[InvoiceID] = [Sales].[Invoices].[InvoiceID]
JOIN [Sales].[Customers] ON [Sales].[Invoices].CustomerID =[Sales].[Customers].CustomerID
Where [Warehouse].[StockItems].[StockItemName] like 'Chocolate frogs 250%'
