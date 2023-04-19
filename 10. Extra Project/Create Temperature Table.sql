USE [Weather]
GO

/****** Object:  Table [dbo].[Temperature]    Script Date: 8/20/2017 4:49:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Temperature](
	[State_Code] [varchar](50) NULL,
	[County_Code] [varchar](50) NULL,
	[Site_Num] [varchar](50) NULL,
	[Date_Local] [date] NULL,
	[Average_Temp] [decimal](10, 6) NULL,
	[Daily_High_Temp] [decimal](10, 6) NULL,
	[1st Max Hour] [varchar](50) NULL,
	[Date_Last_Change] [varchar](50) NULL
) ON [PRIMARY]
GO


