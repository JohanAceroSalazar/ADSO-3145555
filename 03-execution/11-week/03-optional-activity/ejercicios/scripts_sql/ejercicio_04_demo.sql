DO $$
DECLARE
    v_loyalty_account_id uuid;
BEGIN
    -- 1. Buscar una cuenta de fidelización existente
    SELECT loyalty_account_id
    INTO v_loyalty_account_id
    FROM loyalty_account
    LIMIT 1;

    IF v_loyalty_account_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró una cuenta de fidelización para la prueba.';
    END IF;

    -- 2. Invocar el procedimiento de acumulación de millas (dispara el trigger)
    CALL sp_add_miles_transaction(
        v_loyalty_account_id,
        'EARN',
        500,
        'DEMO-PROMO-2024',
        'Acumulación por vuelo promocional'
    );

    RAISE NOTICE 'Transacción de millas registrada para la cuenta %', v_loyalty_account_id;
END;
$$;

-- 3. Verificación
SELECT 
    la.account_number,
    la.updated_at AS account_last_update,
    mt.transaction_type,
    mt.miles_delta,
    mt.reference_code
FROM loyalty_account la
INNER JOIN miles_transaction mt ON mt.loyalty_account_id = la.loyalty_account_id
WHERE mt.reference_code = 'DEMO-PROMO-2024'
ORDER BY mt.created_at DESC;
