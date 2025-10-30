# Database Tables Analysis - What to Keep vs Drop

## Current Situation

Your **current schema.sql** only includes the 6 new MVP tables:
- ✅ `client_characterization`
- ✅ `naming_projects`
- ✅ `briefs`
- ✅ `payments`
- ✅ `project_proposals`
- ✅ `project_notes`

**However**, if you ran the **V1 schema** previously, you may still have these **old tables** in your database:
- ❌ `users`
- ❌ `events`
- ❌ `form_submissions`
- ❌ `form_answers`
- ⚠️ `generated_names`
- ⚠️ `trademark_checks`
- ⚠️ `similarity_checks`
- ⚠️ `cached_searches`

---

## Tables to DROP (Redundant for MVP)

### 1. `users` ❌ DROP
**Why:** Completely replaced by `client_characterization`
- Old `users` table was generic (email, full_name, company_name)
- New `client_characterization` has specific fields (razon_social, documento, tipo_persona, etc.)
- Much better for your Peruvian legal requirements

### 2. `events` ❌ DROP
**Why:** Too generic for MVP, overkill
- Tracks "all user interactions and system events"
- Your MVP is manual backend - you don't need granular event tracking
- Can add back later if you automate

### 3. `form_submissions` ❌ DROP
**Why:** Replaced by `briefs` table
- Old: Generic "form_submissions" + "form_answers" (key-value pairs)
- New: Structured `briefs` table with specific columns
- Better data integrity and easier to query

### 4. `form_answers` ❌ DROP
**Why:** Replaced by `briefs` table
- Stored individual field answers in normalized format
- Now you have `briefs` with actual columns (producto_servicio, publico_objetivo, etc.)
- Much cleaner architecture

---

## Tables to KEEP (Useful for Backend)

### 1. `generated_names` ✅ KEEP
**Why:** Your naming engine uses this
- Stores brand names with probability scores
- Used by `brandy/name_generator.py`
- Links to `project_proposals` via `generated_name_id`

### 2. `trademark_checks` ✅ KEEP
**Why:** INDECOPI validation tracking
- Stores trademark check history
- Used by `brandy/indecopi_scraper.py`
- Important for verifying name availability

### 3. `similarity_checks` ✅ KEEP
**Why:** Name analysis
- Stores phonetic/spelling similarity results
- Used by `brandy/similarity_analyzer.py`
- Helps avoid conflicts

### 4. `cached_searches` ✅ KEEP
**Why:** Performance optimization
- Caches INDECOPI search results (7-day expiry)
- Reduces load on INDECOPI website
- Improves speed

---

## Recommended Action

### Option 1: Clean Database (Recommended for MVP)

Drop the 4 redundant tables:

**PostgreSQL:**
```sql
-- Check if tables exist first
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('users', 'events', 'form_submissions', 'form_answers');

-- Drop redundant tables
DROP TABLE IF EXISTS form_answers CASCADE;
DROP TABLE IF EXISTS form_submissions CASCADE;
DROP TABLE IF EXISTS events CASCADE;
DROP TABLE IF EXISTS users CASCADE;
```

**MySQL:**
```sql
-- Check if tables exist first
SHOW TABLES LIKE 'users';
SHOW TABLES LIKE 'events';
SHOW TABLES LIKE 'form_submissions';
SHOW TABLES LIKE 'form_answers';

-- Drop redundant tables
DROP TABLE IF EXISTS form_answers;
DROP TABLE IF EXISTS form_submissions;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS users;
```

### Option 2: Keep Everything (If Uncertain)

If you're not sure, keep all tables for now. The redundant tables won't hurt anything, they'll just be unused.

---

## Final Recommended Database Structure

```
CORE MVP TABLES (from landing page):
✅ client_characterization  (Step 1: Legal/business data)
✅ naming_projects          (Project lifecycle tracking)
✅ briefs                   (Step 2: Brand brief)
✅ payments                 (Step 3: Payment processing)
✅ project_proposals        (3 name proposals per project)
✅ project_notes            (Internal communication)

BACKEND PROCESSING TABLES (from naming engine):
✅ generated_names          (All generated brand names)
✅ trademark_checks         (INDECOPI validation)
✅ similarity_checks        (Phonetic/spelling analysis)
✅ cached_searches          (INDECOPI search cache)

REMOVED:
❌ users                    (replaced by client_characterization)
❌ events                   (too generic for MVP)
❌ form_submissions         (replaced by briefs)
❌ form_answers             (replaced by briefs)
```

---

## Migration Script to Clean Up

I can create a migration script that safely drops the old tables. Would you like me to create that?

The script would:
1. Check if old tables exist
2. Check if they have any data (warn you)
3. Drop them safely with CASCADE
4. Verify cleanup

---

## Summary

**DROP these 4 tables:** users, events, form_submissions, form_answers
**KEEP these 4 tables:** generated_names, trademark_checks, similarity_checks, cached_searches

This gives you a clean MVP database focused on your multi-step form workflow while keeping the backend naming engine functionality.
