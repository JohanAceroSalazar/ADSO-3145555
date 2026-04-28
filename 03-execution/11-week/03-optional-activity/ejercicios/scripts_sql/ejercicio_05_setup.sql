DROP TRIGGER IF EXISTS trg_update_aircraft_status ON maintenance_event;
DROP FUNCTION IF EXISTS fn_update_aircraft_status();
DROP PROCEDURE IF EXISTS sp_register_maintenance_event(uuid, uuid, uuid, varchar, timestamp, text);

-- ============================================
-- TRIGGER: ACTUALIZAR ESTADO DE AERONAVE SEGÚN MANTENIMIENTO
-- ============================================

CREATE OR REPLACE FUNCTION fn_update_aircraft_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Ejemplo: si el mantenimiento se marca como COMPLETED,
    -- se actualiza algún indicador en la aeronave (simulado con updated_at)

    IF NEW.end_date IS NOT NULL THEN
        UPDATE aircraft
        SET updated_at = now()
        WHERE aircraft_id = NEW.aircraft_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_aircraft_status
AFTER UPDATE ON maintenance_event
FOR EACH ROW
EXECUTE FUNCTION fn_update_aircraft_status();


-- ============================================
-- PROCEDIMIENTO: REGISTRAR EVENTO DE MANTENIMIENTO
-- ============================================

CREATE OR REPLACE PROCEDURE sp_register_maintenance_event(
    p_aircraft_id uuid,
    p_maintenance_type_id uuid,
    p_provider_id uuid,
    p_status varchar,
    p_start_date timestamp,
    p_notes text
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO maintenance_event (
        aircraft_id,
        maintenance_type_id,
        maintenance_provider_id,
        status,
        start_date,
        notes
    )
    VALUES (
        p_aircraft_id,
        p_maintenance_type_id,
        p_provider_id,
        p_status,
        p_start_date,
        p_notes
    );
END;
$$;