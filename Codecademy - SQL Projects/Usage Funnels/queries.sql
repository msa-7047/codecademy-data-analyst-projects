

-- Task 1: Explore the survey data
SELECT *
FROM survey
LIMIT 10;


-- Task 2: Count unique responses for each question
SELECT
    question,
    COUNT(DISTINCT user_id) AS num_responses
FROM survey
GROUP BY question
ORDER BY question;


-- Task 3: Calculate quiz completion rates
WITH responses AS (
    SELECT
        question,
        COUNT(DISTINCT user_id) AS num_responses
    FROM survey
    GROUP BY question
)
SELECT
    question,
    num_responses,
    1.0 * num_responses /
        MAX(
            CASE
                WHEN question = '1. What are you looking for?'
                THEN num_responses
            END
        ) OVER () AS completion_rate
FROM responses
ORDER BY question;


-- Task 4: Explore the purchase funnel tables
SELECT * FROM quiz LIMIT 5;
SELECT * FROM home_try_on LIMIT 5;
SELECT * FROM purchase LIMIT 5;


-- Task 5: Combine the three funnel stages
SELECT
    q.user_id,
    h.user_id IS NOT NULL AS is_home_try_on,
    h.number_of_pairs,
    p.user_id IS NOT NULL AS is_purchase
FROM quiz AS q
LEFT JOIN home_try_on AS h
    ON q.user_id = h.user_id
LEFT JOIN purchase AS p
    ON q.user_id = p.user_id
LIMIT 10;


-- Task 6A: Calculate overall conversion rates
WITH data AS (
    SELECT
        q.user_id,
        h.user_id IS NOT NULL AS is_home_try_on,
        h.number_of_pairs,
        p.user_id IS NOT NULL AS is_purchase
    FROM quiz AS q
    LEFT JOIN home_try_on AS h
        ON q.user_id = h.user_id
    LEFT JOIN purchase AS p
        ON q.user_id = p.user_id
)
SELECT
    COUNT(user_id) AS total_users,
    1.0 * SUM(is_home_try_on) / COUNT(user_id)
        AS quiz_to_try_on_rate,
    1.0 * SUM(is_purchase) / SUM(is_home_try_on)
        AS try_on_to_purchase_rate
FROM data;


-- Task 6B: Compare purchase rates by number of pairs
WITH data AS (
    SELECT
        q.user_id,
        h.user_id IS NOT NULL AS is_home_try_on,
        h.number_of_pairs,
        p.user_id IS NOT NULL AS is_purchase
    FROM quiz AS q
    LEFT JOIN home_try_on AS h
        ON q.user_id = h.user_id
    LEFT JOIN purchase AS p
        ON q.user_id = p.user_id
)
SELECT
    number_of_pairs,
    COUNT(number_of_pairs) AS total_users,
    SUM(is_purchase) AS num_purchased,
    1.0 * SUM(is_purchase) / COUNT(number_of_pairs)
        AS purchase_rate
FROM data
WHERE number_of_pairs IN ('3 pairs', '5 pairs')
GROUP BY number_of_pairs;
