/*
DROP TABLE IF EXISTS [HW].ContractsPartitioned;
DROP PARTITION SCHEME [schmYearPartition];
DROP PARTITION FUNCTION [fnYearPartition];
*/
USE InsuranceCompany;
GO
ALTER DATABASE [InsuranceCompany] ADD FILEGROUP [YearData]
GO
--добавляем файл БД
ALTER DATABASE [InsuranceCompany] ADD FILE 
( NAME = N'Years', FILENAME = N'D:\SQL\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO
--создаем функцию партиционирования по годам - по умолчанию left!!
CREATE PARTITION FUNCTION [fnYearPartition](DATE) AS RANGE RIGHT FOR VALUES
('20060101','20070101','20080101','20090101','20100101','20110101','20120101','20130101'
,'20140101','20150101','20160101','20170101','20180101','20190101','20200101','20210101','20220101','20230101');																																																									
GO
-- партиционируем, используя созданную нами функцию
CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData])
GO
--создаем наши секционированные таблицы
SELECT * INTO HW.ContractsPartitioned
FROM HW.Contracts;
-- и создать новый кластерный индекс с ключом секционирования
ALTER TABLE [HW].[ContractsPartitioned] ADD CONSTRAINT PK_Events_Contracts_date_conclusion 
PRIMARY KEY CLUSTERED  (date_conclusion, contract_id)
ON [schmYearPartition]([date_conclusion]);