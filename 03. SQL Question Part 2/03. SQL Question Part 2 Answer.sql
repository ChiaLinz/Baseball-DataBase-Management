Use Summer_2022_BaseBall
go
-- 1.	Write a query that lists the playerid, birthcity, birthstate, Hits (H), At Bats (AB), salary and batting average for all players born in New Jersey sorted by first name and year in ascending order using the PEOPLE, SALARIES and BATTING tables. The joins must be made using the WHERE clause. Make sure values are properly formatted.
-- Note: your query should return 362 rows using the where statement to resolve divide by zero error or 453 rows using nullif 

select P.PlayerID, P.birthcity, P.birthstate, B.teamID, B.H, B.AB, format(salary,'C') as Salary, convert(decimal(5,4),(B.H*1.0/(B.AB))) as   [Batting Average] 
from People P, salaries S, Batting B
where P.PlayerID = B.PlayerID
		and P.PlayerID = S.PlayerID
		and B.teamID = S.teamID
		and B.yearID = S.yearID
		and P.birthState = 'NJ'
		and B.AB > 0
order by P.nameFirst ASC, S.yearID ASC

-- using nullif 
select P.PlayerID, P.birthcity, P.birthstate, B.teamID, B.H, B.AB,  format(salary,'C') as Salary, convert(decimal(5,4),(B.H*1.0/NULLIF(B.AB, 0))) as   [Batting Average] 
from People P, salaries S, Batting B
where P.PlayerID = B.PlayerID
		and P.PlayerID = S.PlayerID
--		and S.PlayerID = B.PlayerID
		and B.teamID = S.teamID
		and B.yearID = S.yearID
		and P.birthState = 'NJ'
--		and B.AB > 0
order by P.nameFirst ASC, S.yearID ASC


-- 2.	Write the same query as #2 but use LE 
-- Notes: Using the where statement for divide by zero returns 1970 rows, 2,322 rows will be returned using nullif. Order matters in this question. If you JOIN PEOPLE and SALARIES first, all players with no salary information will have a 0.0000 batting average. You will see some duplicates in your results due to problems in the Salary table. Running the following query will identify the duplicates.


-- Findings
--	Use left join will keep row on left hand table and show null rows
--	Join the null table last to prevent data not match

select P.PlayerID, P.birthcity, P.birthstate, P.birthYear, S.yearID, format(salary,'C') as Salary, convert(decimal(5,4),(B.H*1.0/(B.AB))) as   [Batting Average] 
from People P
left join Batting B on P.PlayerID = B.PlayerID 
left join salaries S on  B.teamID = S.teamID and P.PlayerID = S.PlayerID and B.yearID = S.yearID
where P.birthState = 'NJ'
		and B.AB > 0
order by S.Salary DESC, P.nameFirst ASC, S.yearID ASC


-- 3.	You get into a debate regarding the level of school that professional sports players attend. Your stance is that there are plenty of baseball players who attended Ivy League schools and were good batters in addition to being scholars. Write a query to support your argument using the CollegePlaying and HallofFame tables. You must use an IN clause in the WHERE clause to identify the Ivy League schools. Only include players that were indicted into the HallofFame (Inducted = Y). Sort you answer by schoolid in ascending order and Batting Average in descending order. Your answer should return 2 rows and contain the columns below.  Note the yearid is the year for the batting average not the year in College Playing. The colleges in the Ivy League are Brown, Columbia, Cornell, Dartmouth, Harvard, Princeton, UPenn, and Yale. You will need to use the BATTING and COLLEGEPLAYING tables.

select distinct C.playerid, C.schoolid 
from Batting B, CollegePlaying C, HallOfFame H
where 	B.playerID = H.playerID
		and C.playerID = H.playerID
--		and B.yearID = H.yearid  
		and H.inducted = 'Y'
		and C.schoolID IN ('Brown', 'Columbia', 'Cornell', 'Dartmouth', 'Harvard', 'Princeton', 'UPenn', 'Yale')
order by schoolid ASC

-- 4.	You are now interested in the longevity of players careers. Using the BATTING table and the appropriate SET clause from slide 45 of the Chapter 3 PowerPoint presentation, find the players that played for the same teams in 2016 and 2021. Your query only needs to return the playerid and teamids. The query should return 138 rows.

select playerid, teamid
from Batting
where yearid = 2016
INTERSECT (select playerid, teamid
			from Batting
			where yearid = 2021)

-- 5.	Using the BATTING table and the appropriate SET clause from slide 45 of the Chapter 3 PowerPoint presentation, find the players that played for the different teams in 2016 and 2021 Your query only needs to return the playerids and the **2016** teamid. The query should return 1,344 rows.

