CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS staging.incident_events (
  event_id BIGSERIAL PRIMARY KEY,

  number VARCHAR(30) NOT NULL,
  incident_state VARCHAR(50),

  active BOOLEAN,
  reassignment_count INTEGER,
  reopen_count INTEGER,
  sys_mod_count INTEGER,
  made_sla BOOLEAN,

  caller_id VARCHAR(100),
  opened_by VARCHAR(100),
  opened_at TIMESTAMP,

  sys_created_by VARCHAR(100),
  sys_created_at TIMESTAMP,
  sys_updated_by VARCHAR(100),
  sys_updated_at TIMESTAMP NOT NULL,

  contact_type VARCHAR(50),
  location VARCHAR(100),
  category VARCHAR(100),
  subcategory VARCHAR(100),
  u_symptom VARCHAR(100),
  cmdb_ci VARCHAR(100),

  impact VARCHAR(50),
  urgency VARCHAR(50),
  priority VARCHAR(50),

  assignment_group VARCHAR(100),
  assigned_to VARCHAR(100),

  knowledge BOOLEAN,
  u_priority_confirmation BOOLEAN,

  notify VARCHAR(50),
  problem_id VARCHAR(100),
  rfc VARCHAR(100),
  vendor VARCHAR(100),
  caused_by VARCHAR(100),


  closed_code VARCHAR(100),
  resolved_by VARCHAR(100),
  resolved_at TIMESTAMP,
  closed_at TIMESTAMP,

  impact_level SMALLINT,
  urgency_level SMALLINT,
  priority_level SMALLINT,

  UNIQUE (number, sys_updated_at, sys_mod_count)
);