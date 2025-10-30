-- Brandy Database Schema V2 - MySQL Version
-- MySQL 8.0+ relational database for MVP multi-step form
-- Updated: 2025-10-29
--
-- NEW FEATURES:
-- - Client characterization (legal/business data)
-- - Naming projects tracking
-- - Payment processing
-- - Brief responses (simplified 9 questions)

-- ============================================================================
-- CLIENT CHARACTERIZATION TABLE
-- Stores legal and business information from Step 1
-- ============================================================================
CREATE TABLE IF NOT EXISTS client_characterization (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),

    -- Legal/Identity Information
    razon_social VARCHAR(255) NOT NULL,
    tipo_persona ENUM('natural', 'juridica') NOT NULL,
    documento VARCHAR(50) NOT NULL,
    representante_legal VARCHAR(255),

    -- Contact Information
    email VARCHAR(255) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    nacionalidad VARCHAR(100) DEFAULT 'Peruana',

    -- Address Information
    direccion TEXT NOT NULL,
    distrito VARCHAR(100) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,

    -- Business Information
    etapa_negocio ENUM('idea', 'operacion', 'expansion') NOT NULL,
    rubro VARCHAR(255) NOT NULL,
    lugar_operacion TEXT NOT NULL,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    metadata JSON DEFAULT ('{}'),

    INDEX idx_characterization_email (email),
    INDEX idx_characterization_documento (documento),
    INDEX idx_characterization_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- NAMING PROJECTS TABLE