select playerid, teamid
from Batting 
where yearID = 2016
EXCEPT
 (select playerid, teamid
  from Batting 
  where yearid = 2021)


-- 6.	Using the Salaries table, calculate the average and total salary for each player. Make sure the amounts are properly formatted and sorted by the total salary in descending order. Your query should return 6,246 rows.

select playerid, format(avg(salary),'C') as [Average Salary], format(sum(salary),'C') as [Total Salary]
from Salaries
Group by playerid
Order by sum(salary) DESC


-- 7.	Using the Batting  and People tables and a HAVING clause, write a query that lists the playerid, the players full name, the number of home runs (HR) for all players having more than 400 home runs and the number of years they played. The query should return 57 rows.

select P.playerid, ( P.namefirst + ' ( ' + P.nameGiven + ' ) ' +  P.nameLast) as [Full Name],  sum(B.HR) as [Total Home Runs], count(B.yearID) as Years_Played
from Batting B, People P
where B.playerid = P.playerid
Group by P.playerid, P.nameGiven, P.namefirst,  P.nameLast
Having sum(B.HR) > 400
Order by sum(B.HR) DESC


--  8.	Hitting 500 home runs is a hallmark achievement in baseball. You want to project if the players with under 500 but more than 400 home runs will have over 500 home runs, assuming they will play for a total of 22 years like the top lpayers in question 7. To create your estimates, divide the total number of home runs by the years played and multiply by 22. Use a BETWEEN clause in the HAVING statement to identify players having between 400 and 499 home runs.  This will return 18 rows

select P.playerid, ( P.namefirst + ' ( ' + P.nameGiven + ' ) ' +  P.nameLast) as [Full Name], sum(B.HR) as [Total Home Runs], count(B.yearID) as Years_Played, (sum(B.HR)/count(B.yearID)*22) as Projected_HR
from Batting B, People P
where B.playerid = P.playerid
Group by P.playerid, P.nameGiven, P.namefirst,  P.nameLast
Having sum(B.HR) between 400 and 499 and (sum(B.HR)/count(B.yearID)*22) > 500
Order by (sum(B.HR)/count(B.yearID)*22) DESC, sum(B.HR) DESC


-- 9.	Using a subquery along with an IN clause in the WHERE statement, write a query that identifies all the playerids, the players full name and the team names who in 2021 that were playing on teams that existed prior to 1910. You should use the appearances table to identify the players years and the TEAMS table to identify the team name. Sort your results by players last name. Your query should return 613 rows.

select A.playerid, ( P.nameGiven + ' ( ' +  P.namefirst + ' ) ' +  P.nameLast) as [Full Name], T.name as Team_Name
from Appearances A, Teams T, People P 
where  A.playerid = P.playerid 
		and T.teamID = A.teamID
		and T.yearID = A.yearID
		and A.teamID IN (select teamID 
						 from Appearances
						 where yearID < 1910)
		and A.yearID = 2021
Order by P.nameLast

--  10.	Using the Salaries table, find the players full name, average salary and the last year they played  for each team they played for during their career. Also find the difference between the players salary and the average team salary. You must use subqueries in the FROM statement to get the team and player average salaries and calculate the difference in the SELECT statement. Sort your answer by the last year in descending order , the difference in descending order and the playerid in ascending order. The query should return 12,928 rows


select P.playerid, ( P.nameGiven + ' ( ' +  P.namefirst + ' ) ' +  P.nameLast) as [Full Name], S1.teamid, lastyear as [Last Year], format(player_avg, 'C') as [Player Average], format(team_avg, 'C') as [Player Average], format((player_avg - team_avg), 'C') as [Difference]
from People P,
(select playerid, max(yearid) as lastyear, avg(salary) as player_avg, teamid
 from Salaries
 Group by playerid, teamid) S1,
 (select teamid, avg(salary) as team_avg
 from Salaries
 Group by teamID) S2
 where S1.teamid = S2.teamid
		and S1.playerid = P.playerid
Order by lastyear DESC, player_avg - team_avg DESC, P.playerid ASC;



-- 11.	Rewrite the query in #11 using a WITH statement for the subqueries instead of having the subqueries in the from statement. The answer will be the same. Please make sure you put a GO statement before and after this problem. 5 points will be deducted if the GO statements are missing and I have to add them manually.

with S1 as 
(select playerid, max(yearid) as lastyear , avg(salary) as player_avg, teamID
 from Salaries
 Group By playerID, teamID),

	 S2 AS
