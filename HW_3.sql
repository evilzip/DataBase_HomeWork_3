--1. Вывести распределение (количество) клиентов по сферам деятельности, отсортировав результат по убыванию количества. — (1 балл)
select
	count(customer_id) as count, job_industry_category 
from
	customer_20240101 c 
group by
	job_industry_category 
order by
	count desc

--2. Найти сумму транзакций за каждый месяц по сферам деятельности, отсортировав по месяцам и по сфере деятельности. — (1 балл)
select
	date_trunc('month', transaction_date :: timestamp) as month,
	sum(list_price) as sum, job_industry_category 
from
	transaction_20240101 t
inner join customer_20240101 c on
			t.customer_id = c.customer_id 
group by
	month, job_industry_category
order by
	month, job_industry_category


--3. Вывести количество онлайн-заказов для всех брендов в рамках подтвержденных заказов клиентов из сферы IT. — (1 балл)
select
	count(transaction_id),  brand 
from 
	transaction_20240101 t
inner join customer_20240101 c on
	t.customer_id = c.customer_id
where
	order_status = 'Approved'
	and
	job_industry_category = 'IT'
group by
	brand


--4. Найти по всем клиентам сумму всех транзакций (list_price), максимум, минимум и количество транзакций, отсортировав результат по убыванию суммы транзакций и количества клиентов. 
--Выполните двумя способами: используя только group by и используя только оконные функции. Сравните результат. — (2 балла)
---- С помощью GROUP BY
select
	sum(list_price) as sum,
	max(list_price) as max,
	min(list_price) as min,
	count(t.transaction_id) as count,
	c.customer_id 
from
	transaction_20240101 t
inner join customer_20240101 c on
	t.customer_id = c.customer_id
group by
	c.customer_id
order by
	sum desc,
	count desc

---- С помощью Оконных функций
select
	sum(list_price) over client_group as sum,
	max(list_price) over client_group as max,
	min(list_price) over client_group as min,
	count(t.transaction_id) over client_group as count_transaction,
	c.customer_id 
from
	transaction_20240101 t
inner join customer_20240101 c on
	t.customer_id = c.customer_id
window client_group as (partition by c.customer_id)
order by
	sum desc,
	count_transaction desc



--5. Найти имена и фамилии клиентов с минимальной/максимальной суммой транзакций за весь период (сумма транзакций не может быть null). Напишите отдельные запросы для минимальной и максимальной суммы. — (2 балла)
-----Максимальная сумма тарнзакций
with totalsum_names as (
	select
		sum(list_price) as sum,
		first_name,
		last_name
	from transaction_20240101 t
	inner join customer_20240101 c on t.customer_id = c.customer_id
	group by
		first_name,
		last_name
		)
select
	sum,
	first_name,
	last_name
from
	totalsum_names
where
	sum = (select max(sum) from totalsum_names)

------Минимальная сумма транзакций
with totalsum_names as (
	select
		sum(list_price) as sum,
		first_name,
		last_name
	from
		transaction_20240101 t
	inner join customer_20240101 c on t.customer_id = c.customer_id
	group by
		first_name
		,last_name
		)
select
	sum,
	first_name,
	last_name
from
	totalsum_names
where
	sum = (select min(sum) from totalsum_names)


--6. Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций. — (1 балл)
select
	*
from (
	select
		transaction_date,
		transaction_id,
		customer_id,
		row_number () over customers as rn
	from
		transaction_20240101 t
	window customers as (
		partition by customer_id order by transaction_date :: timestamp)
	)
where
	rn = 1



--7. Вывести имена, фамилии и профессии клиентов, между транзакциями которых был максимальный интервал (интервал вычисляется в днях) — (2 балла).
with
	diff_table as (
	select
			transaction_date:: timestamp - lag (transaction_date:: timestamp) over customers as days_diff,
			c.customer_id, 
			c.first_name,
			c. last_name
	from
		transaction_20240101 t
	inner join customer_20240101 c on t.customer_id = c.customer_id
	window customers as (partition by t.customer_id order by transaction_date :: timestamp)
	)
select
	*
from
	diff_table
where
	days_diff = (select max(days_diff) from diff_table)



 




