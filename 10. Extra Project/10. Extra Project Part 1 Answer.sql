Use Weather
go
IF NOT EXISTS(
    SELECT *
    FROM sys.columns 
    WHERE Name      = N'GeoLocation'
      AND Object_ID = Object_ID(N'AQS_Sites'))
BEGIN
      ALTER TABLE AQS_Sites ADD GeoLocation Geography NULL
END
go

Alter Table AQS_Sites Alter Column Latitude float null;


UPDATE [dbo].[aqs_sites]
SET [GeoLocation] = geography::STPointFromText('POINT(' + CAST([LONGITUDE] AS VARCHAR(max)) 
+ ' ' + CAST([Latitude] AS VARCHAR(max)) + ')', 4326)
WHERE [LATITUDE] > 0 and latitude <> ''


-- 1.	Find the minimum, maximum and average of the average temperature column for each state sorted by state name.

Alter Table Temperature Alter Column Average_Temp float null;

Select distinct State_Name, min(Average_Temp) as [Minimum Temp], max(Average_Temp) as [Maximum Temp], avg(Average_Temp) as [Average Temp]
From (select State_Name, Average_Temp 
	  From Temperature T , AQS_Sites A
	  Where T.Site_Num = A.Site_Number ) P
Group By State_Name
Order By State_Name;



-- 2.	The results from question #2 show issues with the database.  Obviously, a temperature of -99 degrees Fahrenheit in Arizona is not an accurate reading as most likely is 135.5 degrees for Delaware.  Write a query to count all the suspect temperatures (below -39o and above 105o). Sort your output by State_Name, state_code, County_Code, and Site_Number


SELECT State_Name as [State Name], T.State_Code as [State Code], T.County_Code as [County Code], T.Site_Num as [Site Number], Count( T.Site_Num) as [Num_Bad_Entries]
FROM Temperature T
 LEFT JOIN AQS_Sites A 
		ON A.State_Code = T.State_Code and 
	       A.County_Code = T.County_Code and 
		   A.Site_Number = T.Site_Num 
WHERE T.Average_Temp < -39.0 or T.Average_Temp > 105.0
Group By  T.Site_Num, State_Name, T.State_Code, T.County_Code
Order By [State Name], [State Code], [County Code],  [Site Number]

---select average_Temp
---from Temperature
---where Average_Temp < -39.0 or Average_Temp > 105.0

-- 3.	You noticed that the average temperatures become questionable below -39 o and above 125 o and that it is unreasonable to have temperatures over 105 o for state codes 30, 29, 37, 26, 18, 38. You also decide that you are only interested in living in the United States, not Canada or the US territories. Create a view that combines the data in the AQS_Sites and Temperature tables. The view should have the appropriate SQL to exclude the data above. You should use this view for all subsequent queries. My view returned 5,616,127 rows. The view includes the State_code, State_Name, County_Code, Site_Number. Make sure you include schema binding in your view for later problems.

--- If you want to verify your view is correct, display the count of rows grouped by state. Please do not use a select * since it runs for a long time. The results would look like the following:


IF EXISTS(select * FROM sys.views where name = 'Temp_View')
BEGIN
DROP VIEW Temp_View
END
GO


--WITH SCHEMABINDING

CREATE VIEW Temp_View WITH SCHEMABINDING
AS
SELECT T.State_Code, State_Name, T.County_Code, T.Site_Num, Average_Temp, City_Name, Date_Local
FROM dbo.Temperature T, dbo.AQS_Sites A
WHERE T.State_Code = A.State_Code and
	  T.Site_Num = A.Site_Number and
	  T.County_Code = A.County_Code and
	  (Average_Temp > -39 or Average_Temp < 125) and
	  State_Name NOT IN ('Canada','Country Of Mexico','District Of¡@Columbia','Guam','Puerto Rico','Virgin Islands')
Go

/*
 CREATE VIEW Temp_View AS
WITH
Temp_Data AS
(SELECT * FROM Temperature
WHERE Average_Temp > -39 OR Average_Temp < 125),
AQS_data AS
(SELECT * FROM AQS_Sites
WHERE State_Name NOT IN ('Canada','Country Of Mexico','District Of¡@Columbia','Guam','Puerto Rico','Virgin Islands'))
SELECT Temp_Data.State_Code, State_Name, Temp_Data.County_Code, Temp_Data.Site_Num, Average_Temp, City_Name
FROM Temp_Data, AQS_data
WHERE Temp_Data.State_Code = AQS_data.State_Code AND
Temp_Data.Site_Num = AQS_data.Site_Number AND
Temp_Data.County_Code = AQS_data.County_Code
GO
*/

