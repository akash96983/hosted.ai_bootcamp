# Linux Filesystem & Permissions

## Filesystem Hierarchy

Linux uses a tree structure starting from root (`/`):

- `/` - Root directory (top of everything)
- `/home` - User home directories
- `/etc` - Configuration files
- `/var` - Variable data (logs, temp files)
- `/bin` - Essential user binaries
- `/usr` - User programs and utilities
- `/tmp` - Temporary files

## Navigation Commands

```bash
pwd                 # Show current directory
ls                  # List files
ls -la              # List all files with permissions
cd /path            # Change directory
cd ..               # Go up one level
cd ~                # Go to home directory
```

## File Permissions

### Permission Format: `rwxrwxrwx`
- **r** (read) = 4
- **w** (write) = 2
- **x** (execute) = 1

Three groups: **Owner | Group | Others**

Example: `-rwxr-xr--` = Owner can read/write/execute, Group can read/execute, Others can only read

### chmod Command

```bash
chmod 755 file.sh       # Owner: rwx, Group: rx, Others: rx
chmod +x file.sh        # Add execute permission
chmod u+w file.txt      # Add write for owner
chmod go-w file.txt     # Remove write for group and others
```

### chown Command

```bash
chown user file.txt             # Change owner
chown user:group file.txt       # Change owner and group
chown -R user:group folder/     # Recursive change
```

## Permissions Impact on Automation

**Why Permissions Matter:**
- Scripts need execute (`x`) permission to run
- Automation tools need read/write access to files they modify
- Wrong permissions = "Permission denied" errors
- Security: Restrict sensitive files from unauthorized access

**Common Issues:**
- Script won't run: Add `chmod +x script.sh`
- Can't write logs: Check write permissions on log directory
- Automation fails: Ensure service user has proper permissions

## Quick Demo Example

```bash
# Create a script
echo '#!/bin/bash' > demo.sh
echo 'echo "Hello from automation!"' >> demo.sh

# Try to run (fails - no execute permission)
./demo.sh  # Permission denied

# Add execute permission
chmod +x demo.sh

# Now it runs!
./demo.sh  # Hello from automation!

# Check permissions
ls -l demo.sh  # -rwxr-xr-x
```

## Key Takeaways

1. Everything in Linux is a file with permissions
2. Use `chmod` to change permissions, `chown` to change ownership
3. Automation scripts must have execute permissions
4. Always verify permissions when troubleshooting automation failures
5. Use least privilege principle: Grant only necessary permissions
