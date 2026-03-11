--Ver el precio de un producto
CREATE OR REPLACE FUNCTION get_product_price(prod_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    product_price NUMERIC;
BEGIN
    SELECT price
    INTO product_price
    FROM product
    WHERE id_product = prod_id;

    RETURN product_price;
END;
$$ LANGUAGE plpgsql;

SELECT get_product_price('6bc20015-524e-4e6f-acc1-ccde1625b37b');

--Ver el total de una factura
CREATE OR REPLACE FUNCTION get_invoice_total(inv_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    total_invoice NUMERIC;
BEGIN
    SELECT total
    INTO total_invoice
    FROM invoice
    WHERE id_invoice = inv_id;

    RETURN total_invoice;
END;
$$ LANGUAGE plpgsql;

SELECT get_invoice_total('74c94852-dc3f-4c94-b03b-bbd1679624db');