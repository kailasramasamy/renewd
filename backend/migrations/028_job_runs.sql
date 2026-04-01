CREATE TABLE job_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_name VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'running',
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  duration_ms INT,
  processed INT DEFAULT 0,
  failed INT DEFAULT 0,
  error TEXT,
  metadata JSONB
);

CREATE INDEX idx_job_runs_name ON job_runs(job_name, started_at DESC);
CREATE INDEX idx_job_runs_started ON job_runs(started_at DESC);
