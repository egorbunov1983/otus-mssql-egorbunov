SELECT *
FROM HW.Reports;

--Send message
EXEC HW.SendNewReport
	@CustomerId = 6,
	@StartReport = '2013-02-04',
	@EndReport = '2013-05-25';


SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueueWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueueWWI;

