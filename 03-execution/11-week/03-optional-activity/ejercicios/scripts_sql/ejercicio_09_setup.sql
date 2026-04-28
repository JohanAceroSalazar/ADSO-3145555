DROP TRIGGER IF EXISTS trg_ai_fare_touch_airline ON fare;
DROP FUNCTION IF EXISTS fn_ai_fare_touch_airline();
DROP PROCEDURE IF EXISTS sp_publish_fare;

-- 1. Trigger AFTER sobre fare
-- Actualiza la marca de tiempo de la aerolínea cuando se publica una tarifa
CREATE OR REPLACE FUNCTION fn_ai_fare_touch_airline()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE airline
    SET updated_at = now()
    WHERE airline_id = NEW.airline_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_fare_touch_airline
AFTER INSERT ON fare
FOR EACH ROW
EXECUTE FUNCTION fn_ai_fare_touch_airline();

-- 2. Procedimiento Almacenado
CREATE OR REPLACE PROCEDURE sp_publish_fare(
    p_airline_id uuid,
    p_origin_airport_id uuid,
    p_destination_airport_id uuid,
    p_fare_class_id uuid,
    p_currency_id uuid,
    p_fare_code varchar(30),
    p_base_amount numeric,
    p_valid_from date,
    p_valid_to date
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que aeropuertos sean diferentes
    IF p_origin_airport_id = p_destination_airport_id THEN
        RAISE EXCEPTION 'El aeropuerto de origen y destino no pueden ser el mismo.';
    END IF;

    -- Validar monto
    IF p_base_amount < 0 THEN
        RAISE EXCEPTION 'El monto base no puede ser negativo.';
    END IF;

    INSERT INTO fare (
        airline_id,
        origin_airport_id,
        destination_airport_id,
        fare_class_id,
        currency_id,
        fare_code,
        base_amount,
        valid_from,
        valid_to
    )
    VALUES (
        p_airline_id,
        p_origin_airport_id,
        p_destination_airport_id,
        p_fare_class_id,
        p_currency_id,
        p_fare_code,
        p_base_amount,
        p_valid_from,
        p_valid_to
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento: aerolínea, tarifa, clase, aeropuertos, moneda, reserva, venta y tiquete.
SELECT
    al.airline_name AS aerolinea,
    f.fare_code AS codigo_tarifa,
    fc.fare_class_name AS clase_tarifaria,
    ao.iata_code AS aeropuerto_origen,
    ad.iata_code AS aeropuerto_destino,
    curr.iso_currency_code AS moneda,
    r.reservation_code AS reserva,
    s.sale_code AS venta,
    t.ticket_number AS tiquete
FROM fare f
INNER JOIN airline al ON al.airline_id = f.airline_id
INNER JOIN fare_class fc ON fc.fare_class_id = f.fare_class_id
INNER JOIN airport ao ON ao.airport_id = f.origin_airport_id
INNER JOIN airport ad ON ad.airport_id = f.destination_airport_id
INNER JOIN currency curr ON curr.currency_id = f.currency_id
INNER JOIN ticket t ON t.fare_id = f.fare_id
INNER JOIN sale s ON s.sale_id = t.sale_id
INNER JOIN reservation r ON r.reservation_id = s.reservation_id
ORDER BY al.airline_name, f.fare_code;
