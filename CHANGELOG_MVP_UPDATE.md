# MVP Update - Complete Overhaul

## Date: 2025-11-03

## Summary

Complete redesign of the landing page and database structure based on stakeholder feedback. The MVP has been simplified to focus on data collection through a multi-step form, with manual backend processing.

---

## Landing Page Changes

### ✅ 1. DNI/RUC Character Validation

**Change:** Dynamic validation based on person type
- **Persona Natural** → DNI field (8 digits)
- **Persona Jurídica** → RUC field (11 digits)
- Label updates automatically
- Real-time validation with error messages

**Implementation:**
- `updateDocumentLabel()` function
- `validateDocumento()` function
- Pattern attributes: `[0-9]{8}` for DNI, `[0-9]{11}` for RUC

---

### ✅ 2. Phone Number Format Validation

**Change:** Strict Peruvian mobile format validation
- Must be exactly 9 digits
- Must start with "9"
- Pattern: `9XXXXXXXX`

**Implementation:**
- `validateTelefono()` function
- Pattern attribute: `9[0-9]{8}`
- Maxlength: 9
- Real-time error messages

---

### ✅ 3. Removed Business Stage Field

**Change:** Removed "Etapa del Negocio" field from Step 1

**Removed field:**
```html
<select name="etapa_negocio">
    <option value="idea">Idea</option>
    <option value="operacion">En Operación</option>
    <option value="expansion">Expansión</option>
</select>
```

**Reason:** Simplified onboarding - not essential for MVP

---

### ✅ 4. Conditional Name Question

**Change:** Added conditional field when user already has a name

**New flow:**
1. User selects "Ya tengo nombre"
2. New field appears: "¿Cuál es el nombre actual?"
3. Suggestion message appears: "Aún así, te recomendamos completar el brief..."

**Implementation:**
- `toggleNameField()` function
- Conditional required attribute
- Hidden/shown with `.hidden` class

---

### ✅ 5. Review Page Before Payment (NEW Step 3)

**Change:** Added comprehensive review page before payment

**Features:**
- **Left Column:** Brief review
  - Client name and document
  - Whether they have a name
  - Product/service, audience, keywords
- **Right Column:** Payment information
  - Package details
  - Payment methods (Tarjeta, Yape/Plin, Transferencia)
  - Terms acceptance
  - Total amount (S/ 950)
- **Process Timeline:** 5-step visual process explanation

**Layout:**
- Two-column grid (`grid-template-columns: 1fr 1fr`)
- Review section on left
- Payment card on right
- Mobile responsive (stacks on small screens)

---

### ✅ 6. Confirmation Page (NEW Step 4)

**Change:** Added final confirmation page after payment

**Features:**
- Success icon (green checkmark)
- Auto-generated case number: `BRA-YYYYMMDD-XXX`
- Contact information:
  - Email: contacto@brandia.pe
  - WhatsApp: +51 999 888 777
- Next steps checklist (4 items)
- Professional design with clear hierarchy

**Implementation:**
- Case number displayed prominently
- Contact info in card layout
- Next steps in ordered list

---

## Form Flow Changes

### OLD Flow (3 steps):
1. Characterization (Datos del Titular)
2. Brief de Marca
3. Confirmation & Payment

### NEW Flow (4 steps):
1. **Characterization (Datos del Titular)**
   - Simplified (removed business stage)
   - Enhanced validation (DNI/RUC, phone)

2. **Brief de Marca**
   - Added conditional name field
   - Suggestion for completing brief

3. **Review & Payment** (NEW)
   - Review all inputs
   - Process transparency
   - Payment options

4. **Confirmation** (NEW)
   - Case number
   - Contact information
   - Next steps

---

## Database Changes

### Complete Schema Replacement

**OLD Database:** 10+ tables
- client_characterization
- naming_projects
- briefs
- payments
- project_proposals
- project_notes
- users
- events
- generated_names
- trademark_checks
- similarity_checks
- cached_searches

**NEW Database:** 3 tables only

#### 1. `client_info`
- **Primary Key:** `id_number` (DNI or RUC)
- **Auto-generates:** `user_id` (UUID)
- Stores Step 1 characterization data
- Data saved when Step 1 form submitted

#### 2. `brief_responses`
- **Foreign Keys:** `user_id`, `id_number`
- Each brief question = 1 column
- Stores Step 2 brief data
- Data saved when Step 2 form submitted

#### 3. `payment_info`
- **Foreign Keys:** `user_id`, `id_number`
- **Auto-generates:** `case_number` (BRA-YYYYMMDD-XXX)
- Stores payment status (`payment_successful` boolean)
- Stores contact information
- Data saved when payment confirmed (Step 3)

### Key Database Features

**Auto-generation:**
- `user_id` → Generated on client_info insert
- `case_number` → Generated on payment_info insert (BRA-20251103-001)

**Foreign Key Cascade:**
- Deleting client → Deletes brief + payment
- Maintains data integrity

