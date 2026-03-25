CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid VARCHAR(128) UNIQUE NOT NULL,
  email VARCHAR(255),
  phone VARCHAR(20),
  name VARCHAR(255),
  avatar_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  premium_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE renewals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL,
  provider VARCHAR(255),
  amount DECIMAL(12,2),
  renewal_date DATE NOT NULL,
  frequency VARCHAR(20) NOT NULL,
  frequency_days INT,
  auto_renew BOOLEAN DEFAULT FALSE,
  notes TEXT,
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  renewal_id UUID REFERENCES renewals(id),
  file_url TEXT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_size INT,
  file_hash VARCHAR(64),
  mime_type VARCHAR(100),
  doc_type VARCHAR(50),
  ocr_text TEXT,
  is_current BOOLEAN DEFAULT TRUE,
  issue_date DATE,
  expiry_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  renewal_id UUID NOT NULL REFERENCES renewals(id),
  amount DECIMAL(12,2) NOT NULL,
  paid_date DATE NOT NULL,
  method VARCHAR(30),
  reference_number VARCHAR(100),
  receipt_document_id UUID REFERENCES documents(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  renewal_id UUID NOT NULL REFERENCES renewals(id),
  days_before INT NOT NULL,
  is_sent BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_renewals_user_id ON renewals(user_id);
CREATE INDEX idx_renewals_renewal_date ON renewals(renewal_date);
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_documents_renewal_id ON documents(renewal_id);
CREATE INDEX idx_payments_renewal_id ON payments(renewal_id);
CREATE INDEX idx_reminders_renewal_id ON reminders(renewal_id);
