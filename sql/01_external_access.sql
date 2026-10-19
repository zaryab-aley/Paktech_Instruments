-- Run once as an authorised administrator in the paktech database.
-- Create paktech in Synapse Studio first. A master key must already exist.
-- If a master key is needed, create it interactively with a private password;
-- never commit that password to GitHub.
-- Replace YOUR_STORAGE_ACCOUNT before execution. Existing objects are retained.
IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'cred_paktech')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL cred_paktech WITH IDENTITY = 'MANAGED IDENTITY';
END;
IF NOT EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = N'source_silver')
BEGIN
    CREATE EXTERNAL DATA SOURCE source_silver WITH (
        LOCATION = 'https://YOUR_STORAGE_ACCOUNT.blob.core.windows.net/silver',
        CREDENTIAL = cred_paktech
    );
END;
IF NOT EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = N'source_gold')
BEGIN
    CREATE EXTERNAL DATA SOURCE source_gold WITH (
        LOCATION = 'https://YOUR_STORAGE_ACCOUNT.blob.core.windows.net/gold',
        CREDENTIAL = cred_paktech
    );
END;
IF NOT EXISTS (SELECT 1 FROM sys.external_file_formats WHERE name = N'format_parquet')
BEGIN
    CREATE EXTERNAL FILE FORMAT format_parquet WITH (FORMAT_TYPE = PARQUET);
END;
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'gold')
    EXEC(N'CREATE SCHEMA gold;');

-- Adapt the Entra display name if the Data Factory is renamed.
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'PakTechDataFactory')
    CREATE USER [PakTechDataFactory] FROM EXTERNAL PROVIDER;
GRANT CONNECT TO [PakTechDataFactory];
GRANT SELECT ON SCHEMA::gold TO [PakTechDataFactory];
GRANT SELECT ON SCHEMA::dbo TO [PakTechDataFactory];
GRANT CREATE TABLE TO [PakTechDataFactory];
GRANT CREATE VIEW TO [PakTechDataFactory];
GRANT ALTER ON SCHEMA::dbo TO [PakTechDataFactory];
GRANT ALTER ANY EXTERNAL DATA SOURCE TO [PakTechDataFactory];
GRANT ALTER ANY EXTERNAL FILE FORMAT TO [PakTechDataFactory];
GRANT REFERENCES ON DATABASE SCOPED CREDENTIAL::cred_paktech TO [PakTechDataFactory];
GRANT ADMINISTER DATABASE BULK OPERATIONS TO [PakTechDataFactory];