(select teamid, avg(salary) as team_avg
 from Salaries
 Group By teamID) 

select P.playerid, ( P.nameGiven + ' ( ' +  P.namefirst + ' ) ' +  P.nameLast) as [Full Name], S1.teamid, lastyear as [Last Year], format(player_avg, 'C') as [Player Average], format(team_avg, 'C') as [Player Average], format((player_avg - team_avg), 'C') as [Difference]
from People P, S1, S2
 where S1.teamid = S2.teamid
		and S1.playerid = P.playerid
Order by lastyear DESC, player_avg - team_avg DESC, P.playerid ASC


-- 12.	Using a scalar queries in the SELECT statement and the salaries, batting, pitching and people tables , write a query that shows the full Name, the average salary, career batting average, career ERA and the number of teams the player played. Format the results as shown below and only use the PEOPLE table in the FROM statement of the top level select. This query returns 20,370 rows

select ( P.nameGiven + ' ( ' +  P.namefirst + ' ) ' +  P.nameLast) as [Full Name],
       (select distinct count(teamid) from Salaries where P.playerID = Salaries.playerID) as [Total Teams],
       (select format(avg(salary),'C') from Salaries where P.playerID = Salaries.playerID) as [Avg Salary],
       (select avg(era) from pitching where P.playerID = pitching.playerID) as [Avg ERA],
       (select avg(h*1.0/ab) from batting where P.playerID = batting.playerID and ab > 0) as [Avg BA]
from people P
Order by  [Total Teams] DESC

 

-- NOTE: The columns required for problems #13 through #16 were created in the Add Additional Columns script. You do not need to create or alter any columns. Also, do not format the data you insert into the new columns, formatting the data within a table may make them  in unusable in calculations 



-- 13.	The player¡¦s union has negotiated that players will start to have a 401K retirement plan. Using the [401K Contributions] column in the Salaries table,  populate this column for each row by updating it to contain 6% of the salary in the row. You must use an UPDATE query to fill in the amount. This query updates 32,862 rows. Use the column names given, do not create your own columns. Include a select query with the results sorted by playerid as part of your answer that results the rows shown below.

update Salaries
set [401K Contributions] = (0.06*salary)

select playerid, salary, [401K Contributions]
from Salaries
order by playerid

-- 14.	Contract negotiations have proceeded and now the team owner will make a seperate contribution to each players 401K each year. If the player¡¦s salary is under $1 million, the team will contribute another 5%. If the salary is over $1 million, the team will contribute 2.5%. You now need to write an UPDATE query for the [401K Team Contributions] column in the Salaries table to populate the team contribution with the correct amount. You must use a CASE clause in the UPDATE query to handle the different amounts contributed. This query updates 32,862 rows.

update Salaries
set [401K Team Contributions] = case 
when salary < 1000000 then 0.05*salary
when salary > 1000000 then 0.025*salary
end

select playerid, salary, [401K Contributions], [401K Team Contributions]
from Salaries
order by playerid

-- 15.	You have now been asked to populate the columns to the PEOPLE table that contain the total number of HRs hit ( Total_HR column) by the player and the highest Batting Average the player had during any year they played ( High_BA column). Write a single query that correctly populates these columns. You will need to use a subquery to make is a single query. This query updates 17,593 rows if you use AB > 0 in the where statement. It updates 19,898 rows in nullif is used for batting average. After your update query, write a query that shows the playerid, Total HRs and Highest Batting Average for each player. The Batting Average must be formatted to only show 4 decimal places. Sort the results by playerid. The update query will update 17841 rows and the select query will return 20,370 rows.

update people
set Total_HR = 
(select sum(HR) 
 from batting B 
 where B.playerid = people.playerid 
 group by playerid ) 

update people
set High_BA = 
(select convert(decimal(5,4),max(H*1.0/AB)) 
 from batting B 
 where B.playerid = People.playerid
		and AB>0
Group by playerid)

select playerid, Total_HR, High_BA as Career_BA
from People
order by playerid


-- 16.	You have also been asked to populate a column in the PEOPLE table ( Total_401K column) that contains the total value of the 401K for each player in the Salaries table.  Write the SQL that correctly populates the column. This query updates 5,981 rows.  Also, include a query that shows the playerid, the player full name and their 401K total from the people table. Only show players that have contributed to their 401Ks. Sort the results by playerid. . This query returns 5,981 rows. 

update People
set [Total_401K] = (select sum([401K Contributions]+ [401K Team Contributions]) from salaries S
  where S.playerid = People.playerid
  Group by S.playerid)

