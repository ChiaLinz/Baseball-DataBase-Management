USE Weather
GO
--Adding geography column
IF NOT EXISTS ( SELECT * FROM sys.columns WHERE object_id =
OBJECT_ID(N'[dbo].[GunCrimes]') AND name = 'GeoLocation')
BEGIN
ALTER TABLE [GunCrimes] ADD GeoLocation GEOGRAPHY;
END
GO

--Update the geography column
UPDATE [dbo].[GunCrimes]
SET [GeoLocation] = geography::Point([Latitude], [Longitude], 4326)
GO

-- Submission 3 ¡V GunCrime 
/*
1.	In addition to the temperature, you are also very concerned with crime in the area. You¡¦ve searched very hard and have been unable to find data that easily correlates to the temperature data. The best data you can find is the GunCrime.csv file in the Weather.zip file you downloaded in the beginning of the project. 
2.	Import the GunCrime.csv file into the database using the same method you used for the temperature and AQS_Sites data. Similar to step 11 in Part1, you need to make the following changes in the Advanced Tab:
a.	The column date needs to be changed to have a datatype of date [DT_DATE]
b.	For all columns except incident_id, date and state change the OutputColumnWidth to 5000
c.	For Gun_type needs to change the OutputColumnWidth to 8000
This should import a total of 239,677 rows */

-- 3.	Using the same methods as you used in Step 1 of Part 4, create and populate a geography column to the GunCrimes table you just created
--	a.	Update the procedure you wrote for Part 2 of the project to also identify the number of crimes within 10 miles (16000 meters) of each site in the state you pass to the stored procedure by year that the crime was committed. Note: you will need consider that there are no columns to join the GunCrimes and AQS_Sites tables together, so you need to create a Cartesian Product and filter data out in the where statement using the following formula (which you¡¦ll need to modify) and the location data from your queries geoLocation.STDistance(@h) 

-- 4.	Write a query that ranks all the cities in the state you selected from lowest to highest number of GunCrimes 

 CREATE or alter PROCEDURE Gun_Rank
( @longitude varchar(50),
  @latitude varchar(50),
  @StateName varchar(50),
  @rownum int)
 AS
BEGIN
SET NOCOUNT ON;
Declare @h GEOGRAPHY
SET @h = GEOGRAPHY::Point(@latitude, @longitude, 4326)
Select TOP(@rownum) A.Site_Number, d.local_Site_Name, A.[Address], d.City_Name, State_Name, Zip_Code,  (geoLocation.STDistance(@h)) as "distance in meters", (geoLocation.STDistance(@h)*0.000621371) as "distance in miles", (geoLocation.STDistance(@h)*0.000621371)/55 as "Hours of Travel", d.Crime_Year, d.Shooting_Count
       from aqs_sites a,(select Local_Site_Name, City_Name, datepart(year,date) as Crime_Year, count(incident_id) as Shooting_Count 
                    from aqs_Sites, Guncrimes
                           where (aqs_sites.GeoLocation.STDistance(Guncrimes.GeoLocation)) < 16090 --- 10 miles
                                        and aqs_Sites.State_Name =  @StateName
                           group by Local_Site_Name, City_Name, datepart(year,date)
                           ) D						   

       where a.local_Site_name = d.Local_Site_Name and            
             a.Local_Site_Name <> ''
Order By  d.local_Site_Name
END
GO


EXEC [Gun_Rank] 
@latitude = '40.764820',
@longitude = '-74.143820',  
@StateName = 'New Jersey', 
@rownum = 30
GO
-- 5.	Use your stored procedure to dense rank the cities by the number of shootings in descending order. Note you will need to use a row_num value that returns all the data for the state. See the SQL Server select from stored procedure return table section of this site: SQL Server select from stored procedure (9 Examples) - SQL Server Guides for instructions on how to use a stored procedure in a select query. The following used New Jersey as the state_name

drop table #tmpGunRank;
 --Create temp table
CREATE TABLE #tmpGunRank (
	site_number varchar(50),
	local_Site_Name varchar(255),
	address varchar(5000),
	city_name VARCHAR(255),
	state_name varchar(50),
	zip_code varchar(50),
	[distance in meters] float,
	[distance in miles] float,
	[Hours of Travel] float,
	crime_year int,
	Shooting_Count int
);
GO

--Storing values from procedure into temp table
INSERT INTO #tmpGunRank
EXEC [Gun_Rank] 
@latitude = '40.764820',
@longitude = '-74.143820',  
@StateName = 'New Jersey', 
@rownum = 30
GO
GO

select state_name, city_name, Shooting_Count as shottings, ROW_NUMBER() OVER(ORDER BY Shooting_Count desc) as gun_rank
from #tmpGunRank
order by gun_rank