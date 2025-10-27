-- Brandy Database Schema
-- PostgreSQL relational database for tracking users, events, and form submissions
-- Created: 2025-10-27

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE,
    full_name VARCHAR(255),
    company_name VARCHAR(255),
    phone VARCHAR(50),
    country VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ============================================================================
-- EVENTS TABLE
-- Track all user interactions and system events
-- ============================================================================
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_type VARCHAR(100) NOT NULL, -- 'form_submission', 'name_generation', 'trademark_check', 'login', etc.
    event_name VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(255),
    referrer TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_events_user_id ON events(user_id);
CREATE INDEX idx_events_event_type ON events(event_type);
CREATE INDEX idx_events_created_at ON events(created_at);
CREATE INDEX idx_events_session_id ON events(session_id);

-- ============================================================================
-- FORM SUBMISSIONS TABLE
-- Stores metadata about form submissions
-- ============================================================================
CREATE TABLE form_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    form_type VARCHAR(100) DEFAULT 'brief_brandy', -- Type of form submitted
    status VARCHAR(50) DEFAULT 'completed', -- 'completed', 'partial', 'abandoned'
    completion_percentage INTEGER DEFAULT 100,
    time_spent_seconds INTEGER,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_form_submissions_user_id ON form_submissions(user_id);
CREATE INDEX idx_form_submissions_event_id ON form_submissions(event_id);
CREATE INDEX idx_form_submissions_form_type ON form_submissions(form_type);
CREATE INDEX idx_form_submissions_submitted_at ON form_submissions(submitted_at);

-- ============================================================================
-- FORM ANSWERS TABLE
-- Stores individual field answers in normalized format
-- ============================================================================
CREATE TABLE form_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    submission_id UUID REFERENCES form_submissions(id) ON DELETE CASCADE,
    field_name VARCHAR(100) NOT NULL,
    field_value TEXT,
    field_type VARCHAR(50), -- 'text', 'textarea', 'checkbox', 'url', etc.
    field_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_form_answers_submission_id ON form_answers(submission_id);
CREATE INDEX idx_form_answers_field_name ON form_answers(field_name);

