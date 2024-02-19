CREATE TABLE SALES ( customer_id varchar(1), order_date date, product_id int)
INSERT INTO SALES (customer_id,order_date,product_id)
Values
  ( 'A', '2021-01-01',1),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE MEMBER (customer_id varchar(1), join_date timestamp)
Alter table member drop column join_date
alter table member
add join_date date
INSERT INTO MEMBER (customer_id, join_date)
VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

CREATE TABLE MENU (product_id int not null primary key, product_name varchar(5), price int)
INSERT INTO MENU (product_id, product_name, price)
VALUES 
('1', 'sushi',10),
('2', 'curry',15),
('3', 'ramen',12);

select * FROM SALES
SELECT * FROM MENU
SELECT * FROM MEMBER

--What is the total amount each customer spent at the restaurant?
Select sub.customer_id, sum(sub.price*sub.count_product)
from (
Select customer_id, s.product_id, count(s.product_id) as count_product, m.price
from SALES as s
left join MENU as m
on s.product_id=m.product_id
Group by customer_id, s.product_id,m.price
 ) as sub
group by sub.customer_id
--other resutl
Select s.customer_id, sum(m.price)
from SALES as s
left join MENU as m 
on s.product_id=m.product_id
group by s.customer_id

--How many days has each customer visited the restaurant?
Select customer_id, count(distinct order_date) as number_visit
from SALES
Group by customer_id

--What was the first item from the menu purchased by each customer?
select customer_id, m.product_name
from SALES as s
left join MENU as m
on s.product_id=m.product_id
Where order_date IN (
Select  min(order_date) as frist_order
from SALES as s
Group by customer_id) 
group by customer_id, m.product_name

--What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(s.product_id) as number_sold from SALES as s
left join menu as m
on s.product_id=m.product_id
group by s.product_id, m.product_name
order by count(s.product_id) desc
offset 0 rows
fetch first 1 rows only

--Which item was the most popular for each customer?
select sub.customer_id, max(sub.pop_order)
from(
select customer_id, m.product_name,  count(m.product_name) as pop_order
from sales as s
left join menu as m
on s.product_id=m.product_id
group by customer_id, m.product_name
) as sub
group by sub.customer_id

--Which item was purchased first by the customer after they became a member?

select s.customer_id, m.product_name
from sales as s
left join menu as m
on s.product_id=m.product_id
left join (
select s.customer_id, min(s.order_date) as first
from sales as s
left join member as me
on s.customer_id=me.customer_id
where order_date>=join_date
group by s.customer_id) as sub
on sub.customer_id = s.customer_id
where sub.first=s.order_date
group by s.customer_id, m.product_name

--Which item was purchased just before the customer became a member?
select s.customer_id, m.product_name
from sales as s
left join menu as m
on s.product_id=m.product_id
left join (
select s.customer_id, max(s.order_date) as first
from sales as s
left join member as me
on s.customer_id=me.customer_id
where order_date<join_date
group by s.customer_id) as sub
on sub.customer_id = s.customer_id
where sub.first=s.order_date
group by s.customer_id, m.product_name

--What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(m.product_id) as total_item, sum(m.price) as total_amount
from sales as s
left join menu as m
on s.product_id=m.product_id
left join member as me
on s.customer_id=me.customer_id
where order_date<join_date
group by s.customer_id

--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select customer_id, sum(point) as total_point
from (
select s.customer_id,
CASE m.product_name WHEN 'sushi' THEN
price*20 ELSE price*10 END as point
from sales as s
left join menu as m
on s.product_id=m.product_id
) as sub
group by customer_id
order by customer_id

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?
select customer_id, sum(point) as total_point
from (
select s.customer_id, m.price, m.product_name, s.order_date,
CASE  
WHEN m.product_name='sushi'  THEN
price*20 
WHEN M.product_name!='sushi' and(
datediff(day,join_date,order_date)<7 and datediff(day,join_date,order_date)>=0) THEN
price*20 
ELSE price*10 END as point
from sales as s
inner join member as me
on me.customer_id=s.customer_id
left join menu as m
on s.product_id=m.product_id
) as sub
where order_date <= '2021-01-31'
group by customer_id
order by customer_id

--bonus question
Select s.customer_id, order_date, m.product_name,
case
when s.order_date <mm.join_date THEN
'N' ELSE 'Y' END as memeber
from (sales as  s
left join menu as m
on m.product_id=s.product_id)
left join member as mm
on mm.customer_id=s.customer_id
--
