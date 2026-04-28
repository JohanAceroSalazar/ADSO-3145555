DO $$
DECLARE
    v_flight_segment_id uuid;
    v_delay_reason_type_id uuid;
BEGIN
    -- 1. Buscar un segmento de vuelo operativo
    SELECT flight_segment_id INTO v_flight_segment_id FROM flight_segment LIMIT 1;

    -- 2. Buscar tipo de razón de retraso
    SELECT delay_reason_type_id INTO v_delay_reason_type_id FROM delay_reason_type LIMIT 1;

    IF v_flight_segment_id IS NULL OR v_delay_reason_type_id IS NULL THEN
        RAISE EXCEPTION 'No se encontraron datos base para la prueba de retrasos.';
    END IF;

    -- 3. Invocar procedimiento (dispara el trigger)
    CALL sp_register_flight_delay(
        v_flight_segment_id,
        v_delay_reason_type_id,
        45, -- 45 minutos
        'Retraso por condiciones climáticas en origen (Demo)'
    );

    RAISE NOTICE 'Retraso registrado para el segmento %', v_flight_segment_id;
END;
$$;

-- 4. Verificación
SELECT 
    fs.segment_number,
    fs.updated_at AS segment_last_update,
    fd.delay_minutes,
    fd.notes,
    drt.reason_name
FROM flight_segment fs
INNER JOIN flight_delay fd ON fd.flight_segment_id = fs.flight_segment_id
INNER JOIN delay_reason_type drt ON drt.delay_reason_type_id = fd.delay_reason_type_id
WHERE fd.notes = 'Retraso por condiciones climáticas en origen (Demo)'
ORDER BY fd.created_at DESC;