-- Tracks the overall naming and trademark registration project
-- ============================================================================
CREATE TABLE IF NOT EXISTS naming_projects (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    characterization_id CHAR(36) NOT NULL,

    -- Project Information
    project_code VARCHAR(50) UNIQUE NOT NULL,
    package_type VARCHAR(50) DEFAULT 'START',
    package_price DECIMAL(10, 2) DEFAULT 950.00,

    -- Status Tracking
    status VARCHAR(50) DEFAULT 'brief_pending' NOT NULL,
    current_stage VARCHAR(50) DEFAULT 'onboarding',

    -- Timeline
    brief_completed_at TIMESTAMP NULL,
    payment_completed_at TIMESTAMP NULL,
    naming_started_at TIMESTAMP NULL,
    proposals_sent_at TIMESTAMP NULL,
    client_selected_at TIMESTAMP NULL,
    indecopi_submitted_at TIMESTAMP NULL,
    registered_at TIMESTAMP NULL,

    -- Selected Name
    selected_name VARCHAR(100),
    selected_proposal_id CHAR(36),

    -- INDECOPI Information
    indecopi_expediente VARCHAR(100),
    indecopi_clase INT,
    indecopi_certificado VARCHAR(100),

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    notes TEXT,
    metadata JSON DEFAULT ('{}'),

    INDEX idx_projects_characterization_id (characterization_id),
    INDEX idx_projects_status (status),
    INDEX idx_projects_project_code (project_code),
    INDEX idx_projects_created_at (created_at),

    FOREIGN KEY (characterization_id) REFERENCES client_characterization(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- BRIEFS TABLE
-- Stores responses to the brand brief (Step 2)
-- ============================================================================
CREATE TABLE IF NOT EXISTS briefs (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    project_id CHAR(36) NOT NULL,

    -- Brief Questions
    tiene_nombre BOOLEAN NOT NULL,
    producto_servicio TEXT NOT NULL,
    publico_objetivo TEXT NOT NULL,
    valores TEXT NOT NULL,

    -- 3 defining words
    palabra_1 VARCHAR(100) NOT NULL,
    palabra_2 VARCHAR(100) NOT NULL,
    palabra_3 VARCHAR(100) NOT NULL,

    idea_nombre VARCHAR(255),
    tiene_logo BOOLEAN NOT NULL,
    donde_vende TEXT NOT NULL,
    idioma_preferencia VARCHAR(50) NOT NULL,

    -- Metadata
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    time_spent_seconds INT,
    metadata JSON DEFAULT ('{}'),

    INDEX idx_briefs_project_id (project_id),
    INDEX idx_briefs_completed_at (completed_at),

    FOREIGN KEY (project_id) REFERENCES naming_projects(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PAYMENTS TABLE
-- Tracks payment transactions
-- ============================================================================
CREATE TABLE IF NOT EXISTS payments (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    project_id CHAR(36) NOT NULL,

    -- Payment Information
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'PEN',
    payment_method VARCHAR(50),

    -- Payment Status
    status VARCHAR(50) DEFAULT 'pending' NOT NULL,

    -- Gateway Information
    gateway_transaction_id VARCHAR(255),
    gateway_response JSON,

    -- Customer Info
    payer_email VARCHAR(255),
    payer_name VARCHAR(255),

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP NULL,
    refunded_at TIMESTAMP NULL,

    -- Additional Info
    ip_address VARCHAR(45),
    user_agent TEXT,
    notes TEXT,
    metadata JSON DEFAULT ('{}'),

    INDEX idx_payments_project_id (project_id),
    INDEX idx_payments_status (status),
    INDEX idx_payments_created_at (created_at),
    INDEX idx_payments_gateway_transaction_id (gateway_transaction_id),

    FOREIGN KEY (project_id) REFERENCES naming_projects(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PROJECT PROPOSALS TABLE
-- Links generated names to specific projects
-- ============================================================================
CREATE TABLE IF NOT EXISTS project_proposals (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    project_id CHAR(36) NOT NULL,
    generated_name_id CHAR(36),

    -- Proposal Information
    name VARCHAR(100) NOT NULL,
    proposal_order INT DEFAULT 1,
    rationale TEXT,

    -- Status
    status VARCHAR(50) DEFAULT 'proposed',
    is_selected BOOLEAN DEFAULT FALSE,

    -- Timestamps
    sent_to_client_at TIMESTAMP NULL,
    client_feedback TEXT,
    client_responded_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSON DEFAULT ('{}'),

    INDEX idx_proposals_project_id (project_id),
    INDEX idx_proposals_status (status),
    INDEX idx_proposals_is_selected (is_selected),

    FOREIGN KEY (project_id) REFERENCES naming_projects(id) ON DELETE CASCADE,
    FOREIGN KEY (generated_name_id) REFERENCES generated_names(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- PROJECT NOTES TABLE
-- Internal notes and communications log
-- ============================================================================
CREATE TABLE IF NOT EXISTS project_notes (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    project_id CHAR(36) NOT NULL,

    note_type VARCHAR(50) NOT NULL,
    note_text TEXT NOT NULL,

    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    is_visible_to_client BOOLEAN DEFAULT FALSE,
    metadata JSON DEFAULT ('{}'),

    INDEX idx_notes_project_id (project_id),
    INDEX idx_notes_created_at (created_at),
    INDEX idx_notes_note_type (note_type),

    FOREIGN KEY (project_id) REFERENCES naming_projects(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- UPDATE EXISTING TABLES
-- ============================================================================

-- Add project_id to generated_names (if table exists)
ALTER TABLE generated_names
ADD COLUMN project_id CHAR(36) DEFAULT NULL,
ADD INDEX idx_generated_names_project_id (project_id),
ADD FOREIGN KEY (project_id) REFERENCES naming_projects(id) ON DELETE SET NULL;

-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- Procedure to generate project code
DELIMITER //
CREATE PROCEDURE generate_project_code(OUT new_code VARCHAR(50))
BEGIN
    DECLARE next_number INT;

    -- Get the count of projects created today
    SELECT COUNT(*) + 1 INTO next_number
    FROM naming_projects
    WHERE DATE(created_at) = CURDATE();

    -- Format: BRA-YYYYMMDD-XXX
    SET new_code = CONCAT('BRA-', DATE_FORMAT(CURDATE(), '%Y%m%d'), '-', LPAD(next_number, 3, '0'));
END //
DELIMITER ;

-- Trigger to auto-generate project code
DELIMITER //
CREATE TRIGGER auto_generate_project_code
BEFORE INSERT ON naming_projects
FOR EACH ROW
BEGIN
    IF NEW.project_code IS NULL OR NEW.project_code = '' THEN
        CALL generate_project_code(NEW.project_code);
    END IF;
END //
DELIMITER ;

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Complete project overview
CREATE OR REPLACE VIEW v_projects_complete AS
SELECT
    p.id AS project_id,
    p.project_code,
    p.status,
    p.current_stage,
    p.package_type,
    p.package_price,

    -- Client Information
    c.razon_social,
    c.tipo_persona,
    c.documento,
    c.email,
    c.telefono,
    c.etapa_negocio,
    c.rubro,

    -- Brief Information
    b.producto_servicio,
    b.publico_objetivo,
    b.valores,
    b.idioma_preferencia,

    -- Selected Name
    p.selected_name,

    -- Payment Information
    pay.status AS payment_status,
    pay.amount AS payment_amount,
    pay.paid_at AS payment_date,

    -- Timeline
    p.created_at AS project_created,
    p.brief_completed_at,
    p.payment_completed_at,
    p.naming_started_at,
    p.proposals_sent_at,
    p.registered_at,

    -- INDECOPI
    p.indecopi_expediente,
    p.indecopi_certificado

FROM naming_projects p
LEFT JOIN client_characterization c ON p.characterization_id = c.id
LEFT JOIN briefs b ON p.id = b.project_id
LEFT JOIN payments pay ON p.id = pay.project_id AND pay.status = 'completed';

-- Active projects requiring attention
CREATE OR REPLACE VIEW v_projects_active AS
SELECT
    p.project_code,
    p.status,
    p.current_stage,
    c.razon_social,
    c.email,
    c.telefono,
    p.created_at,
    DATEDIFF(NOW(), p.created_at) AS days_since_creation,
    CASE
        WHEN p.status = 'brief_pending' THEN 'Waiting for brief completion'
        WHEN p.status = 'payment_pending' THEN 'Waiting for payment'
        WHEN p.status = 'naming_in_progress' THEN 'Creating name proposals'
        WHEN p.status = 'proposals_sent' THEN 'Waiting for client selection'
        WHEN p.status = 'indecopi_submitted' THEN 'INDECOPI review in progress'
        ELSE 'Check project status'
    END AS action_required
FROM naming_projects p
JOIN client_characterization c ON p.characterization_id = c.id
WHERE p.status NOT IN ('registered', 'cancelled', 'rejected')
ORDER BY p.created_at DESC;

-- Payment summary
CREATE OR REPLACE VIEW v_payment_summary AS
SELECT
    DATE(created_at) AS payment_date,
    COUNT(*) AS total_payments,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_payments,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_payments,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_payments,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) AS revenue,
    AVG(CASE WHEN status = 'completed' THEN amount END) AS avg_transaction
FROM payments
GROUP BY DATE(created_at)
ORDER BY payment_date DESC;

-- Client acquisition funnel
CREATE OR REPLACE VIEW v_acquisition_funnel AS
SELECT
    COUNT(DISTINCT c.id) AS total_characterizations,
    COUNT(DISTINCT CASE WHEN b.id IS NOT NULL THEN c.id END) AS completed_briefs,
    COUNT(DISTINCT CASE WHEN pay.status = 'completed' THEN c.id END) AS paid_clients,
    COUNT(DISTINCT CASE WHEN p.status IN ('registered') THEN c.id END) AS registered_clients,

    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN b.id IS NOT NULL THEN c.id END) /
        NULLIF(COUNT(DISTINCT c.id), 0), 2
    ) AS brief_completion_rate,

    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN pay.status = 'completed' THEN c.id END) /
        NULLIF(COUNT(DISTINCT CASE WHEN b.id IS NOT NULL THEN c.id END), 0), 2
    ) AS payment_conversion_rate,

    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN p.status = 'registered' THEN c.id END) /
        NULLIF(COUNT(DISTINCT CASE WHEN pay.status = 'completed' THEN c.id END), 0), 2
    ) AS registration_success_rate

FROM client_characterization c
LEFT JOIN naming_projects p ON c.id = p.characterization_id
LEFT JOIN briefs b ON p.id = b.project_id
LEFT JOIN payments pay ON p.id = pay.project_id;

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Sample characterization
INSERT INTO client_characterization (
    id, razon_social, tipo_persona, documento, email, telefono, nacionalidad,
    direccion, distrito, provincia, departamento,
    etapa_negocio, rubro, lugar_operacion
) VALUES (
    UUID(), 'Test Company SAC', 'juridica', '20123456789', 'test@example.com', '+51987654321', 'Peruana',
    'Av. Principal 123', 'Miraflores', 'Lima', 'Lima',
    'operacion', 'Tecnología', 'Lima, Perú'
);

-- ============================================================================
-- TABLE COMMENTS (MySQL 8.0+)
-- ============================================================================

ALTER TABLE client_characterization COMMENT 'Stores legal and business information from Step 1 of the form';
ALTER TABLE naming_projects COMMENT 'Tracks overall naming and trademark registration projects';
ALTER TABLE briefs COMMENT 'Stores brand brief responses from Step 2';
ALTER TABLE payments COMMENT 'Tracks payment transactions and status';
ALTER TABLE project_proposals COMMENT 'Links generated name proposals to projects';
ALTER TABLE project_notes COMMENT 'Internal notes and communication log for projects';
