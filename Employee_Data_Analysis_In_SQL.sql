# Task1:
/*
Create a visualization that provides a breakdown between the male and female empoyees
working in the company each year, starting from 1990.
*/

use employees_mod;

select
	year(d.from_date) calendar_year,
    e.gender,
    count(e.emp_no) num_of_employees
from
	t_employees e
		join
	t_dept_emp d on d.emp_no = e.emp_no
group by calendar_year, e.gender
having calendar_year >= 1990;


# Task2
/*
Compare the number of male managers to the number of female managers from 
different departments for each year, starting from 1990.
*/

select
	d.dept_name,
	ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    case
		#when year(dm.to_date) >= e.calendar_year and year(dm.from_date) <= e.calendar_year then 1
        when e.calendar_year between year(dm.from_date) and year(dm.to_date) then 1
        else 0
	end active
from
	(select
		year(hire_date) calendar_year
	from
		t_employees
	group by calendar_year) e
        cross join
	t_dept_manager dm 
		join
	t_departments d on dm.dept_no = d.dept_no
		join
	t_employees ee on dm.emp_no = ee.emp_no
order by dm.emp_no, calendar_year;



#Task3
/*
Compare the average salary of female versus male employees in the entire 
company until year 2002, and add a filter allowing you to see that 
per each department.
*/

select
	e.gender,
    dm.dept_name,
    round(avg(s.salary),2) salary,
    year(s.from_date) calendar_year
from
	t_salaries s 
		join
	t_employees e on s.emp_no = e.emp_no
		join
	t_dept_emp d on s.emp_no = d.emp_no
		join 
	t_departments dm on d.dept_no = dm.dept_no
group by 
	d.dept_no, e.gender, calendar_year
having calendar_year <= 2002
order by d.dept_no;



#Task4
/*
Create an SQL stored procedure that will allow you to obtain the average male and female salary per 
department within a certain salary range. Let this range be defined by two values the user can insert 
when calling the procedure.

Finally, visualize the obtained result-set in Tableau as a double bar chart. 
*/

drop procedure if exists avg_salary_info;

delimiter $$
create procedure avg_salary_info(in p_min_salary float, in p_max_salary float)
begin
select
	e.gender,
    d.dept_name,
    round(avg(s.salary),2) avg_salary
from
	t_salaries s 
		join
	t_employees e on s.emp_no = e.emp_no
		join
	t_dept_emp de on e.emp_no = de.emp_no
		join
	t_departments d on de.dept_no = d.dept_no
    where s.salary between p_min_salary and p_max_salary
group by 
	d.dept_no, e.gender;
end$$ 

delimiter ;

call avg_salary_info(50000, 90000);
