# Bash Scripting Basics for Automation

## Script Structure

```bash
#!/bin/bash
# Shebang - tells system to use bash

# Your code here
echo "Hello World"
```

Always start with `#!/bin/bash` and make executable: `chmod +x script.sh`

## Variables

```bash
NAME="John"                 # No spaces around =
AGE=25
echo "Hello $NAME"          # Use $ to access
echo "Age: ${AGE}"          # Curly braces for clarity

# Command output to variable
FILES=$(ls -l)
CURRENT_DIR=$(pwd)
```

## Command Chaining

```bash
# AND (&&) - run next only if previous succeeds
mkdir test && cd test && touch file.txt

# OR (||) - run next only if previous fails
cd /somedir || echo "Directory not found"

# Semicolon (;) - run regardless of success/failure
cd /tmp; ls; pwd

# Pipe (|) - pass output to next command
cat file.txt | grep "error" | wc -l
```

## Exit Codes

```bash
# 0 = success, non-zero = failure
command
echo $?  # Shows exit code of last command

# Set exit code in script
exit 0   # Success
exit 1   # Failure

# Use in scripts
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi
```

## Control Flow

### If Statements

```bash
if [ condition ]; then
    # code
elif [ condition ]; then
    # code
else
    # code
fi

# Examples
if [ -f "file.txt" ]; then
    echo "File exists"
fi

if [ $AGE -gt 18 ]; then
    echo "Adult"
fi
```

### Loops

```bash
# For loop
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

for file in *.txt; do
    echo "Processing $file"
done

# While loop
counter=0
while [ $counter -lt 5 ]; do
    echo $counter
    counter=$((counter + 1))
done
```

## Error Handling

```bash
# Exit on error
set -e  # Stop script if any command fails

# Check command success
if ! mkdir /test 2>/dev/null; then
    echo "Error: Cannot create directory"
    exit 1
fi

# Function with error handling
backup_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        echo "Error: File not found"
        return 1
    fi
    cp "$file" "${file}.bak" || {
        echo "Error: Backup failed"
        return 1
    }
    echo "Backup successful"
    return 0
}
```

## Practical Automation Examples

### Example 1: System Cleanup

```bash
#!/bin/bash
set -e

LOG_DIR="/var/log/myapp"
DAYS=7

echo "Cleaning logs older than $DAYS days..."

if [ -d "$LOG_DIR" ]; then
    find "$LOG_DIR" -name "*.log" -mtime +$DAYS -delete
    echo "Cleanup completed: Exit code $?"
else
    echo "Error: Log directory not found"
    exit 1
fi
```

### Example 2: Backup Script

```bash
#!/bin/bash

SOURCE="/home/user/data"
BACKUP="/backup"
DATE=$(date +%Y%m%d)

# Create backup directory
mkdir -p "$BACKUP" || {
    echo "Error: Cannot create backup directory"
    exit 1
}

# Perform backup
tar -czf "$BACKUP/backup-$DATE.tar.gz" "$SOURCE" && {
    echo "Backup successful: $BACKUP/backup-$DATE.tar.gz"
    exit 0
} || {
    echo "Backup failed"
    exit 1
}
```

### Example 3: Service Health Check

```bash
#!/bin/bash

SERVICE="nginx"
MAX_RETRIES=3
retry=0

while [ $retry -lt $MAX_RETRIES ]; do
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$SERVICE is running"
        exit 0
    else
        echo "Attempt $((retry + 1)): $SERVICE not running, restarting..."
        systemctl restart "$SERVICE"
        retry=$((retry + 1))
        sleep 2
    fi
done

echo "Error: Failed to start $SERVICE after $MAX_RETRIES attempts"
exit 1
```

## Common Conditions

```bash
# File tests
[ -f file ]     # File exists
[ -d dir ]      # Directory exists
[ -r file ]     # Readable
[ -w file ]     # Writable
[ -x file ]     # Executable

# String tests
[ -z "$str" ]   # String is empty
[ -n "$str" ]   # String is not empty
[ "$a" = "$b" ] # Strings equal

# Number tests
[ $a -eq $b ]   # Equal
[ $a -ne $b ]   # Not equal
[ $a -gt $b ]   # Greater than
[ $a -lt $b ]   # Less than
```

## Key Takeaways

1. Always use `#!/bin/bash` shebang and `chmod +x` to make scripts executable
2. Exit code 0 = success, non-zero = failure
3. Use `&&` for conditional chaining, `||` for fallback
4. `set -e` stops script on first error
5. Check exit codes with `$?` and handle errors properly
6. Variables don't use spaces: `VAR="value"` not `VAR = "value"`
7. Quote variables to prevent word splitting: `"$VAR"`
8. Test scripts before deploying to automation workflows
