-- Migration: Complete Database Rebuild
-- PostgreSQL Version
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

BEGIN;

-- ============================================================================
-- STEP 1: Drop ALL existing tables and views
-- ============================================================================

-- Drop views first
DROP VIEW IF EXISTS v_complete_client_data CASCADE;
DROP VIEW IF EXISTS v_payments_summary CASCADE;
DROP VIEW IF EXISTS v_recent_registrations CASCADE;
DROP VIEW IF EXISTS v_projects_complete CASCADE;
DROP VIEW IF EXISTS v_projects_active CASCADE;
DROP VIEW IF EXISTS v_payment_summary CASCADE;
DROP VIEW IF EXISTS v_acquisition_funnel CASCADE;
DROP VIEW IF EXISTS v_form_submissions_complete CASCADE;
DROP VIEW IF EXISTS v_user_activity_summary CASCADE;
DROP VIEW IF EXISTS v_popular_names CASCADE;

RAISE NOTICE 'Dropped all views';

-- Drop all tables (in correct order for dependencies)
DROP TABLE IF EXISTS project_notes CASCADE;
DROP TABLE IF EXISTS project_proposals CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS briefs CASCADE;
DROP TABLE IF EXISTS naming_projects CASCADE;
DROP TABLE IF EXISTS client_characterization CASCADE;
DROP TABLE IF EXISTS form_answers CASCADE;
DROP TABLE IF EXISTS form_submissions CASCADE;
DROP TABLE IF EXISTS similarity_checks CASCADE;
DROP TABLE IF EXISTS trademark_checks CASCADE;
DROP TABLE IF EXISTS generated_names CASCADE;
DROP TABLE IF EXISTS cached_searches CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS users CASCADE;

RAISE NOTICE 'Dropped all old tables';

-- Drop old functions
DROP FUNCTION IF EXISTS generate_project_code() CASCADE;
DROP FUNCTION IF EXISTS set_project_code() CASCADE;
DROP FUNCTION IF EXISTS clean_expired_cache() CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

RAISE NOTICE 'Dropped old functions';

-- ============================================================================
-- STEP 2: Create new simplified schema
-- ============================================================================

-- Recreate update function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TABLE 1: CLIENT_INFO
CREATE TABLE client_info (
    id_number VARCHAR(11) PRIMARY KEY,
    user_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),
    razon_social VARCHAR(255) NOT NULL,
    tipo_persona VARCHAR(20) NOT NULL CHECK (tipo_persona IN ('natural', 'juridica')),
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_client_email ON client_info(email);
CREATE INDEX idx_client_user_id ON client_info(user_id);
CREATE INDEX idx_client_created_at ON client_info(created_at);

RAISE NOTICE 'Created client_info table';

-- TABLE 2: BRIEF_RESPONSES
CREATE TABLE brief_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES client_info(user_id) ON DELETE CASCADE,
    id_number VARCHAR(11) NOT NULL REFERENCES client_info(id_number) ON DELETE CASCADE,
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
    idioma_preferencia VARCHAR(50) NOT NULL CHECK (idioma_preferencia IN ('espanol', 'ingles', 'neutro', 'indiferente')),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_brief_user_id ON brief_responses(user_id);
CREATE INDEX idx_brief_id_number ON brief_responses(id_number);
CREATE INDEX idx_brief_submitted_at ON brief_responses(submitted_at);

RAISE NOTICE 'Created brief_responses table';

-- TABLE 3: PAYMENT_INFO
CREATE TABLE payment_info (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES client_info(user_id) ON DELETE CASCADE,
    id_number VARCHAR(11) NOT NULL REFERENCES client_info(id_number) ON DELETE CASCADE,
    case_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL DEFAULT 950.00,
    currency VARCHAR(3) DEFAULT 'PEN',
    payment_method VARCHAR(50),
    payment_successful BOOLEAN DEFAULT FALSE,
    payment_date TIMESTAMP WITH TIME ZONE,
    payment_reference VARCHAR(255),
    contact_email VARCHAR(255) DEFAULT 'contacto@brandia.pe',
    contact_phone VARCHAR(20) DEFAULT '+51 999 888 777',
    contact_whatsapp VARCHAR(20) DEFAULT '+51 999 888 777',
    terms_accepted BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payment_user_id ON payment_info(user_id);
CREATE INDEX idx_payment_id_number ON payment_info(id_number);
CREATE INDEX idx_payment_case_number ON payment_info(case_number);
CREATE INDEX idx_payment_successful ON payment_info(payment_successful);
CREATE INDEX idx_payment_created_at ON payment_info(created_at);

RAISE NOTICE 'Created payment_info table';

-- ============================================================================
-- STEP 3: Create triggers
-- ============================================================================

CREATE TRIGGER update_client_updated_at
    BEFORE UPDATE ON client_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_updated_at
    BEFORE UPDATE ON payment_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Case number generation
CREATE OR REPLACE FUNCTION generate_case_number()
RETURNS TEXT AS $$
DECLARE
    next_number INTEGER;
    case_code TEXT;
BEGIN
    SELECT COUNT(*) + 1 INTO next_number
    FROM payment_info
    WHERE DATE(created_at) = CURRENT_DATE;

    case_code := 'BRA-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(next_number::TEXT, 3, '0');
    RETURN case_code;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_case_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.case_number IS NULL OR NEW.case_number = '' THEN
        NEW.case_number := generate_case_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_generate_case_number
    BEFORE INSERT ON payment_info
    FOR EACH ROW
    EXECUTE FUNCTION set_case_number();

RAISE NOTICE 'Created all triggers';

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
    COUNT(CASE WHEN payment_successful = TRUE THEN 1 END) AS successful_payments,
    COUNT(CASE WHEN payment_successful = FALSE THEN 1 END) AS pending_payments,
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

RAISE NOTICE 'Created all views';

-- ============================================================================
-- STEP 5: Add comments
-- ============================================================================

COMMENT ON TABLE client_info IS 'Stores client characterization information from Step 1 of landing page';
COMMENT ON TABLE brief_responses IS 'Stores brand brief responses from Step 2 of landing page';
COMMENT ON TABLE payment_info IS 'Stores payment and confirmation information from Step 3-4 of landing page';

COMMENT ON COLUMN client_info.id_number IS 'DNI (8 digits) or RUC (11 digits) - Primary Key';
COMMENT ON COLUMN client_info.user_id IS 'Auto-generated unique user identifier';
COMMENT ON COLUMN payment_info.case_number IS 'Auto-generated case number format: BRA-YYYYMMDD-XXX';
COMMENT ON COLUMN payment_info.payment_successful IS 'TRUE if payment was successful, FALSE if pending/failed';

-- ============================================================================
-- STEP 6: Verify new structure
-- ============================================================================

DO $$
DECLARE
    table_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '====================================';
    RAISE NOTICE 'NEW DATABASE STRUCTURE:';
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
    RAISE NOTICE 'Database rebuild completed!';
    RAISE NOTICE '====================================';
END $$;

COMMIT;

-- ============================================================================
-- Post-migration verification
-- ============================================================================

-- Verify tables
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name;

-- Expected tables:
-- - brief_responses
-- - client_info
-- - payment_info

-- Verify views
-- SELECT table_name FROM information_schema.views WHERE table_schema = 'public' ORDER BY table_name;

-- Expected views:
-- - v_complete_client_data
-- - v_payments_summary
-- - v_recent_registrations
