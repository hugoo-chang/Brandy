# Brandy Database - Simplified MVP Schema

## Overview

This is a **completely new database structure** that replaces the previous 10-table schema with a **simple 3-table design** focused solely on the landing page workflow.

## What Changed?

### OLD Schema (Dropped)
The previous database had 10+ tables including:
- `client_characterization`
- `naming_projects`
- `briefs`
- `payments`
- `project_proposals`
- `project_notes`
- `users`
- `events`
- `generated_names`
- `trademark_checks`
- `similarity_checks`
- `cached_searches`

### NEW Schema (Current)
Now we have **only 3 tables**:
1. `client_info` - Step 1 data
2. `brief_responses` - Step 2 data
3. `payment_info` - Step 3-4 data

---

## Table Structures

### 1. `client_info`

Stores client characterization information from **Step 1** of the landing page.

**Primary Key:** `id_number` (DNI or RUC)
**Auto-generated:** `user_id` (UUID)

| Column | Type | Description |
|--------|------|-------------|
| `id_number` | VARCHAR(11) | **PK** - DNI (8) or RUC (11) |
| `user_id` | UUID | Auto-generated unique ID |
| `razon_social` | VARCHAR(255) | Legal name |
| `tipo_persona` | ENUM | 'natural' or 'juridica' |
| `representante_legal` | VARCHAR(255) | Legal rep (if juridica) |
| `email` | VARCHAR(255) | Contact email |
| `telefono` | VARCHAR(9) | Phone (9XXXXXXXX) |
| `nacionalidad` | VARCHAR(100) | Nationality (default: Peruana) |
| `direccion` | TEXT | Full address |
| `distrito` | VARCHAR(100) | District |
| `provincia` | VARCHAR(100) | Province |
| `departamento` | VARCHAR(100) | Department |
| `rubro` | VARCHAR(255) | Industry |
| `lugar_operacion` | TEXT | Where they operate |
| `created_at` | TIMESTAMP | Registration time |
| `updated_at` | TIMESTAMP | Last update |

**When data is saved:** When user submits Step 1 form

---

### 2. `brief_responses`

Stores brand brief responses from **Step 2** of the landing page.

**Primary Key:** `id` (UUID)
**Foreign Keys:** `user_id`, `id_number`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | **FK** → client_info.user_id |
| `id_number` | VARCHAR(11) | **FK** → client_info.id_number |
| `tiene_nombre` | BOOLEAN | Already has a name? |
| `nombre_actual` | VARCHAR(255) | Current name (if tiene_nombre=true) |
| `producto_servicio` | TEXT | Product/service description |
| `publico_objetivo` | TEXT | Target audience |
| `valores` | TEXT | Brand values |
| `palabra_1` | VARCHAR(100) | Defining word 1 |
| `palabra_2` | VARCHAR(100) | Defining word 2 |
| `palabra_3` | VARCHAR(100) | Defining word 3 |
| `idea_nombre` | VARCHAR(255) | Optional name idea |
| `tiene_logo` | BOOLEAN | Has logo? |
| `donde_vende` | TEXT | Where they sell |
| `idioma_preferencia` | ENUM | Language preference |
| `submitted_at` | TIMESTAMP | When brief was submitted |

**When data is saved:** When user submits Step 2 form

---

### 3. `payment_info`

Stores payment and confirmation information from **Step 3-4** of the landing page.

**Primary Key:** `id` (UUID)
**Foreign Keys:** `user_id`, `id_number`
**Auto-generated:** `case_number`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | **FK** → client_info.user_id |
| `id_number` | VARCHAR(11) | **FK** → client_info.id_number |
| `case_number` | VARCHAR(50) | **Auto-gen** case # (BRA-YYYYMMDD-XXX) |
| `amount` | DECIMAL(10,2) | Payment amount (default: 950.00) |
| `currency` | VARCHAR(3) | Currency (default: PEN) |
| `payment_method` | VARCHAR(50) | Payment method used |
| `payment_successful` | BOOLEAN | **TRUE** if paid, **FALSE** if pending |
| `payment_date` | TIMESTAMP | When payment completed |
| `payment_reference` | VARCHAR(255) | External gateway reference |
| `contact_email` | VARCHAR(255) | BrandiA contact email |
| `contact_phone` | VARCHAR(20) | BrandiA contact phone |
| `contact_whatsapp` | VARCHAR(20) | BrandiA WhatsApp |
| `terms_accepted` | BOOLEAN | Terms accepted? |
| `ip_address` | INET | Client IP |
| `user_agent` | TEXT | Browser info |
| `created_at` | TIMESTAMP | Record creation |
| `updated_at` | TIMESTAMP | Last update |

**When data is saved:** When user confirms payment on Step 3

---

## Database Views

### `v_complete_client_data`

Complete view joining all 3 tables - shows full client journey.

```sql
SELECT * FROM v_complete_client_data WHERE payment_successful = TRUE;
```

### `v_payments_summary`

Daily payment summary with revenue metrics.

```sql
SELECT * FROM v_payments_summary ORDER BY payment_date DESC;
```

### `v_recent_registrations`

Last 50 registrations.

