DROP TRIGGER IF EXISTS trg_ai_flight_delay_update_segment ON flight_delay;
DROP FUNCTION IF EXISTS fn_ai_flight_delay_update_segment();
DROP PROCEDURE IF EXISTS sp_register_flight_delay(uuid, uuid, integer, text);

-- 1. Trigger AFTER sobre flight_delay
-- Actualiza la marca de tiempo del segmento operativo cuando se registra un retraso
CREATE OR REPLACE FUNCTION fn_ai_flight_delay_update_segment()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE flight_segment
    SET updated_at = now()
    WHERE flight_segment_id = NEW.flight_segment_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_flight_delay_update_segment
AFTER INSERT ON flight_delay
FOR EACH ROW
EXECUTE FUNCTION fn_ai_flight_delay_update_segment();

-- 2. Procedimiento Almacenado
CREATE OR REPLACE PROCEDURE sp_register_flight_delay(
    p_flight_segment_id uuid,
    p_delay_reason_type_id uuid,
    p_delay_minutes integer,
    p_notes text
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar minutos
    IF p_delay_minutes <= 0 THEN
        RAISE EXCEPTION 'Los minutos de retraso deben ser mayores a cero.';
    END IF;

    INSERT INTO flight_delay (
        flight_segment_id,
        delay_reason_type_id,
        reported_at,
        delay_minutes,
        notes
    )
    VALUES (
        p_flight_segment_id,
        p_delay_reason_type_id,
        now(),
        p_delay_minutes,
        p_notes
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento: número vuelo, fecha servicio, secuencia, aeropuertos, motivo, minutos y reporte.
SELECT
    f.flight_number AS numero_vuelo,
    f.service_date AS fecha_servicio,
    fs.segment_number AS secuencia_segmento,
    ao.iata_code AS aeropuerto_origen,
    ad.iata_code AS aeropuerto_destino,
    drt.reason_name AS motivo_retraso,
    fd.delay_minutes AS minutos_retraso,
    fd.reported_at AS fecha_hora_reporte
FROM flight f
INNER JOIN flight_segment fs ON fs.flight_id = f.flight_id
INNER JOIN airport ao ON ao.airport_id = fs.origin_airport_id
INNER JOIN airport ad ON ad.airport_id = fs.destination_airport_id
INNER JOIN flight_delay fd ON fd.flight_segment_id = fs.flight_segment_id
INNER JOIN delay_reason_type drt ON drt.delay_reason_type_id = fd.delay_reason_type_id
ORDER BY fd.reported_at DESC;
