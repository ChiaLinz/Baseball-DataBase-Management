USE [Weather]
GO

/****** Object:  Table [dbo].[aqs_sites]    Script Date: 8/20/2017 4:47:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[aqs_sites](
	[State_Code] [varchar](50) NULL,
	[County_Code] [varchar](50) NULL,
	[Site_Number] [varchar](50) NULL,
	[Latitude] [varchar](50) NULL,
	[Longitude] [varchar](50) NULL,
	[Datum] [varchar](50) NULL,
	[Elevation] [varchar](50) NULL,
	[Land Use] [varchar](50) NULL,
	[Location Setting] [varchar](50) NULL,
	[Site Established Date] [varchar](50) NULL,
	[Site Closed Date] [varchar](50) NULL,
	[Met Site State Code] [varchar](50) NULL,
	[Met Site County Code] [varchar](50) NULL,
	[Met Site Site Number] [varchar](50) NULL,
	[Met Site Type] [varchar](50) NULL,
	[Met Site Distance] [varchar](50) NULL,
	[Met Site Direction] [varchar](50) NULL,
	[GMT Offset] [varchar](50) NULL,
	[Owning Agency] [varchar](500) NULL,
	[Local_Site_Name] [varchar](500) NULL,
	[Address] [varchar](500) NULL,
	[Zip_Code] [varchar](50) NULL,
	[State_Name] [varchar](50) NULL,
	[County_Name] [varchar](500) NULL,
	[City_Name] [varchar](500) NULL,
	[CBSA_Name] [varchar](500) NULL,
	[Tribe_Name] [varchar](500) NULL,
	[Extraction Date] [varchar](50) NULL
) ON [PRIMARY]
GO


