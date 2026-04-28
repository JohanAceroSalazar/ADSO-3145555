DO $$
DECLARE
    v_payment_id uuid;
BEGIN
    -- 1. Buscar un pago existente
    SELECT payment_id
    INTO v_payment_id
    FROM payment
    LIMIT 1;

    IF v_payment_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró un pago para la prueba.';
    END IF;

    -- 2. Invocar el procedimiento simulando una transacción de DEVOLUCIÓN ('REFUND')
    -- Esto disparará el trigger y creará un registro en la tabla refund
    CALL sp_register_payment_transaction(
        v_payment_id,
        'REFUND',  -- Tipo de transacción que activa el trigger
        150.00,    -- Monto
        now(),
        'Devolución parcial solicitada por el cliente'
    );

    RAISE NOTICE 'Transacción de tipo REFUND registrada para el pago %', v_payment_id;
END;
$$;

-- 3. Verificación de la Transacción y la Devolución (creada por el trigger)
SELECT 
    pt.transaction_reference,
    pt.transaction_type,
    pt.transaction_amount,
    r.refund_reference,
    r.amount,
    r.refund_reason
FROM payment_transaction pt
INNER JOIN refund r ON r.payment_id = pt.payment_id
-- Relacionamos por fecha de procesamiento y monto para encontrar la que acabamos de crear
WHERE pt.transaction_type = 'REFUND'
ORDER BY pt.created_at DESC
LIMIT 1;
