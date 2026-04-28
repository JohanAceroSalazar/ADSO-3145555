DROP TRIGGER IF EXISTS trg_ai_invoice_line_touch_invoice ON invoice_line;
DROP FUNCTION IF EXISTS fn_ai_invoice_line_touch_invoice();
DROP PROCEDURE IF EXISTS sp_add_invoice_line(uuid, uuid, varchar, numeric, numeric);

-- 1. Trigger AFTER sobre invoice_line
-- Actualiza la marca de tiempo de la factura cabecera cuando se agrega una línea
CREATE OR REPLACE FUNCTION fn_ai_invoice_line_touch_invoice()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE invoice
    SET updated_at = now()
    WHERE invoice_id = NEW.invoice_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_invoice_line_touch_invoice
AFTER INSERT ON invoice_line
FOR EACH ROW
EXECUTE FUNCTION fn_ai_invoice_line_touch_invoice();

-- 2. Procedimiento Almacenado
CREATE OR REPLACE PROCEDURE sp_add_invoice_line(
    p_invoice_id uuid,
    p_tax_id uuid,
    p_line_number integer,
    p_line_description varchar(255),
    p_quantity numeric,
    p_unit_price numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar cantidades
    IF p_quantity <= 0 OR p_unit_price < 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor a cero y el precio no puede ser negativo.';
    END IF;

    INSERT INTO invoice_line (
        invoice_id,
        tax_id,
        line_number,
        line_description,
        quantity,
        unit_price
    )
    VALUES (
        p_invoice_id,
        p_tax_id,
        p_line_number,
        p_line_description,
        p_quantity,
        p_unit_price
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento: Relación entre venta, factura, estado, líneas e impuestos.
SELECT
    s.sale_code,
    i.invoice_number,
    ist.status_name AS invoice_status,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price,
    t.tax_name,
    curr.iso_currency_code AS currency
FROM sale s
INNER JOIN invoice i ON i.sale_id = s.sale_id
INNER JOIN invoice_status ist ON ist.invoice_status_id = i.invoice_status_id
INNER JOIN invoice_line il ON il.invoice_id = i.invoice_id
INNER JOIN tax t ON t.tax_id = il.tax_id
INNER JOIN currency curr ON curr.currency_id = i.currency_id
ORDER BY i.invoice_number, il.line_number;
