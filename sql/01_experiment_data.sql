-- Project 4: Mobile checkout redesign A/B test (synthetic)
-- Population: mobile users who started checkout, 7 Sep – 4 Oct 2026 (28 days), randomized 50/50.
-- Planted truths the analysis should uncover:
--   * real overall lift in checkout completion (control ~46%)
--   * the lift is concentrated on iOS (Apple Pay) and small on Android
--   * a novelty effect: extra lift in the first 4 days that fades
--   * a data-quality issue: ~1% of assignments were double-logged (duplicate rows)

CREATE TABLE IF NOT EXISTS analytics.ab_checkout_experiment
(
    user_id     UInt32,
    variant     LowCardinality(String),   -- control / treatment
    assigned_at DateTime,
    platform    LowCardinality(String),   -- iOS / Android
    completed   UInt8,                    -- 1 = finished checkout
    revenue     Decimal(10, 2)            -- order value if completed, else 0
)
ENGINE = MergeTree
ORDER BY (assigned_at, user_id);

TRUNCATE TABLE analytics.ab_checkout_experiment;

INSERT INTO analytics.ab_checkout_experiment
WITH
    (cityHash64(number, 'var')  % 100000) / 100000.0 AS r_var,
    (cityHash64(number, 'day')  % 100000) / 100000.0 AS r_day,
    (cityHash64(number, 'sec')  % 100000) / 100000.0 AS r_sec,
    (cityHash64(number, 'plat') % 100000) / 100000.0 AS r_plat,
    (cityHash64(number, 'conv') % 100000) / 100000.0 AS r_conv,
    greatest((cityHash64(number, 'u1') % 100000) / 100000.0, 1e-6) AS u1,
    (cityHash64(number, 'u2') % 100000) / 100000.0 AS u2,
    r_var < 0.5 AS is_control,
    toUInt8(floor(r_day * 28)) AS day_idx,
    r_plat < 0.55 AS is_ios,
    0.46
      + if(is_control, 0, if(is_ios, 0.09, 0.02))            -- true effect by platform
      + if(NOT is_control AND day_idx < 4, 0.06, 0)          -- novelty boost, first 4 days
      AS p_complete,
    r_conv < p_complete AS done,
    sqrt(-2 * ln(u1)) * cos(2 * pi() * u2) AS z               -- standard normal (Box-Muller)
SELECT
    toUInt32(500000 + number)                                          AS user_id,
    if(is_control, 'control', 'treatment')                             AS variant,
    addSeconds(toDateTime('2026-09-07 00:00:00'), toUInt32(day_idx * 86400 + r_sec * 86399)) AS assigned_at,
    if(is_ios, 'iOS', 'Android')                                       AS platform,
    toUInt8(done)                                                      AS completed,
    if(done, round(exp(log(1700) + 0.55 * z), 2), 0)                   AS revenue
FROM numbers(4000);

-- Data-quality trap: double-logged assignments (exact duplicate rows)
INSERT INTO analytics.ab_checkout_experiment
SELECT * FROM analytics.ab_checkout_experiment
WHERE cityHash64(user_id, 'dup') % 100 = 0;
