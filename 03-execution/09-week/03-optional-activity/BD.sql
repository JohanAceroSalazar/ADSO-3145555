-- ============================================================
-- AIRLINE MANAGEMENT SYSTEM — ESQUEMA CORREGIDO
-- Versión: 2.0
-- Fecha:   2025-04-13
-- Cambios aplicados según ADR-001 al ADR-010:
--   ADR-002 → Tablas de catálogo reemplazan VARCHAR+CHECK
--   ADR-003 → Columnas created_by / updated_by en tablas operacionales
--   ADR-004 → Soft delete (is_deleted, deleted_at, deleted_by)
--   ADR-005 → Tabla gender_type alineada con ISO 5218
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- GEOGRAFÍA Y DATOS DE REFERENCIA
-- ============================================================

CREATE TABLE time_zone (
    time_zone_id        uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    time_zone_name      varchar(64) NOT NULL,
    utc_offset_minutes  integer     NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_time_zone_name UNIQUE (time_zone_name)
);

CREATE TABLE continent (
    continent_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    continent_code  varchar(3)  NOT NULL,
    continent_name  varchar(64) NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_continent_code UNIQUE (continent_code),
    CONSTRAINT uq_continent_name UNIQUE (continent_name)
);

CREATE TABLE country (
    country_id      uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    continent_id    uuid         NOT NULL REFERENCES continent(continent_id),
    iso_alpha2      varchar(2)   NOT NULL,
    iso_alpha3      varchar(3)   NOT NULL,
    country_name    varchar(128) NOT NULL,
    created_at      timestamptz  NOT NULL DEFAULT now(),
    updated_at      timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_country_alpha2 UNIQUE (iso_alpha2),
    CONSTRAINT uq_country_alpha3 UNIQUE (iso_alpha3),
    CONSTRAINT uq_country_name   UNIQUE (country_name)
);

CREATE TABLE state_province (
    state_province_id   uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id          uuid         NOT NULL REFERENCES country(country_id),
    state_code          varchar(10),
    state_name          varchar(128) NOT NULL,
    created_at          timestamptz  NOT NULL DEFAULT now(),
    updated_at          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_state_country_name UNIQUE (country_id, state_name)
);

CREATE TABLE city (
    city_id             uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    state_province_id   uuid         NOT NULL REFERENCES state_province(state_province_id),
    time_zone_id        uuid         NOT NULL REFERENCES time_zone(time_zone_id),
    city_name           varchar(128) NOT NULL,
    created_at          timestamptz  NOT NULL DEFAULT now(),
    updated_at          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_city_state_name UNIQUE (state_province_id, city_name)
);

CREATE TABLE district (
    district_id     uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    city_id         uuid         NOT NULL REFERENCES city(city_id),
    district_name   varchar(128) NOT NULL,
    created_at      timestamptz  NOT NULL DEFAULT now(),
    updated_at      timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_district_city_name UNIQUE (city_id, district_name)
);

