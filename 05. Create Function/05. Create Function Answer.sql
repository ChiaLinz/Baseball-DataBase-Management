Use Summer_2022_BaseBall;
GO

-- By creating a function, you can take snippets of SQL and eliminate the repetitive coding of the same SQL over and over such as the Full Name. 
-- For this assignment, you must write a scalar function ( a function that returns a single value) that is passed the playerid and returns the career Power finesse ratio or PFR. This is a statistical measure of the performance of a pitcher used in Sabermetrics. It is the sum of strikeouts (SO) and walks (BB) divided by innings pitched. The alternative to a strikeout or a walk is either a hit or an action by a fielder (that is, the batter "puts the ball in play"), so it is an estimate of the number of times that the pitcher, rather than the batter or fielder(s), determines the outcome of the at-bat. To calculate a career PFR, simply sum all the columns required for the calculation. The PITCHING table does not contain a column for innings pitched, so you will have to estimate it by dividing IPOuts (Outs Pitched (innings pitched x 3) by 3. To test your function, write the following sql and use the function you wrote to get the player・s PFR.  If there is no entry for the player in the PITCHING table, the function should return a value of 0. You should also leave the result unformatted so that it can be used in calculation When you create the function, start the name with your UCID. The select statement you submit with your function SQL is:
 -- select playerid, nameFirst + ． ( ． + nameGiven + ． ) ． + nameLast, dbo.UCID_PFR(playerid) as PFR from PEOPLE


IF OBJECT_ID (N'dbo.ch35_PFR', N'FN') IS NOT NULL
    DROP FUNCTION ch35_PFR;
go

create function ch35_PFR(@playerid varchar(255))
       returns float
      begin
		   declare @ptr float;
           set @ptr = (select (sum(SO) + sum(BB))*1.0 / (sum(Ipouts)/3) 
           from Pitching
           where Ipouts/3 > 0 and pitching.playerid = @playerid )
           return  @ptr;
       end;
go
select playerid, nameFirst + ' ( ' + nameGiven + ') ' + nameLast as [Full Name], dbo.ch35_PFR(playerid) as PFR from PEOPLE