**Views:**
- `v_complete_client_data` - Full client journey
- `v_payments_summary` - Daily revenue metrics
- `v_recent_registrations` - Last 50 clients

---

## Migration Instructions

### For New Installations

**PostgreSQL:**
```bash
psql -U user -d brandy_db -f database/schema.sql
```

**MySQL:**
```bash
mysql -u user -p brandy_db < database/schema_mysql.sql
```

### For Existing Databases

⚠️ **WARNING: This deletes ALL existing data!**

**Backup first:**
```bash
# PostgreSQL
pg_dump -U user brandy_db > backup_$(date +%Y%m%d).sql

# MySQL
mysqldump -u user -p brandy_db > backup_$(date +%Y%m%d).sql
```

**Run migration:**
```bash
# PostgreSQL
psql -U user -d brandy_db -f database/migrations/001_initial_schema.sql

# MySQL
mysql -u user -p brandy_db < database/migrations/001_initial_schema_mysql.sql
```

---

## File Changes

### New Files Created

**Landing Page:**
- `landing/index-v3.html` - Updated landing page
- `docs/index.html` - Production version (copy of v3)

**Database:**
- `database/schema.sql` - PostgreSQL schema (3 tables)
- `database/schema_mysql.sql` - MySQL schema (3 tables)
- `database/migrations/001_initial_schema.sql` - PostgreSQL migration (clean rebuild)
- `database/migrations/001_initial_schema_mysql.sql` - MySQL migration (clean rebuild)
- `database/README_NEW_SCHEMA.md` - Comprehensive documentation

**Documentation:**
- `CHANGELOG_MVP_UPDATE.md` - This file

### Modified Files

- `docs/index.html` - Replaced with new version

---

## Technical Details

### JavaScript Functions Added

**Validation:**
- `updateDocumentLabel()` - Updates DNI/RUC label
- `validateDocumento()` - Validates document number
- `validateTelefono()` - Validates phone format

**Form Logic:**
- `toggleNameField()` - Shows/hides name field
- `saveFormData()` - Saves form state
- `populateReview()` - Fills review page
- `processPayment()` - Handles payment confirmation

### CSS Additions

**New Classes:**
- `.review-container` - Two-column review layout
- `.review-section` - Review card styling
- `.review-item` - Individual review field
- `.process-timeline` - Visual timeline
- `.timeline-step` - Timeline item
- `.payment-card` - Payment section
- `.payment-methods` - Payment method grid
- `.confirmation-container` - Confirmation page
- `.success-icon` - Green checkmark
- `.case-number` - Case number display
- `.contact-info` - Contact card
- `.error-message` - Validation errors

---

## Testing Checklist

- [ ] Step 1: DNI validation (8 digits for natural)
- [ ] Step 1: RUC validation (11 digits for juridica)
- [ ] Step 1: Phone validation (9XXXXXXXX format)
- [ ] Step 1: Business stage field removed
- [ ] Step 2: Conditional name field appears
- [ ] Step 2: Suggestion text shows
- [ ] Step 3: Review page shows all data
- [ ] Step 3: Payment methods display
- [ ] Step 3: Terms checkbox required
- [ ] Step 4: Case number generated
- [ ] Step 4: Contact info displays
- [ ] Mobile: All steps responsive
- [ ] Mobile: Review page stacks vertically
- [ ] Database: client_info saves on Step 1
- [ ] Database: brief_responses saves on Step 2
- [ ] Database: payment_info saves on Step 3
- [ ] Database: case_number auto-generates
- [ ] Database: Foreign keys work
- [ ] Database: Views return correct data

---

## Next Steps

1. **Test the landing page:**
   - Go to docs/index.html
   - Test all validations
   - Test full form flow
   - Test on mobile devices

2. **Set up database:**
   - Choose PostgreSQL or MySQL
   - Run new schema script
   - Test data insertion
   - Verify auto-generation works

3. **Backend integration (future):**
   - Create API endpoints to receive form data
   - Integrate payment gateway (Culqi/Niubiz)
   - Set up email notifications
   - Create admin dashboard

4. **Deploy to production:**
   - Push to GitHub
   - Deploy to GitHub Pages
   - Test live site
   - Monitor form submissions

---

## Breaking Changes

⚠️ **This update breaks compatibility with the old system:**

1. **Database structure completely changed**
   - Old tables dropped
   - New 3-table structure
   - Different column names
   - Different relationships

2. **Form flow changed**
   - Added Step 3 (Review)
   - Added Step 4 (Confirmation)
   - Modified Step 1 (removed field)
   - Modified Step 2 (added field)

3. **Data model changed**
   - id_number is now primary key (not user_id)
   - No more project tracking
   - No more proposal system
   - Simplified to form submission only

---

## Support

For questions or issues:
1. Review `database/README_NEW_SCHEMA.md` for database help
2. Check `landing/index-v3.html` for form implementation
3. Test locally before deploying to production
4. Backup data before running migrations

---

**Status:** ✅ Complete
**Version:** 3.0.0
**Date:** 2025-11-03
