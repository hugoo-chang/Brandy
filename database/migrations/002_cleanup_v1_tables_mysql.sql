-- Migration: Cleanup V1 Tables
-- MySQL Version
-- Drops redundant V1 tables that are replaced by V2 tables
-- Date: 2025-10-30
--
-- This migration removes:
-- - users (replaced by client_characterization)
-- - events (too generic for MVP)
-- - form_submissions (replaced by briefs)
-- - form_answers (replaced by briefs)
--
-- KEEPS useful tables:
-- - generated_names (used by naming engine)
-- - trademark_checks (used for INDECOPI validation)
-- - similarity_checks (used for name analysis)
-- - cached_searches (performance optimization)

START TRANSACTION;

-- ============================================================================
-- STEP 1: Check if tables exist and have data
-- ============================================================================

-- Check and show row counts for tables that will be dropped
SELECT 'Checking existing tables...' AS status;

SELECT
    'users' AS table_name,
    COUNT(*) AS row_count
FROM users
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE()
    AND table_name = 'users'
)
UNION ALL
SELECT
    'events' AS table_name,
    COUNT(*) AS row_count
FROM events
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE()
    AND table_name = 'events'
)
UNION ALL
SELECT
    'form_submissions' AS table_name,
    COUNT(*) AS row_count
FROM form_submissions
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE()
    AND table_name = 'form_submissions'
)
UNION ALL
SELECT
    'form_answers' AS table_name,
    COUNT(*) AS row_count
FROM form_answers
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE()
    AND table_name = 'form_answers'
);

-- ============================================================================
-- STEP 2: Drop old V1 tables
-- ============================================================================

SELECT 'Dropping redundant V1 tables...' AS status;

-- Drop in correct order (respecting foreign keys)
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS form_answers;
DROP TABLE IF EXISTS form_submissions;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'V1 tables dropped successfully.' AS status;

-- ============================================================================
-- STEP 3: Drop old views that reference dropped tables
-- ============================================================================

-- These views may exist from V1 schema
DROP VIEW IF EXISTS v_form_submissions_complete;
DROP VIEW IF EXISTS v_user_activity_summary;
DROP VIEW IF EXISTS v_popular_names;

SELECT 'Old V1 views dropped.' AS status;

-- ============================================================================
-- STEP 4: Verify remaining tables
-- ============================================================================

SELECT 'Remaining tables in database:' AS status;

SELECT
    table_name,
    table_rows AS estimated_rows,
    ROUND(data_length / 1024 / 1024, 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ============================================================================
-- Commit transaction
-- ============================================================================

COMMIT;

-- ============================================================================
-- Post-cleanup verification
-- ============================================================================

-- Show all remaining tables
-- SHOW TABLES;

-- Expected remaining tables:
-- - briefs
-- - cached_searches (kept - useful)
-- - client_characterization
-- - generated_names (kept - useful)
-- - naming_projects
-- - payments
-- - project_notes
-- - project_proposals
-- - similarity_checks (kept - useful)
-- - trademark_checks (kept - useful)
