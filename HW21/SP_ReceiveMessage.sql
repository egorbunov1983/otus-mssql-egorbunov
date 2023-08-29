DROP PROCEDURE HW.ReceiveNewReport
GO

CREATE PROCEDURE HW.ReceiveNewReport
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@CustomerId INT,
			@StartReport date,
			@EndReport date,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SELECT @Message; --

	SET @xml = CAST(@Message AS XML);

	SELECT @CustomerId = R.Iv.value('@CustomerId','INT')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);
	SELECT 	@StartReport = R.Iv.value('@StartReport','Date')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);
	SELECT @EndReport = R.Iv.value('@EndReport','Date')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	IF EXISTS (SELECT * FROM Sales.Invoices WHERE CustomerId = @CustomerId and InvoiceDate between @StartReport and @EndReport)
	BEGIN
		Insert Into HW.Reports(CustomerID,Orders,StartReport,EndReport)
		Select  SI.CustomerID, Count(SI.OrderID) as Orders, @StartReport as StartReport, @EndReport as EndReport
		From Sales.Invoices as SI
		Where SI.CustomerID = @CustomerID and SI.InvoiceDate between @StartReport and @EndReport
		Group by SI.CustomerID;  	
	END;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END