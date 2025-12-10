-- =============================================================================
-- PostgreSQL Initialization Script for Auth Services
-- =============================================================================
-- Creates databases and users for:
--   - ORY Hydra (OAuth 2.0 / OIDC)
--   - ORY Kratos (Identity Management)
--   - ORY Keto (Permissions)
--   - SpiceDB (Authorization)
--
-- This script runs automatically on first PostgreSQL startup.
-- To re-run, delete the PostgreSQL data directory and restart.
-- =============================================================================

-- =============================================================================
-- ORY Hydra Database
-- =============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'hydra') THEN
        CREATE ROLE hydra WITH LOGIN PASSWORD 'hydra_password_change_me';
    END IF;
END
$$;

SELECT 'Creating database: hydra' AS status;
CREATE DATABASE hydra WITH OWNER = hydra ENCODING = 'UTF8';

\c hydra
GRANT ALL PRIVILEGES ON DATABASE hydra TO hydra;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hydra;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hydra;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO hydra;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO hydra;

\c postgres

-- =============================================================================
-- ORY Kratos Database
-- =============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'kratos') THEN
        CREATE ROLE kratos WITH LOGIN PASSWORD 'kratos_password_change_me';
    END IF;
END
$$;

SELECT 'Creating database: kratos' AS status;
CREATE DATABASE kratos WITH OWNER = kratos ENCODING = 'UTF8';

\c kratos
GRANT ALL PRIVILEGES ON DATABASE kratos TO kratos;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO kratos;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO kratos;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO kratos;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO kratos;

\c postgres

-- =============================================================================
-- ORY Keto Database
-- =============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'keto') THEN
        CREATE ROLE keto WITH LOGIN PASSWORD 'keto_password_change_me';
    END IF;
END
$$;

SELECT 'Creating database: keto' AS status;
CREATE DATABASE keto WITH OWNER = keto ENCODING = 'UTF8';

\c keto
GRANT ALL PRIVILEGES ON DATABASE keto TO keto;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO keto;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO keto;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO keto;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO keto;

\c postgres

-- =============================================================================
-- SpiceDB Database
-- =============================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'spicedb') THEN
        CREATE ROLE spicedb WITH LOGIN PASSWORD 'spicedb_password_change_me';
    END IF;
END
$$;

SELECT 'Creating database: spicedb' AS status;
CREATE DATABASE spicedb WITH OWNER = spicedb ENCODING = 'UTF8';

\c spicedb
GRANT ALL PRIVILEGES ON DATABASE spicedb TO spicedb;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO spicedb;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO spicedb;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO spicedb;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO spicedb;

\c postgres

-- =============================================================================
-- Summary
-- =============================================================================
SELECT 'Auth databases initialized successfully!' AS status;
SELECT datname AS database FROM pg_database WHERE datname IN ('hydra', 'kratos', 'keto', 'spicedb');
