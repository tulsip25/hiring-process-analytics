
-- =========================================================
-- PROJECT: The Hidden Cost of a Slow Hiring Process
-- FILE: data_quality_checks.sql
-- PURPOSE: Validate the recruiting dataset before analysis
-- DATABASE: SQLite
-- TABLE: recruiting_funnel
-- =========================================================


-- QUERY 1: Check the total number of records
-- Why: Establish the size of the dataset.

SELECT
    COUNT(*) AS total_records
FROM recruiting_funnel;


-- QUERY 2: Preview the first 10 records
-- Why: Inspect the values and understand how the data is organized.

SELECT *
FROM recruiting_funnel
LIMIT 10;


-- QUERY 3: Inspect the table structure
-- Why: Confirm column names and data types before writing
-- further queries.

PRAGMA table_info(recruiting_funnel);


-- QUERY 4: Check for duplicate candidate IDs
-- Why: Determine whether candidate_id appears more than once.
-- Note: A repeated ID does not automatically mean an error;
-- one candidate could potentially have multiple records.

SELECT
    candidate_id,
    COUNT(*) AS record_count
FROM recruiting_funnel
GROUP BY candidate_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


-- QUERY 5: Check for missing candidate IDs

SELECT
    COUNT(*) AS missing_candidate_ids
FROM recruiting_funnel
WHERE candidate_id IS NULL
   OR TRIM(CAST(candidate_id AS TEXT)) = '';


-- QUERY 6: Check for missing application dates

SELECT
    COUNT(*) AS missing_application_dates
FROM recruiting_funnel
WHERE application_date IS NULL
   OR TRIM(CAST(application_date AS TEXT)) = '';


-- QUERY 7: Review the final disposition categories
-- Why: Check the distinct values used to describe outcomes.

SELECT
    final_disposition,
    COUNT(*) AS record_count
FROM recruiting_funnel
GROUP BY final_disposition
ORDER BY record_count DESC;


-- QUERY 8: Review the furthest hiring stage categories
-- Why: Confirm which stage labels are present in the dataset.

SELECT
    stage_reached,
    COUNT(*) AS record_count
FROM recruiting_funnel
GROUP BY stage_reached
ORDER BY record_count DESC;


-- QUERY 9: Check missing dates for records marked Hired
-- Why: A missing start date or offer date may affect
-- time-to-start and hiring-process analysis.

SELECT
    COUNT(*) AS hired_records,
    SUM(
        CASE
            WHEN stage_offer_date IS NULL
              OR TRIM(CAST(stage_offer_date AS TEXT)) = ''
            THEN 1 ELSE 0
        END
    ) AS hired_records_missing_offer_date,
    SUM(
        CASE
            WHEN start_date IS NULL
              OR TRIM(CAST(start_date AS TEXT)) = ''
            THEN 1 ELSE 0
        END
    ) AS hired_records_missing_start_date
FROM recruiting_funnel
WHERE final_disposition = 'Hired';


-- QUERY 10: Check for missing recruiting sources
-- Why: Missing source values could make source comparisons
-- incomplete.

SELECT
    COUNT(*) AS missing_sources
FROM recruiting_funnel
WHERE source IS NULL
   OR TRIM(CAST(source AS TEXT)) = '';


-- QUERY 11: Check for missing stage-duration values
-- Why: Identify where supplied duration fields may be
-- unavailable. These fields are reviewed separately from
-- durations calculated directly from dates.

SELECT
    COUNT(*) AS total_records,
    SUM(
        CASE
            WHEN days_applied_to_screen IS NULL
              OR TRIM(CAST(days_applied_to_screen AS TEXT)) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_application_to_screen,
    SUM(
        CASE
            WHEN days_screen_to_tech IS NULL
              OR TRIM(CAST(days_screen_to_tech AS TEXT)) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_screen_to_technical,
    SUM(
        CASE
            WHEN days_tech_to_onsite IS NULL
              OR TRIM(CAST(days_tech_to_onsite AS TEXT)) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_technical_to_onsite,
    SUM(
        CASE
            WHEN days_onsite_to_offer IS NULL
              OR TRIM(CAST(days_onsite_to_offer AS TEXT)) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_onsite_to_offer
FROM recruiting_funnel;


-- QUERY 12: Check for unexpected final-disposition values
-- Why: Spot spelling variations, blanks, or unexpected categories.

SELECT DISTINCT
    final_disposition
FROM recruiting_funnel
ORDER BY final_disposition;


-- QUERY 13: Check for negative supplied stage durations
-- Why: Negative waiting times may indicate data-entry errors
-- or inconsistent date calculations.

SELECT
    COUNT(*) AS records_with_negative_durations
FROM recruiting_funnel
WHERE CAST(days_applied_to_screen AS REAL) < 0
   OR CAST(days_screen_to_tech AS REAL) < 0
   OR CAST(days_tech_to_onsite AS REAL) < 0
   OR CAST(days_onsite_to_offer AS REAL) < 0;


-- END OF DATA QUALITY CHECKS
