-- Brandy Database Schema V2
-- PostgreSQL relational database for MVP multi-step form
-- Updated: 2025-10-29
--
-- NEW FEATURES:
-- - Client characterization (legal/business data)
-- - Naming projects tracking
-- - Payment processing
-- - Brief responses (simplified 9 questions)

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- CLIENT CHARACTERIZATION TABLE
-- Stores legal and business information from Step 1
-- ============================================================================
CREATE TABLE client_characterization (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Legal/Identity Information
    razon_social VARCHAR(255) NOT NULL,
    tipo_persona VARCHAR(20) NOT NULL CHECK (tipo_persona IN ('natural', 'juridica')),
    documento VARCHAR(50) NOT NULL, -- DNI or RUC
    representante_legal VARCHAR(255), -- Only for 'juridica'

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
    etapa_negocio VARCHAR(20) NOT NULL CHECK (etapa_negocio IN ('idea', 'operacion', 'expansion')),
    rubro VARCHAR(255) NOT NULL, -- Industry/sector
    lugar_operacion TEXT NOT NULL, -- Where they operate

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_characterization_email ON client_characterization(email);
CREATE INDEX idx_characterization_documento ON client_characterization(documento);
CREATE INDEX idx_characterization_created_at ON client_characterization(created_at);

-- ============================================================================
-- NAMING PROJECTS TABLE
-- Tracks the overall naming and trademark registration project
-- ============================================================================
CREATE TABLE naming_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    characterization_id UUID NOT NULL REFERENCES client_characterization(id) ON DELETE CASCADE,

    -- Project Information
    project_code VARCHAR(50) UNIQUE NOT NULL, -- e.g., "BRA-2025-001"
    package_type VARCHAR(50) DEFAULT 'START', -- Package selected
    package_price DECIMAL(10, 2) DEFAULT 950.00,

    -- Status Tracking
    status VARCHAR(50) DEFAULT 'brief_pending' NOT NULL,
    -- Possible statuses: 'brief_pending', 'brief_completed', 'payment_pending', 'payment_completed',
    --                   'naming_in_progress', 'proposals_sent', 'client_selected',
    --                   'indecopi_submitted', 'indecopi_in_review', 'registered', 'rejected', 'cancelled'

    current_stage VARCHAR(50) DEFAULT 'onboarding',
    -- Stages: 'onboarding', 'naming', 'registration', 'completed'

    -- Timeline
    brief_completed_at TIMESTAMP WITH TIME ZONE,
    payment_completed_at TIMESTAMP WITH TIME ZONE,
    naming_started_at TIMESTAMP WITH TIME ZONE,
    proposals_sent_at TIMESTAMP WITH TIME ZONE,
    client_selected_at TIMESTAMP WITH TIME ZONE,
    indecopi_submitted_at TIMESTAMP WITH TIME ZONE,
    registered_at TIMESTAMP WITH TIME ZONE,

    -- Selected Name
    selected_name VARCHAR(100),
    selected_proposal_id UUID, -- References generated_names table

    -- INDECOPI Information
    indecopi_expediente VARCHAR(100), -- Expediente number
    indecopi_clase INTEGER, -- NICE classification (1-45)
    indecopi_certificado VARCHAR(100), -- Certificate number

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_projects_characterization_id ON naming_projects(characterization_id);
CREATE INDEX idx_projects_status ON naming_projects(status);
CREATE INDEX idx_projects_project_code ON naming_projects(project_code);
CREATE INDEX idx_projects_created_at ON naming_projects(created_at);

-- ============================================================================
-- BRIEFS TABLE
-- Stores responses to the brand brief (Step 2)
-- ============================================================================
CREATE TABLE briefs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES naming_projects(id) ON DELETE CASCADE,

    -- Brief Questions
    tiene_nombre BOOLEAN NOT NULL, -- Already has a name
    producto_servicio TEXT NOT NULL, -- Product/service description
    publico_objetivo TEXT NOT NULL, -- Target audience
    valores TEXT NOT NULL, -- Brand values/ideas

    -- 3 defining words
    palabra_1 VARCHAR(100) NOT NULL,
    palabra_2 VARCHAR(100) NOT NULL,
    palabra_3 VARCHAR(100) NOT NULL,

    idea_nombre VARCHAR(255), -- Optional name idea
    tiene_logo BOOLEAN NOT NULL, -- Has logo
    donde_vende TEXT NOT NULL, -- Where they sell
    idioma_preferencia VARCHAR(50) NOT NULL, -- Language preference (espanol/ingles/neutro/indiferente)

    -- Metadata
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    time_spent_seconds INTEGER, -- Time to complete
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_briefs_project_id ON briefs(project_id);
CREATE INDEX idx_briefs_completed_at ON briefs(completed_at);

-- ============================================================================
-- PAYMENTS TABLE
-- Tracks payment transactions
-- ============================================================================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES naming_projects(id) ON DELETE CASCADE,

    -- Payment Information
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'PEN', -- Peruvian Soles
    payment_method VARCHAR(50), -- 'culqi', 'niubiz', 'stripe', 'bank_transfer'

    -- Payment Status
    status VARCHAR(50) DEFAULT 'pending' NOT NULL,
    -- Possible statuses: 'pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled'

    -- Gateway Information
    gateway_transaction_id VARCHAR(255), -- External payment ID
    gateway_response JSONB, -- Raw gateway response

    -- Customer Info
    payer_email VARCHAR(255),
    payer_name VARCHAR(255),

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP WITH TIME ZONE,
    refunded_at TIMESTAMP WITH TIME ZONE,

    -- Additional Info
    ip_address INET,
    user_agent TEXT,
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_payments_project_id ON payments(project_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_payments_gateway_transaction_id ON payments(gateway_transaction_id);

-- ============================================================================
-- PROJECT PROPOSALS TABLE
-- Links generated names to specific projects
-- ============================================================================
CREATE TABLE project_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES naming_projects(id) ON DELETE CASCADE,
    generated_name_id UUID REFERENCES generated_names(id) ON DELETE SET NULL,

    -- Proposal Information
    name VARCHAR(100) NOT NULL,
    proposal_order INTEGER DEFAULT 1, -- 1st, 2nd, or 3rd proposal
    rationale TEXT, -- Why we recommend this name

    -- Status
    status VARCHAR(50) DEFAULT 'proposed',
    -- Possible statuses: 'proposed', 'client_favorite', 'selected', 'rejected'

    is_selected BOOLEAN DEFAULT FALSE,

    -- Timestamps
    sent_to_client_at TIMESTAMP WITH TIME ZONE,
    client_feedback TEXT,
    client_responded_at TIMESTAMP WITH TIME ZONE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_proposals_project_id ON project_proposals(project_id);
CREATE INDEX idx_proposals_status ON project_proposals(status);
CREATE INDEX idx_proposals_is_selected ON project_proposals(is_selected);

-- ============================================================================
-- PROJECT NOTES TABLE
-- Internal notes and communications log
-- ============================================================================
CREATE TABLE project_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES naming_projects(id) ON DELETE CASCADE,

    note_type VARCHAR(50) NOT NULL, -- 'internal', 'client_communication', 'indecopi_update', 'status_change'
    note_text TEXT NOT NULL,

    created_by VARCHAR(255), -- User/system who created the note
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    is_visible_to_client BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_notes_project_id ON project_notes(project_id);
CREATE INDEX idx_notes_created_at ON project_notes(created_at);
CREATE INDEX idx_notes_note_type ON project_notes(note_type);

-- ============================================================================
-- UPDATE EXISTING TABLES
-- ============================================================================

-- Update generated_names to optionally link to projects
ALTER TABLE generated_names
ADD COLUMN project_id UUID REFERENCES naming_projects(id) ON DELETE SET NULL;

CREATE INDEX idx_generated_names_project_id ON generated_names(project_id);

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
CREATE TRIGGER update_characterization_updated_at
    BEFORE UPDATE ON client_characterization
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

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
    -- Get the count of projects created today
    SELECT COUNT(*) + 1 INTO next_number
    FROM naming_projects
    WHERE DATE(created_at) = CURRENT_DATE;

    -- Format: BRA-YYYYMMDD-XXX
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
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE client_characterization IS 'Stores legal and business information from Step 1 of the form';
COMMENT ON TABLE naming_projects IS 'Tracks overall naming and trademark registration projects';
COMMENT ON TABLE briefs IS 'Stores brand brief responses from Step 2';
COMMENT ON TABLE payments IS 'Tracks payment transactions and status';
COMMENT ON TABLE project_proposals IS 'Links generated name proposals to projects';
COMMENT ON TABLE project_notes IS 'Internal notes and communication log for projects';

COMMENT ON COLUMN naming_projects.status IS 'Current status of the project workflow';
COMMENT ON COLUMN naming_projects.current_stage IS 'High-level stage: onboarding, naming, registration, completed';
COMMENT ON COLUMN payments.status IS 'Payment transaction status';

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Sample characterization
INSERT INTO client_characterization (
    razon_social, tipo_persona, documento, email, telefono, nacionalidad,
    direccion, distrito, provincia, departamento,
    etapa_negocio, rubro, lugar_operacion
) VALUES (
    'Test Company SAC', 'juridica', '20123456789', 'test@example.com', '+51987654321', 'Peruana',
    'Av. Principal 123', 'Miraflores', 'Lima', 'Lima',
    'operacion', 'Tecnología', 'Lima, Perú'
) RETURNING id;

-- Note: Additional sample data should reference the returned IDs

-- ============================================================================
-- GRANTS (Adjust based on your user/role setup)
-- ============================================================================

-- Example: GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO brandy_app;
-- Example: GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO brandy_app;
