-- To view all the data in a dataset
SELECT 
    *
FROM
    dataset2
ORDER BY district;

-- To get the total number of rows in the dataset
SELECT 
    COUNT(*)
FROM
    dataset2;

-- To get the total population of India
SELECT 
    SUM(population) AS population
FROM
    dataset2;


-- To join tables dataset1 and dataset2

SELECT 
    a.district, a.state, a.sex_ratio, b.population
FROM
    dataset1 a,
    dataset2 b
WHERE
    a.district = b.district;


-- alternative method to join tables dataset1 and dataset2

SELECT 
    a.district, a.state, a.sex_ratio, b.population
FROM
    dataset1 a
        INNER JOIN
    dataset2 b ON a.district = b.district;

/* 
	sex_ratio = female/male -----1
	population = male+female -----2
    female = population-male ------3
    sex_ratio = (population-male)/male
    sex_ratio*male = population-male
    population = sex_ratio*male +male
    population = male(sex_ratio+1)
    male = population/(sex_ratio+1) ----4 *We will use this formula to get total number of males in the dataset*
    female = population - population/(sex_ratio+1) ----5
    female = population (1- 1/(sex_ratio+1)) *We will use this formula to get total number of females in the dataset*
    female = population(sex_ratio+1-1/sex_ratio+1)
    female = population*sex_ratio/(sex_ratio+1)
*/

-- To get the total number of males and females in each district
 
SELECT 
    c.district,
    c.state,
    ROUND((c.population) / (c.sex_ratio + 1), 0) male,
    ROUND((c.population * c.sex_ratio) / (c.sex_ratio + 1),
            0) female
FROM
    (SELECT 
        a.district,
            a.state,
            (a.sex_ratio / 1000) AS sex_ratio,
            b.population
    FROM
        dataset1 a
    INNER JOIN dataset2 b ON a.district = b.district) c
ORDER BY c.state;


-- To get total males and females in each state

SELECT 
    d.state,
    SUM(d.male) total_males,
    SUM(d.female) total_females
FROM
    (SELECT 
        c.district,
            c.state,
            ROUND((c.population) / (c.sex_ratio + 1), 0) male,
            ROUND((c.population * c.sex_ratio) / (c.sex_ratio + 1), 0) female
    FROM
        (SELECT 
        a.district,
            a.state,
            (a.sex_ratio / 1000) AS sex_ratio,
            b.population
    FROM
        dataset1 a
    INNER JOIN dataset2 b ON a.district = b.district) c) d
GROUP BY d.state
ORDER BY d.state
;

/* let t= total literacy, p = population , lr= literacy ratio
t/p=lr
t= lr*p*/

-- To get literacy rate 

select c.district, c.state, round(c.literacy_ratio*c.population,0) as literate_people, ROUND((1-c.literacy_ratio) * c.population, 0) illeterate_people from
(SELECT 
        a.district,
            a.state,
            a.literacy/100 AS literacy_ratio,
            b.population
    FROM
        dataset1 a
    INNER JOIN dataset2 b ON a.district = b.district)c;


-- To get total literacy rate for each state

SELECT 
    c.state,
    SUM(c.literate) AS literate_people,
    SUM(c.illeterate) AS illteretate_people
FROM
    (SELECT 
        a.district,
            a.state,
            ROUND(a.literacy * b.population, 0) AS literate,
            ROUND((a.literacy - 1) * b.population, 0) illeterate
    FROM
        dataset1 a
    INNER JOIN dataset2 b ON a.district = b.district) c
GROUP BY c.state
ORDER BY c.state;


-- To get the population in previous census

/* 
prev_census+prev_census*growth = population
prev_census = population/(1+growth) 
*/

select d.district, d.state, round(d.population/d.Growthh,0) as previous_census_population, d.population current_census_population from 
(SELECT 
        a.district,
            a.state,
            1+(a.growth/100) AS Growthh,
            b.population
    FROM
        dataset1 a
    INNER JOIN dataset2 b ON a.district = b.district)d;

-- Alternative method 

with 
t1 as 
(SELECT 
        a.district as district,
            a.state state,
            1+growth/100 as g,
            b.population population
    FROM
        dataset1 a
    INNER JOIN dataset2 b ON a.district = b.district),
    t2 as 
    (select district,state, round(population/g) as previous_census_population , population as current_census_population from t1)
    
select * from t2;

-- to get the total population of India for current and previous census

SELECT 
    SUM(h.previous_census_population),
    SUM(h.current_census_population)
FROM
    (SELECT 
        e.state,
            SUM(e.previous_census_population) previous_census_population,
            SUM(e.current_census_population) current_census_population
    FROM
        (SELECT 
        d.district,
            d.state,
            ROUND(d.population / d.Growthh, 0) AS previous_census_population,
            d.population current_census_population
    FROM
        (SELECT 
        a.district,
            a.state,
            1 + (a.growth / 100) AS Growthh,
            b.population
    FROM
        dataset1 a
    INNER JOIN dataset2 b ON a.district = b.district) d) e
    GROUP BY e.state) h;

-- To get the population vs area 

SELECT 
    l.Total_Area / l.previous_census_population previous_census_population_vs_area,
    l.Total_Area / l.current_census_population current_census_population_vs_area
FROM
    (SELECT 
        q.*, s.Total_Area
    FROM
        (SELECT 
        '1' AS keyy, n.*
    FROM
        (SELECT 
        SUM(h.previous_census_population) previous_census_population,
            SUM(h.current_census_population) current_census_population
    FROM
        (SELECT 
        e.state,
            SUM(e.previous_census_population) previous_census_population,
            SUM(e.current_census_population) current_census_population
    FROM
        (SELECT 
        d.district,
            d.state,
            ROUND(d.population / d.Growthh, 0) AS previous_census_population,
            d.population current_census_population
    FROM
        (SELECT 
        a.district,
            a.state,
            1 + (a.growth / 100) AS Growthh,
            b.population
    FROM
        dataset1 a
    INNER JOIN dataset2 b ON a.district = b.district) d) e
    GROUP BY e.state) h) n) q
    INNER JOIN (SELECT 
        '1' AS keyy, z.*
    FROM
        (SELECT 
        SUM(area_km2) Total_Area
    FROM
        dataset2) z) s ON q.keyy = s.keyy) l;

-- To get the districts from each state with the highest literacy ratio using window function

select a.* from(
select district, state, literacy, rank() over(partition by state order by literacy desc) rnk from dataset1)a 
where a.rnk in (1,2,3) order by state ;
