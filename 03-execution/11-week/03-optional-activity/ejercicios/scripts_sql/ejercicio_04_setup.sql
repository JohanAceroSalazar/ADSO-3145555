DROP TRIGGER IF EXISTS trg_ai_miles_transaction_touch_account ON miles_transaction;
DROP FUNCTION IF EXISTS fn_ai_miles_transaction_touch_account();
DROP PROCEDURE IF EXISTS sp_add_miles_transaction(uuid, varchar, integer, varchar, text);

-- 1. Trigger AFTER sobre miles_transaction
-- Actualiza la marca de actualización de la cuenta de fidelización
CREATE OR REPLACE FUNCTION fn_ai_miles_transaction_touch_account()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE loyalty_account
    SET updated_at = now()
    WHERE loyalty_account_id = NEW.loyalty_account_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_miles_transaction_touch_account
AFTER INSERT ON miles_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_ai_miles_transaction_touch_account();

-- 2. Procedimiento Almacenado
CREATE OR REPLACE PROCEDURE sp_add_miles_transaction(
    p_loyalty_account_id uuid,
    p_transaction_type varchar(20),
    p_miles_delta integer,
    p_reference_code varchar(60),
    p_notes text
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar tipo de transacción
    IF p_transaction_type NOT IN ('EARN', 'REDEEM', 'ADJUST') THEN
        RAISE EXCEPTION 'Tipo de transacción inválido. Debe ser EARN, REDEEM o ADJUST.';
    END IF;

    -- Validar que el delta no sea cero
    IF p_miles_delta = 0 THEN
        RAISE EXCEPTION 'La cantidad de millas no puede ser cero.';
    END IF;

    INSERT INTO miles_transaction (
        loyalty_account_id,
        transaction_type,
        miles_delta,
        occurred_at,
        reference_code,
        notes
    )
    VALUES (
        p_loyalty_account_id,
        p_transaction_type,
        p_miles_delta,
        now(),
        p_reference_code,
        p_notes
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento: Relación entre cliente, persona, cuenta, programa, nivel y ventas asociadas.
SELECT
    c.customer_id AS cliente,
    p.first_name || ' ' || p.last_name AS persona_asociada,
    la.account_number AS cuenta_fidelizacion,
    lp.program_name AS programa,
    lt.tier_name AS nivel,
    lat.assigned_at AS fecha_asignacion_nivel,
    s.sale_code AS venta_relacionada
FROM customer c
INNER JOIN person p ON p.person_id = c.person_id
INNER JOIN loyalty_account la ON la.customer_id = c.customer_id
INNER JOIN loyalty_program lp ON lp.loyalty_program_id = la.loyalty_program_id
INNER JOIN loyalty_account_tier lat ON lat.loyalty_account_id = la.loyalty_account_id
INNER JOIN loyalty_tier lt ON lt.loyalty_tier_id = lat.loyalty_tier_id
INNER JOIN reservation r ON r.booked_by_customer_id = c.customer_id
INNER JOIN sale s ON s.reservation_id = r.reservation_id
ORDER BY persona_asociada, fecha_asignacion_nivel DESC;
