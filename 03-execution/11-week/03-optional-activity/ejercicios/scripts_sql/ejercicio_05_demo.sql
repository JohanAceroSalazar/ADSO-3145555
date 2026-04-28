DO $$
DECLARE
    v_aircraft_id uuid;
    v_maintenance_type_id uuid;
    v_maintenance_provider_id uuid;
BEGIN
    -- 1. Buscar una aeronave
    SELECT aircraft_id INTO v_aircraft_id FROM aircraft LIMIT 1;

    -- 2. Buscar tipo de mantenimiento
    SELECT maintenance_type_id INTO v_maintenance_type_id FROM maintenance_type LIMIT 1;

    -- 3. Buscar proveedor de mantenimiento
    SELECT maintenance_provider_id INTO v_maintenance_provider_id FROM maintenance_provider LIMIT 1;

    IF v_aircraft_id IS NULL OR v_maintenance_type_id IS NULL OR v_maintenance_provider_id IS NULL THEN
        RAISE EXCEPTION 'No se encontraron datos base para la prueba de mantenimiento.';
    END IF;

    -- 4. Invocar procedimiento (dispara el trigger)
    CALL sp_register_maintenance_event(
        v_aircraft_id,
        v_maintenance_type_id,
        v_maintenance_provider_id,
        'IN_PROGRESS',
        now(),
        'Mantenimiento preventivo de rutina (Demo)'
    );

    RAISE NOTICE 'Evento de mantenimiento registrado para la aeronave %', v_aircraft_id;
END;
$$;

-- 5. Verificación
SELECT 
    a.registration_number,
    a.updated_at AS aircraft_last_update,
    me.status_code,
    me.notes,
    mt.type_name
FROM aircraft a
INNER JOIN maintenance_event me ON me.aircraft_id = a.aircraft_id
INNER JOIN maintenance_type mt ON mt.maintenance_type_id = me.maintenance_type_id
WHERE me.notes = 'Mantenimiento preventivo de rutina (Demo)'
ORDER BY me.created_at DESC;
