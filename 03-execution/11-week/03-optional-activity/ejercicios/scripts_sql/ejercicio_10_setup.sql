DROP TRIGGER IF EXISTS trg_ai_person_document_touch_person ON person_document;
DROP FUNCTION IF EXISTS fn_ai_person_document_touch_person();
DROP PROCEDURE IF EXISTS sp_register_person_document;

-- 1. Trigger AFTER sobre person_document
-- Actualiza la marca de tiempo de la persona cuando se registra un documento
CREATE OR REPLACE FUNCTION fn_ai_person_document_touch_person()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE person
    SET updated_at = now()
    WHERE person_id = NEW.person_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_person_document_touch_person
AFTER INSERT ON person_document
FOR EACH ROW
EXECUTE FUNCTION fn_ai_person_document_touch_person();

-- 2. Procedimiento Almacenado
CREATE OR REPLACE PROCEDURE sp_register_person_document(
    p_person_id uuid,
    p_document_type_id uuid,
    p_issuing_country_id uuid,
    p_document_number varchar(64),
    p_issued_on date,
    p_expires_on date
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar fechas
    IF p_expires_on IS NOT NULL AND p_issued_on IS NOT NULL AND p_expires_on < p_issued_on THEN
        RAISE EXCEPTION 'La fecha de vencimiento no puede ser anterior a la de emisión.';
    END IF;

    INSERT INTO person_document (
        person_id,
        document_type_id,
        issuing_country_id,
        document_number,
        issued_on,
        expires_on
    )
    VALUES (
        p_person_id,
        p_document_type_id,
        p_issuing_country_id,
        p_document_number,
        p_issued_on,
        p_expires_on
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento: persona, tipo, documento, tipo documento, contacto, tipo contacto y reserva.
SELECT
    p.first_name || ' ' || p.last_name AS persona,
    pt.type_name AS tipo_persona,
    dt.type_name AS tipo_documento,
    pd.document_number AS numero_documento,
    ct.type_name AS tipo_contacto,
    pc.contact_value AS valor_contacto,
    r.reservation_code AS reserva_relacionada,
    rp.passenger_sequence_no AS secuencia_pasajero
FROM person p
INNER JOIN person_type pt ON pt.person_type_id = p.person_type_id
INNER JOIN person_document pd ON pd.person_id = p.person_id
INNER JOIN document_type dt ON dt.document_type_id = pd.document_type_id
INNER JOIN person_contact pc ON pc.person_id = p.person_id
INNER JOIN contact_type ct ON ct.contact_type_id = pc.contact_type_id
INNER JOIN reservation_passenger rp ON rp.person_id = p.person_id
INNER JOIN reservation r ON r.reservation_id = rp.reservation_id
ORDER BY persona;
