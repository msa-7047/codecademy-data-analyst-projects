
-- Task 1: Explore the climate dataset
SELECT *
FROM state_climate;


-- Task 2: Calculate running average temperatures by state
SELECT
    state,
    year,
    tempf,
    AVG(tempf) OVER (
        PARTITION BY state
        ORDER BY year
    ) AS running_avg_temp
FROM state_climate
ORDER BY state, year;


-- Task 3: Identify the lowest temperature for each state
SELECT
    state,
    year,
    tempf,
    FIRST_VALUE(tempf) OVER (
        PARTITION BY state
        ORDER BY tempf
    ) AS lowest_temp
FROM state_climate
ORDER BY state, year;


-- Task 4: Identify the highest temperature for each state
SELECT
    state,
    year,
    tempf,
    LAST_VALUE(tempf) OVER (
        PARTITION BY state
        ORDER BY tempf
        RANGE BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS highest_temp
FROM state_climate
ORDER BY state, year;


-- Task 5: Calculate year-on-year temperature changes
SELECT
    state,
    year,
    tempf,
    tempf - LAG(tempf, 1, tempf) OVER (
        PARTITION BY state
        ORDER BY year
    ) AS change_in_temp
FROM state_climate
ORDER BY change_in_temp DESC;


-- Task 6: Rank the coldest temperatures across all states
SELECT
    year,
    state,
    tempf,
    RANK() OVER (
        ORDER BY tempf
    ) AS coldest_rank
FROM state_climate
ORDER BY coldest_rank;


-- Task 7: Rank the warmest temperatures within each state
SELECT
    state,
    year,
    tempf,
    RANK() OVER (
        PARTITION BY state
        ORDER BY tempf DESC
    ) AS warmest_rank
FROM state_climate
ORDER BY state, warmest_rank;


-- Task 8: Divide each state's temperatures into quartiles
SELECT
    NTILE(4) OVER (
        PARTITION BY state
        ORDER BY tempf
    ) AS quartile,
    year,
    state,
    tempf
FROM state_climate
ORDER BY state, quartile, year;


-- Task 9: Divide all temperature records into quintiles
SELECT
    NTILE(5) OVER (
        ORDER BY tempf
    ) AS quintile,
    year,
    state,
    tempf
FROM state_climate
ORDER BY quintile, tempf, state, year;
