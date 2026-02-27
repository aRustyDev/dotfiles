# dolt

Dolt - The SQL database with Git-like version control.

## Current Configuration

- `brewfile` - dolt and doltgres packages

### Features

- **Version control**: Branch, merge, diff, and log for your data
- **SQL interface**: Standard MySQL-compatible SQL
- **DoltgreSQL**: PostgreSQL-compatible interface
- **DoltHub**: GitHub-like hosting for databases

## Installation

```bash
just -f dolt/justfile install
```

Configure your identity:

```bash
dolt config --global --add user.email "you@example.com"
dolt config --global --add user.name "Your Name"
```

## Usage

### Database Management

```bash
# Create a new database
just -f dolt/justfile init mydb

# List databases
just -f dolt/justfile list

# Open SQL shell
just -f dolt/justfile sql mydb

# Show status/log/diff
just -f dolt/justfile status mydb
just -f dolt/justfile log mydb
just -f dolt/justfile diff mydb

# Commit changes
just -f dolt/justfile commit mydb "Add users table"
```

### Server Mode

```bash
# Start MySQL-compatible server (foreground)
just -f dolt/justfile serve mydb

# Start in background
just -f dolt/justfile serve-bg mydb

# Stop server
just -f dolt/justfile stop mydb

# Start PostgreSQL-compatible server
just -f dolt/justfile serve-pg mydb
```

### Remote Operations

```bash
# Clone from DoltHub
just -f dolt/justfile clone dolthub/us-housing-prices

# Push/pull
just -f dolt/justfile push mydb
just -f dolt/justfile pull mydb
```

## SQL Shell Commands

```sql
-- Create a table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Insert data
INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com');

-- Query
SELECT * FROM users;

-- Dolt-specific: create a commit
CALL dolt_commit('-am', 'Add initial users');

-- Dolt-specific: view history
SELECT * FROM dolt_log;

-- Dolt-specific: create branch
CALL dolt_branch('feature-branch');

-- Dolt-specific: diff between commits
SELECT * FROM dolt_diff('HEAD~1', 'HEAD', 'users');
```

## Connecting from Applications

### MySQL-compatible (port 3306)

```bash
mysql -h 127.0.0.1 -P 3306 -u root mydb
```

### PostgreSQL-compatible (port 5432)

```bash
psql -h 127.0.0.1 -p 5432 -U root mydb
```

## Directory Structure

```
~/.dolt/                           # Global config
~/.local/share/dolt/databases/     # Database storage
  mydb/                            # Database directory
    .dolt/                         # Version control data
```

## TODOs

### Configuration (Medium Priority)

- [ ] **Default remote**: Configure DoltHub credentials
- [ ] **Replication**: Set up read replicas

### Integration (Low Priority)

- [ ] **Backup automation**: Scheduled dumps/clones
- [ ] **Monitoring**: Prometheus metrics

## File Structure

```
dolt/
├── brewfile      # dolt and doltgres
├── justfile      # Database management recipes
├── data.yml      # Module config
└── README.md     # This file
```

## References

- [Dolt Documentation](https://docs.dolthub.com/)
- [DoltHub](https://www.dolthub.com/) - Database hosting
- [Dolt SQL Reference](https://docs.dolthub.com/sql-reference/version-control)
- [DoltgreSQL](https://docs.dolthub.com/sql-reference/doltgres)
