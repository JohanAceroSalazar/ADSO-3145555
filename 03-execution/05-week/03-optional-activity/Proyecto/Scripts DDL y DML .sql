-- =========================
-- TABLAS BASE
-- =========================

CREATE TABLE Password_Policies (
    id_PasswordPolicy SERIAL PRIMARY KEY,
    minLength INT,
    maxLength INT,
    requireUppercase BIT,
    lockoutThreshold INT,
    lockoutDurationMinutes INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE Users (
    id_user SERIAL PRIMARY KEY,
    id_PasswordPolicy INT,
    userName VARCHAR(100),
    email VARCHAR(255),
    passwordHash VARCHAR(255),
    userStatus BIT,
    lastAccess TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_PasswordPolicy) REFERENCES Password_Policies(id_PasswordPolicy)
);

CREATE TABLE Permissions (
    id_permission SERIAL PRIMARY KEY,
    permission_Name VARCHAR(100),
    description VARCHAR(100),
    createdAt TIMESTAMP,
    updatedAt TIMESTAMP
);

CREATE TABLE Language (
    id_language SERIAL PRIMARY KEY,
    name VARCHAR(50),
    code VARCHAR(10),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- =========================
-- RELACIONES USUARIO
-- =========================

CREATE TABLE Profiles (
    id_profiles SERIAL PRIMARY KEY,
    id_user INT,
    fullName VARCHAR(100),
    email VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES Users(id_user)
);

CREATE TABLE User_Permissions (
    id_user INT,
    id_permission INT,
    grantedAt TIMESTAMP,
    status VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    PRIMARY KEY (id_user, id_permission),
    FOREIGN KEY (id_user) REFERENCES Users(id_user),
    FOREIGN KEY (id_permission) REFERENCES Permissions(id_permission)
);

CREATE TABLE Accessibility_Settings (
    id_settings SERIAL PRIMARY KEY,
    id_user INT,
    id_language INT,
    textSize VARCHAR(50),
    themeColor VARCHAR(20),
    voiceFeedback BIT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES Users(id_user),
    FOREIGN KEY (id_language) REFERENCES Language(id_language)
);

-- =========================
-- SEGURIDAD
-- =========================

CREATE TABLE Security_Ip (
    id_security SERIAL PRIMARY KEY,
    ip VARCHAR(50),
    type VARCHAR(20),
    description VARCHAR(250),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE Login_History (
    id_login SERIAL PRIMARY KEY,
    id_user INT,
    id_security INT,
    loginDate TIMESTAMP,
    isSuccessful BIT,
    deviceInfo VARCHAR(200),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES Users(id_user),
    FOREIGN KEY (id_security) REFERENCES Security_Ip(id_security)
);

CREATE TABLE Failed_Attempts (
    id_attempt SERIAL PRIMARY KEY,
    id_user INT,
    attemptDate TIMESTAMP,
    originIp VARCHAR(50),
    reason VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES Users(id_user)
);

CREATE TABLE Sessions (
    id_session SERIAL PRIMARY KEY,
    id_user INT,
    token VARCHAR(200),
    expires_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES Users(id_user)
);

CREATE TABLE Password_Reset_Tokens (
    id_token SERIAL PRIMARY KEY,
    id_user INT,
    tokenHash INT,
    expires_at TIMESTAMP,
    used_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES Users(id_user)
);

CREATE TABLE Suspicious_Activity (
    id_activity SERIAL PRIMARY KEY,
    id_user INT,
    activityType VARCHAR(100),
    details VARCHAR(500),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES Users(id_user)
);

-- =========================
-- TRADUCCIONES E IA
-- =========================

CREATE TABLE Translations (
    id_translation SERIAL PRIMARY KEY,
    id_user INT,
    input_type VARCHAR(20),
    translated_text TEXT,
    processing_time FLOAT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES Users(id_user)
);

CREATE TABLE Signs (
    id_sign SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    gesture_reference VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE Translation_Signs (
    id_translation INT,
    id_sign INT,
    confidence FLOAT,
    position INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    PRIMARY KEY (id_translation, id_sign),
    FOREIGN KEY (id_translation) REFERENCES Translations(id_translation),
    FOREIGN KEY (id_sign) REFERENCES Signs(id_sign)
);

CREATE TABLE Audio_Files (
    id_audio SERIAL PRIMARY KEY,
    id_translation INT,
    file_url VARCHAR(255),
    file_type VARCHAR(50),
    file_size INT,
    durationSeconds INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (id_translation) REFERENCES Translations(id_translation)
);

-- =========================================
-- INSERTS
-- =========================================

-- =========================================
-- PASSWORD POLICIES
-- =========================================
INSERT INTO Password_Policies 
(id_PasswordPolicy, minLength, maxLength, requireUppercase, lockoutThreshold, lockoutDurationMinutes, created_at, updated_at)
VALUES
(1,8,16,B'1',5,30,'2026-01-01 08:00:00','2026-01-01 08:00:00'),
(2,10,20,B'1',3,15,'2026-01-02 09:00:00','2026-01-02 09:00:00'),
(3,6,12,B'0',10,60,'2026-01-03 10:00:00','2026-01-03 10:00:00'),
(4,12,24,B'1',2,10,'2026-01-04 11:00:00','2026-01-04 11:00:00'),
(5,8,32,B'1',5,20,'2026-01-05 12:00:00','2026-01-05 12:00:00');

-- =========================================
-- USERS
-- =========================================
INSERT INTO Users 
(id_user, id_PasswordPolicy, userName, email, passwordHash, userStatus, lastAccess, created_at, updated_at)
VALUES
(1,1,'luis_sordo','luis.lsc@mail.com','hash_seguro_1',B'1','2026-02-01 10:00:00','2026-01-01 08:10:00','2026-02-01 10:00:00'),
(2,2,'ana_interprete','ana.interprete@mail.com','hash_seguro_2',B'1','2026-02-02 11:00:00','2026-01-02 09:10:00','2026-02-02 11:00:00'),
(3,1,'carlos_estudiante','carlos.sena@mail.com','hash_seguro_3',B'1','2026-02-03 12:00:00','2026-01-03 10:10:00','2026-02-03 12:00:00'),
(4,2,'docente_lsc','profe.lsc@mail.com','hash_seguro_4',B'1','2026-02-04 13:00:00','2026-01-04 11:10:00','2026-02-04 13:00:00'),
(5,1,'familiar_usuario','maria.familia@mail.com','hash_seguro_5',B'1','2026-02-05 14:00:00','2026-01-05 12:10:00','2026-02-05 14:00:00');

-- =========================================
-- PERMISSIONS
-- =========================================
INSERT INTO Permissions 
(id_permission, permission_Name, description, createdAt, updatedAt)
VALUES
(1,'USE_APP','Uso de la aplicación','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(2,'ADMIN','Administración del sistema','2026-01-01 08:05:00','2026-01-01 08:05:00'),
(3,'VIEW_TRANSLATIONS','Ver traducciones','2026-01-01 08:10:00','2026-01-01 08:10:00'),
(4,'EXPORT_AUDIO','Descargar audios','2026-01-01 08:15:00','2026-01-01 08:15:00'),
(5,'TRAIN_MODEL','Entrenamiento IA','2026-01-01 08:20:00','2026-01-01 08:20:00');

-- =========================================
-- LANGUAGE
-- =========================================
INSERT INTO Language 
(id_language, name, code, created_at, updated_at)
VALUES
(1,'Español','es','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(2,'Inglés','en','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(3,'Lengua de Señas Colombiana','lsc','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(4,'Francés','fr','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(5,'Portugués','pt','2026-01-01 08:00:00','2026-01-01 08:00:00');

-- =========================================
-- PROFILES
-- =========================================
INSERT INTO Profiles 
(id_profiles, id_user, fullName, email, created_at, updated_at)
VALUES
(1,1,'Luis Pérez','luis.lsc@mail.com','2026-01-10 09:00:00','2026-01-10 09:00:00'),
(2,2,'Ana Torres','ana.interprete@mail.com','2026-01-11 09:00:00','2026-01-11 09:00:00'),
(3,3,'Carlos Gómez','carlos.sena@mail.com','2026-01-12 09:00:00','2026-01-12 09:00:00'),
(4,4,'Profesor Ruiz','profe.lsc@mail.com','2026-01-13 09:00:00','2026-01-13 09:00:00'),
(5,5,'María López','maria.familia@mail.com','2026-01-14 09:00:00','2026-01-14 09:00:00');

-- =========================================
-- USER PERMISSIONS
-- =========================================
INSERT INTO User_Permissions
(id_user, id_permission, grantedAt, status, created_at, updated_at)
VALUES
(1,1,'2026-02-01 10:00:00','active','2026-02-01 10:00:00','2026-02-01 10:00:00'),
(2,2,'2026-02-02 11:00:00','active','2026-02-02 11:00:00','2026-02-02 11:00:00'),
(3,1,'2026-02-03 12:00:00','active','2026-02-03 12:00:00','2026-02-03 12:00:00'),
(4,3,'2026-02-04 13:00:00','active','2026-02-04 13:00:00','2026-02-04 13:00:00'),
(5,4,'2026-02-05 14:00:00','active','2026-02-05 14:00:00','2026-02-05 14:00:00');

-- =========================================
-- ACCESSIBILITY SETTINGS
-- =========================================
INSERT INTO Accessibility_Settings
(id_settings, id_user, id_language, textSize, themeColor, voiceFeedback, created_at, updated_at)
VALUES
(1,1,1,'large','dark',B'1','2026-02-01 10:05:00','2026-02-01 10:05:00'),
(2,2,1,'medium','light',B'1','2026-02-02 11:05:00','2026-02-02 11:05:00'),
(3,3,2,'medium','dark',B'0','2026-02-03 12:05:00','2026-02-03 12:05:00'),
(4,4,1,'large','light',B'1','2026-02-04 13:05:00','2026-02-04 13:05:00'),
(5,5,1,'large','dark',B'1','2026-02-05 14:05:00','2026-02-05 14:05:00');

-- =========================================
-- SECURITY IP
-- =========================================
INSERT INTO Security_Ip
(id_security, ip, type, description, created_at, updated_at)
VALUES
(1,'192.168.0.10','safe','Red doméstica','2026-02-01 10:00:00','2026-02-01 10:00:00'),
(2,'192.168.0.11','safe','Dispositivo móvil','2026-02-02 11:00:00','2026-02-02 11:00:00'),
(3,'10.10.10.5','blocked','Intento sospechoso','2026-02-03 12:00:00','2026-02-03 12:00:00'),
(4,'172.16.1.20','safe','Red SENA','2026-02-04 13:00:00','2026-02-04 13:00:00'),
(5,'8.8.8.8','safe','Servidor externo','2026-02-05 14:00:00','2026-02-05 14:00:00');

-- =========================================
-- LOGIN HISTORY
-- =========================================
INSERT INTO Login_History
(id_login, id_user, id_security, loginDate, isSuccessful, deviceInfo, created_at, updated_at)
VALUES
(1,1,1,'2026-02-01 10:00:00',B'1','Android','2026-02-01 10:00:00','2026-02-01 10:00:00'),
(2,2,2,'2026-02-02 11:00:00',B'1','Web Chrome','2026-02-02 11:00:00','2026-02-02 11:00:00'),
(3,3,3,'2026-02-03 12:00:00',B'0','PC','2026-02-03 12:00:00','2026-02-03 12:00:00'),
(4,4,4,'2026-02-04 13:00:00',B'1','Laptop','2026-02-04 13:00:00','2026-02-04 13:00:00'),
(5,5,5,'2026-02-05 14:00:00',B'1','Tablet','2026-02-05 14:00:00','2026-02-05 14:00:00');

-- =========================================
-- FAILED ATTEMPTS
-- =========================================
INSERT INTO Failed_Attempts
(id_attempt, id_user, attemptDate, originIp, reason, created_at, updated_at)
VALUES
(1,1,'2026-02-01 09:55:00','10.0.0.1','Contraseña incorrecta','2026-02-01 09:55:00','2026-02-01 09:55:00'),
(2,2,'2026-02-02 10:55:00','10.0.0.2','Contraseña incorrecta','2026-02-02 10:55:00','2026-02-02 10:55:00'),
(3,3,'2026-02-03 11:55:00','10.0.0.3','Usuario bloqueado','2026-02-03 11:55:00','2026-02-03 11:55:00'),
(4,4,'2026-02-04 12:55:00','10.0.0.4','Intentos repetidos','2026-02-04 12:55:00','2026-02-04 12:55:00'),
(5,5,'2026-02-05 13:55:00','10.0.0.5','Contraseña incorrecta','2026-02-05 13:55:00','2026-02-05 13:55:00');

-- =========================================
-- SESSIONS
-- =========================================
INSERT INTO Sessions
(id_session, id_user, token, expires_at, created_at, updated_at)
VALUES
(1,1,'token_abc123','2026-02-02 10:00:00','2026-02-01 10:00:00','2026-02-01 10:00:00'),
(2,2,'token_def456','2026-02-03 11:00:00','2026-02-02 11:00:00','2026-02-02 11:00:00'),
(3,3,'token_ghi789','2026-02-04 12:00:00','2026-02-03 12:00:00','2026-02-03 12:00:00'),
(4,4,'token_jkl012','2026-02-05 13:00:00','2026-02-04 13:00:00','2026-02-04 13:00:00'),
(5,5,'token_mno345','2026-02-06 14:00:00','2026-02-05 14:00:00','2026-02-05 14:00:00');

-- =========================================
-- PASSWORD RESET TOKENS
-- =========================================
INSERT INTO Password_Reset_Tokens
(id_token, id_user, tokenHash, expires_at, used_at, created_at, updated_at)
VALUES
(1,1,111222,'2026-02-02 10:00:00','2026-02-01 11:00:00','2026-02-01 10:30:00','2026-02-01 11:00:00'),
(2,2,333444,'2026-02-03 11:00:00','2026-02-02 12:00:00','2026-02-02 11:30:00','2026-02-02 12:00:00'),
(3,3,555666,'2026-02-04 12:00:00','2026-02-03 13:00:00','2026-02-03 12:30:00','2026-02-03 13:00:00'),
(4,4,777888,'2026-02-05 13:00:00','2026-02-04 14:00:00','2026-02-04 13:30:00','2026-02-04 14:00:00'),
(5,5,999000,'2026-02-06 14:00:00','2026-02-05 15:00:00','2026-02-05 14:30:00','2026-02-05 15:00:00');

-- =========================================
-- SUSPICIOUS ACTIVITY
-- =========================================
INSERT INTO Suspicious_Activity
(id_activity, id_user, activityType, details, created_at, updated_at)
VALUES
(1,1,'login_fail','Muchos intentos fallidos','2026-02-01 10:10:00','2026-02-01 10:10:00'),
(2,2,'ip_change','Cambio de IP sospechoso','2026-02-02 11:10:00','2026-02-02 11:10:00'),
(3,3,'account_lock','Cuenta bloqueada','2026-02-03 12:10:00','2026-02-03 12:10:00'),
(4,4,'login_pattern','Patrón irregular','2026-02-04 13:10:00','2026-02-04 13:10:00'),
(5,5,'token_expired','Token expirado','2026-02-05 14:10:00','2026-02-05 14:10:00');

-- =========================================
-- SIGNS
-- =========================================
INSERT INTO Signs
(id_sign, name, description, gesture_reference, created_at, updated_at)
VALUES
(1,'Hola','Saludo','lsc_hola.png','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(2,'Gracias','Agradecimiento','lsc_gracias.png','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(3,'Por favor','Petición','lsc_porfavor.png','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(4,'Sí','Afirmación','lsc_si.png','2026-01-01 08:00:00','2026-01-01 08:00:00'),
(5,'No','Negación','lsc_no.png','2026-01-01 08:00:00','2026-01-01 08:00:00');

-- =========================================
-- TRANSLATIONS
-- =========================================
INSERT INTO Translations
(id_translation, id_user, input_type, translated_text, processing_time, created_at, updated_at)
VALUES
(1,1,'camera','Hola',0.45,'2026-02-01 10:00:00','2026-02-01 10:00:00'),
(2,1,'camera','Gracias',0.40,'2026-02-01 10:02:00','2026-02-01 10:02:00'),
(3,3,'text','Por favor necesito ayuda',0.20,'2026-02-03 12:00:00','2026-02-03 12:00:00'),
(4,5,'text','Sí puedo asistir',0.18,'2026-02-05 14:00:00','2026-02-05 14:00:00'),
(5,1,'camera','No',0.35,'2026-02-01 10:05:00','2026-02-01 10:05:00');

-- =========================================
-- TRANSLATION SIGNS
-- =========================================
INSERT INTO Translation_Signs
(id_translation, id_sign, confidence, position, created_at, updated_at)
VALUES
(1,1,0.95,1,'2026-02-01 10:00:00','2026-02-01 10:00:00'),
(2,2,0.93,1,'2026-02-01 10:02:00','2026-02-01 10:02:00'),
(3,3,0.90,1,'2026-02-03 12:00:00','2026-02-03 12:00:00'),
(4,4,0.97,1,'2026-02-05 14:00:00','2026-02-05 14:00:00'),
(5,5,0.96,1,'2026-02-01 10:05:00','2026-02-01 10:05:00');

-- =========================================
-- AUDIO FILES
-- =========================================
INSERT INTO Audio_Files
(id_audio, id_translation, file_url, file_type, file_size, durationSeconds, created_at, updated_at)
VALUES
(1,1,'audio/hola.mp3','mp3',150,2,'2026-02-01 10:01:00','2026-02-01 10:01:00'),
(2,2,'audio/gracias.mp3','mp3',160,2,'2026-02-01 10:03:00','2026-02-01 10:03:00'),
(3,3,'audio/ayuda.mp3','mp3',300,4,'2026-02-03 12:01:00','2026-02-03 12:01:00'),
(4,4,'audio/si.mp3','mp3',180,3,'2026-02-05 14:01:00','2026-02-05 14:01:00'),
(5,5,'audio/no.mp3','mp3',140,2,'2026-02-01 10:06:00','2026-02-01 10:06:00');



-- =========================================
-- INDEX
-- =========================================


-- Búsqueda de usuarios
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_users_username ON Users(userName);

-- Relaciones clave
CREATE INDEX idx_profiles_user ON Profiles(id_user);
CREATE INDEX idx_accessibility_user ON Accessibility_Settings(id_user);

-- Seguridad
CREATE INDEX idx_login_user ON Login_History(id_user);
CREATE INDEX idx_login_date ON Login_History(loginDate);
CREATE INDEX idx_failed_user ON Failed_Attempts(id_user);

-- Traducciones (muy importante en tu sistema)
CREATE INDEX idx_translation_user ON Translations(id_user);
CREATE INDEX idx_translation_date ON Translations(created_at);

-- IA
CREATE INDEX idx_translation_signs_translation ON Translation_Signs(id_translation);
CREATE INDEX idx_translation_signs_sign ON Translation_Signs(id_sign);

-- Audio
CREATE INDEX idx_audio_translation ON Audio_Files(id_translation);

-- =========================================
-- VIEW
-- =========================================


-- Vista de traducciones con usuario

CREATE VIEW vw_user_translations AS
SELECT 
    u.userName,
    t.translated_text,
    t.input_type,
    t.processing_time,
    t.created_at
FROM Users u
JOIN Translations t ON u.id_user = t.id_user;

-- Vista de actividad de seguridad

CREATE VIEW vw_security_activity AS
SELECT 
    u.userName,
    lh.loginDate,
    lh.isSuccessful,
    si.ip,
    si.type
FROM Login_History lh
JOIN Users u ON lh.id_user = u.id_user
JOIN Security_Ip si ON lh.id_security = si.id_security;

--Vista de accesibilidad

CREATE VIEW vw_accessibility_users AS
SELECT 
    u.userName,
    l.name AS language,
    a.textSize,
    a.themeColor,
    a.voiceFeedback
FROM Accessibility_Settings a
JOIN Users u ON a.id_user = u.id_user
JOIN Language l ON a.id_language = l.id_language;


-- =========================================
-- QUERY
-- =========================================

-- Últimas traducciones

SELECT * 
FROM Translations
ORDER BY created_at DESC
LIMIT 5;

-- Traducciones por usuario

SELECT u.userName, COUNT(t.id_translation) AS total_traducciones
FROM Users u
JOIN Translations t ON u.id_user = t.id_user
GROUP BY u.userName;

-- Intentos fallidos por usuario

SELECT u.userName, COUNT(f.id_attempt) AS intentos_fallidos
FROM Users u
JOIN Failed_Attempts f ON u.id_user = f.id_user
GROUP BY u.userName;

-- Traducciones con audio

SELECT t.translated_text, a.file_url
FROM Translations t
JOIN Audio_Files a ON t.id_translation = a.id_translation;


-- =========================================
-- SUBQUERY
-- =========================================

-- Usuarios con más traducciones

SELECT userName
FROM Users
WHERE id_user IN (
    SELECT id_user
    FROM Translations
    GROUP BY id_user
    HAVING COUNT(*) > 1
);

-- Usuarios con intentos fallidos

SELECT userName
FROM Users
WHERE id_user IN (
    SELECT id_user
    FROM Failed_Attempts
);

-- Traducción más rápida

SELECT translated_text
FROM Translations
WHERE processing_time = (
    SELECT MIN(processing_time)
    FROM Translations
);







