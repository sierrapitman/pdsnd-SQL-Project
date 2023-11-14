-- Optimization opportunity for all questions: convert subquery to a CTE

--Set 1 Q1: 
--Create a query that lists each movie, the film category it is
--classified in, and the number of times it has been rented out.

SELECT
  sub.category AS category
  , SUM(rental_count) AS rental_count
  FROM (
    -- select distinct film titles, their categories, and the count of rentals for each film using a window function
    -- window function: for each unique f.title, calculate the r.rental_id count separately, effectively counting the number of rentals for each film title
    SELECT DISTINCT f.title AS title
      -- limit query to only the categories listed in the WHERE clause
      , c.name as category
      , COUNT(r.rental_id) OVER (PARTITION BY f.title) AS rental_count
      FROM film f
      JOIN film_category fc
        ON f.film_id = fc.film_id
      JOIN category c
        ON fc.category_id = c.category_id
      JOIN inventory i
        ON f.film_id = i.film_id
      JOIN rental r
        ON i.inventory_id = r.inventory_id
    -- filter the results to include only films in specific categories
    WHERE c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) sub
    GROUP BY 1
    ORDER BY 2;



--Set 1 q2:
--Can you provide a table with the movie titles and divide
--them into 4 levels (first_quarter, second_quarter,
--third_quarter, and final_quarter) based on the quartiles
--(25%, 50%, 75%) of the rental duration for movies across
--all categories?

SELECT sub.title AS title
      , sub.category AS category
      , sub.rental_duration AS rental_duration
      -- divide the result set into four quartiles based on rental_duration
      -- quartiles are calculated independently for each distinct value in the rental_duration column
      -- each quartile represents one-fourth of the result set
      , NTILE(4) OVER (PARTITION BY sub.rental_duration) AS quartile
  FROM
    (SELECT
      f.title AS title
      , c.name AS category
      , f.rental_duration AS rental_duration
    FROM film f
    JOIN film_category fc
      ON f.film_id = fc.film_id
    JOIN category c
      ON fc.category_id = c.category_id
    WHERE c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) AS sub
ORDER BY 4, 3, 2, 1;



--Set 1 q3:
--Finally, provide a table with the family-friendly film
--category, each of the quartiles, and the corresponding
--count of movies within each combination of film category
--for each corresponding rental duration category. The
--resulting table should have three columns: Category, Rental length category, Count

SELECT category, quartile, count(quartile)
FROM(
  SELECT sub.title AS title
        , sub.category AS category
        , sub.rental_duration AS rental_duration
        , NTILE(4) OVER (PARTITION BY sub.rental_duration) AS quartile
  FROM
    (SELECT
      f.title AS title
      , c.name AS category
      , f.rental_duration AS rental_duration
    FROM film f
    JOIN film_category fc
      ON f.film_id = fc.film_id
    JOIN category c
      ON fc.category_id = c.category_id
    WHERE c.name in ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')) AS sub) sub2
GROUP BY 1, 2
ORDER BY 1, 2;



--Set 2 q1:
--Write a query that returns the store ID for the store, the
--year and month and the number of rental orders each
--store has fulfilled for that month. Your table should
--include a column for each of the following: year, month,
--store ID and count of rental orders fulfilled during that
--month.

SELECT s.store_id
  , date_part ('month', r.rental_date) AS rental_month
  , date_part ('year', r.rental_date) AS rental_year
  , count(r.rental_id)
FROM rental r
JOIN staff st
ON r.staff_id = st.staff_id
JOIN store s
ON st.store_id = s.store_id
GROUP BY 1, 2, 3
ORDER BY 3, 2, 1;
