CREATE TABLE tester_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  app_name VARCHAR(100) NOT NULL DEFAULT 'Renewd',
  description TEXT,
  reward TEXT NOT NULL DEFAULT '₹100 Amazon Gift Card',
  platforms TEXT[] NOT NULL DEFAULT '{android}',
  tester_cap INT NOT NULL DEFAULT 20,
  status VARCHAR(20) NOT NULL DEFAULT 'open',
  test_duration_days INT NOT NULL DEFAULT 7,
  android_test_link TEXT,
  ios_test_link TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE testers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID NOT NULL REFERENCES tester_programs(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL,
  email VARCHAR(320) NOT NULL,
  platform VARCHAR(20) NOT NULL,
  device_info VARCHAR(200),
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(program_id, email)
);

CREATE TABLE tester_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tester_id UUID NOT NULL REFERENCES testers(id) ON DELETE CASCADE,
  program_id UUID NOT NULL REFERENCES tester_programs(id) ON DELETE CASCADE,
  category VARCHAR(30) NOT NULL DEFAULT 'general',
  title VARCHAR(300) NOT NULL,
  description TEXT NOT NULL,
  screenshot_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_testers_program ON testers(program_id);
CREATE INDEX idx_tester_feedback_program ON tester_feedback(program_id);
CREATE INDEX idx_tester_feedback_tester ON tester_feedback(tester_id);
