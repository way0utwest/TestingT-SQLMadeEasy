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
CREATE PROCEDURE dbo.GetCurrentHeadlines
AS
BEGIN

SELECT TOP 5
	ci.ContentItemID
   ,ci.Title
   ,ci.ExternalURL
   ,se.StartDate
 FROM dbo.ContentItems AS ci
  INNER JOIN dbo.ScheduleEntries AS se
  ON se.ContentItemID = ci.ContentItemID
  WHERE se.StartDate <= GETDATE()
  ORDER BY se.Startdate desc
 
END
GO


-- run
EXEC dbo.GetCurrentHeadlines
GO






-- how do we test this?
-- There are a couple ways. First, try to move GETDATE() to a function.

CREATE FUNCTION GetCurrentDate()
 RETURNS datetime2(3)
 AS
BEGIN
 return GETDATE()
end
GO







-- this means changing code:
ALTER PROCEDURE dbo.GetCurrentHeadlines
AS
  BEGIN
    SELECT TOP 5
        ci.ContentItemID
      , ci.Title
      , ci.ExternalURL
      , se.StartDate
      FROM
        dbo.ContentItems AS ci
      INNER JOIN dbo.ScheduleEntries AS se
      ON
        se.ContentItemID = ci.ContentItemID
      WHERE
        se.StartDate <= dbo.GetCurrentDate()
      ORDER BY
        se.StartDate desc

  END
GO









-- run
EXEC dbo.GetCurrentHeadlines
GO






-- But this allows us to upgrade
ALTER FUNCTION GetCurrentDate()
 RETURNS datetime2(3)
 AS
BEGIN
 return SYSDATETIME()
end
GO










-- run
EXEC dbo.GetCurrentHeadlines
GO











-- Let's test
EXEC tsqlt.NewTestClass 
  @ClassName = N'tContentItemTests';
go
CREATE PROCEDURE [tContentItemTests].[test Check GetCurrentHeadlines for Current item]
AS
BEGIN
-- Assemble 
EXEC tsqlt.FakeTable
  @TableName = N'ContentItems'
, @SchemaName = N'dbo'

INSERT dbo.ContentItems ( ContentItemID, Title, ExternalURL)
 VALUES (1, 'Test 1', 'http://someurl.com/1/')
      , (2, 'Test 2', 'http://someurl.com/2/')
      , (3, 'Test 3', 'http://someurl.com/3/')
      , (4, 'Test 4', 'http://someurl.com/4/')
      , (5, 'Test 5', 'http://someurl.com/5/')
      , (6, 'Test 6', 'http://someurl.com/6/')
      , (7, 'Test 7', 'http://someurl.com/7/')
      , (8, 'Test 8', 'http://someurl.com/8/')
      , (9, 'Test 9', 'http://someurl.com/9/')
      , (10, 'Test 10', 'http://someurl.com/10/')
      , (11, 'Test 11', 'http://someurl.com/11/')

EXEC tsqlt.FakeTable
  @TableName = N'ScheduleEntries'
, @SchemaName = N'dbo'

INSERT dbo.ScheduleEntries ( ScheduleEntryID, ContentItemID, StartDate, EndDate)
 VALUES (1, 1,   '20160102', null)
      , (2, 2,   '20160103', null)
      , (3, 3,   '20160104', null)
      , (4, 4,   '20160106', null)
      , (5, 5,   '20160107', null)
      , (6, 6,   '20160108', null)
      , (7, 7,   '20160109', null)
      , (8, 8,   '20160110', null)
      , (9, 9,   '20160112', null)
      , (10, 10, '20160113', NULL)
      , (11, 11, '20160114', NULL)

CREATE TABLE #expected
 ( ContentItemID int
 , Title VARCHAR(200)
 , ExternalURL VARCHAR(250)
 , StartDate DATETIME
 ) 
 
 INSERT #expected
 VALUES (6, 'Test 6', 'http://someurl.com/6/'   , '20160108')
      , (7, 'Test 7', 'http://someurl.com/7/'   , '20160109')
      , (8, 'Test 8', 'http://someurl.com/8/'   , '20160110')
      , (9, 'Test 9', 'http://someurl.com/9/'   , '20160112')
      , (10, 'Test 10', 'http://someurl.com/10/', '20160113')

CREATE TABLE #actual
 ( ContentItemID int
 , Title VARCHAR(200)
 , ExternalURL VARCHAR(250)
 , StartDate DATETIME
 ) 

--------------------------------------------------------
-- This is the important part
--------------------------------------------------------
EXEC tsqlt.FakeFunction
  @FunctionName = N'dbo.GetCurrentDate'
, @FakeFunctionName = N'dbo.GetDate20160113';


 -- Act
 INSERT #actual EXEC dbo.GetCurrentHeadlines;

 -- Assert
 EXEC tsqlt.AssertEqualsTable
   @Expected = N'#expected'
 , @Actual = N'#actual'
 , @FailMsg = N'Query does not return current headlines'
 

END
GO

/*********************************************************************
End test
**********************************************************************/

CREATE FUNCTION dbo.GetDate20160113()
RETURNS DATETIME2(3)
AS
BEGIN
 RETURN CAST('20160113' AS DATETIME)
