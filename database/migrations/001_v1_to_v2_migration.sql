-- Migration: V1 to V2
-- PostgreSQL Version
-- Adds new tables for multi-step form MVP
-- Date: 2025-10-29

-- This migration adds:
-- - client_characterization table
-- - naming_projects table
-- - briefs table
-- - payments table
-- - project_proposals table
-- - project_notes table

BEGIN;

-- ============================================================================
-- STEP 1: Create new tables
-- ============================================================================

-- Client Characterization Table
CREATE TABLE IF NOT EXISTS client_characterization (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    razon_social VARCHAR(255) NOT NULL,
    tipo_persona VARCHAR(20) NOT NULL CHECK (tipo_persona IN ('natural', 'juridica')),
    documento VARCHAR(50) NOT NULL,
    representante_legal VARCHAR(255),
    email VARCHAR(255) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    nacionalidad VARCHAR(100) DEFAULT 'Peruana',
    direccion TEXT NOT NULL,
    distrito VARCHAR(100) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL,
    etapa_negocio VARCHAR(20) NOT NULL CHECK (etapa_negocio IN ('idea', 'operacion', 'expansion')),
    rubro VARCHAR(255) NOT NULL,
    lugar_operacion TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_characterization_email ON client_characterization(email);
CREATE INDEX idx_characterization_documento ON client_characterization(documento);
CREATE INDEX idx_characterization_created_at ON client_characterization(created_at);

-- Naming Projects Table
CREATE TABLE IF NOT EXISTS naming_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    characterization_id UUID NOT NULL REFERENCES client_characterization(id) ON DELETE CASCADE,
    project_code VARCHAR(50) UNIQUE NOT NULL,
    package_type VARCHAR(50) DEFAULT 'START',
    package_price DECIMAL(10, 2) DEFAULT 950.00,
    status VARCHAR(50) DEFAULT 'brief_pending' NOT NULL,
    current_stage VARCHAR(50) DEFAULT 'onboarding',
    brief_completed_at TIMESTAMP WITH TIME ZONE,
    payment_completed_at TIMESTAMP WITH TIME ZONE,
    naming_started_at TIMESTAMP WITH TIME ZONE,
    proposals_sent_at TIMESTAMP WITH TIME ZONE,
    client_selected_at TIMESTAMP WITH TIME ZONE,
    indecopi_submitted_at TIMESTAMP WITH TIME ZONE,
    registered_at TIMESTAMP WITH TIME ZONE,
    selected_name VARCHAR(100),
    selected_proposal_id UUID,
    indecopi_expediente VARCHAR(100),
    indecopi_clase INTEGER,
    indecopi_certificado VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_projects_characterization_id ON naming_projects(characterization_id);
CREATE INDEX idx_projects_status ON naming_projects(status);
CREATE INDEX idx_projects_project_code ON naming_projects(project_code);
CREATE INDEX idx_projects_created_at ON naming_projects(created_at);

-- Briefs Table
CREATE TABLE IF NOT EXISTS briefs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES naming_projects(id) ON DELETE CASCADE,
    tiene_nombre BOOLEAN NOT NULL,
    producto_servicio TEXT NOT NULL,
    publico_objetivo TEXT NOT NULL,
    valores TEXT NOT NULL,
    palabra_1 VARCHAR(100) NOT NULL,
    palabra_2 VARCHAR(100) NOT NULL,
    palabra_3 VARCHAR(100) NOT NULL,
    idea_nombre VARCHAR(255),
    tiene_logo BOOLEAN NOT NULL,
    donde_vende TEXT NOT NULL,
    idioma_preferencia VARCHAR(50) NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    time_spent_seconds INTEGER,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_briefs_project_id ON briefs(project_id);
CREATE INDEX idx_briefs_completed_at ON briefs(completed_at);

-- Payments Table
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES naming_projects(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'PEN',
    payment_method VARCHAR(50),
    status VARCHAR(50) DEFAULT 'pending' NOT NULL,
    gateway_transaction_id VARCHAR(255),
    gateway_response JSONB,
    payer_email VARCHAR(255),
    payer_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,
    ip_address INET,
    user_agent TEXT,
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_payments_project_id ON payments(project_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_payments_gateway_transaction_id ON payments(gateway_transaction_id);

-- Project Proposals Table
CREATE TABLE IF NOT EXISTS project_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES naming_projects(id) ON DELETE CASCADE,
    generated_name_id UUID REFERENCES generated_names(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    proposal_order INTEGER DEFAULT 1,
    rationale TEXT,
    status VARCHAR(50) DEFAULT 'proposed',
    is_selected BOOLEAN DEFAULT FALSE,
    sent_to_client_at TIMESTAMP WITH TIME ZONE,
    client_feedback TEXT,
    client_responded_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_proposals_project_id ON project_proposals(project_id);
CREATE INDEX idx_proposals_status ON project_proposals(status);
CREATE INDEX idx_proposals_is_selected ON project_proposals(is_selected);

-- Project Notes Table
CREATE TABLE IF NOT EXISTS project_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES naming_projects(id) ON DELETE CASCADE,
    note_type VARCHAR(50) NOT NULL,
    note_text TEXT NOT NULL,
    created_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_visible_to_client BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_notes_project_id ON project_notes(project_id);
CREATE INDEX idx_notes_created_at ON project_notes(created_at);
CREATE INDEX idx_notes_note_type ON project_notes(note_type);

-- ============================================================================
-- STEP 2: Update existing tables
-- ============================================================================

-- Add project_id to generated_names
ALTER TABLE generated_names
ADD COLUMN IF NOT EXISTS project_id UUID REFERENCES naming_projects(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_generated_names_project_id ON generated_names(project_id);

-- ============================================================================
-- STEP 3: Create helper functions and triggers
-- ============================================================================

-- Trigger for characterization updated_at
CREATE TRIGGER update_characterization_updated_at
    BEFORE UPDATE ON client_characterization
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for projects updated_at
CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON naming_projects
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to generate project code
CREATE OR REPLACE FUNCTION generate_project_code()
RETURNS TEXT AS $$
DECLARE
    next_number INTEGER;
    project_code TEXT;
BEGIN
    SELECT COUNT(*) + 1 INTO next_number
    FROM naming_projects
    WHERE DATE(created_at) = CURRENT_DATE;

    project_code := 'BRA-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(next_number::TEXT, 3, '0');
    RETURN project_code;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate project code
CREATE OR REPLACE FUNCTION set_project_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.project_code IS NULL THEN
        NEW.project_code := generate_project_code();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER auto_generate_project_code
    BEFORE INSERT ON naming_projects
    FOR EACH ROW
    EXECUTE FUNCTION set_project_code();

-- ============================================================================
-- STEP 4: Create views
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
    c.razon_social,
    c.tipo_persona,
    c.documento,
    c.email,
    c.telefono,
    c.etapa_negocio,
    c.rubro,
    b.producto_servicio,
    b.publico_objetivo,
    b.valores,
    b.idioma_preferencia,
    p.selected_name,
    pay.status AS payment_status,
    pay.amount AS payment_amount,
    pay.paid_at AS payment_date,
    p.created_at AS project_created,
    p.brief_completed_at,
    p.payment_completed_at,
    p.naming_started_at,
    p.proposals_sent_at,
    p.registered_at,
    p.indecopi_expediente,
    p.indecopi_certificado
FROM naming_projects p
LEFT JOIN client_characterization c ON p.characterization_id = c.id
LEFT JOIN briefs b ON p.id = b.project_id
LEFT JOIN payments pay ON p.id = pay.project_id AND pay.status = 'completed';

-- Active projects
CREATE OR REPLACE VIEW v_projects_active AS
SELECT
    p.project_code,
    p.status,
    p.current_stage,
    c.razon_social,
    c.email,
    c.telefono,
    p.created_at,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - p.created_at)) AS days_since_creation,
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
    COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_payments,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) AS pending_payments,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) AS failed_payments,
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
-- STEP 5: Add comments
-- ============================================================================

COMMENT ON TABLE client_characterization IS 'Stores legal and business information from Step 1 of the form';
COMMENT ON TABLE naming_projects IS 'Tracks overall naming and trademark registration projects';
COMMENT ON TABLE briefs IS 'Stores brand brief responses from Step 2';
COMMENT ON TABLE payments IS 'Tracks payment transactions and status';
COMMENT ON TABLE project_proposals IS 'Links generated name proposals to projects';
COMMENT ON TABLE project_notes IS 'Internal notes and communication log for projects';

-- ============================================================================
-- Commit transaction
-- ============================================================================

COMMIT;

-- ============================================================================
-- Post-migration verification queries
-- ============================================================================

-- Uncomment to verify tables were created:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%project%' OR table_name LIKE '%brief%' OR table_name LIKE '%payment%' OR table_name LIKE '%characterization%';

-- Uncomment to verify indexes:
-- SELECT indexname, tablename FROM pg_indexes WHERE schemaname = 'public' AND (tablename LIKE '%project%' OR tablename LIKE '%brief%');

-- Uncomment to verify views:
-- SELECT table_name FROM information_schema.views WHERE table_schema = 'public' AND table_name LIKE 'v_%project%';
