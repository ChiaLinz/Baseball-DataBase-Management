-- Assignment 12 
-- Transaction Processing Assignment ¡V Cursor Processing
-- Cursors are often used as a way to limit processing when you need to update a very large number of rows in a database. In large commercial database, it can often take hours to update hundreds of millions of rows. Data quality can often cause these processes to abend and need to be rerun. Cursors can also be useful in these instances since they can be used to identify and skip rows that have already been processed. The Baseball database does not lend itself to this type of processing, so while it may appear to be easier to simply update all rows instead of using a Cursor, a Cursor is being used as an example for this type of processing.  For this assignment, you need to write a script that does the following:

-- 1.	Add 2 columns to the PEOPLE table. The columns should be UCID_Career_EqA and UCID_Date_Last_Update. As always, the UCID should be replaced with your actual UCID.

Use Summer_2022_BaseBall;
GO

Alter Table People ADD ch35_Career_EqA float DEFAULT NULL
Alter Table People ADD ch35_Date_Last_Update DATE DEFAULT NULL
Alter Table People ADD ch35_Cursor_count int Default Null


update people
set ch35_Date_Last_Update = getdate()-1,
	ch35_Career_EqA = 0,
	ch35_Cursor_count = 0

select *  from people

-- 2.	Creates an update cursor that contains the playerid and the sum of the player¡¦s Equivalent Average calculated using the BATTING . Equivalent Average (EqA) is a baseball metric invented by Clay Davenport and intended to express the production of hitters in a context independent of park and league effects.[1] It represents a hitter's productivity using the same scale as batting average. Thus, a hitter with an EqA over .300 is a very good hitter, while a hitter with an EqA of .220 or below is poor. An EqA of .260 is defined as league average.The formula for the Equivalent Average is 

IF exists(select 1 from sys.procedures
		  where Name = 'Baseball_Cursor')
Begin
	 Drop procedure [dbo].[Baseball_Cursor]
End
Go

Create Procedure Baseball_Cursor as
	Begin
	set nocount off
	Declare  @today date
	set		 @today = convert(date,getdate())
	Declare  @playerID varchar(50)
	Declare  @EQA float
	Declare  @stop int
	Declare  @Updatecount int
	Declare  @MSG varchar(100)
	set      @Stop = 0
	set		 @Updatecount = 1

--- Declare Cursor
select @msg = 'Update script started at - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
            RAISERROR(@msg, 0, 1) WITH NOWAIT

DECLARE updatecursor CURSOR STATIC FOR
        SELECT playerid, sum((H+ ( H + 2*B2+3*B3+4*HR) + 1.5*(BB+HBP) + SB + SH + SF)/(AB + BB + HBP + SH + SF + CS +(SB/3))) as EqA
            FROM Batting
			WHERE SB > 0 and AB + BB + HBP + SH + SF + CS > 0
			Group by playerID

--- Open Cursor
    Open updatecursor
	Fetch next from updatecursor into @Playerid, @EQA
	while @@fetch_status = 0 
	begin
		Update people set ch35_Date_Last_Update = @today where @playerID = playerid;
		Update people set ch35_Career_EqA = @EQA where @playerID = playerid;
--		Update People set ch35_Coursor_Count = ch35_Coursor_Count +1 where @playerID = playerID;

		If @Updatecount % 100 = 0
		Begin 
            select @msg = 'Completed processrecord number - ' + RTRIM(CAST(@updateCount AS nvarchar(30))) + ' At - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))
            RAISERROR(@msg, 0, 1) WITH NOWAIT
	    END
	   Fetch next from updatecursor into @playerid, @EQA
		END
--- Close and Deallocate Cursor
CLOSE updatecursor
DEALLOCATE updatecursor
END
GO

exec Baseball_Cursor
