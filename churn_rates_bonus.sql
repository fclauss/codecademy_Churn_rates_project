WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-28' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT
 id,
 first_day as month,
 segment,
CASE
  WHEN (subscription_start < first_day) THEN 1
  ELSE 0
END as is_active,
CASE
 WHEN (subscription_end BETWEEN first_day AND last_day) THEN 1
  ELSE 0
END as is_canceled
FROM cross_join
),
which_month AS
(SELECT
 segment,
CASE
  WHEN (month = '2017-01-01')
   AND (is_active = 1) THEN 1
  ELSE 0
END as is_active_january,
CASE
  WHEN (month = '2017-02-01')
   AND (is_active = 1) THEN 1
  ELSE 0
END as is_active_february,
CASE
  WHEN (month = '2017-03-01')
   AND (is_active = 1) THEN 1
  ELSE 0
END as is_active_march,
CASE
  WHEN (month = '2017-01-01')
   AND (is_canceled = 1) THEN 1
  ELSE 0
END as is_canceled_january,
CASE
  WHEN (month = '2017-02-01')
   AND (is_canceled = 1) THEN 1
  ELSE 0
END as is_canceled_february,
CASE
  WHEN (month = '2017-03-01')
   AND (is_canceled = 1) THEN 1
  ELSE 0
END as is_canceled_march
FROM status
),
aggregate AS
(SELECT
 segment,
 SUM(is_active_january) as active_january,
 SUM(is_active_february) as active_februry,
 SUM(is_active_march) as active_march,
 SUM(is_canceled_january) as canceled_january,
 SUM(is_canceled_february) as canceled_february,
 SUM(is_canceled_march) as canceled_march
FROM which_month
GROUP BY 1
)
SELECT segment,
1.0 * aggregate.canceled_january / aggregate.active_january AS churn_rate_january,
1.0 * aggregate.canceled_february / aggregate.active_februry AS churn_rate_february,
1.0 * aggregate.canceled_march / aggregate.active_march AS churn_rate_march
FROM aggregate
GROUP BY 1;