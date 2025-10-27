#!/usr/bin/env python3
"""
Test MySQL connection and help configure password
"""

import mysql.connector
from mysql.connector import Error
import getpass

print("MySQL Connection Tester")
print("=" * 50)

# Test 1: Try without password
print("\n1. Testing connection without password...")
try:
    conn = mysql.connector.connect(
        host='localhost',
        port=3306,
        user='root',
        password=''
    )
    print("✓ SUCCESS! No password required.")
    print("\nYour .env file is correctly configured.")
    conn.close()
    exit(0)
except Error as e:
    print(f"✗ Failed: {e}")

# Test 2: Try with empty password string
print("\n2. Testing with empty password string...")
try:
    conn = mysql.connector.connect(
        host='localhost',
        port=3306,
        user='root',
        password=None
    )
    print("✓ SUCCESS! Connection works with None password.")
    conn.close()
    exit(0)
except Error as e:
    print(f"✗ Failed: {e}")

# Test 3: Ask for password
print("\n3. The root user requires a password.")
print("\nOptions:")
print("  a) Enter the password now to test")
print("  b) Reset the MySQL root password")
print("  c) Quit and manually configure")

choice = input("\nChoose option (a/b/c): ").strip().lower()

if choice == 'a':
    password = getpass.getpass("Enter MySQL root password: ")
    try:
        conn = mysql.connector.connect(
            host='localhost',
            port=3306,
            user='root',
            password=password
        )
        print("\n✓ SUCCESS! Connection works.")
        print(f"\nUpdate your .env file:")
        print(f"DB_PASSWORD={password}")
        conn.close()
    except Error as e:
        print(f"\n✗ Failed: {e}")

elif choice == 'b':
    print("\nTo reset MySQL root password:")
    print("\nOption 1 - If you have sudo access:")
    print("  sudo mysql -u root")
    print("  ALTER USER 'root'@'localhost' IDENTIFIED BY '';")
    print("  FLUSH PRIVILEGES;")
    print("  exit;")
    print("\nOption 2 - If MySQL was installed via Homebrew:")
    print("  brew services stop mysql")
    print("  mysqld_safe --skip-grant-tables &")
    print("  mysql -u root")
    print("  FLUSH PRIVILEGES;")
    print("  ALTER USER 'root'@'localhost' IDENTIFIED BY '';")
    print("  exit;")
    print("  killall mysqld")
    print("  brew services start mysql")

else:
    print("\nPlease manually configure your .env file with:")
    print("DB_PASSWORD=your_mysql_password")