END




-- run the test
EXEC tsqlt.run '[tContentItemTests].[test Check GetCurrentHeadlines for Current item]';
go




-- passes







-- let's alter the function and retest
ALTER FUNCTION dbo.GetDate20160113()
RETURNS DATETIME2(3)
AS
BEGIN
 RETURN CAST('20160112' AS DATETIME)
END
GO


-- retest
EXEC tsqlt.run '[tContentItemTests].[test Check GetCurrentHeadlines for Current item]';
go




-- fails. That's fine. it should. Fix.
ALTER FUNCTION dbo.GetDate20160113()
RETURNS DATETIME2(3)
AS
BEGIN
 RETURN CAST('20160113' AS DATETIME)
END
GO

-- test
EXEC tsqlt.run '[tContentItemTests].[test Check GetCurrentHeadlines for Current item]';
go







-- what if we can't alter code?
-- let's look at a new procedure
-- from https://www.mssqltips.com/sqlservertip/2534/sql-server-stored-procedure-to-generate-random-passwords/
CREATE PROC [dbo].uspRandChars
  @len INT
, @min TINYINT = 48
, @range TINYINT = 74
, @exclude VARCHAR(50) = '0:;<=>?@O[]`^\/'
, @output VARCHAR(50) OUTPUT
AS
  DECLARE @char CHAR
  SET @output = ''
 
  WHILE @len > 0
    BEGIN
      SELECT
          @char = CHAR(ROUND(RAND() * @range + @min, 0))
      IF CHARINDEX(@char, @exclude) = 0
        BEGIN
          SET @output += @char
          SET @len = @len - 1
        END
    END;
GO
-- test
DECLARE @o VARCHAR(50) = '';
EXEC dbo.uspRandChars
  @len = 8
, @output = @o OUTPUT
;
SELECT @o;
GO



-- DROP  PROCEDURE dbo.ResetPassword
CREATE PROCEDURE dbo.ResetPassword @userid INT
AS
    BEGIN
 
        DECLARE @newpwd VARCHAR(20) = ''

        EXEC [dbo].uspRandChars
            @len = 8
          , @output = @newpwd OUT

        DELETE
                dbo.UserTempPwd
            WHERE
                UserID = @userid;

------------------------------------
-- Note the time
------------------------------------
        INSERT dbo.UserTempPwd
            VALUES
                ( @userid, HASHBYTES('SHA2_512', @newpwd),
                  DATEADD(MINUTE, 15, SYSDATETIME()) )

    END
GO

-- test
SELECT top 10
  *
 FROM dbo.UserTempPwd AS utp
 WHERE utp.UserID = 12
GO
EXEC dbo.ResetPassword
  @userid = 12;
GO
SELECT top 10
  *
 FROM dbo.UserTempPwd AS utp
 WHERE utp.UserID = 12
go






 -- works
 -- how to we test?
 -- Use Bracking
EXEC tsqlt.NewTestClass
   @ClassName = N'tSecurityTests';
go 
CREATE PROCEDURE [tSecurityTests].[test password reset timeout]
AS
BEGIN
   -- assemble 
   DECLARE @begintime DATETIME2(3)
	     , @endtime DATETIME2(3)
	    , @actualtime DATETIME2(3)

  SELECT @begintime = DATEADD(MINUTE, 15, SYSDATETIME());   
   
   -- act
   EXEC dbo.ResetPassword
     @userid = 12
  
  SELECT @endtime = DATEADD(MINUTE, 15, SYSDATETIME());

  
   -- assert 
   SELECT @actualtime = utp.PasswordExpires
    FROM dbo.UserTempPwd AS utp
	WHERE utp.UserID = 12;

	IF(@actualtime < @begintime OR @actualtime > @endtime OR @actualtime IS NULL)
	BEGIN
	  DECLARE @msg NVARCHAR(MAX) = 
	      'Expected:'+
		      CONVERT(NVARCHAR(MAX),@begintime,121)+
			      ' <= '+
	          ISNULL(CONVERT(NVARCHAR(MAX),@actualtime,121),'!NULL!')+
    ' <= '+
    CONVERT(NVARCHAR(MAX),@endtime,121);

    EXEC tSQLt.Fail @msg;

END;

END
GO






-- check the tests
EXEC tsqlt.run '[tSecurityTests].[test password reset timeout]';
go






-- can we fail it?
-- Sure, change the expiration
ALTER PROCEDURE dbo.ResetPassword
  @userid INT
 AS
 BEGIN
 
DECLARE @newpwd VARCHAR(20) = ''

EXEC [dbo].uspRandChars
  @len = 8
, @output = @newpwd OUT

DELETE dbo.UserTempPwd
 WHERE UserID = @userid;

 INSERT dbo.UserTempPwd
  VALUES (@userid, HASHBYTES('SHA2_512', @newpwd), DATEADD(MINUTE, 5, GETDATE()))

 END
GO





-- retest
EXEC tsqlt.run '[tSecurityTests].[test password reset timeout]';
go




/*******************************************************************************
*                                                                              *
*                            END DEMO                                          *
*                                                                              *
********************************************************************************/
