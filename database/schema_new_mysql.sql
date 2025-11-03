-- Brandy Database Schema - Simplified MVP
-- MySQL 8.0+ relational database for multi-step landing page
-- Created: 2025-11-03
--
-- SIMPLIFIED STRUCTURE: 3 TABLES ONLY
-- 1. client_info - Client characterization data (Step 1)
-- 2. brief_responses - Brand brief answers (Step 2)
-- 3. payment_info - Payment and confirmation data (Step 3-4)

-- ============================================================================
-- TABLE 1: CLIENT_INFO
-- Stores client characterization information from Step 1
-- Primary Key: id_number (DNI or RUC)
-- Auto-generates: user_id
-- ============================================================================
CREATE TABLE IF NOT EXISTS client_info (
    -- Primary identifier
    id_number VARCHAR(11) PRIMARY KEY,
    user_id CHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),

    -- Legal/Identity Information
    razon_social VARCHAR(255) NOT NULL,
    tipo_persona ENUM('natural', 'juridica') NOT NULL,
    representante_legal VARCHAR(255),

    -- Contact Information
    email VARCHAR(255) NOT NULL,
    telefono VARCHAR(9) NOT NULL,
    nacionalidad VARCHAR(100) DEFAULT 'Peruana',

    -- Address Information
    direccion TEXT NOT NULL,
    distrito VARCHAR(100) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,

    -- Business Information
    rubro VARCHAR(255) NOT NULL,
    lugar_operacion TEXT NOT NULL,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_client_email (email),
    INDEX idx_client_user_id (user_id),
    INDEX idx_client_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 2: BRIEF_RESPONSES
-- Stores brand brief responses from Step 2
-- Foreign Keys: user_id and id_number reference client_info
-- ============================================================================
CREATE TABLE IF NOT EXISTS brief_responses (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),

    -- Foreign Keys
    user_id CHAR(36) NOT NULL,
    id_number VARCHAR(11) NOT NULL,

    -- Question 1: ¿Ya tiene nombre?
    tiene_nombre BOOLEAN NOT NULL,
    nombre_actual VARCHAR(255),

    -- Question 2: Producto o servicio
    producto_servicio TEXT NOT NULL,

    -- Question 3: Público objetivo
    publico_objetivo TEXT NOT NULL,

    -- Question 4: Valores o ideas
    valores TEXT NOT NULL,

    -- Question 5: 3 palabras que definan el negocio
    palabra_1 VARCHAR(100) NOT NULL,
    palabra_2 VARCHAR(100) NOT NULL,
    palabra_3 VARCHAR(100) NOT NULL,

    -- Question 6: Idea de nombre (opcional)
    idea_nombre VARCHAR(255),

    -- Question 7: ¿Tiene logo?
    tiene_logo BOOLEAN NOT NULL,

    -- Question 8: ¿Dónde vende?
    donde_vende TEXT NOT NULL,

    -- Question 9: Preferencia de idioma
    idioma_preferencia ENUM('espanol', 'ingles', 'neutro', 'indiferente') NOT NULL,

    -- Metadata
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_brief_user_id (user_id),
    INDEX idx_brief_id_number (id_number),
    INDEX idx_brief_submitted_at (submitted_at),

    FOREIGN KEY (user_id) REFERENCES client_info(user_id) ON DELETE CASCADE,
    FOREIGN KEY (id_number) REFERENCES client_info(id_number) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE 3: PAYMENT_INFO
-- Stores payment and client confirmation information from Step 3-4
-- Foreign Keys: user_id and id_number reference client_info
-- ============================================================================
CREATE TABLE IF NOT EXISTS payment_info (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),

    -- Foreign Keys
    user_id CHAR(36) NOT NULL,
    id_number VARCHAR(11) NOT NULL,

    -- Case/Registration Number
    case_number VARCHAR(50) UNIQUE NOT NULL,

    -- Payment Information
    amount DECIMAL(10, 2) NOT NULL DEFAULT 950.00,
    currency VARCHAR(3) DEFAULT 'PEN',
    payment_method VARCHAR(50),

    -- Payment Status
    payment_successful BOOLEAN DEFAULT FALSE,
    payment_date TIMESTAMP NULL,
    payment_reference VARCHAR(255),

    -- Client Contact Point
    contact_email VARCHAR(255) DEFAULT 'contacto@brandia.pe',
    contact_phone VARCHAR(20) DEFAULT '+51 999 888 777',
    contact_whatsapp VARCHAR(20) DEFAULT '+51 999 888 777',

    -- Additional Info
    terms_accepted BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address VARCHAR(45),
    user_agent TEXT,

    -- Metadata
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

-- ============================================================================
-- STORED PROCEDURES
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

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Complete client view with all related data
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

-- Payments summary view
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

-- Recent registrations view
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

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

INSERT INTO client_info (
    id_number, razon_social, tipo_persona, email, telefono,
    direccion, distrito, provincia, departamento,
    rubro, lugar_operacion
) VALUES (
    '12345678', 'Juan Pérez', 'natural', 'juan.perez@example.com', '987654321',
    'Av. Test 123', 'Miraflores', 'Lima', 'Lima',
    'Tecnología', 'Lima, Perú'
) ON DUPLICATE KEY UPDATE id_number=id_number;

-- ============================================================================
-- TABLE COMMENTS
-- ============================================================================

ALTER TABLE client_info COMMENT 'Stores client characterization information from Step 1 of landing page';
ALTER TABLE brief_responses COMMENT 'Stores brand brief responses from Step 2 of landing page';
ALTER TABLE payment_info COMMENT 'Stores payment and confirmation information from Step 3-4 of landing page';
