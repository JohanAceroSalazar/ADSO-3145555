DROP TRIGGER IF EXISTS trg_ai_payment_transaction_create_refund ON payment_transaction;
DROP FUNCTION IF EXISTS fn_ai_payment_transaction_create_refund();
DROP PROCEDURE IF EXISTS sp_register_payment_transaction(uuid, varchar, numeric, timestamptz, text);

-- 1. Trigger AFTER sobre payment_transaction
-- Si la transacción es de tipo 'REFUND' o 'REVERSAL', se genera automáticamente el registro en la tabla refund
CREATE OR REPLACE FUNCTION fn_ai_payment_transaction_create_refund()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.transaction_type IN ('REFUND', 'REVERSAL') THEN
        INSERT INTO refund (
            payment_id,
            refund_reference,
            amount,
            requested_at,
            processed_at,
            refund_reason
        )
        VALUES (
            NEW.payment_id,
            'REF-' || NEW.transaction_reference,
            NEW.transaction_amount,
            NEW.processed_at,
            NEW.processed_at,
            'Generado automáticamente por transacción de tipo ' || NEW.transaction_type || ': ' || COALESCE(NEW.provider_message, '')
        );
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_payment_transaction_create_refund
AFTER INSERT ON payment_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_ai_payment_transaction_create_refund();

-- 2. Procedimiento Almacenado
-- Registra una transacción financiera sobre un pago
CREATE OR REPLACE PROCEDURE sp_register_payment_transaction(
    p_payment_id uuid,
    p_transaction_type varchar(20),
    p_transaction_amount numeric,
    p_processed_at timestamptz,
    p_provider_message text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_transaction_reference varchar(60);
BEGIN
    -- Validar monto
    IF p_transaction_amount <= 0 THEN
        RAISE EXCEPTION 'El monto de la transacción debe ser mayor a cero.';
    END IF;

    -- Generar referencia única
    v_transaction_reference := 'TXN-' || upper(replace(left(gen_random_uuid()::text, 10), '-', ''));

    INSERT INTO payment_transaction (
        payment_id,
        transaction_reference,
        transaction_type,
        transaction_amount,
        processed_at,
        provider_message
    )
    VALUES (
        p_payment_id,
        v_transaction_reference,
        p_transaction_type,
        p_transaction_amount,
        p_processed_at,
        p_provider_message
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento MD: venta, reserva, pago, estado, método, transacción, moneda.
SELECT
    s.sale_code AS codigo_venta,
    r.reservation_code AS codigo_reserva,
    p.payment_reference AS referencia_pago,
    ps.status_name AS estado_pago,
    pm.method_name AS metodo_pago,
    pt.transaction_reference AS referencia_transaccion,
    pt.transaction_type AS tipo_transaccion,
    pt.transaction_amount AS monto_procesado,
    curr.iso_currency_code AS moneda
FROM sale s
INNER JOIN reservation r ON r.reservation_id = s.reservation_id
INNER JOIN payment p ON p.sale_id = s.sale_id
INNER JOIN payment_status ps ON ps.payment_status_id = p.payment_status_id
INNER JOIN payment_method pm ON pm.payment_method_id = p.payment_method_id
INNER JOIN payment_transaction pt ON pt.payment_id = p.payment_id
INNER JOIN currency curr ON curr.currency_id = p.currency_id
ORDER BY pt.processed_at DESC;
