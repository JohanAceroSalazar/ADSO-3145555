# Uso de Liquibase con Docker y PostgreSQL

## 🧠 ¿Qué es Liquibase?

**Liquibase** es una herramienta que permite **gestionar, versionar y automatizar cambios en bases de datos**.

Funciona como Git, pero para bases de datos.

---

# 🐳 1. Instalación de Liquibase con Docker

## ✅ Requisito

Tener instalado:

* Docker

## 📥 Descargar imagen de Liquibase

```bash
docker pull liquibase/liquibase
```

## 🔍 Verificar instalación

```bash
docker run liquibase/liquibase --version
```

---

# 🐘 2. Crear contenedor de PostgreSQL

Se utilizó el siguiente contenedor:

```yaml
postgres:
  image: postgres:15
  container_name: postgres-container
  restart: always
  environment:
    POSTGRES_USER: miusuario
    POSTGRES_PASSWORD: MiPassword123
    POSTGRES_DB: mi_base
  ports:
    - "5433:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data
```

---

# 📁 3. Estructura del proyecto

Se creó una carpeta llamada:

```plaintext
liquibase-project/
```

Dentro se ubicaron los siguientes archivos:

```plaintext
liquibase-project/
│
├── changelog.xml
├── liquibase.properties
├── postgresql-42.7.9.jar
```

---

# ⚙️ 4. Configuración de conexión

## 📄 liquibase.properties

```properties
url=jdbc:postgresql://host.docker.internal:5433/liqui-base
username=miusuario
password=MiPassword123
driver=org.postgresql.Driver
changeLogFile=changelog.xml
```

---

# 🧱 5. Creación del changelog

## 📄 changelog.xml

```xml
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.8.xsd">

    <changeSet id="1" author="johan">
        <createTable tableName="cliente">
            <column name="id" type="SERIAL">
                <constraints primaryKey="true"/>
            </column>
            <column name="nombre" type="VARCHAR(50)"/>
        </createTable>
    </changeSet>

    <changeSet id="2" author="freiner">
        <createTable tableName="producto">
            <column name="id" type="SERIAL">
                <constraints primaryKey="true"/>
            </column>
            <column name="nombre" type="VARCHAR(50)"/>
        </createTable>
    </changeSet>

    <changeSet id="3" author="camilo">
        <createTable tableName="categoria">
            <column name="id" type="SERIAL">
                <constraints primaryKey="true"/>
            </column>
            <column name="nombre" type="VARCHAR(50)"/>
        </createTable>
    </changeSet>

</databaseChangeLog>
```

---

# 🚀 6. Ejecución de Liquibase

Desde PowerShell (dentro de la carpeta):

```bash
docker run --rm -v ${PWD}:/liquibase/changelog -w /liquibase/changelog liquibase/liquibase --classpath=postgresql-42.7.9.jar --defaultsFile=liquibase.properties update
```

---

# ❗Problemas encontrados y solución

## ❌ Error: Driver no encontrado

```
Cannot find database driver: org.postgresql.Driver
```

### ✅ Solución:

* Descargar el driver JDBC de PostgreSQL
* Guardarlo en la carpeta del proyecto
* Agregarlo con:

```bash
--classpath=postgresql-42.7.9.jar
```

# 🧪 7. Verificación

Ingresar al contenedor:

```bash
docker exec -it postgres-container psql -U miusuario -d liqui-base
```

Ver tablas:

```sql
\dt
```

---

# 🔄 8. Agregar nuevos cambios

Ejemplo: agregar producto

```xml
<changeSet id="4" author="johan">
    <insert tableName="producto">
        <column name="nombre" value="computador"/>
    </insert>
</changeSet>
```
---

# ▶️ Ejecutar nuevamente

```bash
docker run --rm -v ${PWD}:/liquibase/changelog -w /liquibase/changelog liquibase/liquibase --classpath=postgresql-42.7.9.jar --defaultsFile=liquibase.properties update
```

---

# ⚠️ Buenas prácticas

* ❌ No modificar changeSet ya ejecutados
* ✅ Crear siempre nuevos changeSet
* ✅ IDs únicos
* ✅ Mantener control con Git

---

# 🧠 Conclusión

Se logró:

* Conectar Liquibase con PostgreSQL en Docker
* Crear tablas automáticamente
* Versionar cambios de base de datos
* Insertar datos desde código
* Automatizar cambios