select playerid, ( nameGiven + ' ( ' +  namefirst + ' ) ' +  nameLast) as [Full Name], format(Total_401K, 'C') as [401K Total] 
from People
where Total_401K is not null
order by playerid


-- 17.	2021 Fan Cost Index (the amount it costs for a group of four people to attend an MLB game was an average of $256.41. MLB management has asked you to calculate the following using the teamid, name, yearid, attendance and GHomes (# of home games) from teams table:
-- a.	The total amount the team lost due to covid (The difference between pre-COVID and COVID multiplied by the per person Fan Cost Index)
-- b.	The average loss per game (Total amount lost/Total number of COVID HGames)
-- c.	The number of extra games it would take to recover the losses (total amount lost / average loss per game
-- d.	Per-COVID average attendance (pre-COVID attendance/pre-COVID HGames)
-- e.	COVID average attendance (sum of attendance / sum HGames)
-- f.	COVID drop in per average game attendance (e minus d)
-- g.	% drop in attendance due to cover  (e divided by d)
-- Use values for 2020 and 2021 for the COVID value and 2019 for the pre-COVID values. 
-- Your query should return 30 rows.My recommendation is to use separate subqueries to get the required pre-COVID and COVID related data. You can then use the info in the main select to calculate the required values. 
 
 select A.teamid, A.name, format(A.Total_Loss, 'N') as Total_Team_Loss, 
		format(A.CV_per_Game_Loss, 'N') as CV_per_Game_$_Loss,
		cast((Total_Loss*-1/(Pre_CV_Avg_Game_Attendance*256.41/4)) as integer) Games_To_Recover,
		format(A.CV_Avg_Game_Attendance, 'N0') as CV_Avg_attendance,
		format(Pre_CV_Avg_Game_Attendance, 'N0') as  pre_CV_Avg_attendance,
		format((A.CV_Avg_Game_Attendance - Pre_CV_Avg_Game_Attendance), 'N0') as CV_drop_attendance,
		format((A.CV_Avg_Game_Attendance*1.0/Pre_CV_Avg_Game_Attendance), 'P')as [CV_%_drop]
 from (select T.teamid, T.name, cast((CV_avg_Game_Attendance - Pre_CV_Avg_Game_Attendance)*256.41/4*(cast(CV.Ghome as integer)) as Money) as Total_Loss, CV_Avg_Game_Attendance, Pre_CV_Avg_Game_Attendance, Pre_CV_Games, ((CV_Avg_Game_Attendance - Pre_CV_Avg_Game_Attendance)*256.41/4)/Ghome as CV_per_Game_Loss
		from (select distinct teamid, name
				from Teams
				where (attendance is not null or attendance = 0) 
						and yearid between 2020 and 2021) T
			left join (select teamid, name, sum(cast(Ghome as integer)) as Ghome, sum(cast(attendance as integer))/sum(cast(Ghome as integer)) as  CV_Avg_Game_Attendance
				from Teams
				where yearid between 2020 and 2021
				Group by teamid, name) CV on 
					T.name = CV.name 
					and T.teamid = CV.teamid
			left join (select teamid, name,Ghome as Pre_CV_Games, sum(cast(attendance as integer))/sum(cast(Ghome as integer)) as Pre_CV_Avg_Game_Attendance
				 from Teams
				 where yearid = 2019
				 Group by teamid, name, Ghome) PCV on
					T.teamid = PCV.teamid	
 ) A
 order by Total_Loss


-- EXTRA CREDIT

-- 18.	As with any job, players are given raises each year, write a query that calculates the increase each player received and calculate the % increase that raise makes. You will only need to use the SALARIES  and PEOPLE tables. You answer should include the columns below. Include the players full name and sort your results by playerid in ascending order and year in descending order. This query returns 15,569 rows. You cannot use advanced aggregate functions such as LAG for this question. The answer can be written using only the SQL parameters you learned in this chapter.

 select P.playerid, ( P.nameGiven + ' ( ' +  P.namefirst + ' ) ' +  P.nameLast) as [Player Name],
       S.yearid, format(S.salary,'C') as [Current Salary], format(S1.salary, 'C') as [Prior Salary],
	  format((S.salary - S1.salary),'C') as [Salary Difference],
       format((S.salary - S1.salary)/s1.salary,'P') as [Salary Increase]
from People P, Salaries S, Salaries S1
where S.playerid = P.playerid
      and s1.playerid = p.playerid 
	  and s1.yearid = s.yearid-1 
	  and s.teamid = s1.teamid 
	  and s1.salary >0
Order by playerid ASC, yearid DESC