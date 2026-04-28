DO $$
DECLARE
    v_airline_id uuid;
    v_origin_id uuid;
    v_dest_id uuid;
    v_fare_class_id uuid;
    v_currency_id uuid;
    v_fare_code varchar(30);
BEGIN
    -- 1. Obtener datos necesarios
    SELECT airline_id INTO v_airline_id FROM airline LIMIT 1;
    SELECT airport_id INTO v_origin_id FROM airport LIMIT 1;
    SELECT airport_id INTO v_dest_id FROM airport OFFSET 1 LIMIT 1;
    SELECT fare_class_id INTO v_fare_class_id FROM fare_class LIMIT 1;
    SELECT currency_id INTO v_currency_id FROM currency LIMIT 1;

    IF v_airline_id IS NULL OR v_origin_id IS NULL OR v_dest_id IS NULL THEN
        RAISE NOTICE 'v_airline_id: %, v_origin_id: %, v_dest_id: %', v_airline_id, v_origin_id, v_dest_id;
        RAISE EXCEPTION 'No se encontraron datos base suficientes para la prueba de tarifas.';
    END IF;

    v_fare_code := 'FARE-DEMO-' || upper(replace(left(gen_random_uuid()::text, 8), '-', ''));
    RAISE NOTICE 'Generando tarifa con código: %', v_fare_code;

    -- 2. Invocar procedimiento (dispara el trigger)
    CALL sp_publish_fare(
        v_airline_id,
        v_origin_id,
        v_dest_id,
        v_fare_class_id,
        v_currency_id,
        v_fare_code,
        299.99,
        current_date,
        (current_date + interval '1 year')::date
    );

    RAISE NOTICE 'Tarifa % publicada exitosamente.', v_fare_code;
END;
$$;

-- 3. Verificación
SELECT 
    al.airline_name,
    al.updated_at AS airline_last_update,
    f.fare_code,
    f.base_amount,
    f.valid_from
FROM airline al
INNER JOIN fare f ON f.airline_id = al.airline_id
WHERE f.fare_code LIKE 'FARE-DEMO-%'
ORDER BY f.created_at DESC;
