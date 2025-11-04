# Connecting Brandy Database to Google Sheets and Excel

This guide explains how to connect your Brandy PostgreSQL or MySQL database to Google Sheets and Excel for live data access and analysis.

## Table of Contents
1. [Google Sheets Connection](#google-sheets-connection)
2. [Excel Connection](#excel-connection)
3. [Useful Queries](#useful-queries)
4. [Security Best Practices](#security-best-practices)

---

## Google Sheets Connection

### Option 1: Using Google Apps Script (Recommended for PostgreSQL/MySQL)

#### Prerequisites
- Google account with access to Google Sheets
- Database credentials (host, port, database name, username, password)
- Database must be accessible from the internet (or use Cloud SQL Proxy)

#### Setup Steps

1. **Create a new Google Sheet**
   - Go to [Google Sheets](https://sheets.google.com)
   - Create a new blank spreadsheet

2. **Open Apps Script Editor**
   - Click on `Extensions` → `Apps Script`

3. **Add Database Connection Script**

```javascript
// Database Configuration
const DB_CONFIG = {
  host: 'YOUR_DATABASE_HOST',
  port: '5432', // 5432 for PostgreSQL, 3306 for MySQL
  database: 'brandy_db',
  username: 'YOUR_USERNAME',
  password: 'YOUR_PASSWORD'
};

/**
 * Fetches client information from the database
 * This function can be called from your Google Sheet
 */
function fetchClientInfo() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Client Info');

  // Clear existing data (keep headers)
  if (sheet.getLastRow() > 1) {
    sheet.getRange(2, 1, sheet.getLastRow() - 1, sheet.getLastColumn()).clearContent();
  }

  // Set headers if not present
  if (sheet.getLastRow() === 0) {
    sheet.appendRow([
      'ID Number', 'User ID', 'Razón Social', 'Tipo Persona',
      'Email', 'Teléfono', 'Departamento', 'Provincia', 'Distrito',
      'Dirección', 'Actividad', 'Tiene Nombre', 'Created At'
    ]);
  }

  // Fetch data using JDBC
  const conn = Jdbc.getConnection(
    `jdbc:postgresql://${DB_CONFIG.host}:${DB_CONFIG.port}/${DB_CONFIG.database}`,
    DB_CONFIG.username,
    DB_CONFIG.password
  );

  const stmt = conn.createStatement();
  const results = stmt.executeQuery('SELECT * FROM client_info ORDER BY created_at DESC');

  // Process results
  while (results.next()) {
    sheet.appendRow([
      results.getString('id_number'),
      results.getString('user_id'),
      results.getString('razon_social'),
      results.getString('tipo_persona'),
      results.getString('email'),
      results.getString('telefono'),
      results.getString('departamento'),
      results.getString('provincia'),
      results.getString('distrito'),
      results.getString('direccion'),
      results.getString('actividad_economica'),
      results.getBoolean('tiene_nombre') ? 'Sí' : 'No',
      results.getTimestamp('created_at')
    ]);
  }

  results.close();
  stmt.close();
  conn.close();

  SpreadsheetApp.getActiveSpreadsheet().toast('Data refreshed successfully!', 'Success', 3);
}

/**
 * Fetches brief responses from the database
 */
function fetchBriefResponses() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Brief Responses');

  // Clear existing data
  if (sheet.getLastRow() > 1) {
    sheet.getRange(2, 1, sheet.getLastRow() - 1, sheet.getLastColumn()).clearContent();
  }

  // Set headers
  if (sheet.getLastRow() === 0) {
    sheet.appendRow([
      'User ID', 'ID Number', 'Tiene Nombre', 'Nombre Actual',
      'Palabra 1', 'Palabra 2', 'Palabra 3', 'Valores',
      'Público Objetivo', 'Personalidad', 'Mensaje', 'Evitar',
      'Idioma', 'Origen', 'Restricciones', 'Created At'
    ]);
  }

  const conn = Jdbc.getConnection(
    `jdbc:postgresql://${DB_CONFIG.host}:${DB_CONFIG.port}/${DB_CONFIG.database}`,
    DB_CONFIG.username,
    DB_CONFIG.password
  );

  const stmt = conn.createStatement();
  const results = stmt.executeQuery('SELECT * FROM brief_responses ORDER BY created_at DESC');

  while (results.next()) {
    sheet.appendRow([
      results.getString('user_id'),
      results.getString('id_number'),
      results.getBoolean('tiene_nombre') ? 'Sí' : 'No',
      results.getString('nombre_actual') || '',
      results.getString('palabra_1') || '',
      results.getString('palabra_2') || '',
      results.getString('palabra_3') || '',
      results.getString('valores') || '',
      results.getString('publico_objetivo') || '',
      results.getString('personalidad') || '',
      results.getString('mensaje') || '',
      results.getString('evitar') || '',
      results.getString('idioma') || '',
      results.getString('origen') || '',
      results.getString('restricciones') || '',
      results.getTimestamp('created_at')
    ]);
  }

  results.close();
  stmt.close();
  conn.close();

  SpreadsheetApp.getActiveSpreadsheet().toast('Brief data refreshed successfully!', 'Success', 3);
}

/**
 * Fetches payment information from the database
 */
function fetchPaymentInfo() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Payment Info');

  // Clear existing data
  if (sheet.getLastRow() > 1) {
    sheet.getRange(2, 1, sheet.getLastRow() - 1, sheet.getLastColumn()).clearContent();
  }

  // Set headers
  if (sheet.getLastRow() === 0) {
    sheet.appendRow([
      'Case Number', 'User ID', 'ID Number', 'Payment Successful',
      'Amount', 'Payment Method', 'Transaction ID', 'Created At'
    ]);
  }

  const conn = Jdbc.getConnection(
    `jdbc:postgresql://${DB_CONFIG.host}:${DB_CONFIG.port}/${DB_CONFIG.database}`,
    DB_CONFIG.username,
    DB_CONFIG.password
  );

  const stmt = conn.createStatement();
  const results = stmt.executeQuery('SELECT * FROM payment_info ORDER BY created_at DESC');

  while (results.next()) {
    sheet.appendRow([
      results.getString('case_number'),
      results.getString('user_id'),
      results.getString('id_number'),
      results.getBoolean('payment_successful') ? 'Sí' : 'No',
      results.getDouble('payment_amount') || 0,
      results.getString('payment_method') || '',
      results.getString('transaction_id') || '',
      results.getTimestamp('created_at')
    ]);
  }

  results.close();
  stmt.close();
  conn.close();

  SpreadsheetApp.getActiveSpreadsheet().toast('Payment data refreshed successfully!', 'Success', 3);
}

/**
 * Fetches complete client view (joins all tables)
 */
function fetchCompleteClientData() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Complete Data');

  // Clear existing data
  if (sheet.getLastRow() > 1) {
    sheet.getRange(2, 1, sheet.getLastRow() - 1, sheet.getLastColumn()).clearContent();
  }

  // Set headers
  if (sheet.getLastRow() === 0) {
    sheet.appendRow([
      'Case Number', 'ID Number', 'Razón Social', 'Email', 'Teléfono',
      'Tipo Persona', 'Actividad', 'Brief Completado', 'Payment Status',
      'Payment Amount', 'Created At'
    ]);
  }

  const conn = Jdbc.getConnection(
    `jdbc:postgresql://${DB_CONFIG.host}:${DB_CONFIG.port}/${DB_CONFIG.database}`,
    DB_CONFIG.username,
    DB_CONFIG.password
  );

  const stmt = conn.createStatement();
  const query = `
    SELECT
      c.id_number,
      c.razon_social,
      c.email,
      c.telefono,
      c.tipo_persona,
      c.actividad_economica,
      CASE WHEN b.id IS NOT NULL THEN 'Sí' ELSE 'No' END as brief_completed,
      COALESCE(p.case_number, 'Pending') as case_number,
      CASE WHEN p.payment_successful THEN 'Paid' ELSE 'Pending' END as payment_status,
      p.payment_amount,
      c.created_at
    FROM client_info c
    LEFT JOIN brief_responses b ON c.user_id = b.user_id
    LEFT JOIN payment_info p ON c.user_id = p.user_id
    ORDER BY c.created_at DESC
  `;

  const results = stmt.executeQuery(query);

  while (results.next()) {
    sheet.appendRow([
      results.getString('case_number'),
      results.getString('id_number'),
      results.getString('razon_social'),
      results.getString('email'),
      results.getString('telefono'),
      results.getString('tipo_persona'),
      results.getString('actividad_economica'),
      results.getString('brief_completed'),
      results.getString('payment_status'),
      results.getDouble('payment_amount') || 0,
      results.getTimestamp('created_at')
    ]);
  }

  results.close();
  stmt.close();
  conn.close();

  SpreadsheetApp.getActiveSpreadsheet().toast('Complete data refreshed successfully!', 'Success', 3);
}

