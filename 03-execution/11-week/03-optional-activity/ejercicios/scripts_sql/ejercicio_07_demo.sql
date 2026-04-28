DO $$
DECLARE
    v_ticket_segment_id uuid;
    v_tag varchar(30);
BEGIN
    -- 1. Buscar un segmento de tiquete que no tenga equipaje
    SELECT ts.ticket_segment_id 
    INTO v_ticket_segment_id 
    FROM ticket_segment ts
    LEFT JOIN baggage b ON b.ticket_segment_id = ts.ticket_segment_id
    WHERE b.baggage_id IS NULL
    LIMIT 1;

    IF v_ticket_segment_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró un segmento de tiquete disponible para la prueba.';
    END IF;

    v_tag := 'TAG-' || upper(replace(left(gen_random_uuid()::text, 8), '-', ''));

    -- 2. Invocar procedimiento (dispara el trigger)
    CALL sp_register_baggage(
        v_ticket_segment_id,
        v_tag,
        'CHECKED',
        'REGISTERED',
        23.5 -- 23.5 kg
    );

    RAISE NOTICE 'Equipaje registrado con etiqueta % para el segmento %', v_tag, v_ticket_segment_id;
END;
$$;

-- 3. Verificación
SELECT 
    ts.segment_sequence_no,
    ts.updated_at AS segment_last_update,
    b.baggage_tag,
    b.baggage_type,
    b.weight_kg,
    b.checked_at
FROM ticket_segment ts
INNER JOIN baggage b ON b.ticket_segment_id = ts.ticket_segment_id
WHERE b.baggage_tag LIKE 'TAG-%'
ORDER BY b.created_at DESC;
