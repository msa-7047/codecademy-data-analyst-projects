-- User Churn: Codeflix subscription analysis (SQLite)
-- Dataset: fictional Codecademy subscription records.
-- Churn = cancellations during a month / subscriptions active at the start of that month.
-- A subscription ending on the first day is counted as active at the start,
-- and as cancelled during that month. New subscriptions in the month are excluded.

-- Task 1: Inspect the first 100 subscriptions
SELECT * FROM subscriptions LIMIT 100;

-- Task 2: Check the dataset date range and segments
SELECT
    MIN(subscription_start) AS earliest_start,
    MAX(subscription_start) AS latest_start,
    MIN(subscription_end) AS earliest_end,
    MAX(subscription_end) AS latest_end
FROM subscriptions;

SELECT segment, COUNT(*) AS subscriptions
FROM subscriptions
GROUP BY segment
ORDER BY segment;

-- Task 8A: Overall Jan–Mar aggregate monthly churn rate by segment
-- This is total monthly cancellations / total monthly starting subscriptions.
-- It is NOT the percentage of the January cohort that churned over three months.
WITH months AS (
    SELECT '2017-01-01' AS first_day, '2017-01-31' AS last_day
    UNION ALL SELECT '2017-02-01', '2017-02-28'
    UNION ALL SELECT '2017-03-01', '2017-03-31'
),
cross_join AS (
    SELECT s.*, m.first_day, m.last_day
    FROM subscriptions AS s
    CROSS JOIN months AS m
),
status AS (
    SELECT
        id,
        first_day AS month,
        CASE WHEN segment = 87
                  AND subscription_start < first_day
                  AND (subscription_end >= first_day OR subscription_end IS NULL)
             THEN 1 ELSE 0 END AS is_active_87,
        CASE WHEN segment = 30
                  AND subscription_start < first_day
                  AND (subscription_end >= first_day OR subscription_end IS NULL)
             THEN 1 ELSE 0 END AS is_active_30,
        CASE WHEN segment = 87
                  AND subscription_start < first_day
                  AND subscription_end BETWEEN first_day AND last_day
             THEN 1 ELSE 0 END AS is_cancelled_87,
        CASE WHEN segment = 30
                  AND subscription_start < first_day
                  AND subscription_end BETWEEN first_day AND last_day
             THEN 1 ELSE 0 END AS is_cancelled_30
    FROM cross_join
),
status_aggregate AS (
    SELECT
        SUM(is_active_87) AS sum_active_87,
        SUM(is_active_30) AS sum_active_30,
        SUM(is_cancelled_87) AS sum_cancelled_87,
        SUM(is_cancelled_30) AS sum_cancelled_30
    FROM status
    
)
SELECT
    ROUND(100.0 * sum_cancelled_87 / NULLIF(sum_active_87, 0), 2) AS churn_segment_87_pct,
    ROUND(100.0 * sum_cancelled_30 / NULLIF(sum_active_30, 0), 2) AS churn_segment_30_pct
FROM status_aggregate;

-- Task 8B: Churn rate for each individual month by segment
WITH months AS (
    SELECT '2017-01-01' AS first_day, '2017-01-31' AS last_day
    UNION ALL SELECT '2017-02-01', '2017-02-28'
    UNION ALL SELECT '2017-03-01', '2017-03-31'
),
cross_join AS (
    SELECT s.*, m.first_day, m.last_day
    FROM subscriptions AS s
    CROSS JOIN months AS m
),
status AS (
    SELECT
        id,
        first_day AS month,
        CASE WHEN segment = 87
                  AND subscription_start < first_day
                  AND (subscription_end >= first_day OR subscription_end IS NULL)
             THEN 1 ELSE 0 END AS is_active_87,
        CASE WHEN segment = 30
                  AND subscription_start < first_day
                  AND (subscription_end >= first_day OR subscription_end IS NULL)
             THEN 1 ELSE 0 END AS is_active_30,
        CASE WHEN segment = 87
                  AND subscription_start < first_day
                  AND subscription_end BETWEEN first_day AND last_day
             THEN 1 ELSE 0 END AS is_cancelled_87,
        CASE WHEN segment = 30
                  AND subscription_start < first_day
                  AND subscription_end BETWEEN first_day AND last_day
             THEN 1 ELSE 0 END AS is_cancelled_30
    FROM cross_join
),
status_aggregate AS (
    SELECT
        month,
        SUM(is_active_87) AS sum_active_87,
        SUM(is_active_30) AS sum_active_30,
        SUM(is_cancelled_87) AS sum_cancelled_87,
        SUM(is_cancelled_30) AS sum_cancelled_30
    FROM status
    GROUP BY month
)
SELECT
    month,
    ROUND(100.0 * sum_cancelled_87 / NULLIF(sum_active_87, 0), 2) AS churn_segment_87_pct,
    ROUND(100.0 * sum_cancelled_30 / NULLIF(sum_active_30, 0), 2) AS churn_segment_30_pct
FROM status_aggregate
ORDER BY month;

-- Bonus (Task 9): Scalable query for any number of segments
-- Avoid separate CASE columns for every segment.
WITH months AS (
    SELECT '2017-01-01' AS first_day, '2017-01-31' AS last_day
    UNION ALL SELECT '2017-02-01', '2017-02-28'
    UNION ALL SELECT '2017-03-01', '2017-03-31'
),
monthly_counts AS (
    SELECT
        m.first_day AS month,
        s.segment,
        SUM(CASE WHEN s.subscription_start < m.first_day
                      AND (s.subscription_end >= m.first_day OR s.subscription_end IS NULL)
                 THEN 1 ELSE 0 END) AS active_at_start,
        SUM(CASE WHEN s.subscription_start < m.first_day
                      AND s.subscription_end BETWEEN m.first_day AND m.last_day
                 THEN 1 ELSE 0 END) AS cancellations
    FROM months AS m
    CROSS JOIN subscriptions AS s
    GROUP BY m.first_day, s.segment
)
SELECT
    month,
    segment,
    active_at_start,
    cancellations,
    ROUND(100.0 * cancellations / NULLIF(active_at_start, 0), 2) AS churn_rate_pct
FROM monthly_counts
ORDER BY month, segment;