/**
 * Creates a custom menu in Google Sheets
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('Brandy Database')
    .addItem('Refresh Client Info', 'fetchClientInfo')
    .addItem('Refresh Brief Responses', 'fetchBriefResponses')
    .addItem('Refresh Payment Info', 'fetchPaymentInfo')
    .addSeparator()
    .addItem('Refresh All Data', 'refreshAllData')
    .addItem('Refresh Complete View', 'fetchCompleteClientData')
    .addToUi();
}

/**
 * Refreshes all sheets
 */
function refreshAllData() {
  fetchClientInfo();
  Utilities.sleep(1000);
  fetchBriefResponses();
  Utilities.sleep(1000);
  fetchPaymentInfo();
  Utilities.sleep(1000);
  fetchCompleteClientData();
}

/**
 * Sets up automatic refresh trigger (runs every hour)
 */
function createTimeDrivenTrigger() {
  ScriptApp.newTrigger('refreshAllData')
    .timeBased()
    .everyHours(1)
    .create();
}
```

4. **Enable JDBC Service**
   - In Apps Script, click on the `+` next to Services
   - Find and enable "JDBC"

5. **Create Sheet Tabs**
   - Create sheets named: `Client Info`, `Brief Responses`, `Payment Info`, `Complete Data`

6. **Configure Database Credentials**
   - Update the `DB_CONFIG` object with your actual database credentials
   - **IMPORTANT**: For production, use Google's Properties Service to store credentials securely:

```javascript
// Store credentials securely
function setDatabaseCredentials() {
  const scriptProperties = PropertiesService.getScriptProperties();
  scriptProperties.setProperties({
    'DB_HOST': 'your-host.com',
    'DB_PORT': '5432',
    'DB_NAME': 'brandy_db',
    'DB_USER': 'your-username',
    'DB_PASS': 'your-password'
  });
}

