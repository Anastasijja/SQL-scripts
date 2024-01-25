/*
Представьте, что вы работаете в инвестиционной компании, специализирующейся на волатильных* 
высокорискованных акциях на рынке США. Для решения используйте таблицы prices и securities.
Руководитель поставил перед вами задачу найти такую акцию, максимальная цена (high) которой
была более 200 долларов, а минимальная (low) — менее 30.
Инвестиционная компания планирует сделать ставку на рост котировок такой бумаги, поэтому 
нам нужна не просто волатильная акция, цена которой изменяется в таком широком диапазоне, 
но и такая бумага, среднее значение дневных отклонений** которой больше 0.
Отдел риск-менеджмента инвестиционной компании ограничивает инвестиции в компании, которые 
находятся на рынке менее двух лет (менее 504 торговых дней) и общая сумма торгов по которым 
ниже 5 000 000 долларов. То есть нужные нам акции должны находиться на рынке более 504 
торговых дней и общая сумма торгов по ним должна быть больше 5 000 000 долларов.
Найдите бумаги, подходящие под описанные выше условия, основываясь на данных из таблиц 
prices и securities. В качестве ответа укажите наименование компании, которая имеет 
наибольшее среднее значение дневных отклонений (при соблюдении ограничений, которые вам дал 
ваш руководитель и отдел риск-менеджмента).
*Волатильность или изменчивость — финансовый показатель, характеризующий изменчивость цены 
на что-либо.
**Дневное отклонение — разница между ценой закрытия и ценой закрытия предыдущего дня по 
конкретной ценной бумаге.
*/

with cte_find_lag as (
select  p.symbol,  
p."close" - lag(p."close")
over (
partition by p.symbol 
order by p."date" 
)  as "lag" 
from prices p 

--максимальная цена (high) которой была более 200 долларов, а минимальная (low) — менее 30
where p.high >200
and p.symbol in 
(
select p.symbol from prices p 
where p.low <30
)
--разница между ценой закрытия и ценой закрытия предыдущего дня по конкретной ценной бумаге больше 0
and p.symbol in 
(
select distinct  t1.symbol
from (
select p.symbol, p."close" , 
lag(p."close")
over (
partition by p.symbol 
order by p."date" 
) as "Yerterday_close"
from prices p ) as t1
where "close" - "Yerterday_close" !=0
)
--общая сумма торгов по которым выше 5 000 000 долларов.
and p.symbol in 
(
select distinct  p.symbol 
from  prices p 
group by  p.symbol
having sum(p.volume  )>5000000
)
-- находятся на рынке не менее 504 торговых дней
and p.symbol in 
(
select  p.symbol 
from prices p
group by p.symbol 
having count (p."date" )>=504
)
)

select c.symbol, avg (ABS(c.lag))
from cte_find_lag c
group by symbol

  