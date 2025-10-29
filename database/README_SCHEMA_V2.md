# Database Schema V2 - MVP Multi-Step Form

## Overview

This document describes the updated database schema (V2) designed to support the new multi-step landing page form and MVP business model.

### What's New in V2?

The V2 schema adds comprehensive support for:
- **Client characterization** (legal and business data from Step 1)
- **Project management** (tracking naming and trademark registration workflow)
- **Brief responses** (simplified 9-question brand brief from Step 2)
- **Payment processing** (Step 3 payment tracking)
- **Proposal management** (generated name proposals for clients)
- **Project notes** (internal communication and status updates)

---

## Table Structure

### 1. `client_characterization`

Stores legal and business information collected in **Step 1** of the multi-step form.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID/CHAR(36) | Primary key |
| `razon_social` | VARCHAR(255) | Business or personal legal name |
| `tipo_persona` | ENUM | 'natural' or 'juridica' (individual or company) |
| `documento` | VARCHAR(50) | DNI or RUC (tax ID) |
| `representante_legal` | VARCHAR(255) | Legal representative (for companies) |
| `email` | VARCHAR(255) | Contact email |
| `telefono` | VARCHAR(50) | Phone/WhatsApp number |
| `nacionalidad` | VARCHAR(100) | Nationality (default: 'Peruana') |
| `direccion` | TEXT | Full street address |
| `distrito` | VARCHAR(100) | District |
| `provincia` | VARCHAR(100) | Province |
| `departamento` | VARCHAR(100) | Department/State |
| `etapa_negocio` | ENUM | Business stage: 'idea', 'operacion', 'expansion' |
| `rubro` | VARCHAR(255) | Industry/sector |
| `lugar_operacion` | TEXT | Where the business operates |
| `created_at` | TIMESTAMP | When record was created |
| `updated_at` | TIMESTAMP | Last update |
| `metadata` | JSON/JSONB | Additional custom data |

**Indexes:**
- `email`, `documento`, `created_at`

---

### 2. `naming_projects`

Central table tracking the overall naming and trademark registration project lifecycle.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID/CHAR(36) | Primary key |
| `characterization_id` | UUID/CHAR(36) | Foreign key → `client_characterization` |
| `project_code` | VARCHAR(50) | Unique project code (e.g., "BRA-20251029-001") |
| `package_type` | VARCHAR(50) | Package selected (default: 'START') |
| `package_price` | DECIMAL(10,2) | Package price (default: 950.00) |
| `status` | VARCHAR(50) | Current project status |
| `current_stage` | VARCHAR(50) | High-level stage |
| `brief_completed_at` | TIMESTAMP | When brief was completed |
| `payment_completed_at` | TIMESTAMP | When payment was completed |
| `naming_started_at` | TIMESTAMP | When naming work began |
| `proposals_sent_at` | TIMESTAMP | When proposals were sent to client |
| `client_selected_at` | TIMESTAMP | When client selected a name |
| `indecopi_submitted_at` | TIMESTAMP | When submitted to INDECOPI |
| `registered_at` | TIMESTAMP | When registration was completed |
| `selected_name` | VARCHAR(100) | The name client selected |
| `selected_proposal_id` | UUID | Reference to selected proposal |
| `indecopi_expediente` | VARCHAR(100) | INDECOPI case number |
| `indecopi_clase` | INTEGER | NICE classification (1-45) |
| `indecopi_certificado` | VARCHAR(100) | Certificate number |
| `created_at` | TIMESTAMP | Project creation date |
| `updated_at` | TIMESTAMP | Last update |
| `notes` | TEXT | Additional notes |
| `metadata` | JSON/JSONB | Custom data |

**Project Statuses:**
- `brief_pending` - Waiting for brief completion
- `brief_completed` - Brief completed, awaiting payment
- `payment_pending` - Payment initiated
- `payment_completed` - Payment confirmed
- `naming_in_progress` - Team creating name proposals
- `proposals_sent` - Proposals sent to client
- `client_selected` - Client selected a name
- `indecopi_submitted` - Submitted to INDECOPI
- `indecopi_in_review` - Under INDECOPI review
- `registered` - Successfully registered
- `rejected` - Registration rejected
- `cancelled` - Project cancelled

