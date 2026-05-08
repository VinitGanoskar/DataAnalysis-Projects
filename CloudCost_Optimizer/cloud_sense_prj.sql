select*from cloud_sense_clean


--How much cloud cost is being wasted?
--Which services waste the most money?
--Which regions waste the most money?
--How many idle resources exist?
--Which resources are underutilized?
--What is the monthly trend of spending? 
--Where can management optimize cost?


-- 1.How much cloud cost is being wasted?
select
    sum(allocated_cost) as total_allocated_cost, 
    sum(actual_used_cost) as total_allocated__used_cost,
    sum(waste_cost) as total_waste_cost from 
cloud_sense_clean


-- What % of cloud budget is wasted?
select 
(waste_cost*100)/allocated_cost as overall_Waste_percent
from Cloud_Sense_Clean;


-- 2.Which services waste the most money?

SELECT 
    service_clean,
    SUM(allocated_cost) AS allocated_cost,
    SUM(actual_used_cost) AS used_cost,
    SUM(waste_cost) AS waste_cost
FROM Cloud_Sense_Clean
GROUP BY service_clean
ORDER BY waste_cost DESC;

-- Waste Percentage by Service
select 
service_clean,round(avg(waste_percent),2) as avg_waste_percent from
Cloud_Sense_Clean
group by  service_clean
order by avg_waste_percent desc ;

ALTER TABLE cloud_sense_clean
ALTER COLUMN waste_percent DECIMAL(5,2)

--4.Cost & Waste by Region
select region_clean,
sum(waste_cost) as total_waste_cost
from cloud_sense_clean
group by region_clean
order by total_waste_cost desc;


-- Idle vs Active Resource Count
-- 5.How many resources are idle?

select
status_clean,count(*) as resource_count
from Cloud_Sense_Clean
group by status_clean
 --OR
select count(status_clean) as tot_idle 
from cloud_sense_clean
where status_clean='idle';

--Both Works the same 




---Idle Resource Waste Cost
--6.How much money is wasted on idle resources?

select sum(waste_cost) as Tot_idle_wastecst
from Cloud_Sense_Clean
where status_clean='idle';



--Underutilized Resources (CPU < 20%)
---7.Which resources are running but barely used?
select record_id,
service_clean,
region_clean,
cpu_clean,
waste_cost
from cloud_sense_clean
where cpu_clean<20
order by waste_cost desc;


-- High Cost but Low CPU Usage
--- 8.Which expensive resources are inefficient?

select service_clean,
record_id,
cpu_clean,
allocated_cost,
waste_cost
from Cloud_Sense_Clean
where allocated_cost>500 and cpu_clean<30;

-- Monthly Cost Trend
-- 9.Is cloud spending increasing or decreasing?
select MONTH(date) as month,
sum(allocated_cost) as monthly_allo_cost,
sum(actual_used_cost) as actual_used_cost
from cloud_sense_clean
group by month(date)
order by month ;


--Monthly Waste Trend
-- 10. Is waste increasing over time?

select month(date) as Month,
sum(waste_cost) as monthly_WasteCost
from cloud_sense_clean
group by month(date)
order by Month;


-- Top 10 Waste Records
-- 11. Which individual records waste the most money?
select TOP 10
    record_id,
    service_clean,
    region_clean,
    waste_cost
from Cloud_Sense_Clean
order by waste_cost desc ;

--Average CPU Usage by Service

--- 12. Which service is underutilized?
select service_clean,
round(avg(cpu_clean),2) as Avg_Usage_cpu
from cloud_sense_clean
group by service_clean
order by Avg_Usage_cpu;

-- Storage vs Waste Relationship
-- 13.Does higher storage lead to more waste?
select 
storage_gb,avg(waste_cost) as avg_waste_cost
from cloud_sense_clean
group  by storage_gb
order by storage_gb;

