select employee_id,b.Supervisor_ID, inoffice, coredays, timeoff,month, case when (coredays-timeoff-1) <= 0 then 100 
else round((cast(inoffice as float)/(coredays-timeoff-1))*100,0)  end as ind_percent 
 from (select employee_id,b.Supervisor_ID,
case when  inoffice>(coredays-timeoff-1) then (coredays-timeoff-1) else inoffice end as inoffice,coredays,
timeoff,month from (
Select  b.Supervisor_ID,
DATENAME(month, DATEADD(month, month - 1, '1900-01-01')) as month,
    sum(case when (DATENAME(weekday, a.date) in ('Tuesday','Wednesday','Thursday')
                             ) then 1 else 0 end) as coredays, 
    sum(case when in_office = 'YES' then 1 else 0 end) as inoffice,
     sum (case 
                             when in_office not in ('YES') and (time_off ='YES' or a.stats_holiday='Holiday') 
                             and DATENAME(weekday, a.date) in ('Tuesday','Wednesday','Thursday') then 1 else 0
              end ) as timeoff
      from gft_hr_dal.fact_global_participation a left join gft_hr_dal.dim_employee b  on a.Employee_ID=b.Supervisor_ID 
  where 
  a.employee_id='81419' 
  and 
  a.date between '2024-06-01' and '2024-06-30'
  group by b.Supervisor_ID,month order by b.Supervisor_ID )ind) tt
