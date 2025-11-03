-- Brandy Database Schema - Simplified MVP
-- PostgreSQL relational database for multi-step landing page
-- Created: 2025-11-03
--
-- SIMPLIFIED STRUCTURE: 3 TABLES ONLY
-- 1. client_info - Client characterization data (Step 1)
-- 2. brief_responses - Brand brief answers (Step 2)
-- 3. payment_info - Payment and confirmation data (Step 3-4)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE 1: CLIENT_INFO
-- Stores client characterization information from Step 1
-- Primary Key: id_number (DNI or RUC)
-- Auto-generates: user_id
-- ============================================================================
CREATE TABLE client_info (
    -- Primary identifier
    id_number VARCHAR(11) PRIMARY KEY, -- DNI (8 digits) or RUC (11 digits)
    user_id UUID UNIQUE NOT NULL DEFAULT uuid_generate_v4(),

    -- Legal/Identity Information
    razon_social VARCHAR(255) NOT NULL,
    tipo_persona VARCHAR(20) NOT NULL CHECK (tipo_persona IN ('natural', 'juridica')),
    representante_legal VARCHAR(255), -- Only for juridica

    -- Contact Information
    email VARCHAR(255) NOT NULL,
    telefono VARCHAR(9) NOT NULL, -- 9XXXXXXXX format
    nacionalidad VARCHAR(100) DEFAULT 'Peruana',

    -- Address Information
    direccion TEXT NOT NULL,
    distrito VARCHAR(100) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,

    -- Business Information
    rubro VARCHAR(255) NOT NULL, -- Industry/sector
    lugar_operacion TEXT NOT NULL, -- Where they operate

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for faster lookups
CREATE INDEX idx_client_email ON client_info(email);
CREATE INDEX idx_client_user_id ON client_info(user_id);
CREATE INDEX idx_client_created_at ON client_info(created_at);

-- ============================================================================
-- TABLE 2: BRIEF_RESPONSES
-- Stores brand brief responses from Step 2
-- Foreign Keys: user_id and id_number reference client_info
-- ============================================================================
CREATE TABLE brief_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES client_info(user_id) ON DELETE CASCADE,
    id_number VARCHAR(11) NOT NULL REFERENCES client_info(id_number) ON DELETE CASCADE,

    -- Question 1: ¿Ya tiene nombre?
    tiene_nombre BOOLEAN NOT NULL,
    nombre_actual VARCHAR(255), -- If tiene_nombre = true

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
    idioma_preferencia VARCHAR(50) NOT NULL CHECK (idioma_preferencia IN ('espanol', 'ingles', 'neutro', 'indiferente')),

    -- Metadata
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_brief_user_id ON brief_responses(user_id);
CREATE INDEX idx_brief_id_number ON brief_responses(id_number);
CREATE INDEX idx_brief_submitted_at ON brief_responses(submitted_at);

-- ============================================================================
-- TABLE 3: PAYMENT_INFO
-- Stores payment and client confirmation information from Step 3-4
-- Foreign Keys: user_id and id_number reference client_info
-- ============================================================================
CREATE TABLE payment_info (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Foreign Keys
    user_id UUID NOT NULL REFERENCES client_info(user_id) ON DELETE CASCADE,
    id_number VARCHAR(11) NOT NULL REFERENCES client_info(id_number) ON DELETE CASCADE,

    -- Case/Registration Number
    case_number VARCHAR(50) UNIQUE NOT NULL, -- Format: BRA-YYYYMMDD-XXX

    -- Payment Information
    amount DECIMAL(10, 2) NOT NULL DEFAULT 950.00,
    currency VARCHAR(3) DEFAULT 'PEN',
    payment_method VARCHAR(50), -- 'tarjeta', 'yape', 'transferencia', etc.

    -- Payment Status
    payment_successful BOOLEAN DEFAULT FALSE,
    payment_date TIMESTAMP WITH TIME ZONE,
    payment_reference VARCHAR(255), -- External payment gateway reference

    -- Client Contact Point
    contact_email VARCHAR(255) DEFAULT 'contacto@brandia.pe',
    contact_phone VARCHAR(20) DEFAULT '+51 999 888 777',
    contact_whatsapp VARCHAR(20) DEFAULT '+51 999 888 777',

    -- Additional Info
    terms_accepted BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address INET,
    user_agent TEXT,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_payment_user_id ON payment_info(user_id);
CREATE INDEX idx_payment_id_number ON payment_info(id_number);
CREATE INDEX idx_payment_case_number ON payment_info(case_number);
CREATE INDEX idx_payment_successful ON payment_info(payment_successful);
CREATE INDEX idx_payment_created_at ON payment_info(created_at);

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

-- Triggers for updated_at
CREATE TRIGGER update_client_updated_at
    BEFORE UPDATE ON client_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_updated_at
    BEFORE UPDATE ON payment_info
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to generate case number
CREATE OR REPLACE FUNCTION generate_case_number()
RETURNS TEXT AS $$
DECLARE
    next_number INTEGER;
    case_code TEXT;
BEGIN
    -- Get the count of payments created today
    SELECT COUNT(*) + 1 INTO next_number
    FROM payment_info
    WHERE DATE(created_at) = CURRENT_DATE;

    -- Format: BRA-YYYYMMDD-XXX
    case_code := 'BRA-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(next_number::TEXT, 3, '0');

    RETURN case_code;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate case number
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

    -- Brief data
    b.tiene_nombre,
    b.nombre_actual,
    b.producto_servicio,
    b.publico_objetivo,
    b.valores,
    b.palabra_1,
    b.palabra_2,
    b.palabra_3,
    b.idioma_preferencia,

    -- Payment data
    p.case_number,
    p.amount,
    p.payment_successful,
    p.payment_date,
    p.payment_method,

    -- Timestamps
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
    COUNT(CASE WHEN payment_successful = TRUE THEN 1 END) AS successful_payments,
    COUNT(CASE WHEN payment_successful = FALSE THEN 1 END) AS pending_payments,
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
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE client_info IS 'Stores client characterization information from Step 1 of landing page';
COMMENT ON TABLE brief_responses IS 'Stores brand brief responses from Step 2 of landing page';
COMMENT ON TABLE payment_info IS 'Stores payment and confirmation information from Step 3-4 of landing page';

COMMENT ON COLUMN client_info.id_number IS 'DNI (8 digits) or RUC (11 digits) - Primary Key';
COMMENT ON COLUMN client_info.user_id IS 'Auto-generated unique user identifier';
COMMENT ON COLUMN payment_info.case_number IS 'Auto-generated case number format: BRA-YYYYMMDD-XXX';
COMMENT ON COLUMN payment_info.payment_successful IS 'TRUE if payment was successful, FALSE if pending/failed';

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Sample client
INSERT INTO client_info (
    id_number, razon_social, tipo_persona, email, telefono,
    direccion, distrito, provincia, departamento,
    rubro, lugar_operacion
) VALUES (
    '12345678', 'Juan Pérez', 'natural', 'juan.perez@example.com', '987654321',
    'Av. Test 123', 'Miraflores', 'Lima', 'Lima',
    'Tecnología', 'Lima, Perú'
) ON CONFLICT (id_number) DO NOTHING;

-- Sample brief (will use the auto-generated user_id from above)
-- In production, use the actual user_id
-- INSERT INTO brief_responses (user_id, id_number, tiene_nombre, producto_servicio, ...)
-- VALUES (...);

-- ============================================================================
-- GRANTS (Adjust based on your user/role setup)
-- ============================================================================

-- Example: GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO brandy_app;
-- Example: GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO brandy_app;
