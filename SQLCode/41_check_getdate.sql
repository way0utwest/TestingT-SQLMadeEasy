/*
Testing T-SQL Made Easy - Checking Getdate

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/

-- We want to alter a table.
USE [TestingTSQL]
GO

-- we have a procedure using a getdate()
CREATE PROCEDURE dbo.GetCurrentPosts
AS
BEGIN
END
GO







-- How do we test this?
-- Let's try testing.









-- test happy path






-- alter procedure to a left join





-- check the tests
EXEC tsqlt.run '[].[]';
