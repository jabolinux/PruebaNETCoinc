using Microsoft.AspNetCore.Mvc;
using Npgsql;
using System.Data;
using UsuarioAPI.Models;


namespace UsuarioAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsuarioController : ControllerBase
    {
        private readonly string _connectionString;

        public UsuarioController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? 
                throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        [HttpPost("ubicacion")]
        public async Task<IActionResult> CrearUbicacion([FromBody] UbicacionDto ubicacionDto)
        {
            try
            {
                using var conn = new NpgsqlConnection(_connectionString);
                await conn.OpenAsync();

                using var cmd = new NpgsqlCommand("CALL insertar_ubicacion(@p_idpais, @p_iddepartamento, @p_idmunicipio, @p_idubicacion)", conn);
                cmd.Parameters.AddWithValue("p_idpais", ubicacionDto.IdPais);
                cmd.Parameters.AddWithValue("p_iddepartamento", ubicacionDto.IdDepartamento);
                cmd.Parameters.AddWithValue("p_idmunicipio", ubicacionDto.IdMunicipio);
                
                var idUbicacionParam = new NpgsqlParameter
                {
                    ParameterName = "p_idubicacion",
                    NpgsqlDbType = NpgsqlTypes.NpgsqlDbType.Integer,
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(idUbicacionParam);

                await cmd.ExecuteNonQueryAsync();

                var idUbicacion = idUbicacionParam.Value as int? ?? 
                    throw new InvalidOperationException("No se pudo obtener el ID de ubicación");
                    
                return Ok(new { IdUbicacion = idUbicacion });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno: {ex.Message}");
            }
        }

        [HttpPost("usuario")]
        public async Task<IActionResult> CrearUsuario([FromBody] UsuarioDto usuarioDto)
        {
            try
            {
                using var conn = new NpgsqlConnection(_connectionString);
                await conn.OpenAsync();

                using var cmd = new NpgsqlCommand("CALL insertar_usuario(@p_nombre, @p_telefono, @p_direccion, @p_idubicacion, @p_idusuario)", conn);
                cmd.Parameters.AddWithValue("p_nombre", usuarioDto.Nombre);
                cmd.Parameters.AddWithValue("p_telefono", usuarioDto.Telefono);
                cmd.Parameters.AddWithValue("p_direccion", usuarioDto.Direccion);
                cmd.Parameters.AddWithValue("p_idubicacion", usuarioDto.IdUbicacion);

                var idUsuarioParam = new NpgsqlParameter
                {
                    ParameterName = "p_idusuario",
                    NpgsqlDbType = NpgsqlTypes.NpgsqlDbType.Integer,
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(idUsuarioParam);

                await cmd.ExecuteNonQueryAsync();

                var idUsuario = idUsuarioParam.Value as int? ?? 
                    throw new InvalidOperationException("No se pudo obtener el ID de usuario");
                
                return Ok(new { IdUsuario = idUsuario });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno: {ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> ObtenerUsuario(int id)
        {
            try
            {
                using var conn = new NpgsqlConnection(_connectionString);
                await conn.OpenAsync();

                using var cmd = new NpgsqlCommand("SELECT * FROM obtener_informacion_usuario(@p_idusuario)", conn);
                cmd.Parameters.AddWithValue("p_idusuario", id);

                using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    var usuario = new UsuarioResponseDto
                    {
                        Nombre = reader["Nombre"]?.ToString() ?? string.Empty,
                        Telefono = reader["Telefono"]?.ToString() ?? string.Empty,
                        Direccion = reader["Direccion"]?.ToString() ?? string.Empty,
                        Ubicacion = new UbicacionResponseDto
                        {
                            Pais = reader["NombrePais"]?.ToString() ?? string.Empty,
                            Departamento = reader["NombreDepartamento"]?.ToString() ?? string.Empty,
                            Municipio = reader["NombreMunicipio"]?.ToString() ?? string.Empty
                        }
                    };
                    return Ok(usuario);
                }

                return NotFound("Usuario no encontrado");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno: {ex.Message}");
            }
        }

        // En la clase UsuarioController
    [HttpPut("usuario/{id}")]
    public async Task<IActionResult> ActualizarUsuario(int id, [FromBody] UsuarioDto usuarioDto)
    {
        if (id != usuarioDto.Id)
        {
            return BadRequest("El ID en la URL no coincide con el ID en el cuerpo de la solicitud");
        }

        try
        {
            using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            using var cmd = new NpgsqlCommand(
                "CALL actualizar_usuario(@p_idusuario, @p_nombre, @p_telefono, @p_direccion, @p_idubicacion)", 
                conn);
            
            cmd.Parameters.AddWithValue("p_idusuario", id);
            cmd.Parameters.AddWithValue("p_nombre", usuarioDto.Nombre);
            cmd.Parameters.AddWithValue("p_telefono", usuarioDto.Telefono);
            cmd.Parameters.AddWithValue("p_direccion", usuarioDto.Direccion);
            cmd.Parameters.AddWithValue("p_idubicacion", usuarioDto.IdUbicacion);

            await cmd.ExecuteNonQueryAsync();
            return Ok(new { Mensaje = "Usuario actualizado exitosamente" });
        }
        catch (PostgresException ex) when (ex.MessageText?.Contains("no encontrado") ?? false)
        {
            return NotFound($"No se encontró el usuario con ID {id}");
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Error interno: {ex.Message}");
        }
    }

    [HttpPut("ubicacion/{id}")]
    public async Task<IActionResult> ActualizarUbicacion(int id, [FromBody] UbicacionDto ubicacionDto)
    {
        if (id != ubicacionDto.Id)
        {
            return BadRequest("El ID en la URL no coincide con el ID en el cuerpo de la solicitud");
        }

        try
        {
            using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            using var cmd = new NpgsqlCommand(
                "CALL actualizar_ubicacion(@p_idubicacion, @p_idpais, @p_iddepartamento, @p_idmunicipio)", 
                conn);
            
            cmd.Parameters.AddWithValue("p_idubicacion", id);
            cmd.Parameters.AddWithValue("p_idpais", ubicacionDto.IdPais);
            cmd.Parameters.AddWithValue("p_iddepartamento", ubicacionDto.IdDepartamento);
            cmd.Parameters.AddWithValue("p_idmunicipio", ubicacionDto.IdMunicipio);

            await cmd.ExecuteNonQueryAsync();
            return Ok(new { Mensaje = "Ubicación actualizada exitosamente" });
        }
        catch (PostgresException ex) when (ex.MessageText?.Contains("no encontrada") ?? false)
        {
            return NotFound($"No se encontró la ubicación con ID {id}");
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Error interno: {ex.Message}");
        }
    }

       

       
        [HttpDelete("usuario/{id}")]
        public async Task<IActionResult> EliminarUsuario(int id)
        {
            try
            {
                using var conn = new NpgsqlConnection(_connectionString);
                await conn.OpenAsync();

                using var cmd = new NpgsqlCommand("CALL eliminar_usuario(@p_idusuario)", conn);
                cmd.Parameters.AddWithValue("p_idusuario", id);

                await cmd.ExecuteNonQueryAsync();
                return Ok(new { Mensaje = "Usuario eliminado exitosamente" });
            }
            catch (PostgresException ex) when (ex.MessageText?.Contains("no encontrado") ?? false)
            {
                return NotFound(ex.MessageText);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno: {ex.Message}");
            }
        }

        [HttpDelete("ubicacion/{id}")]
        public async Task<IActionResult> EliminarUbicacion(int id)
        {
            try
            {
                using var conn = new NpgsqlConnection(_connectionString);
                await conn.OpenAsync();

                using var cmd = new NpgsqlCommand("CALL eliminar_ubicacion(@p_idubicacion)", conn);
                cmd.Parameters.AddWithValue("p_idubicacion", id);

                await cmd.ExecuteNonQueryAsync();
                return Ok(new { Mensaje = "Ubicación eliminada exitosamente" });
            }
            catch (PostgresException ex) when (ex.MessageText?.Contains("siendo utilizada") ?? false)
            {
                return BadRequest(ex.MessageText);
            }
            catch (PostgresException ex) when (ex.MessageText?.Contains("no encontrada") ?? false)
            {
                return NotFound(ex.MessageText);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error interno: {ex.Message}");
            }
        }
    }
}