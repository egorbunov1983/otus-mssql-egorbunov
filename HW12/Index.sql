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
Drop table IF EXISTS HW.Contracts;
Drop table IF EXISTS HW.Agents;
Drop table IF EXISTS HW.Clients;
Drop table IF EXISTS HW.TypeInsurance;
Drop table IF EXISTS HW.EventInsurance;
--Таблица Агенты
Create Table HW.Agents(
agent_id int not null identity(1,1) Primary Key,
FullName nvarchar(50) not null,
birth date ,
city nvarchar(40)  ,
region nvarchar(40)  ,
Email nvarchar(40) 
);
----------------------------------
--Таблица Клиенты
Create Table HW.Clients(
client_id int not null identity(1,1) Primary Key,
FullName nvarchar(50) not null,
birth date ,
city nvarchar(40)  ,
region nvarchar(40)  ,
Email nvarchar(40) not null
);
--Таблица Контракты
Create Table HW.Contracts(
contract_id int not null identity(1,1) Primary Key,
date_conclusion date not null, --Дата_заключения
date_start date not null,	--Дата_начала_действия
date_validity int not null, --срок заключения
Sum_insured decimal(12,3)  not null,	--Страховая_сумма
TypeInsurance_id int  not null,	--ID_вид_страхования
EventInsurance_id int ,	--ID_страховой_случай
agent_id int not null,
client_id int not null
);
--Таблица Виды страхования
Create Table HW.TypeInsurance(
TypeInsurance_id int not null identity(1,1) Primary Key,
TypeInsurance nvarchar(100) not null  
);
--Таблица Страховые случаи
Create Table HW.EventInsurance(
EventInsurance_id int not null identity(1,1) Primary Key,
date_occurrence date not null, --Дата_возникновения
Description nvarchar(max) , 
date_notification date ,	--Дата_оповещения
payment decimal(12,3)  ,	--Страховая_выплата
date_payment date	--Дата_выплаты
);

----Добавим Foreign key------
Alter Table HW.Contracts ADD CONSTRAINT 
FK_AgentsContracts Foreign Key (agent_id)
References HW.Agents(agent_id);

Alter Table HW.Contracts ADD CONSTRAINT 
FK_ClientsContracts Foreign Key (client_id)
References HW.Clients(client_id);

Alter Table HW.Contracts ADD CONSTRAINT 
FK_ContractsTypeInsurance Foreign Key (TypeInsurance_id)
References HW.TypeInsurance(TypeInsurance_id);

Alter Table HW.Contracts ADD CONSTRAINT 
FK_ContractsEventInsurance Foreign Key (EventInsurance_id)
References HW.EventInsurance(EventInsurance_id);

---Добавим ограничение на срок заключения не более 1 года----
Alter Table HW.Contracts ADD Constraint constr_year 
Check  (date_validity <= 365);
---Добавим ограничение по возрасту, старше 18 лет----
Alter Table HW.Agents ADD Constraint constr_dr_ag 
Check  (datediff(yy,birth,GETDATE()) >= 18);
Alter Table HW.Clients ADD Constraint constr_dr_cl 
Check  (datediff(yy,birth,GETDATE()) >= 18);
---Добавим ограничение для Email------
Alter Table HW.Agents ADD Constraint email_un Unique(Email);

----------------------------------------------------------------
--Добавим некластерный индекс на поле FullName
CREATE NONCLUSTERED INDEX IX_HW_Agents_FullName ON HW.Agents (FullName);

CREATE NONCLUSTERED INDEX IX_HW_Clients_FullName ON HW.Clients (FullName);
--Добавим некластерный индекс на поля c Foreign key
CREATE NONCLUSTERED INDEX IX_HW_Contracts_agent_id ON HW.Contracts (agent_id);

CREATE NONCLUSTERED INDEX IX_HW_Contracts_client_id ON HW.Contracts (client_id);

CREATE NONCLUSTERED INDEX IX_HW_Contracts_TypeInsurance_id ON HW.Contracts (TypeInsurance_id);

CREATE NONCLUSTERED INDEX IX_HW_Contracts_EventInsurance_id ON HW.Contracts (EventInsurance_id);