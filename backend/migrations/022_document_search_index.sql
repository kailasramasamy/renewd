-- Full-text search index for document OCR text
CREATE INDEX IF NOT EXISTS idx_documents_ocr_tsvector
  ON documents USING GIN(to_tsvector('english', COALESCE(ocr_text, '')));
