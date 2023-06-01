/*
1. ��������� ������� ���� ������, ����� ����� ������� �� �������.
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ������� ���� �� ����� �� ���� �������
* ����� ����� ������ �� �����
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
Use [WideWorldImporters];
Select YEAR([InvoiceDate]) as '��� �������', MAX(MONTH([InvoiceDate])) as '����� �������',
	   avg([UnitPrice]) as  '������� ���� �� �����', SUM([Quantity]*[UnitPrice]) as '����� ����� ������ �� �����'
From  [Sales].[Invoices]
JOIN [Sales].[InvoiceLines] ON [Sales].[Invoices].[InvoiceID] = [Sales].[InvoiceLines].[InvoiceID]
Group by YEAR([InvoiceDate]),DATENAME(month,[Sales].[Invoices].[InvoiceDate])
Order by "��� �������", "����� �������"
/*
2. ���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000
�������:
* ��� ������� (��������, 2015)
* ����� ������� (��������, 4)
* ����� ����� ������
������� �������� � ������� Sales.Invoices � ��������� ��������.
���������� �� ���� � ������.
*/
Use [WideWorldImporters];
Select YEAR([InvoiceDate]) as '��� �������', MAX(MONTH([InvoiceDate])) as '����� �������',
	   SUM([Quantity]*[UnitPrice]) as '����� ����� ������ �� �����'
From  [Sales].[Invoices]
JOIN [Sales].[InvoiceLines] ON [Sales].[Invoices].[InvoiceID] = [Sales].[InvoiceLines].[InvoiceID] 
Group by YEAR([InvoiceDate]), DATENAME(month,[Sales].[Invoices].[InvoiceDate])
Having SUM([Quantity]*[UnitPrice])>4600000
Order by "����� �������","��� �������"
/*
3. ������� ����� ������, ���� ������ �������
� ���������� ���������� �� �������, �� �������,
������� ������� ����� 50 �� � �����.
����������� ������ ���� �� ����,  ������, ������.
�������:
* ��� �������
* ����� �������
* ������������ ������
* ����� ������
* ���� ������ �������
* ���������� ����������
������� �������� � ������� Sales.Invoices � ��������� ��������.
*/
Use [WideWorldImporters];
Select YEAR([InvoiceDate]) as '��� �������', MAX(MONTH([InvoiceDate])) as '����� �������',[Description] as '������������ ������',
	   SUM([Quantity]*[UnitPrice]) as '����� ����� ������ �� �����', Min([InvoiceDate]) as '���� ������ �������', SUM([Quantity]) as '���������� ����������'
From  [Sales].[Invoices]
JOIN [Sales].[InvoiceLines] ON [Sales].[Invoices].[InvoiceID] = [Sales].[InvoiceLines].[InvoiceID]
Group by YEAR([InvoiceDate]),DATENAME(month,[Sales].[Invoices].[InvoiceDate]),[Description]
Having SUM([Quantity])<50
Order by "��� �������", "����� �������"
/*
4. �������� ������ ������ ("���������� ��� ������, ��� ����� ����� ������ ��������� 4 600 000") 
�� ������ 2015 ��� ���, ����� �����, � ������� ����� ������ ���� ������ ��������� ����� ����� ����������� � �����������,
�� � �������� ����� ������ ���� �� '-'.
���������� �� ���� � ������.
������ ����������:
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
Select YEAR([InvoiceDate]) as '��� �������', MAX(MONTH([InvoiceDate])) as '����� �������',
	   IIF (SUM([Quantity]*[UnitPrice])>4600000,CAST(SUM([Quantity]*[UnitPrice])AS nvarchar),'-') as '����� ����� ������ �� �����'
From  [Sales].[Invoices]
JOIN [Sales].[InvoiceLines] ON [Sales].[Invoices].[InvoiceID] = [Sales].[InvoiceLines].[InvoiceID] 
Where YEAR([InvoiceDate])='2015'
Group by YEAR([InvoiceDate]), DATENAME(month,[Sales].[Invoices].[InvoiceDate])
Order by "����� �������","��� �������"
