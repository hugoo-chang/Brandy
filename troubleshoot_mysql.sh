#!/bin/bash
# MySQL Troubleshooting Script for macOS

echo "MySQL Startup Troubleshooting"
echo "========================================"
echo ""

echo "1. Checking if MySQL is already running..."
ps aux | grep mysqld | grep -v grep
if [ $? -eq 0 ]; then
    echo "   MySQL is already running!"
    echo "   Try: mysql -u root"
    exit 0
else
    echo "   MySQL is not running."
fi
echo ""

echo "2. Checking for port conflicts (port 3306)..."
lsof -i :3306 2>/dev/null || echo "   Port 3306 is free."
echo ""

echo "3. Checking MySQL error log..."
# Common error log locations
for log in \
    /usr/local/mysql/data/*.err \
    /opt/anaconda3/data/*.err \
    /var/log/mysql/error.log \
    /usr/local/var/mysql/*.err
do
    if [ -f "$log" ]; then
        echo "   Found log: $log"
        echo "   Last 20 lines:"
        tail -20 "$log"
        break
    fi
done
echo ""

echo "4. Checking MySQL data directory permissions..."
for dir in \
    /usr/local/mysql/data \
    /opt/anaconda3/data \
    /usr/local/var/mysql
do
    if [ -d "$dir" ]; then
        echo "   $dir"
        ls -la "$dir" | head -5
    fi
done
echo ""

echo "5. Checking disk space..."
df -h / | grep -v Filesystem
echo ""

echo "========================================"
echo "Next steps to try:"
echo "1. Check the error log output above for specific errors"
echo "2. Try: sudo chown -R $(whoami) /usr/local/mysql/data"
echo "3. Try: sudo chown -R $(whoami) /opt/anaconda3/data"
echo "4. Remove old PID file: rm /opt/anaconda3/data/*.pid"
echo "5. Try starting with: mysqld --skip-grant-tables &"
