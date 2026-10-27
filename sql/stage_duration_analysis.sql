
-- =========================================================
-- PROJECT: The Hidden Cost of a Slow Hiring Process
-- FILE: stage_duration_analysis.sql
-- PURPOSE: Measure waiting times between recruiting stages
-- METHOD: Calculate durations from date fields using SQLite
-- =========================================================


-- QUERY 1: Average time from application to phone screen
-- Why: Measure the first recorded transition.
-- julianday() allows date differences to be calculated in SQLite.

SELECT
    COUNT(*) AS records_with_both_dates,
    ROUND(
        AVG(
            julianday(stage_phone_screen_date)
            - julianday(application_date)
        ),
        2
    ) AS avg_days_application_to_screen
FROM recruiting_funnel
WHERE NULLIF(TRIM(application_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_phone_screen_date), '') IS NOT NULL;


-- QUERY 2: Average time from phone screen to technical assessment

SELECT
    COUNT(*) AS records_with_both_dates,
    ROUND(
        AVG(
            julianday(stage_tech_assessment_date)
            - julianday(stage_phone_screen_date)
        ),
        2
    ) AS avg_days_screen_to_technical
FROM recruiting_funnel
WHERE NULLIF(TRIM(stage_phone_screen_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_tech_assessment_date), '') IS NOT NULL;


-- QUERY 3: Average time from technical assessment to onsite interview
-- Important: Use the date columns because the supplied duration
-- field days_tech_to_onsite did not consistently match the dates.

SELECT
    COUNT(*) AS records_with_both_dates,
    ROUND(
        AVG(
            julianday(stage_onsite_date)
            - julianday(stage_tech_assessment_date)
        ),
        2
    ) AS avg_days_technical_to_onsite
FROM recruiting_funnel
WHERE NULLIF(TRIM(stage_tech_assessment_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_onsite_date), '') IS NOT NULL;


-- QUERY 4: Average time from onsite interview to offer

SELECT
    COUNT(*) AS records_with_both_dates,
    ROUND(
        AVG(
            julianday(stage_offer_date)
            - julianday(stage_onsite_date)
        ),
        2
    ) AS avg_days_onsite_to_offer
FROM recruiting_funnel
WHERE NULLIF(TRIM(stage_onsite_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_offer_date), '') IS NOT NULL;


-- QUERY 5: Compare all four average waiting times in one result
-- Why: Make it easy to compare stages and identify the longest
-- average wait.

SELECT
    'Application to Phone Screen' AS hiring_stage,
    COUNT(*) AS records_with_both_dates,
    ROUND(
        AVG(
            julianday(stage_phone_screen_date)
            - julianday(application_date)
        ),
        2
    ) AS average_wait_days
FROM recruiting_funnel
WHERE NULLIF(TRIM(application_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_phone_screen_date), '') IS NOT NULL

UNION ALL

SELECT
    'Phone Screen to Technical',
    COUNT(*),
    ROUND(
        AVG(
            julianday(stage_tech_assessment_date)
            - julianday(stage_phone_screen_date)
        ),
        2
    )
FROM recruiting_funnel
WHERE NULLIF(TRIM(stage_phone_screen_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_tech_assessment_date), '') IS NOT NULL

UNION ALL

SELECT
    'Technical to Onsite',
    COUNT(*),
    ROUND(
        AVG(
            julianday(stage_onsite_date)
            - julianday(stage_tech_assessment_date)
        ),
        2
    )
FROM recruiting_funnel
WHERE NULLIF(TRIM(stage_tech_assessment_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_onsite_date), '') IS NOT NULL

UNION ALL

SELECT
    'Onsite to Offer',
    COUNT(*),
    ROUND(
        AVG(
            julianday(stage_offer_date)
            - julianday(stage_onsite_date)
        ),
        2
    )
FROM recruiting_funnel
WHERE NULLIF(TRIM(stage_onsite_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_offer_date), '') IS NOT NULL;


-- QUERY 6: Check for negative date-derived durations
-- Why: A later stage date should not normally precede the
-- date of the earlier stage.

SELECT
    SUM(
        CASE
            WHEN julianday(stage_phone_screen_date)
               < julianday(application_date)
            THEN 1 ELSE 0
        END
    ) AS negative_application_to_screen,
    SUM(
        CASE
            WHEN julianday(stage_tech_assessment_date)
               < julianday(stage_phone_screen_date)
            THEN 1 ELSE 0
        END
    ) AS negative_screen_to_technical,
    SUM(
        CASE
            WHEN julianday(stage_onsite_date)
               < julianday(stage_tech_assessment_date)
            THEN 1 ELSE 0
        END
    ) AS negative_technical_to_onsite,
    SUM(
        CASE
            WHEN julianday(stage_offer_date)
               < julianday(stage_onsite_date)
            THEN 1 ELSE 0
        END
    ) AS negative_onsite_to_offer
FROM recruiting_funnel;


-- QUERY 7: Compare supplied and date-derived technical-to-onsite time
-- Why: Quantify the discrepancy in the original duration field.
-- Only rows with both dates and a usable supplied value are compared.

SELECT
    COUNT(*) AS records_compared,
    SUM(
        CASE
            WHEN ABS(
                CAST(days_tech_to_onsite AS REAL)
                - (
                    julianday(stage_onsite_date)
                    - julianday(stage_tech_assessment_date)
                )
            ) > 0.01
            THEN 1 ELSE 0
        END
    ) AS mismatched_records,
    ROUND(
        AVG(CAST(days_tech_to_onsite AS REAL)),
        2
    ) AS avg_supplied_duration_days,
    ROUND(
        AVG(
            julianday(stage_onsite_date)
            - julianday(stage_tech_assessment_date)
        ),
        2
    ) AS avg_date_derived_duration_days
FROM recruiting_funnel
WHERE NULLIF(TRIM(stage_tech_assessment_date), '') IS NOT NULL
  AND NULLIF(TRIM(stage_onsite_date), '') IS NOT NULL
  AND NULLIF(TRIM(CAST(days_tech_to_onsite AS TEXT)), '') IS NOT NULL;


-- QUERY 8: Calculate time from offer to start date for hired records
-- Why: Explore the gap between the recorded offer date and
-- the candidate's recorded start date.
-- This is a separate measure from stage waiting time.

SELECT
    COUNT(*) AS hired_records_with_both_dates,
    ROUND(
        AVG(
            julianday(start_date) - julianday(stage_offer_date)
        ),
        2
    ) AS avg_days_offer_to_start
FROM recruiting_funnel
WHERE final_disposition = 'Hired'
  AND NULLIF(TRIM(stage_offer_date), '') IS NOT NULL
  AND NULLIF(TRIM(start_date), '') IS NOT NULL;


-- END OF STAGE DURATION ANALYSIS