-- ============================================================================
-- GENERATED NAMES TABLE
-- Stores brand names generated for users
-- ============================================================================
CREATE TABLE generated_names (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    submission_id UUID REFERENCES form_submissions(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    style VARCHAR(50), -- 'evocative', 'syllabic', 'modern', 'hybrid'
    min_length INTEGER,
    max_length INTEGER,
    category VARCHAR(100),
    probability FLOAT,
    risk_level VARCHAR(20), -- 'LOW', 'MEDIUM', 'HIGH', 'VERY HIGH'
    scores JSONB DEFAULT '{}'::jsonb, -- Store similarity scores
    top_conflicts JSONB DEFAULT '[]'::jsonb, -- Store conflicting trademarks
    recommendation TEXT,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_generated_names_user_id ON generated_names(user_id);
CREATE INDEX idx_generated_names_submission_id ON generated_names(submission_id);
CREATE INDEX idx_generated_names_name ON generated_names(name);
CREATE INDEX idx_generated_names_risk_level ON generated_names(risk_level);
CREATE INDEX idx_generated_names_created_at ON generated_names(created_at);

-- ============================================================================
-- TRADEMARK CHECKS TABLE
-- Stores individual trademark check history
-- ============================================================================
CREATE TABLE trademark_checks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    category INTEGER, -- NICE classification 1-45
    search_type VARCHAR(50), -- 'phonetic', 'exact', 'partial'
    probability FLOAT,
    risk_level VARCHAR(20),
    scores JSONB DEFAULT '{}'::jsonb,
    conflicts_found INTEGER DEFAULT 0,
    conflicts JSONB DEFAULT '[]'::jsonb,
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_trademark_checks_user_id ON trademark_checks(user_id);
CREATE INDEX idx_trademark_checks_name ON trademark_checks(name);
CREATE INDEX idx_trademark_checks_checked_at ON trademark_checks(checked_at);

-- ============================================================================
-- SIMILARITY CHECKS TABLE
-- Stores name-to-name comparison results
-- ============================================================================
CREATE TABLE similarity_checks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    name1 VARCHAR(100) NOT NULL,
    name2 VARCHAR(100) NOT NULL,
    phonetic_score FLOAT,
    spelling_score FLOAT,
    visual_score FLOAT,
    overall_score FLOAT,
    is_conflict BOOLEAN,
    algorithm_details JSONB DEFAULT '{}'::jsonb,
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_similarity_checks_user_id ON similarity_checks(user_id);
CREATE INDEX idx_similarity_checks_name1 ON similarity_checks(name1);
CREATE INDEX idx_similarity_checks_checked_at ON similarity_checks(checked_at);

-- ============================================================================
-- CACHED SEARCHES TABLE
-- Replaces file-based pickle cache with database cache
-- ============================================================================
CREATE TABLE cached_searches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    query VARCHAR(100) NOT NULL,
    search_type VARCHAR(50) NOT NULL,
    category INTEGER,
    results JSONB NOT NULL,
    hit_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_cached_searches_unique ON cached_searches(query, search_type, category);
CREATE INDEX idx_cached_searches_expires_at ON cached_searches(expires_at);

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at on users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to clean expired cache entries
CREATE OR REPLACE FUNCTION clean_expired_cache()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM cached_searches WHERE expires_at < CURRENT_TIMESTAMP;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- View for complete form submissions with answers
CREATE OR REPLACE VIEW v_form_submissions_complete AS
SELECT
    fs.id AS submission_id,
    fs.user_id,
    u.email,
    u.full_name,
    u.company_name,
    fs.form_type,
    fs.status,
    fs.completion_percentage,
    fs.time_spent_seconds,
    fs.submitted_at,
    json_object_agg(
        fa.field_name,
        json_build_object(
            'value', fa.field_value,
            'type', fa.field_type
        ) ORDER BY fa.field_order
    ) AS answers,
    fs.metadata
FROM form_submissions fs
LEFT JOIN users u ON fs.user_id = u.id
LEFT JOIN form_answers fa ON fs.id = fa.submission_id
GROUP BY fs.id, u.email, u.full_name, u.company_name;

-- View for user activity summary
CREATE OR REPLACE VIEW v_user_activity_summary AS
SELECT
    u.id AS user_id,
    u.email,
    u.full_name,
    u.created_at AS user_since,
    COUNT(DISTINCT fs.id) AS total_form_submissions,
    COUNT(DISTINCT gn.id) AS total_names_generated,
    COUNT(DISTINCT tc.id) AS total_trademark_checks,
    COUNT(DISTINCT sc.id) AS total_similarity_checks,
    MAX(e.created_at) AS last_activity,
    COUNT(DISTINCT e.id) AS total_events
FROM users u
LEFT JOIN form_submissions fs ON u.id = fs.user_id
LEFT JOIN generated_names gn ON u.id = gn.user_id
LEFT JOIN trademark_checks tc ON u.id = tc.user_id
LEFT JOIN similarity_checks sc ON u.id = sc.user_id
LEFT JOIN events e ON u.id = e.user_id
GROUP BY u.id;

-- View for popular generated names
CREATE OR REPLACE VIEW v_popular_names AS
SELECT
    name,
    COUNT(*) AS generation_count,
    AVG(probability) AS avg_probability,
    MODE() WITHIN GROUP (ORDER BY risk_level) AS common_risk_level,
    COUNT(DISTINCT user_id) AS unique_users,
    MIN(created_at) AS first_generated,
    MAX(created_at) AS last_generated
FROM generated_names
GROUP BY name
ORDER BY generation_count DESC;

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Insert a sample user
INSERT INTO users (email, full_name, company_name, country)
VALUES ('test@example.com', 'Test User', 'Test Company', 'Peru');

-- Insert a sample event
INSERT INTO events (event_type, event_name, ip_address, metadata)
VALUES ('form_submission', 'Brief Brandy Form Submitted', '127.0.0.1', '{"source": "landing_page"}'::jsonb);

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE users IS 'Stores user account information';
COMMENT ON TABLE events IS 'Tracks all user interactions and system events';
COMMENT ON TABLE form_submissions IS 'Stores metadata about form submissions';
COMMENT ON TABLE form_answers IS 'Stores individual field answers in normalized format';
COMMENT ON TABLE generated_names IS 'Stores brand names generated for users';
COMMENT ON TABLE trademark_checks IS 'Stores individual trademark check history';
COMMENT ON TABLE similarity_checks IS 'Stores name-to-name comparison results';
COMMENT ON TABLE cached_searches IS 'Database-based cache for INDECOPI searches';

-- ============================================================================
-- GRANTS (Adjust based on your user/role setup)
-- ============================================================================

-- Example: GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO brandy_app;
-- Example: GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO brandy_app;