**Stages:**
- `onboarding` - Initial data collection
- `naming` - Name creation phase
- `registration` - INDECOPI registration phase
- `completed` - Project complete

**Indexes:**
- `characterization_id`, `status`, `project_code`, `created_at`

---

### 3. `briefs`

Stores brand brief responses from **Step 2** of the form.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID/CHAR(36) | Primary key |
| `project_id` | UUID/CHAR(36) | Foreign key → `naming_projects` |
| `tiene_nombre` | BOOLEAN | Already has a name? |
| `producto_servicio` | TEXT | Product/service description |
| `publico_objetivo` | TEXT | Target audience |
| `valores` | TEXT | Brand values/ideas to convey |
| `palabra_1` | VARCHAR(100) | First defining word |
| `palabra_2` | VARCHAR(100) | Second defining word |
| `palabra_3` | VARCHAR(100) | Third defining word |
| `idea_nombre` | VARCHAR(255) | Optional name idea from client |
| `tiene_logo` | BOOLEAN | Already has a logo? |
| `donde_vende` | TEXT | Where they sell |
| `idioma_preferencia` | VARCHAR(50) | Language preference: 'espanol', 'ingles', 'neutro', 'indiferente' |
| `completed_at` | TIMESTAMP | When brief was completed |
| `time_spent_seconds` | INTEGER | Time spent filling out brief |
| `metadata` | JSON/JSONB | Additional data |

**Indexes:**
- `project_id`, `completed_at`

---

### 4. `payments`

Tracks payment transactions and status for **Step 3**.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID/CHAR(36) | Primary key |
| `project_id` | UUID/CHAR(36) | Foreign key → `naming_projects` |
| `amount` | DECIMAL(10,2) | Payment amount |
| `currency` | VARCHAR(3) | Currency code (default: 'PEN') |
| `payment_method` | VARCHAR(50) | Payment method: 'culqi', 'niubiz', 'stripe', 'bank_transfer' |
| `status` | VARCHAR(50) | Payment status |
| `gateway_transaction_id` | VARCHAR(255) | External transaction ID |
| `gateway_response` | JSON/JSONB | Raw gateway response |
| `payer_email` | VARCHAR(255) | Payer's email |
| `payer_name` | VARCHAR(255) | Payer's name |
| `created_at` | TIMESTAMP | Payment initiated |
| `paid_at` | TIMESTAMP | Payment completed |
| `refunded_at` | TIMESTAMP | If refunded |
| `ip_address` | INET/VARCHAR(45) | Client IP address |
| `user_agent` | TEXT | Client browser |
| `notes` | TEXT | Additional notes |
| `metadata` | JSON/JSONB | Custom data |

**Payment Statuses:**
- `pending` - Payment initiated
- `processing` - Being processed
- `completed` - Successfully paid
- `failed` - Payment failed
- `refunded` - Payment refunded
- `cancelled` - Payment cancelled

**Indexes:**
- `project_id`, `status`, `created_at`, `gateway_transaction_id`

---

### 5. `project_proposals`

Links generated brand name proposals to projects.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID/CHAR(36) | Primary key |
| `project_id` | UUID/CHAR(36) | Foreign key → `naming_projects` |
| `generated_name_id` | UUID/CHAR(36) | Foreign key → `generated_names` |
| `name` | VARCHAR(100) | Proposed name |
| `proposal_order` | INTEGER | Order (1st, 2nd, 3rd) |
| `rationale` | TEXT | Why we recommend this name |
| `status` | VARCHAR(50) | Proposal status |
| `is_selected` | BOOLEAN | Was this selected? |
| `sent_to_client_at` | TIMESTAMP | When sent to client |
| `client_feedback` | TEXT | Client's feedback |
| `client_responded_at` | TIMESTAMP | When client responded |
| `created_at` | TIMESTAMP | Created |
| `metadata` | JSON/JSONB | Custom data |

