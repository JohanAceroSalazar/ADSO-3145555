DROP TRIGGER IF EXISTS trg_ai_baggage_touch_segment ON baggage;
DROP FUNCTION IF EXISTS fn_ai_baggage_touch_segment();
DROP PROCEDURE IF EXISTS sp_register_baggage(uuid, varchar, varchar, varchar, numeric);

-- 1. Trigger AFTER sobre baggage
-- Actualiza la marca de tiempo del segmento de tiquete cuando se registra equipaje
CREATE OR REPLACE FUNCTION fn_ai_baggage_touch_segment()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ticket_segment
    SET updated_at = now()
    WHERE ticket_segment_id = NEW.ticket_segment_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_baggage_touch_segment
AFTER INSERT ON baggage
FOR EACH ROW
EXECUTE FUNCTION fn_ai_baggage_touch_segment();

-- 2. Procedimiento Almacenado
CREATE OR REPLACE PROCEDURE sp_register_baggage(
    p_ticket_segment_id uuid,
    p_baggage_tag varchar(30),
    p_baggage_type varchar(20),
    p_baggage_status varchar(20),
    p_weight_kg numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validaciones de tipo y estado (basadas en restricciones CHECK del modelo)
    IF p_baggage_type NOT IN ('CHECKED', 'CARRY_ON', 'SPECIAL') THEN
        RAISE EXCEPTION 'Tipo de equipaje inválido: %', p_baggage_type;
    END IF;

    IF p_baggage_status NOT IN ('REGISTERED', 'LOADED', 'CLAIMED', 'LOST') THEN
        RAISE EXCEPTION 'Estado de equipaje inválido: %', p_baggage_status;
    END IF;

    IF p_weight_kg <= 0 THEN
        RAISE EXCEPTION 'El peso debe ser mayor a cero.';
    END IF;

    INSERT INTO baggage (
        ticket_segment_id,
        baggage_tag,
        baggage_type,
        baggage_status,
        weight_kg,
        checked_at
    )
    VALUES (
        p_ticket_segment_id,
        p_baggage_tag,
        p_baggage_type,
        p_baggage_status,
        p_weight_kg,
        now()
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento: tiquete, secuencia segmento, vuelo, cabina, asiento y equipaje.
SELECT
    t.ticket_number AS numero_tiquete,
    ts.segment_sequence_no AS secuencia_segmento_ticketed,
    f.flight_number AS numero_vuelo_segmento,
    cc.class_name AS cabina,
    aseat.seat_row_number AS fila_asiento,
    aseat.seat_column_code AS columna_asiento,
    b.baggage_tag AS etiqueta_equipaje,
    b.baggage_type AS tipo_equipaje,
    b.baggage_status AS estado_equipaje
FROM ticket t
INNER JOIN ticket_segment ts ON ts.ticket_id = t.ticket_id
INNER JOIN flight_segment fs ON fs.flight_segment_id = ts.flight_segment_id
INNER JOIN flight f ON f.flight_id = fs.flight_id
LEFT JOIN seat_assignment sa ON sa.ticket_segment_id = ts.ticket_segment_id
LEFT JOIN aircraft_seat aseat ON aseat.aircraft_seat_id = sa.aircraft_seat_id
LEFT JOIN aircraft_cabin ac ON ac.aircraft_cabin_id = aseat.aircraft_cabin_id
LEFT JOIN cabin_class cc ON cc.cabin_class_id = ac.cabin_class_id
LEFT JOIN baggage b ON b.ticket_segment_id = ts.ticket_segment_id
ORDER BY t.ticket_number, ts.segment_sequence_no;