CREATE TABLE address (
    address_id      uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
    district_id     uuid          NOT NULL REFERENCES district(district_id),
    address_line_1  varchar(200)  NOT NULL,
    address_line_2  varchar(200),
    postal_code     varchar(20),
    latitude        numeric(10,7),
    longitude       numeric(10,7),
    created_at      timestamptz   NOT NULL DEFAULT now(),
    updated_at      timestamptz   NOT NULL DEFAULT now(),
    CONSTRAINT ck_address_latitude  CHECK (latitude  IS NULL OR latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_address_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

CREATE TABLE currency (
    currency_id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    iso_currency_code   varchar(3)  NOT NULL,
    currency_name       varchar(64) NOT NULL,
    currency_symbol     varchar(8),
    minor_units         smallint    NOT NULL DEFAULT 2,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_currency_code        UNIQUE (iso_currency_code),
    CONSTRAINT uq_currency_name        UNIQUE (currency_name),
    CONSTRAINT ck_currency_minor_units CHECK (minor_units BETWEEN 0 AND 4)
);

-- ============================================================
-- AEROLÍNEA
-- ============================================================

CREATE TABLE airline (
    airline_id      uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    home_country_id uuid         NOT NULL REFERENCES country(country_id),
    airline_code    varchar(10)  NOT NULL,
    airline_name    varchar(150) NOT NULL,
    iata_code       varchar(2),
    icao_code       varchar(3),
    is_active       boolean      NOT NULL DEFAULT true,
    created_at      timestamptz  NOT NULL DEFAULT now(),
    updated_at      timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_airline_code  UNIQUE (airline_code),
    CONSTRAINT uq_airline_name  UNIQUE (airline_name),
    CONSTRAINT uq_airline_iata  UNIQUE (iata_code),
    CONSTRAINT uq_airline_icao  UNIQUE (icao_code),
    CONSTRAINT ck_airline_iata_len CHECK (iata_code IS NULL OR char_length(iata_code) = 2),
    CONSTRAINT ck_airline_icao_len CHECK (icao_code IS NULL OR char_length(icao_code) = 3)
);

-- ============================================================
-- IDENTIDAD
-- ============================================================

CREATE TABLE person_type (
    person_type_id  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code       varchar(20) NOT NULL,
    type_name       varchar(80) NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_person_type_code UNIQUE (type_code),
    CONSTRAINT uq_person_type_name UNIQUE (type_name)
);

CREATE TABLE document_type (
    document_type_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code           varchar(20) NOT NULL,
    type_name           varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_document_type_code UNIQUE (type_code),
    CONSTRAINT uq_document_type_name UNIQUE (type_name)
);

CREATE TABLE contact_type (
    contact_type_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code       varchar(20) NOT NULL,
    type_name       varchar(80) NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_contact_type_code UNIQUE (type_code),
    CONSTRAINT uq_contact_type_name UNIQUE (type_name)
);

-- ADR-005: Tabla de catálogo para género alineada con ISO 5218
-- Códigos: 0=Not known, 1=Male, 2=Female, 9=Not applicable
CREATE TABLE gender_type (
    gender_type_id  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    iso_code        varchar(1)  NOT NULL,
    gender_name     varchar(60) NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_gender_iso_code  UNIQUE (iso_code),
    CONSTRAINT uq_gender_name      UNIQUE (gender_name)
);

INSERT INTO gender_type (iso_code, gender_name) VALUES
    ('0', 'Not known'),
    ('1', 'Male'),
    ('2', 'Female'),
    ('9', 'Not applicable');

CREATE TABLE person (
    person_id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    person_type_id          uuid        NOT NULL REFERENCES person_type(person_type_id),
    nationality_country_id  uuid        REFERENCES country(country_id),
    -- ADR-005: gender_type_id reemplaza gender_code (ISO 5218)
    gender_type_id          uuid        REFERENCES gender_type(gender_type_id),
    first_name              varchar(80) NOT NULL,
    middle_name             varchar(80),
    last_name               varchar(80) NOT NULL,
    second_last_name        varchar(80),
    birth_date              date,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now()
    -- gender_code eliminado: reemplazado por gender_type_id (ADR-005)
);

CREATE TABLE person_document (
    person_document_id  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id           uuid        NOT NULL REFERENCES person(person_id),
    document_type_id    uuid        NOT NULL REFERENCES document_type(document_type_id),
    issuing_country_id  uuid        REFERENCES country(country_id),
    document_number     varchar(64) NOT NULL,
    issued_on           date,
    expires_on          date,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_person_document_natural  UNIQUE (document_type_id, issuing_country_id, document_number),
    CONSTRAINT ck_person_document_dates    CHECK  (expires_on IS NULL OR issued_on IS NULL OR expires_on >= issued_on)
);

CREATE TABLE person_contact (
    person_contact_id   uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id           uuid         NOT NULL REFERENCES person(person_id),
    contact_type_id     uuid         NOT NULL REFERENCES contact_type(contact_type_id),
    contact_value       varchar(180) NOT NULL,
    is_primary          boolean      NOT NULL DEFAULT false,
    created_at          timestamptz  NOT NULL DEFAULT now(),
    updated_at          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_person_contact_value UNIQUE (person_id, contact_type_id, contact_value)
);

-- ============================================================
-- SEGURIDAD
-- ============================================================

CREATE TABLE user_status (
    user_status_id  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code     varchar(20) NOT NULL,
    status_name     varchar(80) NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_status_code UNIQUE (status_code),
    CONSTRAINT uq_user_status_name UNIQUE (status_name)
);

CREATE TABLE security_role (
    security_role_id    uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    role_code           varchar(30)  NOT NULL,
    role_name           varchar(100) NOT NULL,
    role_description    text,
    created_at          timestamptz  NOT NULL DEFAULT now(),
    updated_at          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_security_role_code UNIQUE (role_code),
    CONSTRAINT uq_security_role_name UNIQUE (role_name)
);

CREATE TABLE security_permission (
    security_permission_id  uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    permission_code         varchar(50)  NOT NULL,
    permission_name         varchar(120) NOT NULL,
    permission_description  text,
    created_at              timestamptz  NOT NULL DEFAULT now(),
    updated_at              timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_security_permission_code UNIQUE (permission_code),
    CONSTRAINT uq_security_permission_name UNIQUE (permission_name)
);

CREATE TABLE user_account (
    user_account_id uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id       uuid         NOT NULL REFERENCES person(person_id),
    user_status_id  uuid         NOT NULL REFERENCES user_status(user_status_id),
    username        varchar(80)  NOT NULL,
    password_hash   varchar(255) NOT NULL,
    last_login_at   timestamptz,
    created_at      timestamptz  NOT NULL DEFAULT now(),
    updated_at      timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_account_person   UNIQUE (person_id),
    CONSTRAINT uq_user_account_username UNIQUE (username)
);

CREATE TABLE user_role (
    user_role_id        uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_account_id     uuid        NOT NULL REFERENCES user_account(user_account_id),
    security_role_id    uuid        NOT NULL REFERENCES security_role(security_role_id),
    assigned_at         timestamptz NOT NULL DEFAULT now(),
    assigned_by_user_id uuid        REFERENCES user_account(user_account_id),
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_role UNIQUE (user_account_id, security_role_id)
);

CREATE TABLE role_permission (
    role_permission_id      uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    security_role_id        uuid        NOT NULL REFERENCES security_role(security_role_id),
    security_permission_id  uuid        NOT NULL REFERENCES security_permission(security_permission_id),
    granted_at              timestamptz NOT NULL DEFAULT now(),
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_role_permission UNIQUE (security_role_id, security_permission_id)
);

-- ============================================================
-- CLIENTE Y FIDELIZACIÓN
-- ============================================================

CREATE TABLE customer_category (
    customer_category_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    category_code           varchar(20) NOT NULL,
    category_name           varchar(80) NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_category_code UNIQUE (category_code),
    CONSTRAINT uq_customer_category_name UNIQUE (category_name)
);

CREATE TABLE benefit_type (
    benefit_type_id     uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    benefit_code        varchar(30)  NOT NULL,
    benefit_name        varchar(100) NOT NULL,
    benefit_description text,
    created_at          timestamptz  NOT NULL DEFAULT now(),
    updated_at          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_benefit_type_code UNIQUE (benefit_code),
    CONSTRAINT uq_benefit_type_name UNIQUE (benefit_name)
);

CREATE TABLE loyalty_program (
    loyalty_program_id  uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id          uuid         NOT NULL REFERENCES airline(airline_id),
    default_currency_id uuid         NOT NULL REFERENCES currency(currency_id),
    program_code        varchar(20)  NOT NULL,
    program_name        varchar(120) NOT NULL,
    expiration_months   integer,
    created_at          timestamptz  NOT NULL DEFAULT now(),
    updated_at          timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_loyalty_program_code UNIQUE (airline_id, program_code),
    CONSTRAINT uq_loyalty_program_name UNIQUE (airline_id, program_name),
    CONSTRAINT ck_loyalty_program_expiration CHECK (expiration_months IS NULL OR expiration_months > 0)
);

CREATE TABLE loyalty_tier (
    loyalty_tier_id     uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    loyalty_program_id  uuid        NOT NULL REFERENCES loyalty_program(loyalty_program_id),
    tier_code           varchar(20) NOT NULL,
    tier_name           varchar(80) NOT NULL,
    priority_level      integer     NOT NULL,
    required_miles      integer     NOT NULL DEFAULT 0,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_loyalty_tier_code           UNIQUE (loyalty_program_id, tier_code),
    CONSTRAINT uq_loyalty_tier_name           UNIQUE (loyalty_program_id, tier_name),
    CONSTRAINT ck_loyalty_tier_priority       CHECK  (priority_level > 0),
    CONSTRAINT ck_loyalty_tier_required_miles CHECK  (required_miles >= 0)
);

CREATE TABLE customer (
    customer_id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id              uuid        NOT NULL REFERENCES airline(airline_id),
    person_id               uuid        NOT NULL REFERENCES person(person_id),
    customer_category_id    uuid        REFERENCES customer_category(customer_category_id),
    customer_since          date        NOT NULL DEFAULT current_date,
    -- ADR-004: soft delete
    is_deleted              boolean     NOT NULL DEFAULT false,
    deleted_at              timestamptz,
    deleted_by              uuid        REFERENCES user_account(user_account_id),
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_airline_person UNIQUE (airline_id, person_id)
);

CREATE TABLE loyalty_account (
    loyalty_account_id  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id         uuid        NOT NULL REFERENCES customer(customer_id),
    loyalty_program_id  uuid        NOT NULL REFERENCES loyalty_program(loyalty_program_id),
    account_number      varchar(40) NOT NULL,
    opened_at           timestamptz NOT NULL DEFAULT now(),
    -- ADR-004: soft delete
    is_deleted          boolean     NOT NULL DEFAULT false,
    deleted_at          timestamptz,
    deleted_by          uuid        REFERENCES user_account(user_account_id),
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_loyalty_account_number           UNIQUE (account_number),
    CONSTRAINT uq_loyalty_account_customer_program UNIQUE (customer_id, loyalty_program_id)
);

-- ADR-007: sequence_no reemplaza UNIQUE (loyalty_account_id, assigned_at)
CREATE TABLE loyalty_account_tier (
    loyalty_account_tier_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    loyalty_account_id      uuid        NOT NULL REFERENCES loyalty_account(loyalty_account_id),
    loyalty_tier_id         uuid        NOT NULL REFERENCES loyalty_tier(loyalty_tier_id),
    -- sequence_no garantiza unicidad sin depender de precisión de timestamp
    sequence_no             serial      NOT NULL,
    assigned_at             timestamptz NOT NULL,
    expires_at              timestamptz,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_loyalty_account_tier_seq   UNIQUE (loyalty_account_id, sequence_no),
    CONSTRAINT ck_loyalty_account_tier_dates CHECK  (expires_at IS NULL OR expires_at > assigned_at)
);

-- ADR-002: transaction_type como tabla de catálogo
CREATE TABLE transaction_type (
    transaction_type_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code           varchar(20) NOT NULL,
    type_name           varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_transaction_type_code UNIQUE (type_code),
    CONSTRAINT uq_transaction_type_name UNIQUE (type_name)
);

INSERT INTO transaction_type (type_code, type_name) VALUES
    ('EARN',   'Earn Miles'),
    ('REDEEM', 'Redeem Miles'),
    ('ADJUST', 'Manual Adjustment');

-- ADR-003: created_by / updated_by en tabla operacional
CREATE TABLE miles_transaction (
    miles_transaction_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    loyalty_account_id      uuid        NOT NULL REFERENCES loyalty_account(loyalty_account_id),
    -- ADR-002: FK a tabla de catálogo
    transaction_type_id     uuid        NOT NULL REFERENCES transaction_type(transaction_type_id),
    miles_delta             integer     NOT NULL,
    occurred_at             timestamptz NOT NULL,
    reference_code          varchar(60),
    notes                   text,
    -- ADR-003: auditoría de usuario
    created_by              uuid        REFERENCES user_account(user_account_id),
    updated_by              uuid        REFERENCES user_account(user_account_id),
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_miles_delta_non_zero CHECK (miles_delta <> 0)
);

CREATE TABLE customer_benefit (
    customer_benefit_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id         uuid        NOT NULL REFERENCES customer(customer_id),
    benefit_type_id     uuid        NOT NULL REFERENCES benefit_type(benefit_type_id),
    granted_at          timestamptz NOT NULL,
    expires_at          timestamptz,
    notes               text,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_benefit      UNIQUE (customer_id, benefit_type_id, granted_at),
    CONSTRAINT ck_customer_benefit_dates CHECK  (expires_at IS NULL OR expires_at > granted_at)
);

-- ============================================================
-- AEROPUERTO
-- ============================================================

CREATE TABLE airport (
    airport_id      uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    address_id      uuid         NOT NULL REFERENCES address(address_id),
    airport_name    varchar(150) NOT NULL,
    iata_code       varchar(3),
    icao_code       varchar(4),
    is_active       boolean      NOT NULL DEFAULT true,
    created_at      timestamptz  NOT NULL DEFAULT now(),
    updated_at      timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_airport_iata     UNIQUE (iata_code),
    CONSTRAINT uq_airport_icao     UNIQUE (icao_code),
    CONSTRAINT ck_airport_iata_len CHECK  (iata_code IS NULL OR char_length(iata_code) = 3),
    CONSTRAINT ck_airport_icao_len CHECK  (icao_code IS NULL OR char_length(icao_code) = 4)
);

CREATE TABLE terminal (
    terminal_id     uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    airport_id      uuid        NOT NULL REFERENCES airport(airport_id),
    terminal_code   varchar(10) NOT NULL,
    terminal_name   varchar(80),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_terminal_code UNIQUE (airport_id, terminal_code)
);

CREATE TABLE boarding_gate (
    boarding_gate_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    terminal_id         uuid        NOT NULL REFERENCES terminal(terminal_id),
    gate_code           varchar(10) NOT NULL,
    is_active           boolean     NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_boarding_gate_code UNIQUE (terminal_id, gate_code)
);

CREATE TABLE runway (
    runway_id       uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    airport_id      uuid        NOT NULL REFERENCES airport(airport_id),
    runway_code     varchar(20) NOT NULL,
    length_meters   integer     NOT NULL,
    surface_type    varchar(30),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_runway_code    UNIQUE (airport_id, runway_code),
    CONSTRAINT ck_runway_length  CHECK  (length_meters > 0)
);

CREATE TABLE airport_regulation (
    airport_regulation_id   uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    airport_id              uuid         NOT NULL REFERENCES airport(airport_id),
    regulation_code         varchar(30)  NOT NULL,
    regulation_title        varchar(150) NOT NULL,
    issuing_authority       varchar(120) NOT NULL,
    effective_from          date         NOT NULL,
    effective_to            date,
    created_at              timestamptz  NOT NULL DEFAULT now(),
    updated_at              timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_airport_regulation      UNIQUE (airport_id, regulation_code),
    CONSTRAINT ck_airport_regulation_dates CHECK  (effective_to IS NULL OR effective_to >= effective_from)
);

-- ============================================================
-- AERONAVE
-- ============================================================

CREATE TABLE aircraft_manufacturer (
    aircraft_manufacturer_id    uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    manufacturer_name           varchar(120) NOT NULL,
    created_at                  timestamptz  NOT NULL DEFAULT now(),
    updated_at                  timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_manufacturer_name UNIQUE (manufacturer_name)
);

CREATE TABLE aircraft_model (
    aircraft_model_id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_manufacturer_id    uuid        NOT NULL REFERENCES aircraft_manufacturer(aircraft_manufacturer_id),
    model_code                  varchar(30) NOT NULL,
    model_name                  varchar(120) NOT NULL,
    max_range_km                integer,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_model_code  UNIQUE (aircraft_manufacturer_id, model_code),
    CONSTRAINT uq_aircraft_model_name  UNIQUE (aircraft_manufacturer_id, model_name),
    CONSTRAINT ck_aircraft_model_range CHECK  (max_range_km IS NULL OR max_range_km > 0)
);

CREATE TABLE cabin_class (
    cabin_class_id  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    class_code      varchar(10) NOT NULL,
    class_name      varchar(60) NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_cabin_class_code UNIQUE (class_code),
    CONSTRAINT uq_cabin_class_name UNIQUE (class_name)
);

CREATE TABLE aircraft (
    aircraft_id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id          uuid        NOT NULL REFERENCES airline(airline_id),
    aircraft_model_id   uuid        NOT NULL REFERENCES aircraft_model(aircraft_model_id),
    registration_number varchar(20) NOT NULL,
    serial_number       varchar(40) NOT NULL,
    in_service_on       date,
    retired_on          date,
    -- ADR-004: soft delete
    is_deleted          boolean     NOT NULL DEFAULT false,
    deleted_at          timestamptz,
    deleted_by          uuid        REFERENCES user_account(user_account_id),
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_registration    UNIQUE (registration_number),
    CONSTRAINT uq_aircraft_serial          UNIQUE (serial_number),
    CONSTRAINT ck_aircraft_service_dates   CHECK  (retired_on IS NULL OR in_service_on IS NULL OR retired_on >= in_service_on)
);

CREATE TABLE aircraft_cabin (
    aircraft_cabin_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_id         uuid        NOT NULL REFERENCES aircraft(aircraft_id),
    cabin_class_id      uuid        NOT NULL REFERENCES cabin_class(cabin_class_id),
    cabin_code          varchar(10) NOT NULL,
    deck_number         smallint    NOT NULL DEFAULT 1,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_cabin_code  UNIQUE (aircraft_id, cabin_code),
    CONSTRAINT ck_aircraft_cabin_deck  CHECK  (deck_number > 0)
);

CREATE TABLE aircraft_seat (
    aircraft_seat_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_cabin_id   uuid        NOT NULL REFERENCES aircraft_cabin(aircraft_cabin_id),
    seat_row_number     integer     NOT NULL,
    seat_column_code    varchar(3)  NOT NULL,
    is_window           boolean     NOT NULL DEFAULT false,
    is_aisle            boolean     NOT NULL DEFAULT false,
    is_exit_row         boolean     NOT NULL DEFAULT false,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_aircraft_seat_position UNIQUE (aircraft_cabin_id, seat_row_number, seat_column_code),
    CONSTRAINT ck_aircraft_seat_row      CHECK  (seat_row_number > 0)
);

CREATE TABLE maintenance_provider (
    maintenance_provider_id uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    address_id              uuid         REFERENCES address(address_id),
    provider_name           varchar(150) NOT NULL,
    contact_name            varchar(120),
    created_at              timestamptz  NOT NULL DEFAULT now(),
    updated_at              timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_maintenance_provider_name UNIQUE (provider_name)
);

CREATE TABLE maintenance_type (
    maintenance_type_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code           varchar(20) NOT NULL,
    type_name           varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_maintenance_type_code UNIQUE (type_code),
    CONSTRAINT uq_maintenance_type_name UNIQUE (type_name)
);

-- ADR-002: maintenance_event_status como tabla de catálogo
CREATE TABLE maintenance_event_status (
    maintenance_event_status_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code                 varchar(20) NOT NULL,
    status_name                 varchar(80) NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_maintenance_event_status_code UNIQUE (status_code),
    CONSTRAINT uq_maintenance_event_status_name UNIQUE (status_name)
);

INSERT INTO maintenance_event_status (status_code, status_name) VALUES
    ('PLANNED',     'Planned'),
    ('IN_PROGRESS', 'In Progress'),
    ('COMPLETED',   'Completed'),
    ('CANCELLED',   'Cancelled');

CREATE TABLE maintenance_event (
    maintenance_event_id        uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    aircraft_id                 uuid        NOT NULL REFERENCES aircraft(aircraft_id),
    maintenance_type_id         uuid        NOT NULL REFERENCES maintenance_type(maintenance_type_id),
    maintenance_provider_id     uuid        REFERENCES maintenance_provider(maintenance_provider_id),
    -- ADR-002: FK a tabla de catálogo
    maintenance_event_status_id uuid        NOT NULL REFERENCES maintenance_event_status(maintenance_event_status_id),
    started_at                  timestamptz NOT NULL,
    completed_at                timestamptz,
    notes                       text,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_maintenance_event_dates CHECK (completed_at IS NULL OR completed_at >= started_at)
);

-- ============================================================
-- OPERACIONES DE VUELO
-- ============================================================

CREATE TABLE flight_status (
    flight_status_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code         varchar(20) NOT NULL,
    status_name         varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_flight_status_code UNIQUE (status_code),
    CONSTRAINT uq_flight_status_name UNIQUE (status_name)
);

CREATE TABLE delay_reason_type (
    delay_reason_type_id    uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    reason_code             varchar(20)  NOT NULL,
    reason_name             varchar(100) NOT NULL,
    created_at              timestamptz  NOT NULL DEFAULT now(),
    updated_at              timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT uq_delay_reason_code UNIQUE (reason_code),
    CONSTRAINT uq_delay_reason_name UNIQUE (reason_name)
);

CREATE TABLE flight (
    flight_id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id          uuid        NOT NULL REFERENCES airline(airline_id),
    aircraft_id         uuid        NOT NULL REFERENCES aircraft(aircraft_id),
    flight_status_id    uuid        NOT NULL REFERENCES flight_status(flight_status_id),
    flight_number       varchar(12) NOT NULL,
    service_date        date        NOT NULL,
    -- ADR-004: soft delete
    is_deleted          boolean     NOT NULL DEFAULT false,
    deleted_at          timestamptz,
    deleted_by          uuid        REFERENCES user_account(user_account_id),
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_flight_instance UNIQUE (airline_id, flight_number, service_date)
);

CREATE TABLE flight_segment (
    flight_segment_id       uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    flight_id               uuid        NOT NULL REFERENCES flight(flight_id),
    origin_airport_id       uuid        NOT NULL REFERENCES airport(airport_id),
    destination_airport_id  uuid        NOT NULL REFERENCES airport(airport_id),
    segment_number          integer     NOT NULL,
    scheduled_departure_at  timestamptz NOT NULL,
    scheduled_arrival_at    timestamptz NOT NULL,
    actual_departure_at     timestamptz,
    actual_arrival_at       timestamptz,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_flight_segment_number    UNIQUE (flight_id, segment_number),
    CONSTRAINT ck_flight_segment_airports  CHECK  (origin_airport_id <> destination_airport_id),
    CONSTRAINT ck_flight_segment_schedule  CHECK  (scheduled_arrival_at > scheduled_departure_at),
    CONSTRAINT ck_flight_segment_actuals   CHECK  (
        actual_arrival_at IS NULL
        OR actual_departure_at IS NULL
        OR actual_arrival_at >= actual_departure_at
    )
);

-- ADR-003: created_by / updated_by en tabla operacional
CREATE TABLE flight_delay (
    flight_delay_id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    flight_segment_id       uuid        NOT NULL REFERENCES flight_segment(flight_segment_id),
    delay_reason_type_id    uuid        NOT NULL REFERENCES delay_reason_type(delay_reason_type_id),
    reported_at             timestamptz NOT NULL,
    delay_minutes           integer     NOT NULL,
    notes                   text,
    -- ADR-003: auditoría de usuario
    created_by              uuid        REFERENCES user_account(user_account_id),
    updated_by              uuid        REFERENCES user_account(user_account_id),
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT ck_flight_delay_minutes CHECK (delay_minutes > 0)
);

-- ============================================================
-- VENTAS, RESERVAS Y TICKETING
-- ============================================================

CREATE TABLE reservation_status (
    reservation_status_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code             varchar(20) NOT NULL,
    status_name             varchar(80) NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_reservation_status_code UNIQUE (status_code),
    CONSTRAINT uq_reservation_status_name UNIQUE (status_name)
);

CREATE TABLE sale_channel (
    sale_channel_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    channel_code    varchar(20) NOT NULL,
    channel_name    varchar(80) NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_sale_channel_code UNIQUE (channel_code),
    CONSTRAINT uq_sale_channel_name UNIQUE (channel_name)
);

CREATE TABLE fare_class (
    fare_class_id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    cabin_class_id              uuid        NOT NULL REFERENCES cabin_class(cabin_class_id),
    fare_class_code             varchar(10) NOT NULL,
    fare_class_name             varchar(80) NOT NULL,
    is_refundable_by_default    boolean     NOT NULL DEFAULT false,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_fare_class_code UNIQUE (fare_class_code),
    CONSTRAINT uq_fare_class_name UNIQUE (fare_class_name)
);

-- ADR-006: is_active controla vigencia de tarifas
CREATE TABLE fare (
    fare_id                 uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
    airline_id              uuid           NOT NULL REFERENCES airline(airline_id),
    origin_airport_id       uuid           NOT NULL REFERENCES airport(airport_id),
    destination_airport_id  uuid           NOT NULL REFERENCES airport(airport_id),
    fare_class_id           uuid           NOT NULL REFERENCES fare_class(fare_class_id),
    currency_id             uuid           NOT NULL REFERENCES currency(currency_id),
    fare_code               varchar(30)    NOT NULL,
    base_amount             numeric(12, 2) NOT NULL,
    valid_from              date           NOT NULL,
    valid_to                date,
    -- ADR-006: columna de vigencia activa
    is_active               boolean        NOT NULL DEFAULT true,
    baggage_allowance_qty   integer        NOT NULL DEFAULT 0,
    change_penalty_amount   numeric(12, 2),
    refund_penalty_amount   numeric(12, 2),
    created_at              timestamptz    NOT NULL DEFAULT now(),
    updated_at              timestamptz    NOT NULL DEFAULT now(),
    CONSTRAINT uq_fare_code              UNIQUE (fare_code),
    CONSTRAINT ck_fare_airports          CHECK  (origin_airport_id <> destination_airport_id),
    CONSTRAINT ck_fare_base_amount       CHECK  (base_amount >= 0),
    CONSTRAINT ck_fare_baggage_allowance CHECK  (baggage_allowance_qty >= 0),
    CONSTRAINT ck_fare_change_penalty    CHECK  (change_penalty_amount IS NULL OR change_penalty_amount >= 0),
    CONSTRAINT ck_fare_refund_penalty    CHECK  (refund_penalty_amount IS NULL OR refund_penalty_amount >= 0),
    CONSTRAINT ck_fare_validity          CHECK  (valid_to IS NULL OR valid_to >= valid_from)
);

CREATE TABLE ticket_status (
    ticket_status_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code         varchar(20) NOT NULL,
    status_name         varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_ticket_status_code UNIQUE (status_code),
    CONSTRAINT uq_ticket_status_name UNIQUE (status_name)
);

-- ADR-002: passenger_type como tabla de catálogo
CREATE TABLE passenger_type (
    passenger_type_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code           varchar(20) NOT NULL,
    type_name           varchar(80) NOT NULL,
    min_age_years       integer,
    max_age_years       integer,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_passenger_type_code UNIQUE (type_code),
    CONSTRAINT uq_passenger_type_name UNIQUE (type_name)
);

INSERT INTO passenger_type (type_code, type_name, min_age_years, max_age_years) VALUES
    ('ADULT',               'Adult',                 18, NULL),
    ('CHILD',               'Child',                  2,   17),
    ('INFANT',              'Infant',                 0,    1),
    ('UNACCOMPANIED_MINOR', 'Unaccompanied Minor',    5,   17);

CREATE TABLE reservation (
    reservation_id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    booked_by_customer_id   uuid        REFERENCES customer(customer_id),
    reservation_status_id   uuid        NOT NULL REFERENCES reservation_status(reservation_status_id),
    sale_channel_id         uuid        NOT NULL REFERENCES sale_channel(sale_channel_id),
    reservation_code        varchar(20) NOT NULL,
    booked_at               timestamptz NOT NULL,
    expires_at              timestamptz,
    notes                   text,
    -- ADR-004: soft delete
    is_deleted              boolean     NOT NULL DEFAULT false,
    deleted_at              timestamptz,
    deleted_by              uuid        REFERENCES user_account(user_account_id),
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_reservation_code  UNIQUE (reservation_code),
    CONSTRAINT ck_reservation_dates CHECK  (expires_at IS NULL OR expires_at > booked_at)
);

CREATE TABLE reservation_passenger (
    reservation_passenger_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id              uuid        NOT NULL REFERENCES reservation(reservation_id),
    person_id                   uuid        NOT NULL REFERENCES person(person_id),
    -- ADR-002: FK a tabla de catálogo
    passenger_type_id           uuid        NOT NULL REFERENCES passenger_type(passenger_type_id),
    passenger_sequence_no       integer     NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_reservation_passenger_person   UNIQUE (reservation_id, person_id),
    CONSTRAINT uq_reservation_passenger_sequence UNIQUE (reservation_id, passenger_sequence_no),
    CONSTRAINT ck_reservation_passenger_sequence CHECK  (passenger_sequence_no > 0)
);

CREATE TABLE sale (
    sale_id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id      uuid        NOT NULL REFERENCES reservation(reservation_id),
    currency_id         uuid        NOT NULL REFERENCES currency(currency_id),
    sale_code           varchar(30) NOT NULL,
    sold_at             timestamptz NOT NULL,
    external_reference  varchar(50),
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_sale_code UNIQUE (sale_code)
);

CREATE TABLE ticket (
    ticket_id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id                     uuid        NOT NULL REFERENCES sale(sale_id),
    reservation_passenger_id    uuid        NOT NULL REFERENCES reservation_passenger(reservation_passenger_id),
    fare_id                     uuid        NOT NULL REFERENCES fare(fare_id),
    ticket_status_id            uuid        NOT NULL REFERENCES ticket_status(ticket_status_id),
    ticket_number               varchar(20) NOT NULL,
    issued_at                   timestamptz NOT NULL,
    -- ADR-004: soft delete
    is_deleted                  boolean     NOT NULL DEFAULT false,
    deleted_at                  timestamptz,
    deleted_by                  uuid        REFERENCES user_account(user_account_id),
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_ticket_number UNIQUE (ticket_number)
);

CREATE TABLE ticket_segment (
    ticket_segment_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id           uuid        NOT NULL REFERENCES ticket(ticket_id),
    flight_segment_id   uuid        NOT NULL REFERENCES flight_segment(flight_segment_id),
    segment_sequence_no integer     NOT NULL,
    fare_basis_code     varchar(20),
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_ticket_segment_sequence UNIQUE (ticket_id, segment_sequence_no),
    CONSTRAINT uq_ticket_segment_flight   UNIQUE (ticket_id, flight_segment_id),
    CONSTRAINT uq_ticket_segment_pair     UNIQUE (ticket_segment_id, flight_segment_id),
    CONSTRAINT ck_ticket_segment_sequence CHECK  (segment_sequence_no > 0)
);

-- ADR-002: assignment_source como tabla de catálogo
CREATE TABLE assignment_source_type (
    assignment_source_type_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    source_code                 varchar(20) NOT NULL,
    source_name                 varchar(80) NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_assignment_source_code UNIQUE (source_code),
    CONSTRAINT uq_assignment_source_name UNIQUE (source_name)
);

INSERT INTO assignment_source_type (source_code, source_name) VALUES
    ('AUTO',     'Automatic Assignment'),
    ('MANUAL',   'Manual Assignment'),
    ('CUSTOMER', 'Customer Selected');

CREATE TABLE seat_assignment (
    seat_assignment_id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_segment_id           uuid        NOT NULL,
    flight_segment_id           uuid        NOT NULL,
    aircraft_seat_id            uuid        NOT NULL REFERENCES aircraft_seat(aircraft_seat_id),
    -- ADR-002: FK a tabla de catálogo
    assignment_source_type_id   uuid        NOT NULL REFERENCES assignment_source_type(assignment_source_type_id),
    assigned_at                 timestamptz NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_seat_assignment_ticket_segment UNIQUE (ticket_segment_id),
    CONSTRAINT uq_seat_assignment_flight_seat    UNIQUE (flight_segment_id, aircraft_seat_id),
    CONSTRAINT fk_seat_assignment_ticket_segment FOREIGN KEY (ticket_segment_id, flight_segment_id)
        REFERENCES ticket_segment(ticket_segment_id, flight_segment_id)
);

-- ADR-002: baggage_type y baggage_status como tablas de catálogo
CREATE TABLE baggage_type (
    baggage_type_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code       varchar(20) NOT NULL,
    type_name       varchar(80) NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_baggage_type_code UNIQUE (type_code),
    CONSTRAINT uq_baggage_type_name UNIQUE (type_name)
);

INSERT INTO baggage_type (type_code, type_name) VALUES
    ('CHECKED',  'Checked Baggage'),
    ('CARRY_ON', 'Carry-On Baggage'),
    ('SPECIAL',  'Special Item');

CREATE TABLE baggage_status (
    baggage_status_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code         varchar(20) NOT NULL,
    status_name         varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_baggage_status_code UNIQUE (status_code),
    CONSTRAINT uq_baggage_status_name UNIQUE (status_name)
);

INSERT INTO baggage_status (status_code, status_name) VALUES
    ('REGISTERED', 'Registered'),
    ('LOADED',     'Loaded'),
    ('CLAIMED',    'Claimed'),
    ('LOST',       'Lost');

CREATE TABLE baggage (
    baggage_id          uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_segment_id   uuid           NOT NULL REFERENCES ticket_segment(ticket_segment_id),
    -- ADR-002: FK a tablas de catálogo
    baggage_type_id     uuid           NOT NULL REFERENCES baggage_type(baggage_type_id),
    baggage_status_id   uuid           NOT NULL REFERENCES baggage_status(baggage_status_id),
    baggage_tag         varchar(30)    NOT NULL,
    weight_kg           numeric(6, 2)  NOT NULL,
    checked_at          timestamptz,
    created_at          timestamptz    NOT NULL DEFAULT now(),
    updated_at          timestamptz    NOT NULL DEFAULT now(),
    CONSTRAINT uq_baggage_tag    UNIQUE (baggage_tag),
    CONSTRAINT ck_baggage_weight CHECK  (weight_kg > 0)
);

-- ============================================================
-- ABORDAJE
-- ============================================================

CREATE TABLE boarding_group (
    boarding_group_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    group_code          varchar(10) NOT NULL,
    group_name          varchar(50) NOT NULL,
    sequence_no         integer     NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_boarding_group_code     UNIQUE (group_code),
    CONSTRAINT uq_boarding_group_name     UNIQUE (group_name),
    CONSTRAINT ck_boarding_group_sequence CHECK  (sequence_no > 0)
);

CREATE TABLE check_in_status (
    check_in_status_id  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code         varchar(20) NOT NULL,
    status_name         varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_check_in_status_code UNIQUE (status_code),
    CONSTRAINT uq_check_in_status_name UNIQUE (status_name)
);

CREATE TABLE check_in (
    check_in_id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_segment_id       uuid        NOT NULL REFERENCES ticket_segment(ticket_segment_id),
    check_in_status_id      uuid        NOT NULL REFERENCES check_in_status(check_in_status_id),
    boarding_group_id       uuid        REFERENCES boarding_group(boarding_group_id),
    checked_in_by_user_id   uuid        REFERENCES user_account(user_account_id),
    checked_in_at           timestamptz NOT NULL,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_check_in_ticket_segment UNIQUE (ticket_segment_id)
);

CREATE TABLE boarding_pass (
    boarding_pass_id    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    check_in_id         uuid        NOT NULL REFERENCES check_in(check_in_id),
    boarding_pass_code  varchar(40) NOT NULL,
    barcode_value       varchar(120) NOT NULL,
    issued_at           timestamptz NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_boarding_pass_check_in UNIQUE (check_in_id),
    CONSTRAINT uq_boarding_pass_code     UNIQUE (boarding_pass_code),
    CONSTRAINT uq_boarding_pass_barcode  UNIQUE (barcode_value)
);

-- ADR-002: validation_result como tabla de catálogo
-- ADR-003: validated_by ya existía; se agrega created_by / updated_by
CREATE TABLE validation_result_type (
    validation_result_type_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    result_code                 varchar(20) NOT NULL,
    result_name                 varchar(80) NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_validation_result_code UNIQUE (result_code),
    CONSTRAINT uq_validation_result_name UNIQUE (result_name)
);

INSERT INTO validation_result_type (result_code, result_name) VALUES
    ('APPROVED',      'Approved'),
    ('REJECTED',      'Rejected'),
    ('MANUAL_REVIEW', 'Manual Review Required');

CREATE TABLE boarding_validation (
    boarding_validation_id      uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    boarding_pass_id            uuid        NOT NULL REFERENCES boarding_pass(boarding_pass_id),
    boarding_gate_id            uuid        REFERENCES boarding_gate(boarding_gate_id),
    validated_by_user_id        uuid        REFERENCES user_account(user_account_id),
    -- ADR-002: FK a tabla de catálogo
    validation_result_type_id   uuid        NOT NULL REFERENCES validation_result_type(validation_result_type_id),
    validated_at                timestamptz NOT NULL,
    notes                       text,
    -- ADR-003: auditoría de usuario
    created_by                  uuid        REFERENCES user_account(user_account_id),
    updated_by                  uuid        REFERENCES user_account(user_account_id),
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- PAGOS
-- ============================================================

CREATE TABLE payment_status (
    payment_status_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code         varchar(20) NOT NULL,
    status_name         varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_status_code UNIQUE (status_code),
    CONSTRAINT uq_payment_status_name UNIQUE (status_name)
);

CREATE TABLE payment_method (
    payment_method_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    method_code         varchar(20) NOT NULL,
    method_name         varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_method_code UNIQUE (method_code),
    CONSTRAINT uq_payment_method_name UNIQUE (method_name)
);

CREATE TABLE payment (
    payment_id          uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id             uuid           NOT NULL REFERENCES sale(sale_id),
    payment_status_id   uuid           NOT NULL REFERENCES payment_status(payment_status_id),
    payment_method_id   uuid           NOT NULL REFERENCES payment_method(payment_method_id),
    currency_id         uuid           NOT NULL REFERENCES currency(currency_id),
    payment_reference   varchar(40)    NOT NULL,
    amount              numeric(12, 2) NOT NULL,
    authorized_at       timestamptz,
    created_at          timestamptz    NOT NULL DEFAULT now(),
    updated_at          timestamptz    NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_reference UNIQUE (payment_reference),
    CONSTRAINT ck_payment_amount    CHECK  (amount > 0)
);

-- ADR-002: transaction_type de payment como tabla de catálogo
CREATE TABLE payment_transaction_type (
    payment_transaction_type_id uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code                   varchar(20) NOT NULL,
    type_name                   varchar(80) NOT NULL,
    created_at                  timestamptz NOT NULL DEFAULT now(),
    updated_at                  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_transaction_type_code UNIQUE (type_code),
    CONSTRAINT uq_payment_transaction_type_name UNIQUE (type_name)
);

INSERT INTO payment_transaction_type (type_code, type_name) VALUES
    ('AUTH',      'Authorization'),
    ('CAPTURE',   'Capture'),
    ('VOID',      'Void'),
    ('REFUND',    'Refund'),
    ('REVERSAL',  'Reversal');

-- ADR-003: created_by / updated_by en tabla operacional
CREATE TABLE payment_transaction (
    payment_transaction_id      uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id                  uuid           NOT NULL REFERENCES payment(payment_id),
    -- ADR-002: FK a tabla de catálogo
    payment_transaction_type_id uuid           NOT NULL REFERENCES payment_transaction_type(payment_transaction_type_id),
    transaction_reference       varchar(60)    NOT NULL,
    transaction_amount          numeric(12, 2) NOT NULL,
    processed_at                timestamptz    NOT NULL,
    provider_message            text,
    -- ADR-003: auditoría de usuario
    created_by                  uuid           REFERENCES user_account(user_account_id),
    updated_by                  uuid           REFERENCES user_account(user_account_id),
    created_at                  timestamptz    NOT NULL DEFAULT now(),
    updated_at                  timestamptz    NOT NULL DEFAULT now(),
    CONSTRAINT uq_payment_transaction_reference UNIQUE (transaction_reference),
    CONSTRAINT ck_payment_transaction_amount    CHECK  (transaction_amount > 0)
);

CREATE TABLE refund (
    refund_id           uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id          uuid           NOT NULL REFERENCES payment(payment_id),
    refund_reference    varchar(40)    NOT NULL,
    amount              numeric(12, 2) NOT NULL,
    requested_at        timestamptz    NOT NULL,
    processed_at        timestamptz,
    refund_reason       text,
    created_at          timestamptz    NOT NULL DEFAULT now(),
    updated_at          timestamptz    NOT NULL DEFAULT now(),
    CONSTRAINT uq_refund_reference  UNIQUE (refund_reference),
    CONSTRAINT ck_refund_amount     CHECK  (amount > 0),
    CONSTRAINT ck_refund_dates      CHECK  (processed_at IS NULL OR processed_at >= requested_at)
);

-- ============================================================
-- FACTURACIÓN
-- ============================================================

CREATE TABLE tax (
    tax_id              uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
    tax_code            varchar(20)    NOT NULL,
    tax_name            varchar(100)   NOT NULL,
    rate_percentage     numeric(6, 3)  NOT NULL,
    effective_from      date           NOT NULL,
    effective_to        date,
    created_at          timestamptz    NOT NULL DEFAULT now(),
    updated_at          timestamptz    NOT NULL DEFAULT now(),
    CONSTRAINT uq_tax_code   UNIQUE (tax_code),
    CONSTRAINT uq_tax_name   UNIQUE (tax_name),
    CONSTRAINT ck_tax_rate   CHECK  (rate_percentage >= 0),
    CONSTRAINT ck_tax_dates  CHECK  (effective_to IS NULL OR effective_to >= effective_from)
);

CREATE TABLE exchange_rate (
    exchange_rate_id    uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency_id    uuid           NOT NULL REFERENCES currency(currency_id),
    to_currency_id      uuid           NOT NULL REFERENCES currency(currency_id),
    effective_date      date           NOT NULL,
    rate_value          numeric(18, 8) NOT NULL,
    created_at          timestamptz    NOT NULL DEFAULT now(),
    updated_at          timestamptz    NOT NULL DEFAULT now(),
    CONSTRAINT uq_exchange_rate      UNIQUE (from_currency_id, to_currency_id, effective_date),
    CONSTRAINT ck_exchange_rate_pair  CHECK  (from_currency_id <> to_currency_id),
    CONSTRAINT ck_exchange_rate_value CHECK  (rate_value > 0)
);

CREATE TABLE invoice_status (
    invoice_status_id   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    status_code         varchar(20) NOT NULL,
    status_name         varchar(80) NOT NULL,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_invoice_status_code UNIQUE (status_code),
    CONSTRAINT uq_invoice_status_name UNIQUE (status_name)
);

-- ADR-008: invoice_type explícito + índice parcial para restricción FULL
CREATE TABLE invoice (
    invoice_id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    sale_id             uuid        NOT NULL REFERENCES sale(sale_id),
    invoice_status_id   uuid        NOT NULL REFERENCES invoice_status(invoice_status_id),
    currency_id         uuid        NOT NULL REFERENCES currency(currency_id),
    -- ADR-008: tipo de factura para controlar cardinalidad
    invoice_type        varchar(20) NOT NULL DEFAULT 'FULL'
        CHECK (invoice_type IN ('FULL', 'PARTIAL', 'CREDIT_NOTE')),
    invoice_number      varchar(40) NOT NULL,
    issued_at           timestamptz NOT NULL,
    due_at              timestamptz,
    notes               text,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT uq_invoice_number  UNIQUE (invoice_number),
    CONSTRAINT ck_invoice_dates   CHECK  (due_at IS NULL OR due_at >= issued_at)
);

-- ADR-008: garantiza como máximo una factura FULL por venta
CREATE UNIQUE INDEX uq_invoice_sale_full
    ON invoice(sale_id)
    WHERE invoice_type = 'FULL';

CREATE TABLE invoice_line (
    invoice_line_id     uuid           PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id          uuid           NOT NULL REFERENCES invoice(invoice_id),
    tax_id              uuid           REFERENCES tax(tax_id),
    line_number         integer        NOT NULL,
    line_description    varchar(200)   NOT NULL,
    quantity            numeric(12, 2) NOT NULL,
    unit_price          numeric(12, 2) NOT NULL,
    created_at          timestamptz    NOT NULL DEFAULT now(),
    updated_at          timestamptz    NOT NULL DEFAULT now(),
    CONSTRAINT uq_invoice_line_number   UNIQUE (invoice_id, line_number),
    CONSTRAINT ck_invoice_line_number   CHECK  (line_number > 0),
    CONSTRAINT ck_invoice_line_quantity CHECK  (quantity > 0),
    CONSTRAINT ck_invoice_line_price    CHECK  (unit_price >= 0)
);

-- ============================================================
-- COMENTARIOS
-- ============================================================

COMMENT ON TABLE reservation             IS 'Entidad raiz del flujo comercial y de booking del sistema.';
COMMENT ON TABLE ticket_segment          IS 'Tabla puente entre ticket y segmentos de vuelo para soportar itinerarios con escalas.';
COMMENT ON TABLE seat_assignment         IS 'Asignacion de asiento normalizada por ticket_segment con control de unicidad por segmento y asiento.';
COMMENT ON TABLE loyalty_account_tier    IS 'Historial de asignacion de nivel. sequence_no garantiza unicidad sin depender de precision de timestamp (ADR-007).';
COMMENT ON TABLE invoice_line            IS 'Detalle facturable sin totales derivados persistidos, para preservar 3FN.';
COMMENT ON TABLE gender_type             IS 'Catalogo de genero alineado con ISO 5218. Reemplaza la columna gender_code de person (ADR-005).';
COMMENT ON TABLE transaction_type        IS 'Catalogo de tipos de transaccion de millas. Reemplaza CHECK constraint en miles_transaction (ADR-002).';
COMMENT ON TABLE passenger_type          IS 'Catalogo de tipos de pasajero con rangos de edad. Reemplaza CHECK constraint en reservation_passenger (ADR-002).';
COMMENT ON TABLE baggage_type            IS 'Catalogo de tipos de equipaje. Reemplaza CHECK constraint en baggage (ADR-002).';
COMMENT ON TABLE baggage_status          IS 'Catalogo de estados de equipaje. Reemplaza CHECK constraint en baggage (ADR-002).';
COMMENT ON TABLE assignment_source_type  IS 'Catalogo de origen de asignacion de asiento. Reemplaza CHECK constraint en seat_assignment (ADR-002).';
COMMENT ON TABLE payment_transaction_type IS 'Catalogo de tipos de transaccion de pago. Reemplaza CHECK constraint en payment_transaction (ADR-002).';
COMMENT ON TABLE validation_result_type  IS 'Catalogo de resultados de validacion de abordaje. Reemplaza CHECK constraint en boarding_validation (ADR-002).';
COMMENT ON TABLE maintenance_event_status IS 'Catalogo de estados de evento de mantenimiento. Reemplaza CHECK constraint en maintenance_event (ADR-002).';
COMMENT ON COLUMN fare.is_active         IS 'Controlado por job diario deactivate_expired_fares(). False cuando valid_to < current_date (ADR-006).';
COMMENT ON COLUMN invoice.invoice_type   IS 'Solo puede existir una factura FULL por sale_id (indice parcial uq_invoice_sale_full). ADR-008.';

-- ============================================================
-- FUNCIÓN DE DESACTIVACIÓN DE TARIFAS EXPIRADAS (ADR-006)
-- ============================================================

CREATE OR REPLACE FUNCTION deactivate_expired_fares()
RETURNS void AS $$
    UPDATE fare
    SET    is_active  = false,
           updated_at = now()
    WHERE  valid_to < current_date
      AND  is_active = true;
$$ LANGUAGE sql;

-- Para programar con pg_cron (ejecutar si la extensión está disponible):
-- SELECT cron.schedule('deactivate-expired-fares', '0 0 * * *', 'SELECT deactivate_expired_fares()');

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Geografía
CREATE INDEX idx_country_continent_id        ON country(continent_id);
CREATE INDEX idx_state_country_id            ON state_province(country_id);
CREATE INDEX idx_city_state_id               ON city(state_province_id);
CREATE INDEX idx_district_city_id            ON district(city_id);
CREATE INDEX idx_address_district_id         ON address(district_id);

-- Identidad
CREATE INDEX idx_person_person_type_id       ON person(person_type_id);
CREATE INDEX idx_person_nationality          ON person(nationality_country_id);
CREATE INDEX idx_person_gender_type_id       ON person(gender_type_id);
CREATE INDEX idx_person_document_person_id   ON person_document(person_id);
CREATE INDEX idx_person_document_number      ON person_document(document_number);
CREATE INDEX idx_person_contact_person_id    ON person_contact(person_id);
CREATE INDEX idx_person_contact_value        ON person_contact(contact_value);

-- Seguridad
CREATE INDEX idx_user_account_status_id      ON user_account(user_status_id);
CREATE INDEX idx_user_role_user_account_id   ON user_role(user_account_id);
CREATE INDEX idx_user_role_role_id           ON user_role(security_role_id);
CREATE INDEX idx_role_permission_role_id     ON role_permission(security_role_id);
CREATE INDEX idx_role_permission_perm_id     ON role_permission(security_permission_id);

-- Cliente y fidelización
CREATE INDEX idx_customer_person_id          ON customer(person_id);
CREATE INDEX idx_customer_active             ON customer(customer_id) WHERE is_deleted = false;
CREATE INDEX idx_loyalty_program_airline_id  ON loyalty_program(airline_id);
CREATE INDEX idx_loyalty_account_customer_id ON loyalty_account(customer_id);
CREATE INDEX idx_loyalty_account_active      ON loyalty_account(loyalty_account_id) WHERE is_deleted = false;
CREATE INDEX idx_loyalty_account_tier_id     ON loyalty_account_tier(loyalty_account_id);
-- ADR-007: índice para consulta eficiente del tier actual
CREATE INDEX idx_lat_account_current         ON loyalty_account_tier(loyalty_account_id, assigned_at DESC);
CREATE INDEX idx_miles_transaction_account   ON miles_transaction(loyalty_account_id);

-- Aeropuerto
CREATE INDEX idx_airport_address_id          ON airport(address_id);
CREATE INDEX idx_terminal_airport_id         ON terminal(airport_id);
CREATE INDEX idx_boarding_gate_terminal_id   ON boarding_gate(terminal_id);
CREATE INDEX idx_runway_airport_id           ON runway(airport_id);

-- Aeronave
CREATE INDEX idx_aircraft_airline_id         ON aircraft(airline_id);
CREATE INDEX idx_aircraft_model_id           ON aircraft(aircraft_model_id);
CREATE INDEX idx_aircraft_active             ON aircraft(aircraft_id) WHERE is_deleted = false;
CREATE INDEX idx_aircraft_cabin_aircraft_id  ON aircraft_cabin(aircraft_id);
CREATE INDEX idx_aircraft_seat_cabin_id      ON aircraft_seat(aircraft_cabin_id);
CREATE INDEX idx_maintenance_event_aircraft  ON maintenance_event(aircraft_id);

-- Vuelos
CREATE INDEX idx_flight_aircraft_id          ON flight(aircraft_id);
CREATE INDEX idx_flight_service_date         ON flight(service_date);
CREATE INDEX idx_flight_active               ON flight(flight_id) WHERE is_deleted = false;
CREATE INDEX idx_flight_segment_flight_id    ON flight_segment(flight_id);
CREATE INDEX idx_flight_segment_origin       ON flight_segment(origin_airport_id);
CREATE INDEX idx_flight_segment_destination  ON flight_segment(destination_airport_id);
CREATE INDEX idx_flight_delay_segment_id     ON flight_delay(flight_segment_id);

-- Ventas y ticketing
CREATE INDEX idx_fare_airline_id             ON fare(airline_id);
CREATE INDEX idx_fare_active                 ON fare(origin_airport_id, destination_airport_id) WHERE is_active = true;
CREATE INDEX idx_fare_class_cabin_class_id   ON fare_class(cabin_class_id);
CREATE INDEX idx_reservation_status_id       ON reservation(reservation_status_id);
CREATE INDEX idx_reservation_customer_id     ON reservation(booked_by_customer_id);
CREATE INDEX idx_reservation_active          ON reservation(reservation_id) WHERE is_deleted = false;
CREATE INDEX idx_reservation_pax_person_id   ON reservation_passenger(person_id);
CREATE INDEX idx_sale_reservation_id         ON sale(reservation_id);
CREATE INDEX idx_ticket_sale_id              ON ticket(sale_id);
CREATE INDEX idx_ticket_res_passenger_id     ON ticket(reservation_passenger_id);
CREATE INDEX idx_ticket_active               ON ticket(ticket_id) WHERE is_deleted = false;
CREATE INDEX idx_ticket_segment_ticket_id    ON ticket_segment(ticket_id);
CREATE INDEX idx_ticket_segment_flight_id    ON ticket_segment(flight_segment_id);
CREATE INDEX idx_seat_assignment_seat_id     ON seat_assignment(aircraft_seat_id);
CREATE INDEX idx_baggage_ticket_segment_id   ON baggage(ticket_segment_id);

-- Abordaje
CREATE INDEX idx_check_in_status_id          ON check_in(check_in_status_id);
CREATE INDEX idx_boarding_pass_check_in_id   ON boarding_pass(check_in_id);
CREATE INDEX idx_boarding_validation_pass_id ON boarding_validation(boarding_pass_id);

-- Pagos
CREATE INDEX idx_payment_sale_id             ON payment(sale_id);
CREATE INDEX idx_payment_status_id           ON payment(payment_status_id);
CREATE INDEX idx_payment_transaction_pay_id  ON payment_transaction(payment_id);
CREATE INDEX idx_refund_payment_id           ON refund(payment_id);

-- Facturación
CREATE INDEX idx_exchange_rate_from_to_date  ON exchange_rate(from_currency_id, to_currency_id, effective_date);
CREATE INDEX idx_invoice_sale_id             ON invoice(sale_id);
CREATE INDEX idx_invoice_status_id           ON invoice(invoice_status_id);
CREATE INDEX idx_invoice_line_invoice_id     ON invoice_line(invoice_id);

-- ============================================================
-- VISTAS DE COMPATIBILIDAD SOFT DELETE (ADR-004)
-- ============================================================

CREATE VIEW v_active_customer AS
    SELECT * FROM customer WHERE is_deleted = false;

CREATE VIEW v_active_loyalty_account AS
    SELECT * FROM loyalty_account WHERE is_deleted = false;

CREATE VIEW v_active_aircraft AS
    SELECT * FROM aircraft WHERE is_deleted = false;

CREATE VIEW v_active_flight AS
    SELECT * FROM flight WHERE is_deleted = false;

CREATE VIEW v_active_reservation AS
    SELECT * FROM reservation WHERE is_deleted = false;

CREATE VIEW v_active_ticket AS
    SELECT * FROM ticket WHERE is_deleted = false;