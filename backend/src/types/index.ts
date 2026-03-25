export interface User {
  id: string;
  firebase_uid: string;
  email: string | null;
  phone: string | null;
  name: string | null;
  avatar_url: string | null;
  is_premium: boolean;
  premium_expires_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface Renewal {
  id: string;
  user_id: string;
  name: string;
  category: string;
  provider: string | null;
  amount: number | null;
  renewal_date: Date;
  frequency: "daily" | "weekly" | "monthly" | "yearly" | "custom";
  frequency_days: number | null;
  auto_renew: boolean;
  notes: string | null;
  status: "active" | "expired" | "cancelled";
  created_at: Date;
  updated_at: Date;
}

export interface Document {
  id: string;
  user_id: string;
  renewal_id: string | null;
  file_url: string;
  file_name: string;
  file_size: number | null;
  file_hash: string | null;
  mime_type: string | null;
  doc_type: string | null;
  ocr_text: string | null;
  is_current: boolean;
  issue_date: Date | null;
  expiry_date: Date | null;
  created_at: Date;
}

export interface Payment {
  id: string;
  user_id: string;
  renewal_id: string;
  amount: number;
  paid_date: Date;
  method: string | null;
  reference_number: string | null;
  receipt_document_id: string | null;
  created_at: Date;
}

export interface Reminder {
  id: string;
  renewal_id: string;
  days_before: number;
  is_sent: boolean;
  sent_at: Date | null;
  created_at: Date;
}
