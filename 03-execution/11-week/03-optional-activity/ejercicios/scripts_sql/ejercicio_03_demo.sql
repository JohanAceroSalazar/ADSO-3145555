DO $$
DECLARE
    v_invoice_id uuid;
    v_tax_id uuid;
BEGIN
    -- 1. Buscar una factura existente
    SELECT invoice_id
    INTO v_invoice_id
    FROM invoice
    LIMIT 1;

    -- 2. Buscar un impuesto (ej. IVA)
    SELECT tax_id
    INTO v_tax_id
    FROM tax
    LIMIT 1;

    IF v_invoice_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró una factura para la prueba.';
    END IF;

    -- 3. Invocar procedimiento (dispara el trigger)
    CALL sp_add_invoice_line(
        v_invoice_id,
        v_tax_id,
        10, -- line_number
        'Cargo adicional por servicio especial (Demo)',
        1.0,
        50.00
    );

    RAISE NOTICE 'Línea de factura agregada exitosamente a la factura %', v_invoice_id;
END;
$$;

-- 4. Verificación de la actualización en la cabecera y la nueva línea
SELECT 
    i.invoice_number,
    i.updated_at AS header_updated_at,
    il.line_number,
    il.line_description,
    il.quantity,
    il.unit_price
FROM invoice i
INNER JOIN invoice_line il ON il.invoice_id = i.invoice_id
WHERE il.line_description = 'Servicio de equipaje adicional (Prueba)'
ORDER BY il.created_at DESC;
