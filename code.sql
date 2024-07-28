with                     
Global_atten as               
(                           
    select a.Employee_ID as emp_id ,a.manager_level_05 as manager_name,                       
        b.date,                       
        b.employee_id,                      
        b.user_name,b.supervisor_id,                         
b.in_office,b.time_off,b.stats_holiday                    
,a.Preferred_Name_UPDW as name                      
from gft_hr_dal.fact_global_participation b                       
left join gft_hr_dal.dim_employee a   on a.Employee_ID=b.Employee_id               
  and a.Date between '2024-06-01' and '2024-06-30'                      
     and b.Date between '2024-06-01' and '2024-06-30'                   
     --and a.Manager_Level_04='Jeffery, James' 
        and a.Manager_Level_05='Gardner, Gregory'  
          and a.working_arrangement  in ('Hybrid')                 
       --and a.user_name <> 'goriroy'                         
     and a.worker_type = 'Employee'                        
    and a.reg_temp <> 'Temporary'                          
    and a.employee_status = 'Active'                        
and a.location_country not in ('China','Brazil','Chile','Myanmar')                
and a.is_sales = '0'                         
and a.is_subsidiary = '0'               
and a.full_part = 'Full time'                        
and a.job_family_group <> 'Sales Group'                             
and a.badge_data='YES'    
and a.wfh_accomodation = 'NO'
  where  a.Employee_id is not null                          
--and a.Employee_id='398418'                 
    ),
new as (      
  Select a.employee_id, name,manager_name,                  
    sum(case when (DATENAME(weekday, a.date) in ('Tuesday','Wednesday','Thursday')) then 1 else 0 end) as coredays,                        
    sum(case when in_office = 'YES' then 1 else 0 end) as inoffice,                
    sum (case                     
                             when in_office not in ('YES') and (time_off ='YES' or a.stats_holiday='Holiday') 
                             and DATENAME(weekday, a.date) in ('Tuesday','Wednesday','Thursday') then 1 else 0 end) as timeoff
       
          from Global_atten a group by a.employee_id, name,manager_name),
new1 as (select employee_id, name,manager_name,coredays,
case when  inoffice>(coredays-timeoff-1) then (coredays-timeoff-1) else inoffice end as inoffice,timeoff from new),
new2 as (select employee_id, name,manager_name,coredays,inoffice,timeoff,
case when (coredays-timeoff-1) <= 0 then 100 
else round((cast(inoffice as float)/(coredays-timeoff-1))*100,0)  end as utilization_percent
from new1),
june as (select *  from new2),                  
Global_atten1 as               
(                           
    select a.Employee_ID as emp_id ,a.manager_level_05 as manager_name,                       
        b.date,                       
        b.employee_id,                      
        b.user_name,b.supervisor_id,                         
b.in_office,b.time_off,b.stats_holiday                    
,a.Preferred_Name_UPDW as name                      
from gft_hr_dal.fact_global_participation b                       
left join gft_hr_dal.dim_employee a   on a.Employee_ID=b.Employee_id               
  and a.Date between '2024-07-01' and '2024-07-31'                      
     and b.Date between '2024-07-01' and '2024-07-31'                   
     --and a.Manager_Level_04='Jeffery, James' 
        and a.Manager_Level_05='Gardner, Gregory'  
          and a.working_arrangement  in ('Hybrid')                 
       --and a.user_name <> 'goriroy'                         
     and a.worker_type = 'Employee'                        
    and a.reg_temp <> 'Temporary'                          
    and a.employee_status = 'Active'                        
and a.location_country not in ('China','Brazil','Chile','Myanmar')                
and a.is_sales = '0'                         
and a.is_subsidiary = '0'               
and a.full_part = 'Full time'                        
and a.job_family_group <> 'Sales Group'                             
and a.badge_data='YES'    
and a.wfh_accomodation = 'NO'
  where  a.Employee_id is not null                          
--and a.Employee_id='398418'                 
    ),
new_july as ( 
  Select a.employee_id, name,manager_name,                  
    sum(case when (DATENAME(weekday, a.date) in ('Tuesday','Wednesday','Thursday')) then 1 else 0 end) as coredays,                        
    sum(case when in_office = 'YES' then 1 else 0 end) as inoffice,                
    sum (case                     
                             when in_office not in ('YES') and (time_off ='YES' or a.stats_holiday='Holiday') 
                             and DATENAME(weekday, a.date) in ('Tuesday','Wednesday','Thursday') then 1 else 0 end) as timeoff
       
          from Global_atten1 a group by a.employee_id, name,manager_name),
new_july1 as (select employee_id, name,manager_name,coredays,
case when  inoffice>(coredays-timeoff) then (coredays-timeoff) else inoffice end as inoffice,timeoff from new_july),
new_july2 as (select employee_id, name,manager_name,coredays,inoffice,timeoff,
case when (coredays-timeoff) <= 0 then 100 
else round((cast(inoffice as float)/(coredays-timeoff))*100,0)  end as utilization_percent
from new_july1),
  july as (select *  from new_july2),
final as (select employee_id,name,utilization_percent from july 
union all
select employee_id,name,utilization_percent from june),
final1 as (select employee_id,name,round(sum(utilization_percent)/2,0) as avg_ind_prc, 
case when round(sum(utilization_percent)/2,0)>84.5 then 1 else 0 end as mid_ribon
from final
group by employee_id,name)
select * from final1


