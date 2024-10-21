 namespace UsuarioAPI.Models
{
    public class Usuario
    {
        public int IdUsuario { get; set; }
        public string Nombre { get; set; }
        public string Telefono { get; set; }
        public string Direccion { get; set; }
        public int IdUbicacion { get; set; }
        public Ubicacion Ubicacion { get; set; }
    }

    public class Ubicacion
    {
        public int IdUbicacion { get; set; }
        public int IdPais { get; set; }
        public Pais Pais { get; set; }
        public int IdDepartamento { get; set; }
        public Departamento Departamento { get; set; }
        public int IdMunicipio { get; set; }
        public Municipio Municipio { get; set; }
    }

    public class Pais
    {
        public int IdPais { get; set; }
        public string NombrePais { get; set; }
    }

    public class Departamento
    {
        public int IdDepartamento { get; set; }
        public string NombreDepartamento { get; set; }
        public int IdPais { get; set; }
        public Pais Pais { get; set; }
    }

    public class Municipio
    {
        public int IdMunicipio { get; set; }
        public string NombreMunicipio { get; set; }
        public int IdDepartamento { get; set; }
        public Departamento Departamento { get; set; }
    }
}
