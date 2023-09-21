/*
Страховая компания Договор страхования заключается между страховой компанией и клиентом сроком не более одного года (но может быть и меньше).
При заключении договора указывается вид страхования, страховая сумма, дата начала действия договора. 
Один клиент может заключить несколько договоров. Один сотрудник работает с несколькими клиентами. 
Страхование осуществляется на основе существующего вида услуг.
*/
Create Database InsuranceCompany;
GO
USE InsuranceCompany;
GO
Create schema HW;
GO
----------------------
Use InsuranceCompany;

Drop table HW.Agents;
Drop table HW.Clients;
Drop table HW.Contracts;
Drop table HW.TypeInsurance;
Drop table HW.EventInsurance;
--Таблица Агенты
Create Table HW.Agents(
ID_агента int not null identity(1,1) Primary Key,
Фамилия nvarchar(20) not null,
Имя nvarchar(20) not null,
Отчество nvarchar(20) ,
Дата_рождения date ,
Город nvarchar(20)  ,
Регион nvarchar(20)  ,
Email nvarchar(20) 
);
----------------------------------
--Таблица Клиенты
Create Table HW.Clients(
ID_клиента int not null identity(1,1) Primary Key,
Фамилия nvarchar(20) not null,
Имя nvarchar(20) not null,
Отчество nvarchar(20) ,
Дата_рождения date ,
Город nvarchar(20)  ,
Регион nvarchar(20)  ,
Email nvarchar(20) not null
);
--Таблица Контракты
Create Table HW.Contracts(
ID_договора int not null identity(1,1) Primary Key,
Дата_заключения date not null,
Дата_начала_действия date not null,
Срок_заключения int not null,
Страховая_сумма decimal(12,3)  not null,
ID_вид_страхования int  not null,
ID_страховой_случай int ,
ID_агента int not null,
ID_клиента int not null
);
--Таблица Виды страхования
Create Table HW.TypeInsurance(
ID_вид_страхования int not null identity(1,1) Primary Key,
Вид_страхования nvarchar(20) not null  
);
--Таблица Страховые случаи
Create Table HW.EventInsurance(
ID_страховой_случай int not null identity(1,1) Primary Key,
Дата_возникновения date not null, 
Описание nvarchar(max) , 
Дата_оповещения date ,
Страховая_выплата decimal(12,3)  ,
Дата_выплаты date 
);

----Добавим Foreign key------
Alter Table HW.Contracts ADD CONSTRAINT 
FK_AgentsContracts Foreign Key (ID_агента)
References HW.Agents(ID_агента);

Alter Table HW.Contracts ADD CONSTRAINT 
FK_ClientsContracts Foreign Key (ID_клиента)
References HW.Clients(ID_клиента);

Alter Table HW.Contracts ADD CONSTRAINT 
FK_ContractsTypeInsurance Foreign Key (ID_вид_страхования)
References HW.TypeInsurance(ID_вид_страхования);

Alter Table HW.Contracts ADD CONSTRAINT 
FK_ContractsEventInsurance Foreign Key (ID_страховой_случай)
References HW.EventInsurance(ID_страховой_случай);

---Добавим ограничение на срок заключения не более 1 года----
Alter Table HW.Contracts ADD Constraint constr_year 
Check  (Срок_заключения <= 365);
---Добавим ограничение по возрасту, старше 18 лет----
Alter Table HW.Clients ADD Constraint constr_dr 
Check  (datediff(yy,Дата_рождения,GETDATE()) >= 18);
---Добавим ограничение для Email------
Alter Table HW.Agents ADD Constraint email_un Unique(Email);
