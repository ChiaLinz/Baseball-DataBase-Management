-- 	Using the People, CollegePlaying, Batting and other tables indicated below, create a view named NJITID_Player_History that contains:
--		playerID
--		Player Full Name,
--		Total_401K amount from the People table
--		# of yrs played from the Batting table
--		# of Teams played for the Batting table
--		Career Total Home Runs from Batting
--		Career Batting Average (calculate the Batting Average using all the data for the player)
--		Total Salary
--		Average Salary
--		Starting Salary from the Salaries table 
--		Ending Salary from the Salaries table
--		Overall percentage of salary increase (percent difference in starting and ending salary)
--		Year Last played in College from the CollegePlaying Table
--		Number of Schools attended from the CollegePlaying Table. The value should be 0 if the player didn・t attend college
--		Last Year Played from Batting
--		Career Total of Wins from Pitching Table
--		Career Total of Strike Outs (SO) from the Pitching Table
--		Career Power Fitness Ratio (statistical measure of the performance of a pitcher. It is the sum of strikeouts (SO) and walks (BB) divided by innings pitched from the Pitching Table
--		Total games played (G) from the Fielding Table
--		Total games started (GS) from the Fielding Table
--		Percent of Total Games Played ( you need to calculate this value by dividing the Total Games Played by the number of games in their career. The number of games in their career can be calculated using the summing G column in the Teams Table for the years the player played)
--		Total Number of Awards as a player from AwardsPlayer and AwardsSharePlayer
--		Total number of Awards as a manager from AwardsManager and AwardsShareManager
--		Year Inducted in the Hall of Fame 
--		# of times  nominated for the hall of fame but not inducted (# of rows where inducted = ．N・)
--		Hall of Fame (Yes or No) as an indicator if the player was actually elected to the Hall of Fame

Use Summer_2022_BaseBall;
GO

DROP VIEW IF EXISTS [ch35_Player_History]
GO


	CREATE VIEW [ch35_Player_History] as

	WITH

	 P as
	 (SELECT playerid, namegiven + ' ( ' + namefirst + ' )'+ namelast as Full_Name, format(Total_401K,'c') as Total_401k
	 from People ),

	 T as
	 (SELECT playerid, count(DISTINCT yearid) as Num_Years, count (DISTINCT teamid) as Num_Teams
	 from Batting b
	 group by playerID),

	 B as
	 (SELECT playerid, avg((h*1.0/ab)) as Career_Batting_AVG, sum(HR) as Total_HomeRuns, max(yearid) as Max_Appear
	 from Batting
	 where ab>0
	 group by playerID),

	 S as
	 (SELECT playerid, sum(salary) as Total_Salary, avg(salary) as Avg_Salary, min(salary) as Min_Salary, max(salary) as Max_Salary,  CASE WHEN min(salary) = 0 THEN 0 ELSE (max(salary)-min(salary)/min(salary)) END as Perct_Inc 
	 from Salaries
	 group by playerid),

	 C as
	 (SELECT playerid, max(yearID) as Max_year
	 from CollegePlaying
	 where yearid in
		(SELECT finalGame
		from People
		where (finalGame= yearID))
		group by playerid),

	 C2 as 
	 (SELECT playerid, count(distinct(schoolID)) as Num_Schools
	 from CollegePlaying
	 group by playerid),

	 Pitch as
	 (SELECT playerID, sum(W) as Total_Wins , sum(SO) as Total_Strikeouts
	 from Pitching
	 group by playerID),

	  Pitch2 as
	  (SELECT playerid, round((sum(SO + BB)*3 / sum(IPouts)),6) as Car_Pfr
	  from Pitching
	  where Pitching.IPouts > 0
	  group by playerid),

	  F as 
	  (SELECT playerid, sum(F.G) as Tot_Games, sum(convert(int,GS)) as Tot_GS, convert(decimal(5,4),sum(F.G)/(sum(T.G))) as Perc_Start
	  from Fielding F, Teams T 
	  where F.lgid = T.lgid
	  group by playerid),

	 Awards as
	 (SELECT p.playerID, count(s.awardID) as Tot_Award_Play
	 from AwardsPlayers p
	 left join AwardsSharePlayers s
	 on p.playerID=s.playerID
	 group by p.playerID),
 
	 AManager as
	 (SELECT p.playerID, count(p.awardID) as Tot_Award_Man
	 from AwardsManagers p
	 left join AwardsShareManagers s
	 on p.playerID=s.playerID
	 group by p.playerID),
   
	 I as
	 (SELECT playerid, yearid as IYear ,inducted
	 from HallOfFame
	 where inducted = 'Y' ),

	 H as
	 (SELECT playerid, inducted, count(inducted) as Nomcount
	 from HallOfFame
	 where inducted = 'N'
	 group by playerID, inducted)

 
	 Select p.playerid, P.Full_name, P.Total_401k, T.Num_Years, T.Num_Teams, B.Total_HomeRuns as Runs, B.Career_Batting_AVG, S.Total_Salary, S.Avg_Salary, S.Min_Salary, S.Max_Salary, S.Perct_Inc, C.Max_year, C2.Num_Schools, B.Max_Appear, Pitch.Total_Strikeouts, Pitch.Total_Wins, Pitch2.Car_Pfr, F.Tot_Games, F.Tot_GS, F.Perc_Start, Awards.Tot_Award_Play, AManager.Tot_Award_Man, I.IYear, CASE WHEN H.Nomcount is Null THEN 0 ELSE H.Nomcount END as Nomcount,  CASE WHEN I.inducted is Null THEN 'N' ELSE I.inducted END as Inducted
	 from P left join T on p.playerID = T.playerID
			left join B on p.playerID = B.playerid
			left join s on p.playerID = s.playerid
			left join C on p.playerID = C.playerID
			left join C2 on p.playerID = C2.playerID 
			left join Pitch on p.playerID = Pitch.playerID
			left join Pitch2 on p.playerID = Pitch2.playerID
			left join F on p.playerID = F.playerID
			left join Awards on p.playerID = Awards.playerID
			left join AManager on p.playerID = AManager.playerID
			left join I on p.playerID = I.playerID
			left join H on p.playerID = H.playerID 	 


	go


-- Your view must return 20, 370 rows, If you have less than that number, you are not coding the LEFT JOINS properly, If you have more than that number, you have a subquery that is returning more than 1 row per player. TO find the problem subquery, run the following:

-- select * from [ch35_Player_History]  order by playerid
-- select playerid, count(*) from [ch35_Player_History] group by playerid having count(*) > 1 order by playerid


 
-- 1.	Select all the columns in your view


select * from [ch35_Player_History]
order by playerid



-- 2.	Write a query that calculates the average of the [# of yrs played], [Average Salary] and [Career Batting Average] of all players who・s last name begins with the letter A using the information in the view. 



select avg(Num_Years) as AvgYrsPlayed, avg(Avg_Salary) as AverageSal, avg(Career_Batting_AVG) as CareerBA
from [ch35_Player_History]
where Full_Name LIKE '%)A%'
