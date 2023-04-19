/* 
Submission 2 -  Geospatial Data, Stored Procedure and Optional Front End

	2.	Your last concern is how long will it take to travel back home to visit friends and family after you move. Since the Weather database has latitude and longitude information, you have decided to convert this information into a new column with a GEOGRAPHY data type and populate the new column with a set command and one of the following formula (Depending on the data type for latitude and longitude):
*/

USE Weather
GO

IF NOT EXISTS ( SELECT * FROM sys.columns WHERE object_id =
OBJECT_ID(N'[dbo].[AQS_Sites]') AND name = 'GeoLocation')
BEGIN
ALTER TABLE [AQS_Sites] ADD GeoLocation GEOGRAPHY;
END
GO

--Update the geography column
UPDATE [dbo].[AQS_Sites]
SET [GeoLocation] = geography::Point([Latitude], [Longitude], 4326)
GO

/* 
	a.	The name of the stored procedure must be UCID_Fall2022_Calc_GEO_Distance
	b.	The stored procedure must have the following variables:
		i.		@longitude ¡V This will contain the longitude of the starting location
		ii.		@latitude ¡V this contains the latitude of the starting location
		iii.	@State ¡V this contains the state name to get the data for
		iv.	@rownum ¡V this contains the number of rows the stored procedure will return
	c.	The logic in the stored procedure must do the following:
			i.	Select the site number, Local_Site_Name, Address, City_Name, State_Name, Zip_Code, Distance_In_Meters, Latitude, Longitude and Hours_of_Travel. If the Local_Site_Name is null, generate a value for the column by concatenating the Site_Number and City_Name 
		ii.	Distance_In_Meters must be calculated using the following equation:
			geoLocation.STDistance(@h) where @h is a geography variable calculated from the latitude and longitude of the starting location. 
		iii.	Hours_of_Travel must be calculated using the following formula
			(geoLocation.STDistance(@h) * *0.000621371)/55 (Assume you¡¦ll be traveling at the legal speed limit)
	d.	The DDL that creates the stored procedure must:
		i.	check to see if the procedure exists and delete prior versions
		ii.	include 2 exec statements for UCID_Fall2022_Calc_GEO_Distance at the end that runs the stored procedure with different variable values
*/



USE Weather
GO
IF EXISTS (SELECT * FROM sysobjects WHERE id =
object_id(N'[dbo].ch35_Fall2022_Calc_GEO_Distance') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
DROP PROCEDURE [dbo].ch35_Fall2022_Calc_GEO_Distance
END
GO

CREATE PROCEDURE ch35_Fall2022_Calc_GEO_Distance
( @longitude varchar(50),
  @latitude varchar(50),
  @StateName varchar(50),
  @rownum int)
 AS
BEGIN
SET NOCOUNT ON;
Declare @h geography 
SET @h = geography::Point(@latitude, @longitude, 4326)
SELECT TOP(@rownum) Site_Number, Case When Local_Site_Name is null or Local_Site_Name = '' then Site_Number + ' ' + City_Name else [Local_Site_Name] end AS [Local_Site_Name] , [Address],City_Name,State_Name,Zip_Code,GeoLocation.STDistance(@h) as Distance_In_Meters, Latitude,Longitude, (GeoLocation.STDistance(@h))*0.000621371/55 as [Hours_of_Travel]
From aqs_sites
Where State_Name = @StateName
Order by Site_Number,Local_Site_Name
END
GO


/*EXEC [Stored Procedure Name] ¡V change the name to the one you used
@latitude = '36.778261',
@longitude = '-119.417932',  
@State = 'California', 
@rownum = 30
GO*/


EXEC [ch35_Fall2022_Calc_GEO_Distance] 
@latitude = '40.764820',
@longitude = '-74.143820',  
@StateName = 'New Jersey', 
@rownum = 30
GO
