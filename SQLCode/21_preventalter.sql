/*
Testing T-SQL Made Easy - Large Tables

Steve Jones, copyright 2016

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.
*/

-- We want to alter a table.
USE [TestingTSQL]
GO
SELECT COUNT(*)
 FROM dbo.Files AS f

 GO
 

 -- check our database for current quality
EXEC tsqlt.run '[SQLCop]';
go




-- all good
-- However, we decide to alter the Files table
-- Here is our code
/*
ALTER TABLE dbo.Files
 ADD FileSummary VARCHAR(1000) NULL
GO
UPDATE dbo.Files
 set FileSummary = a.MetaData
 from Files f
  CROSS APPLY dbo.clrLoadFileMetadata(f.FileID) a
GO
ALTER TABLE dbo.Files
 ALTER COLUMN FileSummary varchar(1000) NOT NULL
*/










-- The problem is this alter will take a long time.
-- We want to ensure these types of changes aren't made without being scheduled.















-- Let's use a Test to notify us that thsi is an issue
EXEC tsqlt.NewTestClass
  @ClassName = N'tMetaDataChecks' -- nvarchar(max)
GO
CREATE PROCEDURE [tMetaDataChecks].[test dbo.Files should not be altered without discussion]
AS
BEGIN
-- Assemble
CREATE TABLE dbo.ExpectedFiles
(
[FileID] [int] NOT NULL,
[FileName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileExtension] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SizeInBytes] [bigint] NOT NULL,
[CreatedDate] [datetime] NOT NULL
)


-- Act


-- Assert
EXEC tsqlt.AssertResultSetsHaveSameMetaData
  @expectedCommand = N'select * from dbo.ExpectedFiles'
, @actualCommand = N'select * from dbo.Files'

END
GO







  
ALTER TABLE dbo.Files
 ADD FileSummary VARCHAR(1000) NULL
GO
UPDATE dbo.Files
 set FileSummary = a.Summary
 from Files f
  CROSS APPLY dbo.clrLoadFileMetadata(f.FileID) a
GO
ALTER TABLE dbo.Files
 ALTER COLUMN FileSummary varchar(1000) NOT NULL
GO







-- run the test
EXEC tsqlt.RunTestClass
  @TestClassName = N'tMetaDataChecks';
GO







-- Failure











-- Now what?
-- schedule meeting
-- discuss strategies (maintenance window, time required for deployment)


-- We DO NOT want an exception here. We want this test to fail, and if the change is approved, the test is altered to allow
-- this change, but prevent future ones.

-- Note, this means you need some control over when/how this test is run.







/*******************************************************************************
*                                                                              *
*                            END DEMO                                          *
*                                                                              *
********************************************************************************/
