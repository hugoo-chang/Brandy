-- Brandy Database Schema - MySQL Version
-- MySQL 8.0+ relational database for tracking users, events, and form submissions
-- Created: 2025-10-27

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    email VARCHAR(255) UNIQUE,
    full_name VARCHAR(255),
    company_name VARCHAR(255),
    phone VARCHAR(50),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSON DEFAULT ('{}'),
    INDEX idx_users_email (email),
    INDEX idx_users_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- EVENTS TABLE
-- Track all user interactions and system events
-- ============================================================================
CREATE TABLE IF NOT EXISTS events (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36),
    event_type VARCHAR(100) NOT NULL,
    event_name VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    session_id VARCHAR(255),
    referrer TEXT,
    metadata JSON DEFAULT ('{}'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_events_user_id (user_id),
    INDEX idx_events_event_type (event_type),
    INDEX idx_events_created_at (created_at),
    INDEX idx_events_session_id (session_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- FORM SUBMISSIONS TABLE
-- Stores metadata about form submissions
-- ============================================================================
CREATE TABLE IF NOT EXISTS form_submissions (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36),
    event_id CHAR(36),
    form_type VARCHAR(100) DEFAULT 'brief_brandy',
    status VARCHAR(50) DEFAULT 'completed',
    completion_percentage INT DEFAULT 100,
    time_spent_seconds INT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSON DEFAULT ('{}'),
    INDEX idx_form_submissions_user_id (user_id),
    INDEX idx_form_submissions_event_id (event_id),
    INDEX idx_form_submissions_form_type (form_type),
    INDEX idx_form_submissions_submitted_at (submitted_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- FORM ANSWERS TABLE
-- Stores individual field answers in normalized format
-- ============================================================================
CREATE TABLE IF NOT EXISTS form_answers (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    submission_id CHAR(36) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    field_value TEXT,
    field_type VARCHAR(50),
    field_order INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_form_answers_submission_id (submission_id),
    INDEX idx_form_answers_field_name (field_name),
    FOREIGN KEY (submission_id) REFERENCES form_submissions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- GENERATED NAMES TABLE
-- Stores brand names generated for users
-- ============================================================================
CREATE TABLE IF NOT EXISTS generated_names (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36),
    event_id CHAR(36),
    submission_id CHAR(36),
    name VARCHAR(100) NOT NULL,
    style VARCHAR(50),
    min_length INT,
    max_length INT,
    category VARCHAR(100),
    probability FLOAT,
    risk_level VARCHAR(20),
    scores JSON DEFAULT ('{}'),
    top_conflicts JSON DEFAULT ('[]'),
    recommendation TEXT,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_generated_names_user_id (user_id),
    INDEX idx_generated_names_submission_id (submission_id),
    INDEX idx_generated_names_name (name),
    INDEX idx_generated_names_risk_level (risk_level),
    INDEX idx_generated_names_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE SET NULL,
    FOREIGN KEY (submission_id) REFERENCES form_submissions(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TRADEMARK CHECKS TABLE
-- Stores individual trademark check history
-- ============================================================================
CREATE TABLE IF NOT EXISTS trademark_checks (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36),
    event_id CHAR(36),
    name VARCHAR(100) NOT NULL,
    category INT,
    search_type VARCHAR(50),
    probability FLOAT,
    risk_level VARCHAR(20),
    scores JSON DEFAULT ('{}'),
    conflicts_found INT DEFAULT 0,
    conflicts JSON DEFAULT ('[]'),
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_trademark_checks_user_id (user_id),
    INDEX idx_trademark_checks_name (name),
    INDEX idx_trademark_checks_checked_at (checked_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- SIMILARITY CHECKS TABLE
-- Stores name-to-name comparison results
-- ============================================================================
CREATE TABLE IF NOT EXISTS similarity_checks (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36),
    event_id CHAR(36),
    name1 VARCHAR(100) NOT NULL,
    name2 VARCHAR(100) NOT NULL,
    phonetic_score FLOAT,
    spelling_score FLOAT,
    visual_score FLOAT,
    overall_score FLOAT,
    is_conflict BOOLEAN,
    algorithm_details JSON DEFAULT ('{}'),
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_similarity_checks_user_id (user_id),
    INDEX idx_similarity_checks_name1 (name1),
    INDEX idx_similarity_checks_checked_at (checked_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- CACHED SEARCHES TABLE
-- Replaces file-based pickle cache with database cache
-- ============================================================================
CREATE TABLE IF NOT EXISTS cached_searches (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    query VARCHAR(100) NOT NULL,
    search_type VARCHAR(50) NOT NULL,
    category INT,
    results JSON NOT NULL,
    hit_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    last_accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_cached_searches_unique (query, search_type, category),
    INDEX idx_cached_searches_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
    JSON_OBJECTAGG(
        fa.field_name,
        JSON_OBJECT(
            'value', fa.field_value,
            'type', fa.field_type
        )
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
    COUNT(DISTINCT user_id) AS unique_users,
    MIN(created_at) AS first_generated,
    MAX(created_at) AS last_generated
FROM generated_names
GROUP BY name
ORDER BY generation_count DESC;

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- Procedure to clean expired cache entries
DELIMITER //
CREATE PROCEDURE clean_expired_cache()
BEGIN
    DELETE FROM cached_searches WHERE expires_at < NOW();
    SELECT ROW_COUNT() AS deleted_count;
END //
DELIMITER ;

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Insert a sample user
INSERT INTO users (id, email, full_name, company_name, country)
VALUES (UUID(), 'test@example.com', 'Test User', 'Test Company', 'Peru');

-- Insert a sample event
INSERT INTO events (id, event_type, event_name, ip_address, metadata)
VALUES (UUID(), 'form_submission', 'Brief Brandy Form Submitted', '127.0.0.1', '{"source": "landing_page"}');

-- ============================================================================
-- COMMENTS (MySQL doesn't support COMMENT ON, but we can add column comments)
-- ============================================================================

-- To add table comments:
-- ALTER TABLE users COMMENT 'Stores user account information';
-- ALTER TABLE events COMMENT 'Tracks all user interactions and system events';
-- etc.
