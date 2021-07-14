-- Preview PerGameStats

select * from NBA..PerGameStats

-- Add new TM column to Standings table with abbreviated team names

alter table Standings
add TM nvarchar(255);

select Team,
	case when Team = 'Golden State Warriors' then 'GSW'
	when Team = 'San Antonio Spurs' then 'SAS'
	when Team = 'Houston Rockets' then 'HOU'
	when Team = 'Boston Celtics' then 'BOS'
	when Team = 'Cleveland Cavaliers' then 'CLE'
	when Team = 'Los Angeles Clippers' then 'LAC'
	when Team = 'Toronto Raptors' then 'TOR'
	when Team = 'Utah Jazz' then 'UTA'
	when Team = 'Washington Wizards' then 'WAS'
	when Team = 'Oklahoma City Thunder' then 'OKC'
	when Team = 'Atlanta Hawks' then 'ATL'
	when Team = 'Memphis Grizzlies' then 'MEM'
	when Team = 'Indiana Pacers' then 'IND'
	when Team = 'Golden State Warriors' then 'IND'
	when Team = 'Milwaukee Bucks' then 'MIL'
	when Team = 'Chicago Bulls' then 'CHI'
	when Team = 'Portland Trail Blazers' then 'POR'
	when Team = 'Miami Heat' then 'MIA'
	when Team = 'Denver Nuggets' then 'DEN'
	when Team = 'Detroit Pistons' then 'DET'
	when Team = 'Charlotte Hornets' then 'CHO'
	when Team = 'New Orleans Pelicans' then 'NOP'
	when Team = 'Dallas Mavericks' then 'DAL'
	when Team = 'Sacramento Kings' then 'SAC'
	when Team = 'Minnesota Timberwolves' then 'MIN'
	when Team = 'New York Knicks' then 'NYK'
	when Team = 'Orlando Magic' then 'ORL'
	when Team = 'Philadelphia 76ers' then 'PHI'
	when Team = 'Los Angeles Lakers' then 'LAL'
	when Team = 'Phoenix Suns' then 'PHO'
	when Team = 'Brooklyn Nets' then 'BRK'
	end as TM
from NBA..Standings

Update Standings
SET TM = case when Team = 'Golden State Warriors' then 'GSW'
	when Team = 'San Antonio Spurs' then 'SAS'
	when Team = 'Houston Rockets' then 'HOU'
	when Team = 'Boston Celtics' then 'BOS'
	when Team = 'Cleveland Cavaliers' then 'CLE'
	when Team = 'Los Angeles Clippers' then 'LAC'
	when Team = 'Toronto Raptors' then 'TOR'
	when Team = 'Utah Jazz' then 'UTA'
	when Team = 'Washington Wizards' then 'WAS'
	when Team = 'Oklahoma City Thunder' then 'OKC'
	when Team = 'Atlanta Hawks' then 'ATL'
	when Team = 'Memphis Grizzlies' then 'MEM'
	when Team = 'Indiana Pacers' then 'IND'
	when Team = 'Golden State Warriors' then 'IND'
	when Team = 'Milwaukee Bucks' then 'MIL'
	when Team = 'Chicago Bulls' then 'CHI'
	when Team = 'Portland Trail Blazers' then 'POR'
	when Team = 'Miami Heat' then 'MIA'
	when Team = 'Denver Nuggets' then 'DEN'
	when Team = 'Detroit Pistons' then 'DET'
	when Team = 'Charlotte Hornets' then 'CHO'
	when Team = 'New Orleans Pelicans' then 'NOP'
	when Team = 'Dallas Mavericks' then 'DAL'
	when Team = 'Sacramento Kings' then 'SAC'
	when Team = 'Minnesota Timberwolves' then 'MIN'
	when Team = 'New York Knicks' then 'NYK'
	when Team = 'Orlando Magic' then 'ORL'
	when Team = 'Philadelphia 76ers' then 'PHI'
	when Team = 'Los Angeles Lakers' then 'LAL'
	when Team = 'Phoenix Suns' then 'PHO'
	when Team = 'Brooklyn Nets' then 'BRK'
	end

select * from NBA..Standings

-- Effect of highest scoring player of the team on the team's win-loss record

with hp as (
	select rank() over (partition by Tm, Season order by PTS desc) as r, * from NBA..PerGameStats
	)

