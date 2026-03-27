-- Full-text search index on document OCR content
CREATE INDEX idx_documents_ocr_fulltext ON documents USING gin(to_tsvector('english', COALESCE(ocr_text, '')));
