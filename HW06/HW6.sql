USE WideWorldImporters

/*
1. ��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.
�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys.
��� ������� ����� �������� ��� ����� �������� ������ ���������.
��������, �������� �������� "Tailspin Toys (Gasport, NY)" - �� �������� ������ "Gasport, NY".
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.
������, ��� ������ ��������� ����������:
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
Order by Month(InvoiceMonth),Year(InvoiceMonth)
/*
2. ��� ���� �������� � ������, � ������� ���� "Tailspin Toys"
������� ��� ������, ������� ���� � �������, � ����� �������.
������ ����������:
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
3. � ������� ����� (Application.Countries) ���� ���� � �������� ����� ������ � � ���������.
�������� ������� �� ������, �������� � �� ���� ���, 
����� � ���� � ����� ��� ���� �������� ���� ��������� ���.
������ ����������:
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
4. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/
;WITH CTE1 (CustomerID,CustomerName,StockItemID, Description,UnitPrice) AS
(
Select  Distinct cust.CustomerID,cust.CustomerName,InvLines.StockItemID, InvLines.Description,InvLines.UnitPrice
From Sales.Invoices as Invoices
	JOIN Sales.InvoiceLines as InvLines ON Invoices.InvoiceID = InvLines.InvoiceID
	JOIN Sales.CustomerTransactions as trans ON Invoices.InvoiceID = trans.InvoiceID AND Invoices.CustomerID = trans.CustomerID
	JOIN Sales.Customers as cust ON trans.CustomerID = cust.CustomerID
)
,CTE3 AS
(
SELECT C.CustomerID, O.*
FROM Sales.Customers C
CROSS APPLY (SELECT TOP 2 O.CustomerName,O.StockItemID, O.Description,O.UnitPrice
                FROM CTE1 O
                WHERE O.CustomerID = C.CustomerID	
				Order by O.CustomerID, O.UnitPrice Desc) AS O
)
Select  cust.CustomerID,cust.CustomerName,InvLines.StockItemID, InvLines.Description,InvLines.UnitPrice, Invoices.InvoiceDate
From Sales.Invoices as Invoices
	JOIN Sales.InvoiceLines as InvLines ON Invoices.InvoiceID = InvLines.InvoiceID
	JOIN Sales.CustomerTransactions as trans ON Invoices.InvoiceID = trans.InvoiceID AND Invoices.CustomerID = trans.CustomerID
	JOIN Sales.Customers as cust ON trans.CustomerID = cust.CustomerID
	JOIN CTE3 ON cust.CustomerID = CTE3.CustomerID and InvLines.StockItemID = CTE3.StockItemID and 
	InvLines.Description = CTE3.Description and  InvLines.UnitPrice = CTE3.UnitPrice
Order by cust.CustomerID