**Proposal Statuses:**
- `proposed` - Sent to client
- `client_favorite` - Client marked as favorite
- `selected` - Client selected this one
- `rejected` - Client rejected

**Indexes:**
- `project_id`, `status`, `is_selected`

---

### 6. `project_notes`

Internal notes and communication log for project management.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID/CHAR(36) | Primary key |
| `project_id` | UUID/CHAR(36) | Foreign key → `naming_projects` |
| `note_type` | VARCHAR(50) | Note type |
| `note_text` | TEXT | Note content |
| `created_by` | VARCHAR(255) | User/system who created note |
| `created_at` | TIMESTAMP | Created |
| `is_visible_to_client` | BOOLEAN | Should client see this? |
| `metadata` | JSON/JSONB | Custom data |

**Note Types:**
- `internal` - Internal team notes
- `client_communication` - Communication with client
- `indecopi_update` - INDECOPI status update
- `status_change` - Project status change
- `payment_update` - Payment-related note

**Indexes:**
- `project_id`, `created_at`, `note_type`

---

### 7. Updated: `generated_names`

Existing table with new column added:

| New Column | Type | Description |
|------------|------|-------------|
| `project_id` | UUID/CHAR(36) | Foreign key → `naming_projects` |

This links generated names to specific projects.

---

## Database Views

### `v_projects_complete`

Complete overview of all projects with joined data from:
- Client characterization
- Brief responses
- Payment status
- Selected name
- INDECOPI information

**Columns:** `project_id`, `project_code`, `status`, `current_stage`, `razon_social`, `email`, `telefono`, `producto_servicio`, `selected_name`, `payment_status`, `indecopi_expediente`, etc.

**Usage:**
```sql
SELECT * FROM v_projects_complete WHERE status = 'naming_in_progress';
```

---

### `v_projects_active`

Shows active projects requiring attention with action items.

**Columns:** `project_code`, `status`, `razon_social`, `email`, `days_since_creation`, `action_required`

**Usage:**
```sql
SELECT * FROM v_projects_active ORDER BY days_since_creation DESC;
```

---

### `v_payment_summary`

Daily payment summary with revenue metrics.

**Columns:** `payment_date`, `total_payments`, `completed_payments`, `pending_payments`, `failed_payments`, `revenue`, `avg_transaction`

**Usage:**
```sql
SELECT * FROM v_payment_summary WHERE payment_date >= CURRENT_DATE - INTERVAL '30 days';
```

---

### `v_acquisition_funnel`

Conversion funnel metrics showing drop-off rates.

**Columns:** `total_characterizations`, `completed_briefs`, `paid_clients`, `registered_clients`, `brief_completion_rate`, `payment_conversion_rate`, `registration_success_rate`

**Usage:**
```sql
SELECT * FROM v_acquisition_funnel;
```

---

## Helper Functions & Triggers

### PostgreSQL

**`generate_project_code()`**
- Auto-generates unique project codes
- Format: `BRA-YYYYMMDD-XXX`
- Example: `BRA-20251029-001`

**`auto_generate_project_code` trigger**
- Automatically assigns project code on insert

**`update_updated_at_column()` trigger**
- Auto-updates `updated_at` timestamp on row changes

### MySQL

**`generate_project_code()` stored procedure**
- Same functionality as PostgreSQL version

**`auto_generate_project_code` trigger**
- Same functionality as PostgreSQL version

---

## Relationships

```
client_characterization
    ↓ (1:many)
naming_projects
    ↓ (1:1)
briefs

naming_projects
    ↓ (1:many)
payments

naming_projects
    ↓ (1:many)
project_proposals
    ↓ (many:1)
generated_names

naming_projects
    ↓ (1:many)
project_notes
```

---

## Migration Guide

### For New Installations

Use the V2 schema directly:

**PostgreSQL:**
```bash
psql -U your_user -d brandy_db -f database/schema_v2.sql
```