--BEGIN
--Select * from Temp_View
--END

Select State_code, Count(state_code) as row_conut
From Temp_View
Group By State_code
Order By State_code;




-- 4.	Using the SQL RANK statement, rank the states by Average Temperature

SELECT State_Name, MIN(Average_Temp) AS 'Minimum Temp', MAX(ABS(Average_Temp))
AS 'Maximum Temp', AVG(Average_Temp) AS 'Average Temp', RANK() OVER(ORDER BY
AVG(Average_Temp) DESC) AS 'State_rank'
FROM Temp_View
GROUP BY State_Name
ORDER BY State_rank



-- 5.	At this point, you¡¦ve started to become annoyed at the amount of time each query is taking to run. If you click the   button and execute the query you wrote for #4, you will see something like the execution plan below. 
-- You¡¦ve heard that creating indexes can speed up queries. Create an index for your view (not the underlying tables). You are required to create a single  index with the unique and clustered parameters and the index will be on the State_Code, County_Code, Site_Number, average_temp, and Date_Local columns. DO NOT create the index on the tables, the index must be created on the VIEW.


CREATE Unique Clustered INDEX idx_State 
ON dbo.Temp_View (State_Code, County_Code, Site_Num, average_temp, Date_Local);



-- 6.	There are 270,511 duplicate rows that you must delete before you can create a unique index. Use the Rownumber parameter in a partition statement and deleted any row where the row number was greater than 1. (Remember the problem in the Chapter 5 SQL assignment?)

with a as
(select State_Code, County_Code, Site_Num, Date_Local,
          ROW_NUMBER() over( partition by State_Code, County_Code, Site_Num, Date_Local 
                order by State_Code, County_Code, Site_Num, Date_Local ) as rownum
          from Temperature)
delete from a where rownum > 1


-- 7.	You¡¦ve decided that you want to see the ranking of each high temperatures for each city in each state to see if that helps you decide where to live. Write a query that ranks (using the rank function) the states by averages temperature and then ranks the cities in each state. The ranking of the cities should restart at 1 when the query returns a new state. You also want to only show results for the 15 states with the highest average temperatures.

--- Note: you will need to use multiple nested queries to get the State and City rankings, join them together and then apply a where clause to limit the state ranks shown.

SELECT [State Rank], S.State_Name, [State City Rank], City_Name, [Avg Temp]
FROM (SELECT State_Name, RANK() OVER(ORDER BY AVG(Average_Temp)
 DESC) AS [State Rank]
 FROM [Temp_View] GROUP BY State_Name) S,
 (SELECT State_Name, RANK() OVER(PARTITION BY State_Name
ORDER BY
 AVG(Average_Temp) DESC) AS [State City Rank], City_Name,
 AVG(Average_Temp) AS [Avg Temp] 
 FROM Temp_View
 GROUP BY State_Name, City_Name) C
WHERE C.State_Name = S.State_Name
AND [State Rank] <= 15
ORDER BY [State Rank],[State City Rank]

-- 8.	You notice in the results that sites with Not in a City as the City Name are include but do not provide you useful information. Exclude these sites from all future answers. You can do this by either adding it to the where clause in the remaining queries or updating the view you created in #4. Include the SQL for #7 with the revised answer 

SELECT [State Rank], S.State_Name, [State City Rank], City_Name, [Avg Temp] 
FROM (SELECT State_Name, RANK() OVER(ORDER BY AVG(Average_Temp)
 DESC) AS [State Rank]
 FROM [Temp_View] 
 GROUP BY State_Name) S,
 (SELECT State_Name, RANK() OVER(PARTITION BY State_Name
ORDER BY
 AVG(Average_Temp) DESC) AS [State City Rank], City_Name,
 AVG(Average_Temp) AS [Avg Temp] 
 FROM [Temp_View]
 WHERE City_Name <> 'Not in a City'
 GROUP BY State_Name, City_Name) C
WHERE C.State_Name = S.State_Name
AND [State Rank] <= 15
ORDER BY [State Rank], [State City Rank] 


-- 9.	You¡¦ve decided that the results in #8 provided too much information and you only want to 2 cities with the highest temperatures and group the results by state rank then city rank. 

SELECT [State Rank], S.State_Name, [State City Rank], City_Name, [Avg Temp]
FROM (SELECT State_Name, RANK() OVER(ORDER BY AVG(Average_Temp)
 DESC) AS [State Rank]
 FROM [Temp_View] 
 GROUP BY State_Name) S,
 (SELECT State_Name, RANK() OVER(PARTITION BY State_Name
ORDER BY
 AVG(Average_Temp) DESC) AS [State City Rank], City_Name,
 AVG(Average_Temp) AS [Avg Temp] 
 FROM [Temp_View]
 WHERE City_Name <> 'Not in a City'
 GROUP BY State_Name, City_Name) C
