
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
DROP PROCEDURE HW.SendNewReport
GO

CREATE PROCEDURE HW.SendNewReport
	@CustomerId INT,
	@StartReport date,
	@EndReport date
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	--Prepare the Message
	SELECT @RequestMessage = (SELECT TOP 1 CustomerId, @StartReport as StartReport, @EndReport as EndReport
							  FROM Sales.Invoices AS Inv
							  WHERE CustomerId = @CustomerId
							  FOR XML AUTO, root('RequestMessage'));
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	
	SELECT @RequestMessage AS SentRequestMessage;
	
	COMMIT TRAN 
END
GO
