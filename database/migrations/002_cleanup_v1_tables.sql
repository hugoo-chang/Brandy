-- Migration: Cleanup V1 Tables
-- PostgreSQL Version
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

BEGIN;

-- ============================================================================
-- STEP 1: Check if tables exist and have data
-- ============================================================================

DO $$
DECLARE
    users_count INTEGER;
    events_count INTEGER;
    form_submissions_count INTEGER;
    form_answers_count INTEGER;
BEGIN
    -- Check users table
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') THEN
        SELECT COUNT(*) INTO users_count FROM users;
        RAISE NOTICE 'users table exists with % rows', users_count;
    ELSE
        RAISE NOTICE 'users table does not exist (already removed)';
    END IF;

    -- Check events table
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'events') THEN
        SELECT COUNT(*) INTO events_count FROM events;
        RAISE NOTICE 'events table exists with % rows', events_count;
    ELSE
        RAISE NOTICE 'events table does not exist (already removed)';
    END IF;

    -- Check form_submissions table
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'form_submissions') THEN
        SELECT COUNT(*) INTO form_submissions_count FROM form_submissions;
        RAISE NOTICE 'form_submissions table exists with % rows', form_submissions_count;
    ELSE
        RAISE NOTICE 'form_submissions table does not exist (already removed)';
    END IF;

    -- Check form_answers table
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'form_answers') THEN
        SELECT COUNT(*) INTO form_answers_count FROM form_answers;
        RAISE NOTICE 'form_answers table exists with % rows', form_answers_count;
    ELSE
        RAISE NOTICE 'form_answers table does not exist (already removed)';
    END IF;
END $$;

-- ============================================================================
-- STEP 2: Drop old V1 tables
-- ============================================================================

RAISE NOTICE 'Dropping redundant V1 tables...';

-- Drop in correct order (respecting foreign keys)
DROP TABLE IF EXISTS form_answers CASCADE;
DROP TABLE IF EXISTS form_submissions CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS users CASCADE;

RAISE NOTICE 'V1 tables dropped successfully.';

-- ============================================================================
-- STEP 3: Drop old views that reference dropped tables
-- ============================================================================

-- These views may exist from V1 schema
DROP VIEW IF EXISTS v_form_submissions_complete CASCADE;
DROP VIEW IF EXISTS v_user_activity_summary CASCADE;
DROP VIEW IF EXISTS v_popular_names CASCADE;

RAISE NOTICE 'Old V1 views dropped.';

-- ============================================================================
-- STEP 4: Verify remaining tables
-- ============================================================================

DO $$
DECLARE
    table_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================';
    RAISE NOTICE 'Remaining tables in database:';
    RAISE NOTICE '====================================';

    FOR table_record IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        RAISE NOTICE '  ✓ %', table_record.table_name;
    END LOOP;

    RAISE NOTICE '====================================';
END $$;

-- ============================================================================
-- Commit transaction
-- ============================================================================

COMMIT;

-- ============================================================================
-- Post-cleanup verification
-- ============================================================================

-- Uncomment to verify tables were dropped:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name;

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
