/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
Use [WideWorldImporters];
Select YEAR([InvoiceDate]) as 'Год продажи', MONTH([InvoiceDate]) as 'Месяц продажи',
	   avg([UnitPrice]) as  'Средняя цена за месяц', SUM([Quantity]*[UnitPrice]) as 'Общая сумма продаж за месяц'
From  [Sales].[Invoices]
JOIN [Sales].[InvoiceLines] ON [Sales].[Invoices].[InvoiceID] = [Sales].[InvoiceLines].[InvoiceID]
Group by YEAR([InvoiceDate]),MONTH([InvoiceDate])
Order by "Год продажи", "Месяц продажи"
/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
Сортировка по году и месяцу.
*/
Use [WideWorldImporters];
Select YEAR([InvoiceDate]) as 'Год продажи', MONTH([InvoiceDate]) as 'Месяц продажи',
	   SUM([Quantity]*[UnitPrice]) as 'Общая сумма продаж за месяц'
From  [Sales].[Invoices]
JOIN [Sales].[InvoiceLines] ON [Sales].[Invoices].[InvoiceID] = [Sales].[InvoiceLines].[InvoiceID] 
Group by YEAR([InvoiceDate]), MONTH([InvoiceDate])
Having SUM([Quantity]*[UnitPrice])>4600000
Order by "Месяц продажи","Год продажи"
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.
Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного
Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
Use [WideWorldImporters];
Select YEAR([InvoiceDate]) as 'Год продажи', MONTH([InvoiceDate]) as 'Месяц продажи',[Description] as 'Наименование товара',
	   SUM([Quantity]*[UnitPrice]) as 'Общая сумма продаж за месяц', Min([InvoiceDate]) as 'Дата первой продажи', SUM([Quantity]) as 'Количество проданного'
From  [Sales].[Invoices]
JOIN [Sales].[InvoiceLines] ON [Sales].[Invoices].[InvoiceID] = [Sales].[InvoiceLines].[InvoiceID]
Group by YEAR([InvoiceDate]),MONTH([InvoiceDate]),[Description]
Having SUM([Quantity])<50
Order by "Год продажи", "Месяц продажи"
/*
4. Написать второй запрос ("Отобразить все месяцы, где общая сумма продаж превысила 4 600 000") 
за период 2015 год так, чтобы месяц, в котором сумма продаж была меньше указанной суммы также отображался в результатах,
но в качестве суммы продаж было бы '-'.
Сортировка по году и месяцу.
Пример результата:
-----+-------+------------
Year | Month | SalesTotal
-----+-------+------------
2015 | 1     | -
2015 | 2     | -
2015 | 3     | -
2015 | 4     | 5073264.75
2015 | 5     | -
2015 | 6     | -
2015 | 7     | 5155672.00
2015 | 8     | -
2015 | 9     | 4662600.00
2015 | 10    | -
2015 | 11    | -
2015 | 12    | -
*/
Use [WideWorldImporters];
Select YEAR([InvoiceDate]) as 'Год продажи', MONTH([InvoiceDate]) as 'Месяц продажи',
	   IIF (SUM([Quantity]*[UnitPrice])>4600000,CAST(SUM([Quantity]*[UnitPrice])AS nvarchar),'-') as 'Общая сумма продаж за месяц'
From  [Sales].[Invoices]
JOIN [Sales].[InvoiceLines] ON [Sales].[Invoices].[InvoiceID] = [Sales].[InvoiceLines].[InvoiceID] 
Where YEAR([InvoiceDate])='2015'
Group by YEAR([InvoiceDate]), MONTH([InvoiceDate])
Order by "Год продажи","Месяц продажи"