select Player, hp.Tm, PTS, Win, Loss, cast(Win as int)+cast(Loss as int) as TotalGames, round(cast(Win as float)/(cast(Win as float)+cast(Loss as float))*100,2) as WinPercentage, hp.Season
from hp
join NBA..Standings as t2
on hp.Tm = t2.TM and hp.Season = t2.Season
where r=1



-- Effect of best passing player of the team on the team's win-loss record

with ha as (
	select rank() over (partition by Tm, Season order by AST desc) as r, * from NBA..PerGameStats
	)

select Player, ha.Tm, AST, Win, Loss, cast(Win as int)+cast(Loss as int) as TotalGames, round(cast(Win as float)/(cast(Win as float)+cast(Loss as float))*100,2) as WinPercentage, ha.Season
from ha
join NBA..Standings as t2
on ha.Tm = t2.TM and ha.Season = t2.Season
where r=1

-- Effect of Age on Individual Performance

select Age, AVG(PTS) as Points, AVG(AST) as Assists, AVG(TRB) as Rebounds, AVG(STL) as Steals, AVG(BLK) as Blocks, AVG([eFG%]) as Accuracy
from NBA..PerGameStats
group by Age
order by Age


-- total 3 point attempted over the years and league wide 3 point percentage

select sum([3PA]*G) as TotalAttmepted, sum([3P]*G) as TotalMade, (sum([3P]*G))/(sum([3PA]*G))*100 as LeaguePercentage, Season
from NBA..PerGameStats
group by Season
order by Season

-- relationship between 3 point accuracy and free throw accuracy

select [3P%], [FT%]
from NBA..PerGameStats


-- Relationship between Field Goals Attempted (estimate for usage rate) and Game Started (estimate for player's role on the team)

select FGA, GS
from NBA..PerGameStats
order by FGA desc


-- Player's preferred mode of scoring (will be slightly off due to rounding of values from raw data)

select Player, [3P]*3 as PointsFrom3pt, round([3P]*3/PTS*100,2) as '%', [2P]*2 as PointsFrom2pt, round([2P]*2/PTS*100,2) as '%', FT as PointsFromFT, round(FT/PTS*100,2) as '%', PTS, Season
from NBA..PerGameStats


-- Create Views for visualization

Use NBA
go

--1
create view PointsOnWin as
with hp as (
	select rank() over (partition by Tm, Season order by PTS desc) as r, * from NBA..PerGameStats
	)

select Player, hp.Tm, PTS, Win, Loss, cast(Win as int)+cast(Loss as int) as TotalGames, round(cast(Win as float)/(cast(Win as float)+cast(Loss as float))*100,2) as WinPercentage, hp.Season
from hp
join NBA..Standings as t2
on hp.Tm = t2.TM and hp.Season = t2.Season
where r=1

--2
create view AssistsOnWin as
with ha as (
	select rank() over (partition by Tm, Season order by AST desc) as r, * from NBA..PerGameStats
	)

select Player, ha.Tm, AST, Win, Loss, cast(Win as int)+cast(Loss as int) as TotalGames, round(cast(Win as float)/(cast(Win as float)+cast(Loss as float))*100,2) as WinPercentage, ha.Season
from ha
join NBA..Standings as t2
on ha.Tm = t2.TM and ha.Season = t2.Season
where r=1

--3
create view AgePerformance as
select Age, AVG(PTS) as Points, AVG(AST) as Assists, AVG(TRB) as Rebounds, AVG(STL) as Steals, AVG(BLK) as Blocks, AVG([eFG%]) as Accuracy
from NBA..PerGameStats
group by Age

--4
create view ThreePointTrend as
select sum([3PA]*G) as TotalAttmepted, sum([3P]*G) as TotalMade, (sum([3P]*G))/(sum([3PA]*G))*100 as LeaguePercentage, Season
from NBA..PerGameStats
group by Season

--5
create view ThreePointFT as
select [3P%], [FT%]
from NBA..PerGameStats

--6
create view UsageEstimate as
select Player, FGA, GS
from NBA..PerGameStats

--7
create view MethodOfScoring as
select Player, [3P]*3 as PointsFrom3pt, round([3P]*3/PTS*100,2) as '% 3pt', [2P]*2 as PointsFrom2pt, round([2P]*2/PTS*100,2) as '% 2pt', FT as PointsFromFT, round(FT/PTS*100,2) as '% FT', PTS, Season
from NBA..PerGameStats