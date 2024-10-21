# API de Usuarios y Ubicaciones

API simple para gestionar usuarios y sus ubicaciones geográficas (país, departamento, municipio).

## ¿Qué necesitas para empezar?

1. PostgreSQL
2. .NET 7.0
3. Tu editor favorito (VS Code, Visual Studio, etc.)

## Configuración rápida

1. Crea la base de datos:
```bash
psql -U tu_usuario
```
```sql
CREATE DATABASE usuariodb;
```

2. Ejecuta el script SQL:
```bash
psql -U tu_usuario -d usuariodb -f script.sql
```

3. Clona y ejecuta el proyecto:
```bash
git clone <repo>
cd UsuarioAPI
```

4. Actualiza la conexión en `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=usuariodb;Username=tu_usuario;Password=tu_password"
  }
}
```

5. ¡Arranca el proyecto!
```bash
dotnet run
```

## Endpoints disponibles

### Usuarios

- `GET /api/usuario/{id}` - Obtener un usuario
- `POST /api/usuario` - Crear usuario
- `PUT /api/usuario/{id}` - Actualizar usuario
- `DELETE /api/usuario/{id}` - Eliminar usuario

### Ubicaciones

- `POST /api/usuario/ubicacion` - Crear ubicación
- `PUT /api/usuario/ubicacion/{id}` - Actualizar ubicación
- `DELETE /api/usuario/ubicacion/{id}` - Eliminar ubicación

## Ejemplos de uso

### Crear una ubicación
```http
POST /api/usuario/ubicacion
{
    "idPais": 1,
    "idDepartamento": 1,
    "idMunicipio": 1
}
```

### Crear un usuario
```http
POST /api/usuario
{
    "nombre": "Juan Pérez",
    "telefono": "123456789",
    "direccion": "Calle 123",
    "idUbicacion": 1
}
```

## ¿Algo no funciona?

### La API no arranca
1. ¿PostgreSQL está corriendo?
2. ¿La cadena de conexión es correcta?
3. ¿Ejecutaste el script SQL?

### Errores comunes
- "Connection refused" → PostgreSQL no está corriendo
- "Database doesn't exist" → Crear la base de datos
- "Password authentication failed" → Revisar credenciales

## ¿Necesitas probar la API?

1. Swagger: `http://localhost:5234/swagger`
2. Postman: Importa la colección adjunta
3. Curl:
```bash
curl -X GET http://localhost:5234/api/usuario/1
```

## Estructura del proyecto

```
UsuarioAPI/
├── Controllers/     # Los endpoints están aquí
├── Models/          # Las clases de datos
├── DTOs/           # Objetos de transferencia
└── SQL/            # Scripts de base de datos
```

## Base de datos

- Tablas: Usuario, Ubicacion, Pais, Departamento, Municipio
- Stored Procedures para todas las operaciones
- Diagrama básico:
```
Usuario → Ubicacion → (Pais, Departamento, Municipio)
```

## Tech Stack

- ASP.NET Core 7.0
- PostgreSQL (con Npgsql)
- Stored Procedures
- Swagger para documentación

## ¿Preguntas?

Abre un issue o contacta al equipo de desarrollo.

---
Hecho con ☕️ y mucho código.
