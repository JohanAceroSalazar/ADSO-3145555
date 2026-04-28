DO $$
DECLARE
    v_person_id uuid;
    v_doc_type_id uuid;
    v_country_id uuid;
    v_doc_num varchar(64);
BEGIN
    -- 1. Obtener datos necesarios
    SELECT person_id INTO v_person_id FROM person LIMIT 1;
    SELECT document_type_id INTO v_doc_type_id FROM document_type LIMIT 1;
    SELECT country_id INTO v_country_id FROM country LIMIT 1;

    IF v_person_id IS NULL OR v_doc_type_id IS NULL OR v_country_id IS NULL THEN
        RAISE NOTICE 'v_person_id: %, v_doc_type_id: %, v_country_id: %', v_person_id, v_doc_type_id, v_country_id;
        RAISE EXCEPTION 'No se encontraron datos base suficientes para la prueba de identidad.';
    END IF;

    v_doc_num := 'DOC-' || upper(replace(left(gen_random_uuid()::text, 12), '-', ''));
    RAISE NOTICE 'Registrando documento con número: %', v_doc_num;

    -- 2. Invocar procedimiento (dispara el trigger)
    CALL sp_register_person_document(
        v_person_id,
        v_doc_type_id,
        v_country_id,
        v_doc_num,
        (current_date - interval '1 year')::date,
        (current_date + interval '5 years')::date
    );

    RAISE NOTICE 'Documento % registrado para la persona %', v_doc_num, v_person_id;
END;
$$;

-- 3. Verificación
SELECT 
    p.first_name || ' ' || p.last_name AS person_name,
    p.updated_at AS person_last_update,
    pd.document_number,
    dt.type_name AS document_type,
    pd.expires_on
FROM person p
INNER JOIN person_document pd ON pd.person_id = p.person_id
INNER JOIN document_type dt ON dt.document_type_id = pd.document_type_id
WHERE pd.document_number LIKE 'DOC-%'
ORDER BY pd.created_at DESC;
