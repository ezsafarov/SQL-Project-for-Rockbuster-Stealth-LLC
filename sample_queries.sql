
-- Sample 1: Insert multiple categories into the category table
INSERT INTO category (name)
VALUES 
    ('Thriller'), 
    ('Crime'), 
    ('Mystery'), 
    ('Romance'), 
    ('War');

-- Expected result:
-- This query adds five new category records to the category table.


-- Sample 2: Create the category table with constraints
CREATE TABLE category(  
  category_id INTEGER NOT NULL DEFAULT nextval('category_category_id_seq'::regclass), -- Auto-incrementing primary key  
  name TEXT COLLATE pg_catalog."default" NOT NULL, -- Category name, required field  
  last_update TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), -- Auto-updated timestamp  
  CONSTRAINT category_pkey PRIMARY KEY (category_id) -- Defines category_id as the unique primary key  
);

-- Expected result:
-- A new table 'category' is created with constraints ensuring data integrity.


-- Sample 3: Update film_category to change the category of 'African Egg' to 'Thriller'
-- Retrieve the film_id for the movie titled 'African Egg'
SELECT film_id  
FROM film  
WHERE title = 'African Egg';
-- Expected result: film_id = 5

-- Retrieve the category_id for the 'Thriller' category  
SELECT category_id  
FROM category  
WHERE name = 'Thriller';
-- Expected result: category_id = 17

-- Update the film_category table to apply the change  
UPDATE film_category  
SET category_id = 17  
WHERE film_id = 5;
-- Expected result: The category_id for film_id 5 is updated to 17.


-- Sample 4: Calculate the average rental rate for each movie rating
SELECT AVG(rental_rate) AS avg_rental_rate, rating  
FROM film  
GROUP BY rating;
  
-- Expected result:
-- Returns the average rental rate for each rating category (e.g., PG, G, PG-13, R, NC-17).


-- Sample 5: Calculate the average total amount paid by the top 5 customers from specific cities
SELECT AVG(total_amount_paid.total_paid_amount_per_customer) AS average  
FROM (  
    -- Subquery to calculate total amount paid per customer from selected cities  
    SELECT A.customer_id, A.first_name, A.last_name, SUM(E.amount) AS total_paid_amount_per_customer,  
           C.city, D.country  
    FROM customer A  
    INNER JOIN address B ON A.address_id = B.address_id  
    INNER JOIN city C ON B.city_id = C.city_id  
    INNER JOIN country D ON C.country_id = D.country_id  
    INNER JOIN payment E ON A.customer_id = E.customer_id  
    WHERE C.city IN ('Aurora', 'London', 'Kitwe', 'Adoni', 'Dhule (Dhulia)', 'Xintai', 'Sivas', 'Mahajanga', 'Nezahualcyotl', 'Escobar')  
    GROUP BY A.customer_id, A.first_name, A.last_name, C.city, D.country  
    ORDER BY total_paid_amount_per_customer DESC  
    LIMIT 5  
) AS total_amount_paid;

-- Expected result:
-- Averages the total payment amounts of the top 5 customers (by sum of payments) from the specified cities.


-- Sample 6: Retrieve total and top customer counts by country using a Common Table Expression (CTE)
WITH top_country_data_cte (country, all_customer_count, top_customer_count) AS (
    SELECT 
        D.country,
        COUNT(DISTINCT A.customer_id) AS all_customer_count,
        COUNT(DISTINCT top_5_countries.customer_id) AS top_customer_count
    FROM customer A
    INNER JOIN address B ON A.address_id = B.address_id
    INNER JOIN city C ON B.city_id = C.city_id
    INNER JOIN country D ON D.country_id = C.country_id
    -- Left join to include top 5 customers (by payment) from specific cities  
    LEFT JOIN (
        SELECT A.customer_id, D.country
        FROM customer A
        INNER JOIN address B ON A.address_id = B.address_id  
        INNER JOIN city C ON B.city_id = C.city_id  
        INNER JOIN country D ON C.country_id = D.country_id  
        INNER JOIN payment E ON A.customer_id = E.customer_id
        WHERE C.city IN ('Aurora', 'London', 'Kitwe', 'Adoni', 'Dhule (Dhulia)', 'Xintai', 'Sivas', 'Mahajanga', 'Nezahualcyotl', 'Escobar')
        GROUP BY A.customer_id, D.country
        ORDER BY SUM(E.amount) DESC
        LIMIT 5
    ) AS top_5_countries ON D.country = top_5_countries.country
    GROUP BY D.country
    HAVING COUNT(DISTINCT top_5_countries.customer_id) > 0
    ORDER BY all_customer_count DESC
)
SELECT country, all_customer_count, top_customer_count
FROM top_country_data_cte;

-- Expected result:
-- For each country that has at least one top customer (based on payment from selected cities), this query displays:
--   - The total number of customers (all_customer_count)
--   - The number of top customers (top_customer_count)
