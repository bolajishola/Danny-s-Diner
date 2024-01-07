-- Creating of sales table
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

--Inserting data into the sales table
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
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
 
--Creating of menu table
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

--Inserting data into the menu table
INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
--Creating of members table
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

--Inserting data into the members table
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  --Vieing of the created tables 
  SELECT *
  FROM members;
  
  SELECT *
  FROM menu;
  
  SELECT *
  FROM sales;
  
  --
  
  --1. What is the total amount each customer spent at the restaurant?
  SELECT DISTINCT (s.customer_id), SUM(price) AS TotalAmountByCustomer
  FROM sales as s
  FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  GROUP BY s.customer_id;
  
  --2. How many days has each customer visited the restaurant?
  SELECT s.customer_id, COUNT(order_date) AS DaysCustomerVisited
  FROM sales as s
  FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  GROUP BY s.customer_id;
  
  --3. What was the first item from the menu purchased by each customer?
  SELECT s.customer_id, MIN(s.order_date) AS DatePurchased, me.product_name 
  FROM sales as s
  FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  GROUP BY s.customer_id, me.product_name;
  
  --4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  SELECT MAX(me.product_name) AS MostPurchasedItem, COUNT(me.product_name) AS TimePurchased 
  FROM sales as s
  FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  GROUP BY s.customer_id, me.product_name;
  
  --5. Which item was the most popular for each customer?
  SELECT s.customer_id, me.product_name, COUNT(me.product_name) AS CountOfMostPopularItem
  FROM sales as s
  FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  GROUP BY s.customer_id, me.product_name
  ORDER BY COUNT(me.product_name) DESC;
  
  --6. Which item was purchased first by the customer after they became a member?
  SELECT s.customer_id, me.product_name, MIN(s.order_date) AS ItemPurchasedFirst
  FROM sales as s
  FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  WHERE s.order_date < m.join_date
  GROUP BY s.customer_id, me.product_name;
  
  --7. Which item was purchased just before the customer became a member?
  SELECT s.customer_id, s.order_date, me.product_name 
  FROM sales as s
  FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  WHERE join_date > order_date;
  
  --8. What is the total items and amount spent for each member before they became a member?
  SELECT s.customer_id, s.order_date, m.join_date, me.product_name, SUM(me.price) AS AmountSpent
  FROM sales as s
  FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  WHERE join_date > order_date
  GROUP BY s.customer_id, s.order_date, m.join_date, me.product_name;
  
  --9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
  SELECT s.customer_id, SUM(
    CASE
    WHEN me.product_name = 'sushi' THEN 2 * me.price * 10
    ELSE me.price * 10
    END
    ) AS total_points
    FROM sales AS s
     FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  GROUP BY s.customer_id;
  
  --10. In the first week after a customer joins the program (including their join date) 
  --they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
  SELECT s.customer_id, SUM(
    CASE
    WHEN s.order_date <= DATEADD(week, 1, m.join_date) THEN 2 * me.price * 10
    ELSE me.price * 10
    END
    ) AS total_points
    FROM sales AS s
     FULL OUTER JOIN members AS m
  ON s.customer_id = m.customer_id
  FULL OUTER JOIN menu AS me
  ON s.product_id = me.product_id
  WHERE s.customer_id IN ('A', 'B')
  AND s.order_date <= '2023-01-31'
  GROUP BY s.customer_id;