// Use credentials securely
const DB_CONFIG = {
  host: PropertiesService.getScriptProperties().getProperty('DB_HOST'),
  port: PropertiesService.getScriptProperties().getProperty('DB_PORT'),
  database: PropertiesService.getScriptProperties().getProperty('DB_NAME'),
  username: PropertiesService.getScriptProperties().getProperty('DB_USER'),
  password: PropertiesService.getScriptProperties().getProperty('DB_PASS')
};
```

7. **Run and Test**
   - Save the script (Ctrl+S)
   - Reload your Google Sheet
   - You should see a new menu "Brandy Database"
   - Click on it to refresh data

8. **Setup Auto-Refresh (Optional)**
   - Run the `createTimeDrivenTrigger()` function once
   - This will refresh data automatically every hour

---

### Option 2: Using Third-Party Tools

#### Zapier + Google Sheets
1. Create a Zapier account (free tier available)
2. Set up a new Zap with trigger: "PostgreSQL - New Row"
3. Connect your database credentials
4. Action: "Google Sheets - Create Spreadsheet Row"
5. Map database columns to sheet columns

#### Coefficient (Commercial Tool)
- Visit [coefficient.io](https://coefficient.io)
- Install Coefficient add-on for Google Sheets
- Connect to PostgreSQL/MySQL database
- Use live data imports with automatic refresh

---

## Excel Connection

### Option 1: Power Query (Excel 2016+)

#### Prerequisites
- Excel 2016 or later (includes Power Query)
- PostgreSQL or MySQL ODBC driver installed

#### Installing ODBC Drivers

**For PostgreSQL:**
1. Download from [PostgreSQL ODBC Driver](https://www.postgresql.org/ftp/odbc/versions/)
2. Install the appropriate version (32-bit or 64-bit, match your Excel version)

**For MySQL:**
1. Download from [MySQL Connector/ODBC](https://dev.mysql.com/downloads/connector/odbc/)
2. Install the connector

#### Connecting Excel to Database

1. **Open Excel and go to Data Tab**
   - Click `Get Data` → `From Database` → `From PostgreSQL Database` (or MySQL)

2. **Enter Connection Details**
   - Server: `your-database-host.com`
   - Database: `brandy_db`
   - Click `OK`

3. **Enter Credentials**
   - Choose "Database" authentication
   - Enter username and password
   - Click `Connect`

4. **Select Tables**
   - You'll see a navigator with available tables
   - Select the tables you want:
     - `client_info`
     - `brief_responses`
     - `payment_info`
   - Click `Load` or `Transform Data` to edit before loading

5. **Load Data**
   - Data will appear in your Excel sheet
   - To refresh: Right-click on the table → `Refresh`

#### Creating a Complete Data Query in Power Query

1. After loading tables, go to `Data` → `Queries & Connections`
2. Right-click in the Queries pane → `New Query` → `Combine Queries` → `Merge`
3. Select `client_info` as base table
4. Merge with `brief_responses` on `user_id`
5. Merge with `payment_info` on `user_id`
6. Expand merged columns to show all data
7. Close & Load to create a complete view

#### Auto-Refresh Setup

1. **Right-click on table** → `Table` → `External Data Properties`
2. Check "Refresh data when opening the file"
3. Check "Refresh every X minutes" (set interval)
4. Click `OK`

---

### Option 2: Direct ODBC Connection (All Excel Versions)

1. **Open Windows ODBC Data Source Administrator**
   - Search for "ODBC" in Windows Start menu
   - Choose 32-bit or 64-bit (match your Excel)

2. **Create New Data Source**
   - Click `Add`
   - Select PostgreSQL ODBC driver or MySQL ODBC driver
   - Click `Finish`

3. **Configure Connection**
   - Data Source Name: `Brandy_DB`
   - Server: `your-host.com`
   - Port: `5432` (PostgreSQL) or `3306` (MySQL)
   - Database: `brandy_db`
   - User: `your-username`
   - Password: `your-password`
   - Click `Test` to verify connection
   - Click `OK` to save

4. **Connect from Excel**
   - Go to `Data` tab → `Get External Data` → `From Other Sources` → `From Data Connection Wizard`
   - Select `ODBC DSN`
   - Choose `Brandy_DB`
   - Select table and click `Finish`

---

## Useful Queries

### Query Templates for Analysis

#### 1. Client Registration Summary
```sql
SELECT
  DATE(created_at) as registration_date,
  COUNT(*) as total_registrations,
  COUNT(CASE WHEN tipo_persona = 'natural' THEN 1 END) as natural_persons,
  COUNT(CASE WHEN tipo_persona = 'juridica' THEN 1 END) as juridica_persons
