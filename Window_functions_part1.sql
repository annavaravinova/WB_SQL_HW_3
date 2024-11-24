--ДЗ по SQL: Window functions
--Часть 1. Без использования оконных функций
select 
	s1.first_name, 
	s1.last_name, 
	s1.salary, 
	s1.industry, 
--подзапрос для определения сотрудника с самой высокой зп по отделу
	(select 
		concat_ws(' ', s2.first_name, s2.last_name) --объединение имени и фамилии в одно поле
		from salary s2 
		where 
			s2.industry = s1.industry and 
			s2.salary = 
				(select max(salary) from salary 
				where industry = s1.industry))
 		-- Limit 1)   на случай, если несколько человек получают одинаково высокую зарплату 
 	AS name_highest_sal,
 --подзапрос для определения сотрудника с самой низкой зп по отделу
 	(select 
 		concat_ws(' ', s2.first_name, s2.last_name) 
 		from salary s2
		where 
			s2.industry = s1.industry and 
			s2.salary = (select min(salary) from salary 
			where industry = s1.industry))
 -- Limit 1)   на случай, если несколько человек получают одинаково низкую зарплату 
 	AS name_lowest_sal
from salary s1
Order by s1.industry, s1.salary DESC; --для наглядности
----------------

--Часть 1. С использованием оконных функций

select 
	s1.first_name, 
	s1.last_name, 
	s1.salary, 
	s1.industry, 
	--максимальная зп 
	first_value(concat_ws(' ', s1.first_name, s1.last_name)) 
	over (partition by s1.industry order by s1.salary desc) as name_highest_sal,
	--так как мы сортируем по убыванию зп сотрудников, нам достаточно выделить первое значение в окне (разбиение по отделу)
	--чтобы получить максимальную зарплату
	last_value(concat_ws(' ', s1.first_name, s1.last_name))  --last_value покажет минимальную зп так как мы сортируем по убыванию зп сотрудников
	over (partition by s1.industry order by s1.salary desc 
	range between unbounded preceding and unbounded following) as name_lowest_sal
	--если не выставить диапазон для окна, last_value будет выводить текущую строку, так как она является последней в окне на момент записи
from salary s1