**MySQL:**
```bash
mysql -u your_user -p brandy_db < database/schema_v2_mysql.sql
```

### For Existing Databases (V1 → V2)

Run the migration script:

**PostgreSQL:**
```bash
psql -U your_user -d brandy_db -f database/migrations/001_v1_to_v2_migration.sql
```

**MySQL:**
```bash
mysql -u your_user -p brandy_db < database/migrations/001_v1_to_v2_migration_mysql.sql
```

The migration is **non-destructive** - it only adds new tables and doesn't modify existing ones (except adding `project_id` to `generated_names`).

---

## Example Queries

### Create a new project from form submission

```sql
-- Step 1: Insert characterization
INSERT INTO client_characterization (
    razon_social, tipo_persona, documento, email, telefono,
    direccion, distrito, provincia, departamento,
    etapa_negocio, rubro, lugar_operacion
) VALUES (
    'Mi Empresa SAC', 'juridica', '20123456789', 'contact@miempresa.com', '+51987654321',
    'Av. Lima 123', 'Miraflores', 'Lima', 'Lima',
    'operacion', 'Tecnología', 'Lima, Perú'
) RETURNING id;

-- Step 2: Create project (auto-generates project_code)
INSERT INTO naming_projects (characterization_id, status)
VALUES ('characterization-uuid-here', 'brief_pending')
RETURNING id, project_code;

-- Step 3: Insert brief
INSERT INTO briefs (
    project_id, tiene_nombre, producto_servicio, publico_objetivo, valores,
    palabra_1, palabra_2, palabra_3, tiene_logo, donde_vende, idioma_preferencia
) VALUES (
    'project-uuid-here', false, 'Software de gestión', 'Pequeñas empresas', 'Innovación y eficiencia',
    'Rápido', 'Confiable', 'Moderno', false, 'Lima, Perú', 'espanol'
);

-- Step 4: Create payment
INSERT INTO payments (project_id, amount, status)
VALUES ('project-uuid-here', 950.00, 'pending');
```

### Update project status

```sql
UPDATE naming_projects
SET status = 'naming_in_progress',
    naming_started_at = CURRENT_TIMESTAMP
WHERE project_code = 'BRA-20251029-001';
```

### Get all active projects

```sql
SELECT * FROM v_projects_active;
```

### Check conversion funnel

```sql
SELECT * FROM v_acquisition_funnel;
```

---

## Best Practices

1. **Always create projects through characterization first**
   - Don't create orphan projects without client data

2. **Use project_code for client-facing references**
   - Never expose internal UUIDs to clients

3. **Track all status changes in project_notes**
   ```sql
   INSERT INTO project_notes (project_id, note_type, note_text, created_by)
   VALUES ('project-uuid', 'status_change', 'Changed to naming_in_progress', 'system');
   ```

4. **Use metadata columns for flexible data**
   - Store custom fields that don't need indexing in metadata JSON

5. **Monitor v_projects_active daily**
   - Identify stalled projects needing follow-up

6. **Track conversion metrics with v_acquisition_funnel**
   - Optimize drop-off points in the funnel

---

## Next Steps

1. **Create Python ORM models** (SQLAlchemy/Django) matching this schema
2. **Build REST API endpoints** for form submission
3. **Integrate payment gateway** (Culqi/Niubiz/Stripe)
4. **Set up email automation** for status updates
5. **Create admin dashboard** using these views

---

## Files

- `database/schema_v2.sql` - PostgreSQL full schema
- `database/schema_v2_mysql.sql` - MySQL full schema
- `database/migrations/001_v1_to_v2_migration.sql` - PostgreSQL migration
- `database/migrations/001_v1_to_v2_migration_mysql.sql` - MySQL migration
- `database/README_SCHEMA_V2.md` - This documentation

---

## Support

For questions or issues with the database schema:
1. Review this documentation
2. Check the inline SQL comments in the schema files
3. Test queries against the views before writing custom queries
4. Use the migration scripts for upgrading existing databases
