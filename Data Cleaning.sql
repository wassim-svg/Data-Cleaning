--Data Cleaning
create table customer_staging
like customers;

select * from customers;

insert customer_staging
select * from customers; 



with duplicate_cte as(
    select *,
    ROW_NUMBER() OVER(partition by product_id, product_name, category,	quantity,	unit_price_eur,	order_date, `date`) AS row_num
    from customer_staging;
)
DELETE
from  duplicate_cte
where row_num > 1;

create table `customer_staging2`(
    `order_id` INT,
    `customer_id` INT,
    `customer_name` TEXT,
    `product_id` INT,
    `product_name` TEXT,
    `category` TEXT,
    `quantity` INT DEFAULT NULL,
    `unit_price_eur` INT,
    `order_date` DATE,
    `city` TEXT		
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from customer_staging2;

insert into customer_staging2
ROW_NUMBER() OVER(partition by product_id, product_name, category,	quantity,	unit_price_eur,	order_date, `date`) AS row_num
    from customer_staging;

DELETE from customer_staging2
where row_num > 1;

select * from customer_staging2;

--Standardizing data

select category(trim(category))
from customer_staging2;

update customer_staging2
set category = trim(category);

select distinct(city)
from customer_staging2
order by 1;



update customer_staging2
set `date` = STR_TO_DATE(`date`, '%d/%m/%Y');

alter tabel customer_staging2
modify column `date` DATE;

select * from customer_staging2 t1
join customer_staging2 t2
on t1.product = t2.product
where( t1.category is null or t1.category = '')
and t2.category is null;

update customer_staging2 t1
join customer_staging2 t2
on t1.product = t2.product
set  t1.category = t2.category
where( t1.category is null or t1.category = '')
and t2.category is null;

alter table customer_staging2
drop column row_num;

select * from customer_staging2;