use netflix;
SET SQL_SAFE_UPDATES = 0;

UPDATE netflix_titles
SET director = 'N/A'
WHERE director = '';

UPDATE netflix_titles
SET type = 'N/A'
WHERE type = '';

UPDATE netflix_titles
SET title = 'N/A'
WHERE title = '';

UPDATE netflix_titles
SET cast = 'N/A'
WHERE cast = '';

UPDATE netflix_titles
SET country = 'N/A'
WHERE country = '';

UPDATE netflix_titles
SET data_added = 'N/A'
WHERE data_added = '';

UPDATE netflix_titles
SET release_year = 'N/A'
WHERE release_year = '';

UPDATE netflix_titles
SET rating = 'N/A'
WHERE rating = '' ;

UPDATE netflix_titles
SET duration = 'N/A'
WHERE duration = '';

UPDATE netflix_titles
SET listed_in = 'N/A'
WHERE Listed_in = '';

UPDATE netflix_titles
SET description = 'N/A'
WHERE description = '';

select * from netflix_titles;

-- Q1. Count the number of Movies vs TV Shows
SELECT 
	distinct type,
	COUNT(*)
FROM netflix_titles
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
with rating_count as (select
type,
rating,
count(*) as rating_count
from netflix_titles
group by type,rating
),
rating_ranks as (
select type,
rating,
rating_count,
rank() over (partition by type order by rating_count desc) as rnk
from rating_count
)
select 
type,
rating as most_frequent_rating
from rating_ranks
where rnk = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select *
from netflix_titles
where release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
select
country,
count(country) as country_count
from  netflix_titles
where country != 'N/A'
group by country
order by country_count desc
limit 5;

-- 5. Identify the longest movie
SELECT 
    title,
    duration
FROM netflix_titles
WHERE type = 'Movie'
  AND duration IS NOT NULL
  AND duration LIKE '%min%'
ORDER BY 
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

-- 6. Find content added in the last 5 years
SELECT 
    title,
    release_year,
    type
FROM netflix_titles
WHERE release_year >= (
    SELECT MAX(release_year) - 4 FROM netflix_titles
)
ORDER BY release_year DESC;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select
title, type,
director
from netflix_titles
WHERE director like '%Rajiv%';

-- 8. List all TV shows with more than 5 seasons
select * 
from netflix_titles
where
type = 'TV show'
and
duration >= '5 seasons';

-- 9. Count the number of content items in each genre
WITH RECURSIVE split_genres AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS remaining
    FROM netflix_titles
    WHERE listed_in != 'N/A'

    UNION ALL

    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS genre,
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_genres
    WHERE remaining != ''
)

SELECT genre, COUNT(*) AS count
FROM split_genres
GROUP BY genre
ORDER BY count DESC;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

select
release_year, 
count(*) as total_content
from netflix_titles
where country = 'India'
group by release_year
order by total_content desc
limit 5;
-- 11. List all movies that are documentaries
select * from netflix_titles
where listed_in like '%Documentaries%';
-- 12. Find all content without a director
select * from netflix_titles
where director = 'N/A';

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT title, release_year
FROM netflix_titles
WHERE type = 'Movie'
  AND cast LIKE '%Salman Khan%'
  AND release_year >= (
      SELECT MAX(release_year) - 10 FROM netflix_titles
  )
ORDER BY release_year DESC;
;
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
-- Step 1: Split cast column into individual actor rows for Indian movies
WITH RECURSIVE split_cast AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(`cast`, ',', 1)) AS actor,
        SUBSTRING(`cast`, LENGTH(SUBSTRING_INDEX(`cast`, ',', 1)) + 2) AS remaining
    FROM netflix_titles
    WHERE country LIKE '%India%'
      AND type = 'Movie'
      AND `cast` IS NOT NULL

    UNION ALL

    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_cast
    WHERE remaining IS NOT NULL AND remaining != ''
)

-- Step 2: Count appearances and get top 10
SELECT 
    actor, 
    COUNT(*) AS movie_count
FROM 
    split_cast
GROUP BY 
    actor
ORDER BY 
    movie_count DESC;
/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
select category,
type,
count(*) as content_count
from (select * ,
case 
when description like '%kill%' or description like '%violence%' then 'Bad' 
else 'Good'
end as category
from netflix_titles
)
as categorized_content
group by category, type
order by type;