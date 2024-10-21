using System.ComponentModel.DataAnnotations;

namespace UsuarioAPI.Models
{
    public class UbicacionDto
    {
        public int? Id { get; set; } // Agregado para actualizaciones
        
        [Required]
        public int IdPais { get; set; }
        
        [Required]
        public int IdDepartamento { get; set; }
        
        [Required]
        public int IdMunicipio { get; set; }
    }

    public class UsuarioDto
    {
        public int? Id { get; set; } // Agregado para actualizaciones
        
        [Required]
        public required string Nombre { get; set; }
        
        [Required]
        public required string Telefono { get; set; }
        
        [Required]
        public required string Direccion { get; set; }
        
        [Required]
        public int IdUbicacion { get; set; }
    }

    public class UbicacionResponseDto
    {
        public required string Pais { get; set; }
        public required string Departamento { get; set; }
        public required string Municipio { get; set; }
    }

    public class UsuarioResponseDto
    {
        public required string Nombre { get; set; }
        public required string Telefono { get; set; }
        public required string Direccion { get; set; }
        public required UbicacionResponseDto Ubicacion { get; set; }
    }
}