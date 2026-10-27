
-- =========================================================
-- PROJECT: The Hidden Cost of a Slow Hiring Process
-- FILE: hiring_outcomes.sql
-- PURPOSE: Analyze recruiting outcomes and stage distribution
-- =========================================================


-- QUERY 1: Count each final disposition
-- Why: Understand the number of records marked Rejected,
-- Hired, Withdrew, and Offer Declined.

SELECT
    final_disposition,
    COUNT(*) AS record_count
FROM recruiting_funnel
GROUP BY final_disposition
ORDER BY record_count DESC;


-- QUERY 2: Calculate each disposition's share of all records
-- Why: Put each outcome in context of the full dataset.
-- These percentages are shares of all records, not stage
-- conversion rates.

SELECT
    final_disposition,
    COUNT(*) AS record_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM recruiting_funnel),
        2
    ) AS percentage_of_all_records
FROM recruiting_funnel
GROUP BY final_disposition
ORDER BY record_count DESC;


-- QUERY 3: Count records by furthest hiring stage reached
-- Why: Identify where records are concentrated in the funnel.

SELECT
    stage_reached,
    COUNT(*) AS record_count
FROM recruiting_funnel
GROUP BY stage_reached
ORDER BY record_count DESC;


-- QUERY 4: Calculate the share of all records at each furthest stage
-- Why: Show the distribution of records across stages.
-- Important: This is NOT stage-to-stage conversion.

SELECT
    stage_reached,
    COUNT(*) AS record_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM recruiting_funnel),
        2
    ) AS percentage_of_all_records
FROM recruiting_funnel
GROUP BY stage_reached
ORDER BY record_count DESC;


-- QUERY 5: Compare furthest stage with final disposition
-- Why: See which outcomes are associated with each recorded stage.
-- This helps check how the two fields relate to one another.

SELECT
    stage_reached,
    final_disposition,
    COUNT(*) AS record_count
FROM recruiting_funnel
GROUP BY
    stage_reached,
    final_disposition
ORDER BY
    stage_reached,
    record_count DESC;


-- QUERY 6: Calculate the overall recorded hire share
-- Why: Measure the percentage of all records whose final
-- disposition is Hired.

SELECT
    COUNT(*) AS total_records,
    SUM(
        CASE
            WHEN final_disposition = 'Hired' THEN 1
            ELSE 0
        END
    ) AS hired_records,
    ROUND(
        SUM(
            CASE
                WHEN final_disposition = 'Hired' THEN 1.0
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS hire_share_percentage
FROM recruiting_funnel;


-- QUERY 7: Analyze recorded withdrawal outcomes
-- Why: Understand how many records ended with a withdrawal
-- and how those records are distributed across stages.

SELECT
    stage_reached,
    COUNT(*) AS withdrawn_records
FROM recruiting_funnel
WHERE final_disposition = 'Withdrew'
GROUP BY stage_reached
ORDER BY withdrawn_records DESC;


-- QUERY 8: Analyze offer declines
-- Why: Identify how many records are marked Offer Declined.
-- Do not call this an offer rejection rate: a proper offer
-- acceptance metric needs a validated offer-level denominator.

SELECT
    COUNT(*) AS offer_declined_records,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM recruiting_funnel),
        2
    ) AS percentage_of_all_records
FROM recruiting_funnel
WHERE final_disposition = 'Offer Declined';


-- QUERY 9: Review rejection reasons
-- Why: Find the most frequently recorded reasons for rejection.
-- Blank or NULL values are kept visible rather than silently
-- removed from the analysis.

SELECT
    COALESCE(
        NULLIF(TRIM(rejection_reason), ''),
        'Missing / Not recorded'
    ) AS rejection_reason_category,
    COUNT(*) AS record_count
FROM recruiting_funnel
WHERE final_disposition = 'Rejected'
GROUP BY rejection_reason_category
ORDER BY record_count DESC;


-- QUERY 10: Compare outcomes by business unit
-- Why: Check whether hiring outcomes differ across business units.
-- These are descriptive comparisons, not proof of performance
-- or hiring quality.

SELECT
    business_unit,
    COUNT(*) AS total_records,
    SUM(
        CASE
            WHEN final_disposition = 'Hired' THEN 1
            ELSE 0
        END
    ) AS hired_records,
    ROUND(
        SUM(
            CASE
                WHEN final_disposition = 'Hired' THEN 1.0
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS hire_share_percentage
FROM recruiting_funnel
GROUP BY business_unit
ORDER BY hire_share_percentage DESC;


-- END OF HIRING OUTCOMES ANALYSIS
