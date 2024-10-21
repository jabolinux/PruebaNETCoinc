using Microsoft.EntityFrameworkCore;
using UsuarioAPI.Models;

namespace UsuarioAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Usuario> Usuarios { get; set; }
        public DbSet<Ubicacion> Ubicaciones { get; set; }
        public DbSet<Pais> Paises { get; set; }
        public DbSet<Departamento> Departamentos { get; set; }
        public DbSet<Municipio> Municipios { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configuración de Usuario
            modelBuilder.Entity<Usuario>()
                .HasOne(u => u.Ubicacion)
                .WithMany()
                .HasForeignKey(u => u.IdUbicacion)
                .OnDelete(DeleteBehavior.Restrict);

            // Configuración de Ubicacion
            modelBuilder.Entity<Ubicacion>()
                .HasOne(u => u.Pais)
                .WithMany()
                .HasForeignKey(u => u.IdPais)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Ubicacion>()
                .HasOne(u => u.Departamento)
                .WithMany()
                .HasForeignKey(u => u.IdDepartamento)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Ubicacion>()
                .HasOne(u => u.Municipio)
                .WithMany()
                .HasForeignKey(u => u.IdMunicipio)
                .OnDelete(DeleteBehavior.Restrict);

            // Configuración de Departamento
            modelBuilder.Entity<Departamento>()
                .HasOne(d => d.Pais)
                .WithMany()
                .HasForeignKey(d => d.IdPais)
                .OnDelete(DeleteBehavior.Restrict);

            // Configuración de Municipio
            modelBuilder.Entity<Municipio>()
                .HasOne(m => m.Departamento)
                .WithMany()
                .HasForeignKey(m => m.IdDepartamento)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}