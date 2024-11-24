--ДЗ по SQL: Window functions
-- Часть 2.1
select distinct s.shopnumber AS "SHOPNUMBER",
    sh.city as "CITY",
    sh.address as "ADDRESS",
    sum(s.qty) over (partition by s.shopnumber) as "SUM_QTY",
    sum(s.qty * g.price) over (partition by s.shopnumber) as "SUM_QTY_PRICE"
from sales s
join goods g on s.id_good = g.id_good
join shops sh on s.shopnumber = sh.shopnumber
where to_date(s."DATE", 'MM/DD/YYYY') = '2016-01-02'
order by s.shopnumber;
----------------------------------------------------------------
-- Часть 2.2
select 
    s."DATE" as "DATE_",
    sh.city as "CITY",
    sum(g.price * s.qty) / sum(sum(g.price * s.qty)) over (partition by s."DATE") as "SUM_SALES_REL"
    --sum(g.price * s.qty) вычисляет продажи в рублях для каждого города d определенную дату без оконки при помощи дальнейшей группировки
    --sum(sum(g.price * s.qty)) over (partition by s."DATE") оконная функция, чтобы рассчитать общую сумму продаж в рублях в ту же дату
from sales s
join goods g on s.id_good = g.id_good
join shops sh on s.shopnumber = sh.shopnumber
where g.category = 'ЧИСТОТА'
group by s."DATE", sh.city
order by s."DATE";
------------------------------------------------------------------------
-- Часть 2.3
with RankedSales as (
    select  
        s."DATE" as "DATE_",
        s.shopnumber as "SHOPNUMBER",
        s.id_good as "ID_GOOD",
        rank() over (partition by s."DATE", s.shopnumber order by sum(s.qty) desc) as rank
        --rank() для ранжирования товаров по продажам в штуках для дальнейшей фильтрации трех первых показателей
    from sales s
    group by s."DATE", s.shopnumber, s.id_good)
select 
    "DATE_",
    "SHOPNUMBER",
    "ID_GOOD"
from RankedSales
where rank <= 3
order by "DATE_";
-------------------------------------------------------------------
-- Часть 2.4
select  
    sales_by_date."DATE" as "DATE_",
    sales_by_date.shopnumber as "SHOPNUMBER",
    sales_by_date.category as "CATEGORY",
    coalesce(lag(sales_by_date.total_sales) --coalesce чтобы убрать null-ы
    over (partition by sales_by_date.shopnumber, sales_by_date.category order by sales_by_date."DATE"),0) as "PREV_SALES"
--подзапрос sales_by_date: выполняет группировку по дате, магазину и категории, чтобы получить суммарные продажи 
--lag берет значение total_sales из предыдущей даты для каждой комбинации магазина и категории.
    from (
    	select 
	        s."DATE",
	        s.shopnumber,
	        g.category,
	        sum(g.price * s.qty) as total_sales
    from sales s
    join goods g on s.id_good = g.id_good
    join shops sh on s.shopnumber = sh.shopnumber
    where sh.city = 'СПб'
    group by s."DATE", s.shopnumber, g.category) as sales_by_date
order by sales_by_date."DATE", sales_by_date.shopnumber, sales_by_date.category;
    
   