WHERE C.State_Name = S.State_Name and
	  [State Rank] <= 15 and [State City Rank] <=2
ORDER BY [State Rank], [State City Rank]


-- 10.	You decide you like the monthly average temperature to be at least 70 degrees. Write a query that returns the states and cities that meets this condition, the number of months where the average is above 70, the number of days in the database where the days are about 70 and calculate the average monthly temperature by month. 

-- Hint, use the datepart function to identify the month for your calculations.


SELECT State_Name, City_Name, Count(distinct DATEPART(MONTH,Date_Local)) [# of months],
Count(Average_Temp) [# of Day in Average], AVG(Average_Temp) as [Average Temp]
From Temp_View
WHERE City_Name <>'Not in a City'
Group by State_Name, City_Name
Having AVG(Average_Temp) > 69.9
Order by State_Name, City_Name 


-- 11.	You assume that the temperatures follow a normal distribution and that the majority of the temperatures will fall within the 40% to 60% range of the cumulative distribution. Using the CUME_DIST function, show the temperatures for the cities having an average temperature of at least 70 degrees that fall within the range.



Select distinct State_Name, City_Name, Avg_Temp, Temp_Cume_Dist
from (select State_Name, City_Name, round(Avg_Temp,0) as Avg_Temp,
            Cume_Dist () over(partition by State_Name, City_Name order by round(q.Avg_Temp,0) asc) as Temp_CUme_Dist
            from (select State_Name, City_Name, round(Average_Temp,0) as Avg_Temp
                    from Temp_View
                    where city_name <> 'Not in a City'
                        and city_Name in (select city_name from (select city_name, avg(average_temp) as atmp
                                            from Temp_View
                                            group by city_name
                                            having round(avg(average_temp),0) > 69.9) a)   
											)q) c
            where c.Temp_CUme_Dist between .40 and .60     
order by State_Name, City_Name, Temp_CUme_Dist

-- 12.	You decide this is helpful, but too much information. You decide to write a query that shows the first temperature and the last temperature that fall within the 40% and 60% range for cities you are focusing on in question #11.

SELECT State_Name, AB.City_Name, MIN(AB.Avg_Temp) as [40 Percentile Temp], MAX(AB.Avg_Temp) as[60 Percentile Temp]
FROM
	(SELECT A.State_Name, A.City_Name [City_Name], A.Average_Temp [Avg_Temp], A.CumeDist,A.PercentRank
	 FROM
(SELECT distinct State_Name, A.City_Name, Average_Temp,
CUME_DIST () OVER (PARTITION BY a.city_name ORDER BY Average_Temp)
AS CumeDist,
PERCENT_RANK() OVER (PARTITION BY a.city_name ORDER BY Average_Temp ) as PercentRank
From Temperature T
INNER JOIN AQS_Sites a on a.State_Code = t.State_Code and
a.County_Code = t.County_Code and a.Site_Number = t.Site_Num) A
Where ROUND(A.PercentRank,4)> 0.400 and 
	  ROUND(A.PercentRank,4) < 0.600) AB
Where city_name <> 'Not in a City'
Group By AB.State_Name, AB.City_Name
Order By AB.State_Name ASC



-- 13.	You remember from your statistics classes that to get a smoother distribution of the temperatures and eliminate the small daily changes that you should use a moving average instead of the actual temperatures. Using the windowing within a ranking function to create a 4 day moving average, calculate the moving average for each day of the year. 

-- Hint: You will need to datepart to get the day of the year for your moving average. You moving average should use the 3 days prior and 1 day after for the moving average.


SELECT AB.[City Name], AB.DayYear,¡@AVG(AB.Temp) Over(partition by AB.[City Name] order by AB.DayYear rows
between 3 preceding and 1 following) as [Rolling Avg Temp]
FROM
	(SELECT A.City_Name as [City Name], DATEPART(DAYOFYEAR,Date_Local)¡@as [DayYear], AVG(Average_Temp) as [Temp]
	 From Temperature T
		  INNER JOIN AQS_Sites a on A.State_Code = T.State_Code and 
		  A.County_Code = T.County_Code and 
		  A.Site_Number = T.Site_Num
	 WHERE A.City_Name in ('Mission') and City_Name <> 'Not in a City'
     Group by A.City_Name, DATEPART(DAYOFYEAR,Date_Local)) AB
Order By AB.[City Name], AB.DayYear;

