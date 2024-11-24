--ДЗ по SQL: Window functions
--Часть 3. Создание таблицы
CREATE TABLE query (
    searchid SERIAL PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    userid INT,
    ts BIGINT,              
    devicetype VARCHAR(20),  
    deviceid INT,            
    query TEXT            

);
----------
--Часть 3. Заполнение таблицы 
INSERT INTO query (year, month, day, userid, ts, devicetype, deviceid, query)
VALUES
    (2023, 11, 1, 1, 1698885600, 'android', 101, 'к'),
    (2023, 11, 1, 1, 1698885660, 'android', 101, 'ку'),
    (2023, 11, 1, 1, 1698885720, 'android', 101, 'куп'),
    (2023, 11, 1, 1, 1698885800, 'android', 101, 'купить'),
    (2023, 11, 1, 1, 1698885900, 'android', 101, 'купить кур'),
    (2023, 11, 1, 1, 1698885960, 'android', 101, 'купить куртку'),

    (2023, 11, 1, 2, 1698885600, 'iphone', 202, 'тел'),
    (2023, 11, 1, 2, 1698885660, 'iphone', 202, 'телефон'),
    (2023, 11, 1, 2, 1698885800, 'iphone', 202, 'телефон чехол'),

    (2023, 11, 2, 3, 1698972000, 'android', 303, 'шарф'),
    (2023, 11, 2, 3, 1698972900, 'android', 303, 'шарф шерстяной'),

    (2023, 11, 2, 4, 1698975000, 'desktop', 404, 'коф'),
    (2023, 11, 2, 4, 1698975060, 'desktop', 404, 'кофе'),
    (2023, 11, 2, 4, 1698975120, 'desktop', 404, 'кофемашина'),

    (2023, 11, 2, 5, 1698975300, 'desktop', 505, 'тел'),
    (2023, 11, 2, 5, 1698975360, 'desktop', 505, 'телевизор'),
    (2023, 11, 2, 5, 1698975660, 'desktop', 505, 'телевизор 4к'),
    (2023, 11, 2, 5, 1698975800, 'desktop', 505, 'телевизор'),
    
    (2023, 11, 2, 6, 1698976000, 'iphone', 606, 'пла'),
    (2023, 11, 2, 6, 1698976060, 'iphone', 606, 'платье'),
    (2023, 11, 2, 6, 1698976600, 'iphone', 606, 'платье красное');
----------
--Часть 3. Запрос
   
 select * from (
 --подзапрос для создания временной таблицы со столбцами next_query и is_final и более простой фильтрации даты и устройства
	 select *,
	 --lead вычисляет следующий запрос конкретного пользователя с конкретного девайса
	 lead(q.query) over (partition by q.userid, q.deviceid order by q.ts) as next_query,
	 --кейс для создания столбца is_final
	    case
	        --нет последующих запросов с данного устройства
	        when lead(q.ts) over (partition by q.userid, q.deviceid order by q.ts) is null then 1
	        
	        --время до следующего запроса более 3 минут
	        when lead(q.ts) over (partition by q.userid, q.deviceid order by q.ts) - q.ts > 180 then 1
	
	        --следующий запрос короче текущего и разница времени более 1 минуты
	        when length(lead(q.query) over (partition by q.userid, q.deviceid order by q.ts)) < length(q.query)
	             and lead(q.ts) over (partition by q.userid, q.deviceid order by q.ts) - q.ts > 60 then 2
			--в промежуточных запросах 0
	        else 0
	    end as is_final
	from query q
	order by q.userid, q.deviceid, q.ts)
where day = 2 and devicetype = 'android' and (is_final = 1 or is_final = 2)