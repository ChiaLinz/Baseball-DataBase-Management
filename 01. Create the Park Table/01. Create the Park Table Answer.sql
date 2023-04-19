Use Summer_2022_BaseBall;
GO

-- 1. Write the DDL to create the Parks table. The script should include an IF statement (see script for creating the baseball database for examples) so that it could be run several times without changing anything in the script. See the 00 - Create Database.sql script for examples.

IF OBJECT_ID (N'dbo.Parks', N'U') IS NOT NULL
drop table dbo.parks
go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Parks](
	[park_key] [varchar](255) NULL,
	[park_name] [varchar](255) NULL,
	[park_alias] [varchar](255) NULL,
	[city] [varchar](255) NULL,
	[state] [varchar](255) NULL,
	[country] [varchar](255) NULL
	) ON [PRIMARY]
GO


-- 2. After loading the data to the table write the SQL using ATLER statements to create:
--	a. The appropriate primary key 
--	b. A check statement to check that the country column contains one of these values:  AU, CA, JP, MX, PR, UK, US  
--  c. The Constrains must have a name included when you add the constraint. The constraint name must be different than the column the constraint is on. An example would be naming the primary key constraint Parks_PK 


alter table Parks
alter column park_key varchar(255) not null

alter table Parks
add constraint Pk_Parks primary key (park_key)

ALTER table Parks
add constraint check_country
  CHECK (country IN ('AU', 'CA', 'JP', 'MX', 'PR', 'UK', 'US'  ))

