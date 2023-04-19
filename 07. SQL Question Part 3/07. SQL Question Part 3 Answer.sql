Use Summer_2022_BaseBall;
GO

IF OBJECT_ID('IS631view', 'V') IS NOT NULL
    DROP VIEW IS631View;
GO
create view IS631View 
As
With 
Player as
	(Select playerid, nameGiven + ' ( ' + nameFirst + ' ) ' + NameLast as [Full Name]
		from people),
AvSalaries as
	(select playerid, avg(Salary) as [Average Salary], sum(salary) as [Total Salary]
		from salaries
		group by playerid), 
CareerBat AS
	( select playerid, sum(HR) as CareerRuns, convert(Decimal(6,4),(Sum(H)*1.0/sum(AB))) as CareerBA,
			 Convert(Decimal(6,4),max(H*1.0/AB)) as MaxBA, max(yearid) as LastPlayed
		from Batting
		where AB > 0
		group by PLayerid),
CareerPitch As
	(select PLayerid, Sum(W) as CareerWins, sum(l) as CareerLoss, Sum(HR) as CareerPHR, Convert(Decimal(5,2),avg(ERA)) as AvgERA, MAX(ERA) as MaxERA, SUm(SO) as [Career SO], max(so) as [High SO]
		from pitching
		group by playerid)
select player.playerid, player.[Full NAme], 
		[Average Salary], [Total Salary], CareerBA, MaxBA, CareerWins, CareerLoss, CareerPHR, AvgERA, MaxERA, [Career SO], [High SO], LastPlayed
	from Player
		left join AvSalaries on player.playerid = AvSalaries.playerID
		left join CareerBat on PLayer.PLayerid = CareerBat.playerid
		left join CareerPitch on player.playerid = CareerPitch.playerid


go
select * from IS631View
select count(*) from IS631View
select count(*) from people

---------------------------------------------------------------------------

-- 1.	Using the view provided in the assignment page, write a query that uses the RANK function to rank the careerBA column where the careerBA < 0.40. Your results must show the playerid, Full Name, CareerBA and the rank for the players. The full name in all questions must use the function you created in the Chapter #2 ¡V Function Assignment

select playerid,[Full Name], CareerBA, RANK() OVER(ORDER BY CareerBA desc) [BA_rank] 
from IS631view
where CareerBA <.40
order by BA_rank


-- 2.	Write the same query as #2 but eliminate any gaps in the ranking 

select playerid, [Full Name] , CareerBA, DENSE_RANK() OVER(ORDER BY CareerBA desc) [BA_rank] 
from IS631view
where CareerBA <.40
order by BA_rank; 


-- 3.	Write the same query as #1, but find the ranking within the last year played by the player starting with the most current year and working backwards. Also eliminate any player where the career batting average is = 0.

select playerid, [Full NAme], lastplayed, careerBA,
rank() over (partition by lastplayed order by careerBA desc) as BA_rank
from IS631view
where careerBA >0
order by lastplayed desc, ba_rank 


-- 4.	Write the same query as #3, but show the ranking by quartile ( use the NTILE(4) parmeter)

select playerid, [Full Name] , LastPlayed, CareerBA, NTILE(4) OVER(ORDER BY LastPlayed desc) [BA_rank] 
from IS631view
where CareerBA >0 and CareerBA < 0.40
order by LastPlayed desc, CareerBA desc; 


-- 5.	Using the Salaries table, write a query that compares the averages salary by team and year with the windowed average of the 3 prior years and the 1 year after the current year. 
-- Note: You will need to use multiple subqueries to get the answer.

Select S.teamID, S.yearID, FORMAT(S.[Year Avg],'C') as Avg_Salary, format(avg([Year Avg]) over (order by yearid rows between 3 preceding and 1 following),'C') as Windowed_Salary
from (Select teamID, yearID, AVG(salary) as [Year Avg]
from Salaries Group by teamID, yearID) S
order by teamID, yearID 


-- 6.	Write a query that shows that teamid, playerid, Player Full Name, total hits, total at bats, total batting average (calculated by using sum(H)*1.0/sum(AB) as the formula) and show the players rank within the team and the rank within all players. Only include players that have a minimum of 150 career hits. 

select teamID, playerID,[Full Name],[Total Hits], [Total At Bats], CAST([Batting Avg] AS decimal(5,4) ) as [Bastting Avg], RANK() OVER(PARTITION BY teamid ORDER BY [Batting Avg] DESC) as [Team Batting Rank], DENSE_RANK() OVER(ORDER BY [Batting Avg] desc) as [All Batting Rank]
from (select teamid, Batting.playerID, I.[Full Name], Sum(Batting.h) as [Total Hits], sum(Batting.AB) as [Total At Bats],sum(H)*1.0/sum(AB) as [Batting Avg]
		from Batting left join IS631view I on Batting.playerID = I.PlayerID
where Batting.AB > 150
group by batting.playerID, Batting.teamID, I.[Full Name]) A
order by teamID, [Batting Avg] desc; 


-- 7.	You¡¦ve decided that due to the number of queries that use the Salaries table, you need to create a primary key consisting of Playerid, Teamid, Yearid and LGID. When try to create the primary key, you will be told that there are duplicate records. You will receive the following error

-- Msg 1505, Level 16, State 1, Line 308
-- The CREATE UNIQUE INDEX statement terminated because a duplicate key was found for the object name 'dbo.Salaries' and the index name 'PK__Salaries__89095551BDD28FCE'. The duplicate key value is (NL, ARI , 2019, GreinZa01).

-- Note that SQL Server stops when a single error is found when creating indexes. Although a key is provided, that is not the only row that needs the duplicate removed. There are 35 duplicate keys as identified by the following query

select playerid, yearid, lgid, teamid, count(*)
from salaries
group by playerid, yearid, lgid, teamid
having count(*) >1;

--  Write a query that performs the following steps:
--	 a.	Using a SELECT * INTO query, create a temporary copy of the Salaries table named #Salaries
--	 b.	Using the row_number function method described in the hint below, write the query that will remove the duplicate records in the #salaries table so that you can create the primary key. 
--	 c.	Create the appropriate primary key for the #Salaries table

--   Hint: Use the Row_Number in a WITH statement and then delete from the WITH statement where row number > 1

select *
into #Salaries
from Salaries

select * from #Salaries
select * from Salaries

ALTER TABLE [dbo].[#Salaries] Alter column playerid [varchar](255) not NULL;
ALTER TABLE [dbo].[#Salaries] Alter column yearid [int] not NULL;
ALTER TABLE [dbo].[#Salaries] Alter column lgid [varchar](25) not NULL;
ALTER TABLE [dbo].[#Salaries] Alter column teamid [varchar](255) not NULL;

With cte as
	(select playerid, yearid, lgid, teamid, 
		ROW_NUMBER () over (partition by playerid, yearid, lgid, teamid 
						order by playerid, yearid, lgid, teamid) as rownum
		from #salaries)
delete from cte where rownum >1

ALTER TABLE #salaries ADD CONSTRAINT PK_#salaries PRIMARY KEY (playerid,yearid,lgid,teamid);




-- 8.	Using a recursive CTE, write a query that will generate the days of the week using the DATENAME(DW, N) function where N indicates the day of the week. Your query must recurse and use N+1 to get the next day of the week. The output should be:

WITH days_cte (n, weekday)
AS
(
    SELECT 0, DATENAME(DW, 0)
    UNION ALL
    SELECT n + 1, DATENAME(DW, n + 1) FROM days_cte
    WHERE n < 6 
)
SELECT weekday FROM days_cte;