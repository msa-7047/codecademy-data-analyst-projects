-- CoolTShirts | Marketing Attribution (SQLite)
-- Run each statement separately in SQLTools.
-- Here's the first-touch query, in case you need it
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id)
SELECT ft.user_id,
    ft.first_touch_at,
    pv.utm_source,
		pv.utm_campaign
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp;


-- Task 1: Number of campaigns and sources, and their relationships.
SELECT COUNT(DISTINCT utm_campaign) AS campaign_count FROM page_visits;
SELECT COUNT(DISTINCT utm_source) AS source_count FROM page_visits;
SELECT DISTINCT utm_campaign, utm_source FROM page_visits ORDER BY utm_campaign;

-- Task 2: Website pages.
SELECT DISTINCT page_name FROM page_visits ORDER BY page_name;

-- Task 3: First touches per campaign.
WITH first_touch AS (
    SELECT user_id, MIN(timestamp) AS first_touch_at
    FROM page_visits GROUP BY user_id
)
SELECT pv.utm_campaign, COUNT(DISTINCT ft.user_id) AS num_first_touches
FROM first_touch ft
JOIN page_visits pv ON pv.user_id = ft.user_id AND pv.timestamp = ft.first_touch_at
GROUP BY pv.utm_campaign
ORDER BY num_first_touches DESC;

-- Task 4: Last touches per campaign (last recorded page visit per user).
WITH last_touch AS (
    SELECT user_id, MAX(timestamp) AS last_touch_at
    FROM page_visits GROUP BY user_id
)
SELECT pv.utm_campaign, COUNT(DISTINCT lt.user_id) AS num_last_touches
FROM last_touch lt
JOIN page_visits pv ON pv.user_id = lt.user_id AND pv.timestamp = lt.last_touch_at
GROUP BY pv.utm_campaign
ORDER BY num_last_touches DESC;

-- Task 5: Number of unique purchasers.
SELECT COUNT(DISTINCT user_id) AS unique_purchasers
FROM page_visits WHERE page_name = '4 - purchase';

-- Task 6: Purchases attributed to campaign recorded at purchase page.
-- Mirrors the Codecademy exercise; counts one purchaser per campaign.
WITH last_purchase AS (
    SELECT user_id, MAX(timestamp) AS last_purchase_at
    FROM page_visits WHERE page_name = '4 - purchase'
    GROUP BY user_id
)
SELECT pv.utm_campaign, COUNT(DISTINCT lp.user_id) AS attributed_purchasers
FROM last_purchase lp
JOIN page_visits pv ON pv.user_id = lp.user_id AND pv.timestamp = lp.last_purchase_at
WHERE pv.page_name = '4 - purchase'
GROUP BY pv.utm_campaign
ORDER BY attributed_purchasers DESC;

-- Task 7: Rank campaigns by attributed purchasers to inform investment.
WITH purchasers AS (
    SELECT user_id, MAX(timestamp) AS purchase_at
    FROM page_visits WHERE page_name = '4 - purchase'
    GROUP BY user_id
)
SELECT pv.utm_campaign, pv.utm_source,
       COUNT(DISTINCT p.user_id) AS attributed_purchasers
FROM purchasers p
JOIN page_visits pv ON pv.user_id = p.user_id AND pv.timestamp = p.purchase_at
WHERE pv.page_name = '4 - purchase'
GROUP BY pv.utm_campaign, pv.utm_source
ORDER BY attributed_purchasers DESC;

-- Bonus: Compare first-touch acquisition with purchase-page attribution.
WITH first_touch AS (
    SELECT user_id, MIN(timestamp) AS first_at FROM page_visits GROUP BY user_id
), first_counts AS (
    SELECT pv.utm_campaign, COUNT(DISTINCT ft.user_id) AS first_touches
    FROM first_touch ft JOIN page_visits pv
      ON pv.user_id = ft.user_id AND pv.timestamp = ft.first_at
    GROUP BY pv.utm_campaign
), purchase_counts AS (
    SELECT utm_campaign, COUNT(DISTINCT user_id) AS purchasers
    FROM page_visits WHERE page_name = '4 - purchase'
    GROUP BY utm_campaign
)
SELECT fc.utm_campaign, fc.first_touches,
       COALESCE(pc.purchasers, 0) AS purchase_page_attributions
FROM first_counts fc LEFT JOIN purchase_counts pc
  ON fc.utm_campaign = pc.utm_campaign
ORDER BY purchase_page_attributions DESC, first_touches DESC;