FROM client_info
GROUP BY DATE(created_at)
ORDER BY registration_date DESC;
```

#### 2. Conversion Funnel
```sql
SELECT
  COUNT(DISTINCT c.id_number) as total_clients,
  COUNT(DISTINCT b.id_number) as completed_brief,
  COUNT(DISTINCT p.id_number) as completed_payment,
  ROUND(COUNT(DISTINCT b.id_number)::NUMERIC / COUNT(DISTINCT c.id_number) * 100, 2) as brief_conversion_rate,
  ROUND(COUNT(DISTINCT p.id_number)::NUMERIC / COUNT(DISTINCT c.id_number) * 100, 2) as payment_conversion_rate
FROM client_info c
LEFT JOIN brief_responses b ON c.id_number = b.id_number
LEFT JOIN payment_info p ON c.id_number = p.id_number;
```

#### 3. Revenue Summary
```sql
SELECT
  DATE(created_at) as date,
  COUNT(*) as total_payments,
  SUM(payment_amount) as total_revenue,
  AVG(payment_amount) as avg_payment,
  COUNT(CASE WHEN payment_successful THEN 1 END) as successful_payments
FROM payment_info
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

#### 4. Most Common Business Activities
```sql
SELECT
  actividad_economica,
  COUNT(*) as count,
  ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 2) as percentage
FROM client_info
GROUP BY actividad_economica
ORDER BY count DESC
LIMIT 10;
```

#### 5. Geographic Distribution
```sql
SELECT
  departamento,
  COUNT(*) as client_count
FROM client_info
GROUP BY departamento
ORDER BY client_count DESC;
```

#### 6. Clients with Existing Names
```sql
SELECT
  c.razon_social,
  c.email,
  b.nombre_actual,
  b.palabra_1,
  b.palabra_2,
  b.palabra_3
FROM client_info c
JOIN brief_responses b ON c.user_id = b.user_id
WHERE b.tiene_nombre = TRUE
ORDER BY c.created_at DESC;
```

---

## Security Best Practices

