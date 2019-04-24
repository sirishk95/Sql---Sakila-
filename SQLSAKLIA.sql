USE sakila;

-- Display the first and last names of all actors from the table actor.
select first_name, last_name from sakila.actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name, ' ' , last_name)) as Actor_Name
from sakila.actor;

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from sakila.actor
where first_name = 'Joe';

-- Find all actors whose last name contain the letters GEN
select * from sakila.actor where last_name like '%gen%';

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from sakila.actor where last_name like '%LI%' order by last_name, first_name;

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from sakila.country where country in ('Afghanistan', 'Bangladesh', 'China');

-- You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

alter table actor ADD description BLOB;
select * from actor limit 5;

-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor Drop Column description;

-- List the last names of actors, as well as how many actors have that last name.
select last_name, COUNT(last_name) as 'number_of_actor' from actor Group by last_name;

-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, COUNT(last_name) as 'number_of_actor' from actor Group by last_name Having number_of_actor > 1;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor set first_name = 'Harpo' where first_name = 'Groucho' and last_name = 'Williams' and actor_id = 172; 

select * from actor where first_name = 'Harpo' and last_name = 'Williams';

-- Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = 'Groucho' where first_name = 'Harpo' and last_name = 'Williams' and actor_id = 172;

-- check for update
select * from actor where first_name = 'Groucho' and last_name = 'Williams';

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table sakila.address;

-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select st.first_name, st.last_name, ad.address from staff st join address ad on st.address_id = ad.address_id;

 -- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
 select first_name, last_name, sum(amount) as total_amount
 from staff st
 join payment pt
 on st.staff_id = pt.staff_id where payment_date between '2005-08-01' and '2005-08-30' Group By first_name, last_name;
 
  -- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
 select f.film_id, f.title, count(fa.actor_id) as "Number_of_actors" 
 from film f
 inner join film_actor fa
 on f.film_id = fa.film_id
 GROUP BY fa.film_id;
 
 -- How many copies of the film Hunchback Impossible exist in the inventory system?
 select f.film_id, f.title, count(f.film_id) as 'Number_of_Copy' 
 from film f join inventory i 
 on f.film_id = i.film_id
 where f.title = 'Hunchback Impossible'
 Group by f.film_id;
 
 -- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
 SELECT cus.first_name, cus.last_name, sum(py.amount) as "Total amount paid"
FROM payment py
JOIN customer cus
ON py.customer_id = cus.customer_id
GROUP BY cus.customer_id
ORDER BY cus.last_name ASC;

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title FROM film
WHERE title like "K%" OR title like "Q%" AND language_id IN
(
  SELECT language_id
  FROM language
  WHERE name IN ('ENGLISH')
);

-- Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor where actor_id In 
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN 
  (
  SELECT film_id
  FROM film
  WHERE title = "ALONE TRIP"
  )
);

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
Select cus.first_name, cus.last_name, cus.email
From customer cus
Join address ad
On cus.address_id = ad.address_id
Join City cty
On ad.city_id = cty.city_id
Join country cnt
On cnt.country_id = cty.country_id
Where country = 'Canada';

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT film.title as "Film Title", category.name as "Movie Type"
FROM film
JOIN film_category 
ON film.film_id = film_category.film_id
JOIN category
ON film_category.category_id = category.category_id
WHERE category.name = "Family";

-- Display the most frequently rented movies in descending order.
SELECT film.title as "Movie", count(rental.rental_id) as "Rent Times"
FROM film JOIN inventory ON film.film_id = inventory.film_id JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY inventory.film_id
ORDER BY count(rental.rental_id) DESC;

-- Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, sum(payment.amount) as "Total_Revenue"
FROM store JOIN inventory ON store.store_id = inventory.store_id JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id GROUP BY store.store_id;

-- Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country FROM store JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id JOIN country ON country.country_id = city.country_id;

-- List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name as "Movie Genres", sum(payment.amount) as "Gross Revenue"
FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON inventory.inventory_id = rental.inventory_id
JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY category.category_id
ORDER BY sum(payment.amount) DESC
LIMIT 5;

 -- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `Top_five_genres` 
AS SELECT c.name as "Movie Genres", sum(py.amount) as "Gross Revenue"
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment py
ON r.rental_id = py.rental_id
GROUP BY c.category_id
ORDER BY sum(py.amount) DESC
LIMIT 5;

-- How would you display the view that you created in 8a?
SELECT * FROM `Top_five_genres`;

-- You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW `Top_five_genres`;



 
 
 
 













 


