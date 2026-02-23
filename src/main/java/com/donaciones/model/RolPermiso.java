package com.donaciones.model;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.MapsId;
import javax.persistence.Table;

@Entity
@Table(name = "rol_permiso")
public class RolPermiso {

    @EmbeddedId
    private RolPermisoId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idRol")
    @JoinColumn(name = "id_rol", nullable = false)
    private RolUsuario rol;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("idPermiso")
    @JoinColumn(name = "id_permiso", nullable = false)
    private Permiso permiso;

    @Column(name = "permitido", nullable = false)
    private Boolean permitido;

    public RolPermisoId getId() {
        return id;
    }

    public void setId(RolPermisoId id) {
        this.id = id;
    }

    public RolUsuario getRol() {
        return rol;
    }

    public void setRol(RolUsuario rol) {
        this.rol = rol;
    }

    public Permiso getPermiso() {
        return permiso;
    }

    public void setPermiso(Permiso permiso) {
        this.permiso = permiso;
    }

    public Boolean getPermitido() {
        return permitido;
    }

    public void setPermitido(Boolean permitido) {
        this.permitido = permitido;
    }
}
