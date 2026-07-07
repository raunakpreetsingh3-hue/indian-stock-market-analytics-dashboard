use stock_market;


alter table stocks
modify turnover decimal(25,2);


load data infile 'C:/ProgramData/MySQL/MySQL Server 9.6/Uploads/stock data cleaned.csv'
into table stocks
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
(
@date,
symbol,
series,
prev_close,
open,
high,
low,
last,
close,
vwap,
volume,
turnover,
@trades,
@deliverable_volume,
deliverable_percentage,
daily_returns,
gap_percentage,
intraday_volatility,
delivery_category
)
set
date = str_to_date(@date, '%d-%m-%Y'),
trades = nullif(@trades, ''),
deliverable_volume = nullif(@deliverable_volume, '');


update stocks
set turnover = turnover / 100000;


alter table stocks
rename column daily_returns to daily_returns_percentage;


-- data analysis


select count(*) from stocks;

select count(*) from stocks
where trades is null;

select count(*) from stocks
where deliverable_volume is null;

select min(date), max(date)
from stocks;

select max(turnover), min(turnover)
from stocks;

select symbol, date, turnover
from stocks
order by turnover desc
limit 10;

select count(symbol)
from stocks
where turnover between 50000000 and 500000000;

select count(*)
from stocks
where turnover > 5000000000;

select symbol, date, volume, vwap, turnover,
round(volume * vwap,2) as expected_turnover,
round(turnover / (volume * vwap),2) as ratio
from stocks
where volume > 0
limit 20;

select symbol, date, volume, vwap, turnover,
round(volume * vwap,2) as expected_turnover
from stocks
limit 10;

select delivery_category, count(*)
from stocks
group by delivery_category;

select symbol, date, intraday_volatility
from stocks
order by intraday_volatility desc
limit 10;


-- practice queries


select symbol,
avg(daily_returns_percentage) as avg_daily_return_percentage
from stocks
group by symbol
order by avg_daily_return_percentage desc
limit 10;


select symbol,
avg(intraday_volatility) as avg_intraday_volatility
from stocks
group by symbol
order by avg_intraday_volatility desc
limit 10;


select year(date) as year,
avg(daily_returns_percentage) as avg_daily_return_percentage
from stocks
group by year(date)
order by avg_daily_return_percentage desc
limit 1;


select symbol,
avg(deliverable_percentage) as avg_deliverable_percentage
from stocks
group by symbol
order by avg_deliverable_percentage desc
limit 10;


select symbol,
sum(volume) as total_trading_volume
from stocks
group by symbol
order by total_trading_volume desc
limit 10;


select year(date) as year,
sum(turnover) as total_turnover,
sum(volume) as total_trading_volume
from stocks
group by year(date)
order by year;


select year(date) as year,
avg(daily_returns_percentage) as avg_daily_return_percentage,
avg(intraday_volatility) as avg_intraday_volatility,
avg(deliverable_percentage) as avg_deliverable_percentage
from stocks
group by year(date)
order by year;


select symbol,
count(date) as total_trading_days
from stocks
group by symbol
having total_trading_days > 1000
order by total_trading_days desc;


select symbol,
avg(daily_returns_percentage) as avg_daily_return_percentage
from stocks
group by symbol
having avg(daily_returns_percentage) > 0.06
order by avg_daily_return_percentage desc
limit 10;


select symbol,
avg(daily_returns_percentage) as avg_daily_return_percentage,
avg(deliverable_percentage) as avg_deliverable_percentage
from stocks
group by symbol
having avg(daily_returns_percentage) > 0
and avg(deliverable_percentage) > 60
order by avg_daily_return_percentage desc
limit 10;


select symbol,avg(daily_returns_percentage) as avg_daily_return_percentage
from stocks
group by symbol 
having avg_daily_return_percentage> (
                                     select avg(daily_returns_percentage)
                                     from stocks
                                     ) 
order by avg_daily_return_percentage desc;


select symbol,sum(turnover) as total_turnover
from stocks
group by symbol 
having total_turnover > (
						select avg(total_turnover) as avg_turnover
						from (
                              select sum(turnover) as total_turnover
                              from stocks
                              group by symbol
							) as t
						) 
order by total_turnover;


select symbol, sum(volume) as total_trading_volume
from stocks
group by symbol 
having total_trading_volume=(
                              select max(t_volume) 
                              from (
                                     select sum(volume) as t_volume
                                     from stocks
                                     group by symbol
                                     ) t
							);


select symbol, sum(turnover) as total_turnover
from stocks 
group by symbol 
having total_turnover > (
						select sum(turnover) 
                        from stocks 
                        where symbol="RELIANCE"
                        );                  


select symbol, avg(daily_returns_percentage) as avg_dpr
from stocks
group by symbol 
having avg_dpr> (
						select avg(daily_returns_percentage) 
                        from stocks 
                        where symbol="TCS"
                        )
order by avg_dpr desc;    


select symbol, avg(daily_returns_percentage) as avg_dpr
from stocks 
group by symbol
having avg_dpr=(
                select max(t_dpr)
                from (  
                      select avg(daily_returns_percentage) as t_dpr
                      from stocks 
                      group by symbol
                      ) t
				);

select symbol, sum(turnover) as total_turnover,
rank() over (order by sum(turnover) desc) as `rank`
from stocks 
group by symbol;


select symbol,total_turnover,rnk
from ( select symbol, sum(turnover) as total_turnover,
       rank() over (order by sum(turnover) desc) as rnk
       from stocks 
       group by symbol
       ) t
where rnk<=5;

select yr, symbol, total_turnover, rnk
from(
     select year(date) as yr, symbol,sum(turnover) as total_turnover,
     rank() over(partition by year(date) order by sum(turnover) desc) as rnk 
     from stocks
     group by symbol, yr
     ) t
where rnk<=3
order by yr,rnk;



with c as
( select symbol, sum(turnover) as total_turnover 
  from stocks
  group by symbol),
r as (
     select symbol, total_turnover,
     rank() over( order by total_turnover desc) as rnk
      from c)
select * from r
where rnk<=5;


with c as
(
select year(date) as yr,symbol,sum(turnover) as total_turnover
from stocks
group by year(date),symbol),
r as (
select yr,symbol,total_turnover,
rank() over(partition by yr order by total_turnover desc) as rnk
from c)
select * from r 
where rnk=1;

 

