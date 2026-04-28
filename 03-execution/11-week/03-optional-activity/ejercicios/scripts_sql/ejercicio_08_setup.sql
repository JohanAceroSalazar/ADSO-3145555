DROP TRIGGER IF EXISTS trg_ai_user_role_touch_account ON user_role;
DROP FUNCTION IF EXISTS fn_ai_user_role_touch_account();
DROP PROCEDURE IF EXISTS sp_assign_user_role(uuid, uuid, uuid);

-- 1. Trigger AFTER sobre user_role
-- Actualiza la marca de tiempo de la cuenta de usuario cuando se asigna un nuevo rol
CREATE OR REPLACE FUNCTION fn_ai_user_role_touch_account()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE user_account
    SET updated_at = now()
    WHERE user_account_id = NEW.user_account_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ai_user_role_touch_account
AFTER INSERT ON user_role
FOR EACH ROW
EXECUTE FUNCTION fn_ai_user_role_touch_account();

-- 2. Procedimiento Almacenado
CREATE OR REPLACE PROCEDURE sp_assign_user_role(
    p_user_account_id uuid,
    p_security_role_id uuid,
    p_assigned_by_user_id uuid
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar si el rol ya está asignado
    IF EXISTS (
        SELECT 1 FROM user_role 
        WHERE user_account_id = p_user_account_id 
        AND security_role_id = p_security_role_id
    ) THEN
        RAISE EXCEPTION 'El rol ya está asignado a este usuario.';
    END IF;

    INSERT INTO user_role (
        user_account_id,
        security_role_id,
        assigned_by_user_id,
        assigned_at
    )
    VALUES (
        p_user_account_id,
        p_security_role_id,
        p_assigned_by_user_id,
        now()
    );
END;
$$;

-- 3. Consulta con INNER JOIN (mínimo 5 tablas)
-- Requerimiento: persona, usuario, estado, rol, fecha asignación y permiso.
SELECT
    p.first_name || ' ' || p.last_name AS persona,
    ua.username AS usuario,
    us.status_name AS estado_usuario,
    sr.role_name AS rol_asignado,
    ur.assigned_at AS fecha_asignacion,
    sp.permission_name AS permiso_asociado
FROM user_account ua
INNER JOIN person p ON p.person_id = ua.person_id
INNER JOIN user_status us ON us.user_status_id = ua.user_status_id
INNER JOIN user_role ur ON ur.user_account_id = ua.user_account_id
INNER JOIN security_role sr ON sr.security_role_id = ur.security_role_id
INNER JOIN role_permission rp ON rp.security_role_id = sr.security_role_id
INNER JOIN security_permission sp ON sp.security_permission_id = rp.security_permission_id
ORDER BY ua.username, sr.role_name;
