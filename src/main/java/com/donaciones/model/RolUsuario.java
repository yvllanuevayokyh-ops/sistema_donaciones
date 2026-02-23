package com.donaciones.model;

import java.util.HashSet;
import java.util.Set;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name = "rol_usuario")
public class RolUsuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_rol")
    private Integer idRol;

    @Column(name = "nombre", nullable = false, length = 50)
    private String nombre;

    @OneToMany(mappedBy = "rol", fetch = FetchType.LAZY)
    private Set<UsuarioSistema> usuarios = new HashSet<UsuarioSistema>();

    @OneToMany(mappedBy = "rol", fetch = FetchType.LAZY)
    private Set<RolPermiso> rolPermisos = new HashSet<RolPermiso>();

    public Integer getIdRol() {
        return idRol;
    }

    public void setIdRol(Integer idRol) {
        this.idRol = idRol;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Set<UsuarioSistema> getUsuarios() {
        return usuarios;
    }

    public void setUsuarios(Set<UsuarioSistema> usuarios) {
        this.usuarios = usuarios;
    }

    public Set<RolPermiso> getRolPermisos() {
        return rolPermisos;
    }

    public void setRolPermisos(Set<RolPermiso> rolPermisos) {
        this.rolPermisos = rolPermisos;
    }
}
