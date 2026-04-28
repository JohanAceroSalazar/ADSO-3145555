DROP TRIGGER IF EXISTS trg_ai_maintenance_event_touch_aircraft ON maintenance_event;
DROP FUNCTION IF EXISTS fn_ai_maintenance_event_touch_aircraft();
DROP PROCEDURE IF EXISTS sp_register_maintenance_event(uuid, uuid, uuid, varchar, timestamptz, text);

-- 1. Trigger AFTER sobre maintenance_event
-- Actualiza la marca de tiempo de la aeronave cuando se registra mantenimiento
CREATE OR REPLACE FUNCTION fn_ai_maintenance_event_touch_aircraft()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE aircraft
    SET updated_at = now()
    WHERE aircraft_id = NEW.aircraft_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_maintenance_event_touch_aircraft
AFTER INSERT ON maintenance_event
FOR EACH ROW
EXECUTE FUNCTION fn_ai_maintenance_event_touch_aircraft();

-- 2. Procedimiento Almacenado
CREATE OR REPLACE PROCEDURE sp_register_maintenance_event(
    p_aircraft_id uuid,
    p_maintenance_type_id uuid,
    p_maintenance_provider_id uuid,
    p_status_code varchar(20),
    p_started_at timestamptz,
    p_notes text
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar estado
    IF p_status_code NOT IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') THEN
        RAISE EXCEPTION 'Estado de mantenimiento inválido: %', p_status_code;
    END IF;

    INSERT INTO maintenance_event (
        aircraft_id,
        maintenance_type_id,
        maintenance_provider_id,
        status_code,
        started_at,
        notes
    )
    VALUES (
        p_aircraft_id,
        p_maintenance_type_id,
        p_maintenance_provider_id,
        p_status_code,
        p_started_at,
        p_notes
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento: aeronave, aerolínea, modelo, fabricante, tipo de mantenimiento, proveedor y estado.
SELECT
    a.registration_number AS matricula,
    al.airline_name AS aerolinea,
    am.model_name AS modelo,
    mfr.manufacturer_name AS fabricante,
    mt.type_name AS tipo_mantenimiento,
    mp.provider_name AS proveedor,
    me.status_code AS estado_evento,
    me.started_at AS fecha_inicio,
    me.completed_at AS fecha_finalizacion
FROM aircraft a
INNER JOIN airline al ON al.airline_id = a.airline_id
INNER JOIN aircraft_model am ON am.aircraft_model_id = a.aircraft_model_id
INNER JOIN aircraft_manufacturer mfr ON mfr.aircraft_manufacturer_id = am.aircraft_manufacturer_id
INNER JOIN maintenance_event me ON me.aircraft_id = a.aircraft_id
INNER JOIN maintenance_type mt ON mt.maintenance_type_id = me.maintenance_type_id
INNER JOIN maintenance_provider mp ON mp.maintenance_provider_id = me.maintenance_provider_id
ORDER BY me.started_at DESC;
