-- =============================================================================
-- N8N PostgreSQL Initialization Script
-- =============================================================================
-- This script sets up a PostgreSQL database for N8N workflow automation
--
-- Environment Variables Required:
--   N8N_DB_USER     - Database username (default: n8n)
--   N8N_DB_PASSWORD - Database password (default: n8n)
--   N8N_DB_NAME     - Database name (default: n8n)
--
-- Usage:
--   This script is automatically executed by PostgreSQL on first initialization
--   when placed in /docker-entrypoint-initdb.d/
--
-- Security Notes:
--   - Change the default password in production
--   - Use environment variables for credentials
--   - Restrict database access via pg_hba.conf
-- =============================================================================

-- Set client encoding to UTF8
SET client_encoding = 'UTF8';

-- Create n8n user if it doesn't exist
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'n8n') THEN
      CREATE ROLE n8n WITH LOGIN PASSWORD 'n8n';
      RAISE NOTICE 'Role "n8n" created';
   ELSE
      RAISE NOTICE 'Role "n8n" already exists';
   END IF;
END
$$;

-- Grant connection privileges
ALTER ROLE n8n WITH CREATEDB;
ALTER ROLE n8n WITH CREATEROLE;

-- Create n8n database if it doesn't exist
SELECT 'CREATE DATABASE n8n
   WITH OWNER = n8n
   ENCODING = ''UTF8''
   LC_COLLATE = ''en_US.utf8''
   LC_CTYPE = ''en_US.utf8''
   TEMPLATE = template0
   CONNECTION LIMIT = -1'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n')\gexec

-- Connect to n8n database
\c n8n

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";       -- Cryptographic functions
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- Trigram matching for text search

-- Grant all privileges on database to n8n user
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO n8n;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO n8n;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO n8n;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO n8n;

-- Create n8n schema for better organization (optional)
CREATE SCHEMA IF NOT EXISTS n8n_data AUTHORIZATION n8n;

-- Grant privileges on n8n_data schema
GRANT ALL ON SCHEMA n8n_data TO n8n;
ALTER DEFAULT PRIVILEGES IN SCHEMA n8n_data GRANT ALL ON TABLES TO n8n;
ALTER DEFAULT PRIVILEGES IN SCHEMA n8n_data GRANT ALL ON SEQUENCES TO n8n;
ALTER DEFAULT PRIVILEGES IN SCHEMA n8n_data GRANT ALL ON FUNCTIONS TO n8n;

-- Set search path to include n8n_data schema
ALTER ROLE n8n SET search_path TO n8n_data, public;

-- Create initial tables structure (optional, n8n will create these automatically)
-- Uncomment if you want to pre-create tables

/*
CREATE TABLE IF NOT EXISTS n8n_data.execution_entity (
    id SERIAL PRIMARY KEY,
    data TEXT,
    finished BOOLEAN,
    mode VARCHAR(255),
    retryOf VARCHAR(255),
    retrySuccessId VARCHAR(255),
    startedAt TIMESTAMP,
    stoppedAt TIMESTAMP,
    workflowData TEXT,
    workflowId VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS n8n_data.workflow_entity (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    active BOOLEAN,
    nodes TEXT,
    connections TEXT,
    settings TEXT,
    staticData TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS n8n_data.credentials_entity (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    data TEXT,
    type VARCHAR(255),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS n8n_data.tag_entity (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_execution_workflowid ON n8n_data.execution_entity(workflowId);
CREATE INDEX IF NOT EXISTS idx_execution_finished ON n8n_data.execution_entity(finished);
CREATE INDEX IF NOT EXISTS idx_workflow_active ON n8n_data.workflow_entity(active);
*/

-- Display configuration summary
DO $$
BEGIN
    RAISE NOTICE '=============================================================================';
    RAISE NOTICE 'N8N Database Configuration Complete';
    RAISE NOTICE '=============================================================================';
    RAISE NOTICE 'Database Name:    n8n';
    RAISE NOTICE 'Database User:    n8n';
    RAISE NOTICE 'Database Owner:   n8n';
    RAISE NOTICE 'Encoding:         UTF8';
    RAISE NOTICE 'Extensions:       uuid-ossp, pgcrypto, pg_trgm';
    RAISE NOTICE 'Schemas:          public, n8n_data';
    RAISE NOTICE '=============================================================================';
    RAISE NOTICE 'Connection String: postgresql://n8n:PASSWORD@postgres:5432/n8n';
    RAISE NOTICE '=============================================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'SECURITY WARNING: Change the default password in production!';
    RAISE NOTICE '';
END $$;

-- Grant CONNECT privilege
GRANT CONNECT ON DATABASE n8n TO n8n;

-- Analyze database for query optimization
ANALYZE;
