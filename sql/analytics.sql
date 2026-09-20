DROP TABLE IF EXISTS analytics.fact_incidents;

CREATE TABLE analytics.fact_incidents AS

WITH ranked_events AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY number
            ORDER BY
                sys_updated_at DESC,
                sys_mod_count DESC,
                event_id DESC
        ) AS rn
    FROM staging.incident_events
),

incident_metrics AS (
    SELECT
        number,

        MIN(opened_at) AS opened_at,
        MAX(resolved_at) AS resolved_at,
        MAX(closed_at) AS closed_at,

        COUNT(*) AS event_count,
        MAX(reassignment_count) AS reassignment_count,
        MAX(reopen_count) AS reopen_count,
        COUNT(DISTINCT assignment_group) AS assignment_group_count

    FROM staging.incident_events
    GROUP BY number
)

SELECT
    r.number AS incident_number,

    m.opened_at,
    m.resolved_at,
    m.closed_at,

    r.incident_state AS final_state,
    r.active AS final_active,
    r.made_sla,

    r.contact_type,
    r.location,
    r.category,
    r.subcategory,

    r.impact,
    r.urgency,
    r.priority,

    r.impact_level,
    r.urgency_level,
    r.priority_level,

    r.assignment_group AS final_assignment_group,
    r.assigned_to AS final_assigned_to,

    r.closed_code,
    r.resolved_by,

    m.event_count,
    m.reassignment_count,
    m.reopen_count,
    m.assignment_group_count,

    EXTRACT(
        EPOCH FROM (m.resolved_at - m.opened_at)
    ) / 3600.0 AS resolution_hours,

    EXTRACT(
        EPOCH FROM (m.closed_at - m.opened_at)
    ) / 3600.0 AS closure_hours

FROM ranked_events r
JOIN incident_metrics m
    ON r.number = m.number

WHERE r.rn = 1;


ALTER TABLE analytics.fact_incidents
ADD PRIMARY KEY (incident_number);


CREATE INDEX idx_fact_incidents_priority
ON analytics.fact_incidents(priority_level);

CREATE INDEX idx_fact_incidents_sla
ON analytics.fact_incidents(made_sla);

CREATE INDEX idx_fact_incidents_category
ON analytics.fact_incidents(category);

CREATE INDEX idx_fact_incidents_opened_at
ON analytics.fact_incidents(opened_at);