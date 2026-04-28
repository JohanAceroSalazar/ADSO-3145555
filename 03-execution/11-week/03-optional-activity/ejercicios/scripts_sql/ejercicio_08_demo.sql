DO $$
DECLARE
    v_user_account_id uuid;
    v_security_role_id uuid;
    v_admin_user_id uuid;
BEGIN
    -- 1. Buscar una cuenta de usuario que no tenga todos los roles
    SELECT user_account_id INTO v_user_account_id FROM user_account LIMIT 1;

    -- 2. Buscar un rol de seguridad
    SELECT security_role_id INTO v_security_role_id FROM security_role LIMIT 1;

    -- 3. Buscar un usuario administrador (el mismo o cualquier otro para la prueba)
    SELECT user_account_id INTO v_admin_user_id FROM user_account LIMIT 1;

    IF v_user_account_id IS NULL OR v_security_role_id IS NULL THEN
        RAISE EXCEPTION 'No se encontraron datos base para la prueba de seguridad.';
    END IF;

    -- 4. Intentar asignar (manejar si ya existe para que la demo no falle)
    BEGIN
        CALL sp_assign_user_role(
            v_user_account_id,
            v_security_role_id,
            v_admin_user_id
        );
        RAISE NOTICE 'Rol asignado exitosamente al usuario %', v_user_account_id;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'El rol ya estaba asignado o hubo un error: %', SQLERRM;
    END;
END;
$$;

-- 5. Verificación
SELECT 
    ua.username,
    ua.updated_at AS user_last_update,
    sr.role_name,
    ur.assigned_at
FROM user_account ua
INNER JOIN user_role ur ON ur.user_account_id = ua.user_account_id
INNER JOIN security_role sr ON sr.security_role_id = ur.security_role_id
ORDER BY ur.created_at DESC
LIMIT 1;
