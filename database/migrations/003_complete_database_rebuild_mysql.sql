-- Migration: Complete Database Rebuild
-- MySQL Version
-- DROPS ALL existing tables and replaces with simplified 3-table structure
-- Date: 2025-11-03
--
-- WARNING: This migration will DELETE ALL existing data!
-- Make sure to backup your data before running this migration.
--
-- NEW STRUCTURE:
-- 1. client_info - Client characterization (Step 1)
-- 2. brief_responses - Brand brief (Step 2)
-- 3. payment_info - Payment and confirmation (Step 3-4)

START TRANSACTION;

-- ============================================================================
-- STEP 1: Drop ALL existing tables and views
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- Drop views
DROP VIEW IF EXISTS v_complete_client_data;
DROP VIEW IF EXISTS v_payments_summary;
DROP VIEW IF EXISTS v_recent_registrations;
DROP VIEW IF EXISTS v_projects_complete;
DROP VIEW IF EXISTS v_projects_active;
DROP VIEW IF EXISTS v_payment_summary;
DROP VIEW IF EXISTS v_acquisition_funnel;
DROP VIEW IF EXISTS v_form_submissions_complete;
DROP VIEW IF EXISTS v_user_activity_summary;
DROP VIEW IF EXISTS v_popular_names;

SELECT 'Dropped all views' AS status;

-- Drop all tables
DROP TABLE IF EXISTS project_notes;
DROP TABLE IF EXISTS project_proposals;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS briefs;
DROP TABLE IF EXISTS naming_projects;
DROP TABLE IF EXISTS client_characterization;
DROP TABLE IF EXISTS form_answers;
DROP TABLE IF EXISTS form_submissions;
DROP TABLE IF EXISTS similarity_checks;
DROP TABLE IF EXISTS trademark_checks;
DROP TABLE IF EXISTS generated_names;
DROP TABLE IF EXISTS cached_searches;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS users;

SELECT 'Dropped all old tables' AS status;

-- Drop old procedures
DROP PROCEDURE IF EXISTS generate_project_code;
DROP PROCEDURE IF EXISTS generate_case_number;
DROP PROCEDURE IF EXISTS clean_expired_cache;

SELECT 'Dropped old procedures' AS status;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- STEP 2: Create new simplified schema
-- ============================================================================

-- TABLE 1: CLIENT_INFO
CREATE TABLE client_info (
    id_number VARCHAR(11) PRIMARY KEY,
    user_id CHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),
    razon_social VARCHAR(255) NOT NULL,
    tipo_persona ENUM('natural', 'juridica') NOT NULL,
    representante_legal VARCHAR(255),
    email VARCHAR(255) NOT NULL,
    telefono VARCHAR(9) NOT NULL,
    nacionalidad VARCHAR(100) DEFAULT 'Peruana',
    direccion TEXT NOT NULL,
    distrito VARCHAR(100) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    rubro VARCHAR(255) NOT NULL,
    lugar_operacion TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_client_email (email),
    INDEX idx_client_user_id (user_id),
    INDEX idx_client_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'Created client_info table' AS status;