### Database Access
1. **Create Read-Only User for Reporting**
```sql
-- PostgreSQL
CREATE USER sheets_reader WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE brandy_db TO sheets_reader;
GRANT USAGE ON SCHEMA public TO sheets_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO sheets_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO sheets_reader;
```

2. **Use SSL/TLS Connections**
   - Always enable SSL in your database connection string
   - For PostgreSQL: Add `?sslmode=require` to connection URL

3. **Whitelist IP Addresses**
   - Configure your database firewall to only allow:
     - Google Sheets IP ranges (for Apps Script)
     - Your office IP addresses
     - Never allow 0.0.0.0/0 (all IPs)

4. **Store Credentials Securely**
   - Use Google Apps Script Properties Service
   - Use Excel's encrypted connection strings
   - Never hardcode passwords in scripts
   - Never share credentials in plain text

5. **Monitor Access Logs**
   - Regularly review database access logs
   - Set up alerts for unusual query patterns
   - Monitor for failed login attempts

### Google Sheets Specific
1. **Restrict Sheet Permissions**
   - Share sheet only with authorized team members
   - Use "Viewer" permissions for those who only need to see data
   - Use "Editor" permissions sparingly

2. **Enable 2-Factor Authentication**
   - Require 2FA for all Google accounts with database access

### Excel Specific
1. **Protect Workbook Structure**
   - In Excel, go to `Review` → `Protect Workbook`
   - This prevents unauthorized changes to queries

2. **Save Connection Files Securely**
   - `.odc` and `.iqy` connection files contain credentials
   - Store in encrypted folders
   - Don't share via email

---

## Troubleshooting

### Google Sheets Issues

**Error: "Access denied for user"**
- Check database credentials in script
- Verify user has SELECT permissions on tables
- Check if database allows remote connections

**Error: "Cannot connect to database"**
- Verify database host and port
- Check if database firewall allows Google's IP ranges
- Ensure database is running

**Data not refreshing**
- Check script execution logs: `Extensions` → `Apps Script` → `Executions`
- Verify trigger is set up correctly
- Check if you've hit Google Apps Script quota limits

### Excel Issues

**Error: "ODBC Driver not found"**
- Ensure you installed the correct bit version (32-bit vs 64-bit)
- Reinstall ODBC driver matching your Excel version

**Error: "Connection failed"**
- Test connection in ODBC Administrator first
- Check firewall settings
- Verify database credentials

**Data loads slowly**
- Add indexes to frequently queried columns
- Limit data with WHERE clauses
- Use Power Query to filter data before loading

---

## Advanced Features

### Creating Dashboards in Google Sheets

Once data is loaded, create visualizations:

1. **Summary Dashboard**
   - Use pivot tables for data summarization
   - Create charts for key metrics:
     - Daily registrations (line chart)
     - Conversion funnel (bar chart)
     - Revenue trends (line chart)
     - Geographic distribution (map chart)

2. **Real-time Metrics**
   - Use formulas on the data:
   ```
   =COUNTIF('Client Info'!A:A,"<>")  // Total clients
   =COUNTIF('Payment Info'!D:D,"Sí")  // Successful payments
   =SUM('Payment Info'!E:E)  // Total revenue
   ```

3. **Conditional Formatting**
   - Highlight overdue cases
   - Color-code payment status
   - Flag incomplete briefs

### Creating Dashboards in Excel

1. **Power BI Integration**
   - Export data to Power BI for advanced analytics
   - Create interactive dashboards
   - Share with team via Power BI Service

2. **Pivot Tables and Charts**
   - Insert → Pivot Table
   - Drag fields to analyze data
   - Create Pivot Charts for visualization

3. **Excel Slicers**
   - Add slicers to filter data interactively
   - Works with Pivot Tables and regular tables

---

## Support and Further Help

For issues with:
- **Database structure**: See `/database/README_NEW_SCHEMA.md`
- **Migration questions**: See `/database/migrations/README.md`
- **API integration**: Contact development team

### Useful Links
- [Google Apps Script JDBC Documentation](https://developers.google.com/apps-script/guides/jdbc)
- [Excel Power Query Documentation](https://support.microsoft.com/en-us/office/power-query-overview-ed614c81-4b00-4291-bd3a-55d80767f81d)
- [PostgreSQL ODBC Documentation](https://odbc.postgresql.org/)
- [MySQL Connector/ODBC Documentation](https://dev.mysql.com/doc/connector-odbc/en/)
