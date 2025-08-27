-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration  VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

-- 1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows
SELECT
	type,rating
	FROM(SELECT 
	type, rating, COUNT(*) as total_count, 
	RANK() OVER(PARTITION BY type 
	ORDER BY COUNT(*) DESC) as ranking 
FROM netflix GROUP BY 1,2) as t1 where ranking=1;

--3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT
	title,release_year
	FROM netflix
	where release_year=2020;

--4. Find the Top 5 Countries with the Most Content on Netflix
SELECT
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,count(*) as total_count
	FROM netflix
	WHERE country IS NOT NULL
	GROUP BY 1
	ORDER BY 2 desc
LIMIT 5;

--5 Identify the Longest Movie
SELECT
	title,duration
	FROM netflix
	WHERE duration = (SELECT MAX(duration) FROM netflix WHERE type='Movie');

--6. Find Content Added in the Last 5 Years
SELECT 
	title,type,date_added
	FROM netflix
	WHERE TO_DATE(date_added,'Month DD,YYYY') > CURRENT_DATE - INTERVAL '5 years';

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT
	title,director
	FROM netflix
	WHERE director
ILIKE '%Rajiv Chilaka%';

--8. List All TV Shows with More Than 5 Seasons
SELECT
	title,duration
	FROM netflix
	WHERE type='TV Show' AND 
CAST(SPLIT_PART(duration,' ',1) AS INT)>5;

--9. Count the Number of Content Items in Each Genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
	COUNT(*) as total_count
	FROM netflix
GROUP BY 1;

--10. Find each year and the average numbers of content release in India on netflix.
SELECT
	release_year,
	CAST(AVG(country_count) AS INT) as avg_count
	FROM (SELECT
		release_year,count(*) as country_count
		FROM netflix where country LIKE '%India%' GROUP BY release_year) 
		AS t GROUP BY release_year ORDER BY release_year;

--11. List All Movies that are Documentaries
SELECT
	* FROM
	netflix
	WHERE listed_in
	ILIKE '%documentaries%';

--12. Find All Content Without a Director
SELECT *
	FROM netflix
	WHERE director IS NULL;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT title,release_year
	FROM netflix
	WHERE casts ILIKE '%salman khan%' AND 
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE)-10 AND 
type='Movie';

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT
	UNNEST(STRING_TO_ARRAY(casts,',')) as actor,
	COUNT(*) as total_count
	FROM netflix
	WHERE country LIKE '%India%'
	GROUP BY actor
	ORDER BY total_count desc
	LIMIT 10;

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    CASE
        WHEN description ILIKE '%kill%' 
          OR description ILIKE '%violence%' 
        THEN 'Bad Content'
        ELSE 'Good Content'
    END AS category,
    COUNT(*) AS total_content
FROM netflix
GROUP BY category;