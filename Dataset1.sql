-- To view all the data in a dataset
SELECT 
    *
FROM
    dataset1 order by district;

-- To get the total number of rows in the dataset
SELECT 
    COUNT(*)
FROM
    dataset1;

-- To only get the result for states Jharkhand and Bihar
SELECT 
    *
FROM
    dataset1
WHERE
    state IN ('Jharkhand' , 'Bihar');

-- To get the average growth of all the states in percentage
SELECT 
    AVG(growth) AS 'Average Growth'
FROM
    dataset1;

-- To get the average growth of each individual state in percentage
SELECT 
    state, ROUND(AVG(growth), 0) AS 'Average Growth'
FROM
    dataset1
GROUP BY state
ORDER BY state;

-- To get the average Sex Ratio of each individual state
SELECT 
    state, ROUND(AVG(Sex_Ratio), 0) AS 'Average Sex Ratio'
FROM
    dataset1
GROUP BY state , Sex_Ratio
ORDER BY Sex_Ratio DESC;

-- To get the average literacy rate
SELECT 
    ROUND(AVG(literacy), 0) AS 'average literacy'
FROM
    dataset1;

-- To get the average literacy rate for each state
SELECT 
    state, ROUND(AVG(literacy), 0) AS 'average_literacy'
FROM
    dataset1
GROUP BY state
ORDER BY state
LIMIT 3;

-- To get the states for those who have literacy rate greater than 90
SELECT 
    state, ROUND(AVG(literacy), 0) AS average_literacy
FROM
    dataset1
GROUP BY state
HAVING ROUND(AVG(literacy), 0) > 90
ORDER BY state;

-- To get the bottom three states with the highest average growth
SELECT 
    state, ROUND(AVG(growth), 0) AS 'Average Growth'
FROM
    dataset1
GROUP BY state
ORDER BY ROUND(AVG(growth), 0)
LIMIT 3;

-- To get the bottom three states with the highest average sex ratio 
SELECT 
    state, ROUND(AVG(Sex_Ratio), 0) AS 'Average Sex Ratio'
FROM
    dataset1
GROUP BY state
ORDER BY ROUND(AVG(Sex_Ratio), 0)
LIMIT 3;

drop table top_states;

CREATE TABLE top_states (
    state TEXT,
    topstates FLOAT
);

-- To get top states

insert into top_states
SELECT 
    state, ROUND(AVG(literacy), 0) AS 'average_literacy'
FROM
    dataset1
GROUP BY state
ORDER BY ROUND(AVG(literacy), 0) desc;

SELECT 
    *
FROM
    top_states
LIMIT 3;

-- To get bottom states

CREATE TABLE bottom_states (
    state TEXT,
    topstates FLOAT
);

insert into bottom_states SELECT 
    state, ROUND(AVG(literacy), 0) AS 'average_literacy'
FROM
    dataset1
GROUP BY state
ORDER BY ROUND(AVG(literacy), 0) asc;

SELECT 
    *
FROM
    bottom_states
LIMIT 3;

-- to get top and bottom combined in one table

SELECT 
    *
FROM
    (SELECT 
        *
    FROM
        top_states
    LIMIT 3) a 
UNION SELECT 
    *
FROM
    (SELECT 
        *
    FROM
        bottom_states
    LIMIT 3) b;
    
-- Alternative method to get top and bottom combined in one table

with t1 as (
SELECT 
    state, ROUND(AVG(literacy), 0) AS 'average_literacy'
FROM
    dataset1
GROUP BY state
ORDER BY average_literacy desc
LIMIT 3),
t2 as ( SELECT 
    state, ROUND(AVG(literacy), 0) AS 'average_literacy'
FROM
    dataset1
GROUP BY state
ORDER BY average_literacy asc
LIMIT 3)
select * from (t1) union select * from 
(t2);

-- To get states starting with letter a or b

SELECT DISTINCT
    (state)
FROM
    dataset1
WHERE
    LOWER(state) LIKE 'a%'
        OR LOWER(state) LIKE 'b%'
ORDER BY state ASC;

-- To get states starting with letter a and ending with m

SELECT DISTINCT
    (state)
FROM
    dataset1
WHERE
    LOWER(state) LIKE 'a%'
        and LOWER(state) LIKE '%m'
ORDER BY state ASC;
