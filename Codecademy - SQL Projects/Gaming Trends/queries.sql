-- Twitch Gaming Trends | Codecademy SQL practice
-- Counts represent event records, not necessarily unique viewers.

-- 1. Inspect both datasets
SELECT * FROM stream LIMIT 20;
SELECT * FROM chat LIMIT 20;

-- 2. Distinct games
SELECT DISTINCT game FROM stream ORDER BY game;

-- 3. Distinct channels
SELECT DISTINCT channel FROM stream ORDER BY channel;

-- 4. Most popular games by viewing records
SELECT game, COUNT(*) AS view_count
FROM stream
GROUP BY game
ORDER BY view_count DESC;

-- 5. Top 10 countries for League of Legends viewing records
SELECT country, COUNT(*) AS view_count
FROM stream
WHERE game = 'League of Legends'
GROUP BY country
ORDER BY view_count DESC
LIMIT 10;

-- 6. Viewing platforms
SELECT player, COUNT(*) AS view_count
FROM stream
GROUP BY player
ORDER BY view_count DESC;

-- 7. Assign genres and count records by game
SELECT game,
       CASE
           WHEN game IN ('League of Legends', 'Dota 2', 'Heroes of the Storm') THEN 'MOBA'
           WHEN game = 'Counter-Strike: Global Offensive' THEN 'FPS'
           WHEN game IN ('DayZ', 'ARK: Survival Evolved') THEN 'Survival'
           ELSE 'Other'
       END AS genre,
       COUNT(*) AS view_count
FROM stream
GROUP BY game
ORDER BY view_count DESC;

-- 8. Inspect timestamps
SELECT time FROM stream LIMIT 10;

-- 9. Extract seconds from timestamps
SELECT time, strftime('%S', time) AS seconds
FROM stream
GROUP BY time
LIMIT 20;

-- 10. Hourly viewing records for Great Britain (UTC/unspecified timezone)
SELECT strftime('%H', time) AS hour_of_day, COUNT(*) AS view_count
FROM stream
WHERE country = 'GB'
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 11. Join example: device IDs may occur multiple times in both tables,
-- so the result can be many-to-many and should not be interpreted as unique viewers.
SELECT s.time AS stream_time, c.time AS chat_time,
       s.device_id, s.game AS stream_game, c.game AS chat_game
FROM stream AS s
JOIN chat AS c ON s.device_id = c.device_id
LIMIT 20;

-- 12a. Popular games among Great Britain viewing records
SELECT game, COUNT(*) AS gb_view_count
FROM stream
WHERE country = 'GB'
GROUP BY game
ORDER BY gb_view_count DESC;

-- 12b. Subscriber flag distribution; NULL means unrecorded, not False
SELECT COALESCE(subscriber, 'Unknown') AS subscriber_status,
       COUNT(*) AS view_count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM stream), 2) AS pct_of_all_records
FROM stream
GROUP BY subscriber_status
ORDER BY view_count DESC;

-- 12c. Chat activity by game
SELECT game, COUNT(*) AS chat_records
FROM chat
GROUP BY game
ORDER BY chat_records DESC;

-- 12d. Compare independent game-level viewing and chat counts without
-- multiplying events through a many-to-many device_id join.
WITH views AS (
    SELECT game, COUNT(*) AS view_records FROM stream GROUP BY game
), chats AS (
    SELECT game, COUNT(*) AS chat_records FROM chat GROUP BY game
)
SELECT v.game, v.view_records, COALESCE(c.chat_records, 0) AS chat_records,
       ROUND(1.0 * COALESCE(c.chat_records, 0) / NULLIF(v.view_records, 0), 3) AS chat_to_view_record_ratio
FROM views AS v
LEFT JOIN chats AS c ON v.game = c.game
ORDER BY v.view_records DESC;
