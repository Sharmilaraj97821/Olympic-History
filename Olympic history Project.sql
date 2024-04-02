select * from athlete_events
select * from athletes

--1 which team has won the maximum gold medals over the years.
select top 1 team,count(distinct event)as total_gold_medals from athletes as a
inner join athlete_events a1 on a.id=a1.athlete_id
where medal='Gold'
group by team
order by total_gold_medals desc


--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
with cte as(select team, a1.year,
count( distinct event)as total_silver_medal,
ROW_NUMBER()
over(partition by team order by count( distinct event) desc)as rn from athletes as a
inner join athlete_events a1 on a.id=a1.athlete_id
where medal='Silver'
group by team,a1.year
)
select team,sum(total_silver_medal)as total_silver_medals,max(case when rn=1 then year end) as year_of_max_silver from cte
group by team

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
with cte as(select name,medal from athletes as a
inner join athlete_events as a1 on a.id=a1.athlete_id)
select top 1 name,count(1) as total from cte
where name not in (select distinct name from cte 
where medal in('Silver','Bronze')) and medal='Gold'
group by name
order by total desc

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
with cte as (select a.name as name,a1.year as year,count(1)as no_of_golds from athletes as a
inner join athlete_events as a1 on a.id=a1.athlete_id
where medal='Gold'
group by a.name,a1.year)
select year,STRING_AGG(name,',') as player_name,no_of_golds from (select *,rank()over(partition by year order by no_of_golds desc) as rn from cte)l
where rn=1
group by year,no_of_golds

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
with cte as(select distinct event,year,medal,Rank()over(partition by medal order by year) as rn from athlete_events a1
inner join athletes a on a.id=a1.athlete_id
where medal in('Gold','Silver','Bronze') and a.team='India')
select medal,year,event from cte
where rn=1

--6 find players who won gold medal in summer and winter olympics both.
select distinct name from athlete_events a1
inner join athletes a on a.id=a1.athlete_id
where medal='gold'
group by name
having count(distinct season)=2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select name,year from athlete_events a1
inner join athletes a on a.id=a1.athlete_id
where medal!='NA'
group by name,year
having count(distinct medal)=3
order by name

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with cte as(select distinct event,name,lag(year,1)over (partition by name,event order by year) as pre_yr,year,
lead(year,1)over (partition by name,event order by year) as nxt_yr from athlete_events a1
inner join athletes a on a.id=a1.athlete_id
where medal='Gold' and season='Summer' and year>=2000
)
select name,event from cte
where year+4=nxt_yr and year-4=pre_yr
order by name,year