```sql
SELECT * FROM v_recent_registrations;
```

---

## Setup Instructions

### NEW Installation

If this is a **new database**, use the new schema directly:

**PostgreSQL:**
```bash
psql -U your_user -d brandy_db -f database/schema.sql
```

**MySQL:**
```bash
mysql -u your_user -p brandy_db < database/schema_mysql.sql
```

### MIGRATION from Old Schema

If you have an **existing database** with the old schema:

⚠️ **WARNING:** This will DELETE ALL existing data!

**PostgreSQL:**
```bash
psql -U your_user -d brandy_db -f database/migrations/001_initial_schema.sql
```

**MySQL:**
```bash
mysql -u your_user -p brandy_db < database/migrations/001_initial_schema_mysql.sql
```

---

## Data Flow

```
USER SUBMITS STEP 1
   ↓
client_info table
(auto-generates user_id)
   ↓
USER SUBMITS STEP 2
   ↓
brief_responses table
(references user_id, id_number)
   ↓
USER CONFIRMS PAYMENT (STEP 3)
   ↓
payment_info table
(auto-generates case_number)
   ↓
CONFIRMATION PAGE (STEP 4)
(shows case_number, contact info)
```

---

## Key Features

### Auto-Generated Fields

**`user_id`** - Auto-generated when creating client_info record
**`case_number`** - Auto-generated when creating payment_info record
Format: `BRA-20251103-001` (BRA-YYYYMMDD-sequential)

### Foreign Key Relationships

```
client_info (id_number, user_id)
    ↓
brief_responses (user_id, id_number)
    ↓
payment_info (user_id, id_number)
```

All related records are deleted if client is deleted (CASCADE).

### Payment Status Tracking

`payment_successful` boolean:
- `FALSE` = Payment pending or failed
- `TRUE` = Payment confirmed

---

## Example Queries

### Insert New Client (Step 1 submission)

```sql
INSERT INTO client_info (
    id_number, razon_social, tipo_persona, email, telefono,
    direccion, distrito, provincia, departamento,
    rubro, lugar_operacion
) VALUES (
    '12345678', 'Juan Pérez', 'natural', 'juan@example.com', '987654321',
    'Av. Test 123', 'Miraflores', 'Lima', 'Lima',
    'Tecnología', 'Lima, Perú'
) RETURNING user_id;
```

### Insert Brief (Step 2 submission)

```sql
INSERT INTO brief_responses (
    user_id, id_number,
    tiene_nombre, producto_servicio, publico_objetivo, valores,
    palabra_1, palabra_2, palabra_3,
    tiene_logo, donde_vende, idioma_preferencia
) VALUES (
    'uuid-from-step-1', '12345678',
    false, 'Software', 'Empresas', 'Innovación',
    'Rápido', 'Confiable', 'Moderno',
    false, 'Lima, Perú', 'espanol'
);
```

### Insert Payment (Step 3 confirmation)

```sql
INSERT INTO payment_info (
    user_id, id_number,
    amount, payment_method, payment_successful, terms_accepted
) VALUES (
    'uuid-from-step-1', '12345678',
    950.00, 'tarjeta', true, true
) RETURNING case_number;
-- Returns: BRA-20251103-001
```

### Get Complete Client Data

```sql
SELECT * FROM v_complete_client_data
WHERE id_number = '12345678';
```

### Get Payment Statistics

```sql
SELECT
    COUNT(*) as total_registrations,
    SUM(CASE WHEN payment_successful THEN 1 ELSE 0 END) as paid,
    SUM(CASE WHEN NOT payment_successful THEN 1 ELSE 0 END) as pending,
    SUM(CASE WHEN payment_successful THEN amount ELSE 0 END) as revenue
FROM payment_info;
```

---

## Files

- `database/schema_new.sql` - PostgreSQL schema
- `database/schema_new_mysql.sql` - MySQL schema
- `database/migrations/003_complete_database_rebuild.sql` - PostgreSQL migration
- `database/migrations/003_complete_database_rebuild_mysql.sql` - MySQL migration
- `database/README_NEW_SCHEMA.md` - This documentation

---

## Differences from Old Schema

| Aspect | OLD | NEW |
|--------|-----|-----|
| **Tables** | 10+ tables | 3 tables |
| **Complexity** | High (projects, proposals, notes) | Low (just form data) |
| **Primary Keys** | UUIDs everywhere | id_number + user_id |
| **Focus** | Full project management | Landing page workflow only |
| **Backend** | Automated naming engine | Manual process |
| **Purpose** | Complete workflow | Data collection MVP |

---

## Migration Notes

The migration script `003_complete_database_rebuild.sql` will:

1. ✅ Drop ALL existing views
2. ✅ Drop ALL existing tables (including data!)
3. ✅ Drop ALL existing functions/procedures
4. ✅ Create new 3-table structure
5. ✅ Create auto-generation triggers
6. ✅ Create new views
7. ✅ Add comments and documentation

**Make sure to backup your data before running the migration!**

---

## Support

For database setup questions:
1. Review this documentation
2. Check the SQL schema files for inline comments
3. Test queries against views before writing custom queries
4. Use the migration script only after backing up data