-- TABLE 2: BRIEF_RESPONSES
CREATE TABLE brief_responses (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    id_number VARCHAR(11) NOT NULL,
    tiene_nombre BOOLEAN NOT NULL,
    nombre_actual VARCHAR(255),
    producto_servicio TEXT NOT NULL,
    publico_objetivo TEXT NOT NULL,
    valores TEXT NOT NULL,
    palabra_1 VARCHAR(100) NOT NULL,
    palabra_2 VARCHAR(100) NOT NULL,
    palabra_3 VARCHAR(100) NOT NULL,
    idea_nombre VARCHAR(255),
    tiene_logo BOOLEAN NOT NULL,
    donde_vende TEXT NOT NULL,
    idioma_preferencia ENUM('espanol', 'ingles', 'neutro', 'indiferente') NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_brief_user_id (user_id),
    INDEX idx_brief_id_number (id_number),
    INDEX idx_brief_submitted_at (submitted_at),
    FOREIGN KEY (user_id) REFERENCES client_info(user_id) ON DELETE CASCADE,
    FOREIGN KEY (id_number) REFERENCES client_info(id_number) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'Created brief_responses table' AS status;

-- TABLE 3: PAYMENT_INFO
CREATE TABLE payment_info (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id CHAR(36) NOT NULL,
    id_number VARCHAR(11) NOT NULL,
    case_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL DEFAULT 950.00,
    currency VARCHAR(3) DEFAULT 'PEN',
    payment_method VARCHAR(50),
    payment_successful BOOLEAN DEFAULT FALSE,
    payment_date TIMESTAMP NULL,
    payment_reference VARCHAR(255),
    contact_email VARCHAR(255) DEFAULT 'contacto@brandia.pe',
    contact_phone VARCHAR(20) DEFAULT '+51 999 888 777',
    contact_whatsapp VARCHAR(20) DEFAULT '+51 999 888 777',
    terms_accepted BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_payment_user_id (user_id),
    INDEX idx_payment_id_number (id_number),
    INDEX idx_payment_case_number (case_number),
    INDEX idx_payment_successful (payment_successful),
    INDEX idx_payment_created_at (created_at),
    FOREIGN KEY (user_id) REFERENCES client_info(user_id) ON DELETE CASCADE,
    FOREIGN KEY (id_number) REFERENCES client_info(id_number) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'Created payment_info table' AS status;

-- ============================================================================
-- STEP 3: Create stored procedures and triggers
-- ============================================================================

-- Procedure to generate case number
DELIMITER //
CREATE PROCEDURE generate_case_number(OUT new_case VARCHAR(50))
BEGIN
    DECLARE next_number INT;

    SELECT COUNT(*) + 1 INTO next_number
    FROM payment_info
    WHERE DATE(created_at) = CURDATE();

    SET new_case = CONCAT('BRA-', DATE_FORMAT(CURDATE(), '%Y%m%d'), '-', LPAD(next_number, 3, '0'));
END //
DELIMITER ;

-- Trigger to auto-generate case number
DELIMITER //
CREATE TRIGGER auto_generate_case_number
BEFORE INSERT ON payment_info
FOR EACH ROW
BEGIN
    IF NEW.case_number IS NULL OR NEW.case_number = '' THEN
        CALL generate_case_number(NEW.case_number);
    END IF;
END //
DELIMITER ;

SELECT 'Created all triggers and procedures' AS status;

-- ============================================================================
-- STEP 4: Create views
-- ============================================================================

CREATE OR REPLACE VIEW v_complete_client_data AS
SELECT
    c.id_number,
    c.user_id,
    c.razon_social,
    c.tipo_persona,
    c.email,
    c.telefono,
    c.rubro,
    c.lugar_operacion,
    b.tiene_nombre,
    b.nombre_actual,
    b.producto_servicio,
    b.publico_objetivo,
    b.valores,
    b.palabra_1,
    b.palabra_2,
    b.palabra_3,
    b.idioma_preferencia,
    p.case_number,
    p.amount,
    p.payment_successful,
    p.payment_date,
    p.payment_method,
    c.created_at AS client_registered_at,
    b.submitted_at AS brief_submitted_at,
    p.created_at AS payment_created_at
FROM client_info c
LEFT JOIN brief_responses b ON c.user_id = b.user_id
LEFT JOIN payment_info p ON c.user_id = p.user_id;

CREATE OR REPLACE VIEW v_payments_summary AS
SELECT
    DATE(created_at) AS payment_date,
    COUNT(*) AS total_payments,
    SUM(CASE WHEN payment_successful = TRUE THEN 1 ELSE 0 END) AS successful_payments,
    SUM(CASE WHEN payment_successful = FALSE THEN 1 ELSE 0 END) AS pending_payments,
    SUM(CASE WHEN payment_successful = TRUE THEN amount ELSE 0 END) AS total_revenue
FROM payment_info
GROUP BY DATE(created_at)
ORDER BY payment_date DESC;

CREATE OR REPLACE VIEW v_recent_registrations AS
SELECT
    c.razon_social,
    c.email,
    c.telefono,
    p.case_number,
    p.payment_successful,
    p.created_at
FROM client_info c
JOIN payment_info p ON c.user_id = p.user_id
ORDER BY p.created_at DESC
LIMIT 50;

SELECT 'Created all views' AS status;

-- ============================================================================
-- STEP 5: Add comments
-- ============================================================================

ALTER TABLE client_info COMMENT 'Stores client characterization information from Step 1 of landing page';
ALTER TABLE brief_responses COMMENT 'Stores brand brief responses from Step 2 of landing page';
ALTER TABLE payment_info COMMENT 'Stores payment and confirmation information from Step 3-4 of landing page';

-- ============================================================================
-- STEP 6: Verify new structure
-- ============================================================================

SELECT 'NEW DATABASE STRUCTURE:' AS status;

SELECT
    table_name AS 'Tables'
FROM information_schema.tables
WHERE table_schema = DATABASE()
AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT 'Database rebuild completed!' AS status;

COMMIT;

-- ============================================================================
-- Post-migration verification
-- ============================================================================

-- Verify tables
-- SHOW TABLES;

-- Expected tables:
-- - brief_responses
-- - client_info
-- - payment_info

-- Verify views
-- SHOW FULL TABLES WHERE table_type = 'VIEW';

-- Expected views:
-- - v_complete_client_data
-- - v_payments_summary
-- - v_recent_registrations
