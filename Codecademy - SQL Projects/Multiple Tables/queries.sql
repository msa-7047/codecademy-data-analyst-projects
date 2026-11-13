
-- 1. Combine trip records with rider information
SELECT *
FROM trips
LEFT JOIN riders
    ON trips.rider_id = riders.id;


-- 2. Match completed trips with the cars used
SELECT *
FROM trips
INNER JOIN cars
    ON trips.car_id = cars.id;


-- 3. Combine rider records from two tables
SELECT *
FROM riders
UNION
SELECT *
FROM riders2;


-- 4. Calculate the average cost of a trip
SELECT AVG(cost) AS average_trip_cost
FROM trips;


-- 5. Find riders who have completed fewer than 500 trips
SELECT *
FROM riders
WHERE total_trips < 500
UNION
SELECT *
FROM riders2
WHERE total_trips < 500;


-- 6. Count the number of active cars
SELECT COUNT(*) AS active_cars
FROM cars
WHERE status = 'active';


-- 7. Identify the two cars with the most completed trips
SELECT *
FROM cars
ORDER BY trips_completed DESC
LIMIT 2;
