create database Music_database; 
use music_database;


select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

#Q1 who is the most senior most employee --

select * from employee
order by levels desc
limit 1;

#Q2 Which countries have the most invoices? --

select * from invoice;
select billing_country,count(*) as Invoice_count from invoice
group by billing_country
order by Invoice_count desc;

#Q3 what are Top 3 values of Total Invoices ?

select * from invoice;
select total from invoice
order by total desc
limit 3;

#Q4 which city has the best customers? we would like to throw a promotional music festival in the city we made most money.
-- write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name and sum of invoice totals

select * from invoice;


select billing_city,sum(total) as Invoice_Total
from invoice
group by 1
order by 2 desc
limit 1;

#Q5 who is the best customer? The customer who had spend the most money will be declared the best customer.
-- write a query trhat returns the person who has spent most money ?

select * from customer;
select * from invoice;

-- First logical test - checking customer_id in invoice table which has highest sum(total) --

select customer_id, sum(total) as Invoice_total 
from invoice
group by 1
order by 2 desc;

-- Now getting the name and other details for the same --

select a.customer_id,a.first_name,a.last_name,a.country,a.state,a.city,a.email,sum(b.Total) Invoice_total
from customer as a inner join invoice as b
on a.customer_id = b.customer_id
group by 1,2,3,4,5,6,7
order by invoice_Total desc
limit 1;



#Q6 Write a query to return email,first_name,Last_name and genre  of all rock music  listeners.
-- Return your list ordered alphabetically by email starts with A.

select * from genre;
select * from customer;


select distinct customer.customer_id,email,first_name,last_name 
from customer
inner join  invoice on customer.customer_id = invoice.customer_id
join invoice_line  on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name like "rock")
order by email;

SELECT DISTINCT c.customer_id, c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
ORDER BY c.email;

#Q7 Lets invite artists who have written the most rock music in our dataset.
-- write a query that returns the artist name and total track 
-- of the Top 10 rock bands

select * from artist;
select * from album;
select * from track;
select * from genre;

select artist.artist_id,artist.name,count(artist.artist_id) as No_of_songs
from track 
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like "rock"
group by 1,2
order by no_of_songs desc
limit 10;

#Q8 Lets invite artists who have written the most rock music in our dataset.
-- write a query that returns the artist name and total track 
-- of the Top 10 rock bands

select ar.artist_id,ar.name,count(*) as no_of_songs
from artist as ar 
join album as al on ar.artist_id = al.artist_id
join track as t on al.album_id = t.album_id
join genre as g on t.genre_id = g.genre_id
where g.name = "rock"
group by ar.artist_id,ar.name 
order by no_of_songs desc
limit 10;

#Q9 return all the track names that have a song length longer than the average song length .
-- Return the name and milliseconds for each track
--  order by the song length with the longest song listed first --


select * from track;
select name,milliseconds 
from track 
where milliseconds > (
select avg(milliseconds) as avg_track_length from track);
 
	

  
  
#Q10  Find how much amount spend by each customer on artists? write a query to return customer name, artist name and Total spent.

use music_database;


with best_selling_artist as (
select artist.artist_id as artist_id,artist.name as artist_name,
sum(invoice_line.unit_price* invoice_line.quantity) as Total_sales
from invoice_line 
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track. album_id
join artist on artist.artist_id = album.artist_id
group by 1,2
order by 3 desc
limit 1
)
select c.customer_id,c.first_name ,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id = i.customer_id 
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id 
join album alb on alb.album_id = t.album_id
join  best_selling_artist bsa on bsa.artist_id  = alb.artist_id
group by 1,2,3,4
order by 5 desc;


#Q11 We want to find out the most popular music genre for each country .
-- We determine the most popular genre as the genre with the highest amount of purchases .
-- write a query that returns each country along with the Top genre.
-- for countries where the maximum number of purchase is shared return all genres.

with popular_genre as 
(
	select count(invoice_line .quantity) as purchases,customer.country,genre.name,genre.genre_id,
    row_number () over (partition by customer.country order by count(invoice_line.quantity)desc) as rowno
    from invoice_line 
    join invoice on invoice.invoice_id = invoice_line.invoice_id
    join customer on customer.customer_id = invoice.customer_id
    join track on track.track_id = invoice_line.track_id
    join genre on genre.genre_id = track.genre_id
    group by 2,3,4
    order by 2 asc,1 desc
)

select * from popular_genre where rowno <= 1;

#Q12 Write a query that determines the customer that has spent the most on music for each country.
-- write a query that returns the country along with the top customer and how much they spent.
-- for countries where the top amount spent is shared, provide all the customers who spent this amount.

with customer_with_country  as (
	select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
    row_number() over (partition by billing_country order by sum(total)desc) as Rowno
    from invoice
    join customer on customer.customer_id = invoice.customer_id
    group by 1,2,3,4
    order by 4 asc,5 desc)
select * from customer_with_country where Rowno <= 1;


    