-- 1. Overall KPI
SELECT
    COUNT(*) AS total_incidents,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE made_sla = TRUE) / COUNT(*),
        2
    ) AS sla_met_pct,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY resolution_hours)::numeric,
        2
    ) AS median_resolution_hours,
    ROUND(AVG(reopen_count), 2) AS avg_reopen_count,
    ROUND(AVG(reassignment_count), 2) AS avg_reassignment_count
FROM analytics.fact_incidents;


-- 2. SLA Performance by Priority
SELECT
    priority,
    COUNT(*) AS total_incidents,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE made_sla = TRUE) / COUNT(*),
        2
    ) AS sla_met_pct,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM analytics.fact_incidents
WHERE priority IS NOT NULL
GROUP BY priority, priority_level
ORDER BY priority_level;


-- 3. Incidents by Category
SELECT
    category,
    COUNT(*) AS total_incidents,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM analytics.fact_incidents
WHERE category IS NOT NULL
GROUP BY category
ORDER BY total_incidents DESC;


-- 4. Reopened Incidents
SELECT
    COUNT(*) FILTER (
        WHERE reopen_count > 0
    ) AS reopened_incidents,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE reopen_count > 0) / COUNT(*),
        2
    ) AS reopened_pct,
    MAX(reopen_count) AS max_reopens
FROM analytics.fact_incidents;


-- 5. Reassignment Complexity
SELECT
    reassignment_count,
    COUNT(*) AS incident_count,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours
FROM analytics.fact_incidents
GROUP BY reassignment_count
ORDER BY reassignment_count;