package com.donaciones.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "comunidad_responsable")
public class ComunidadResponsable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_responsable")
    private Integer idResponsable;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_comunidad", nullable = false)
    private ComunidadVulnerable comunidad;

    @Column(name = "nombre", nullable = false, length = 150)
    private String nombre;

    @Column(name = "telefono", length = 20)
    private String telefono;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "cargo", length = 100)
    private String cargo;

    @Column(name = "activo", nullable = false)
    private Boolean activo;

    public Integer getIdResponsable() {
        return idResponsable;
    }

    public void setIdResponsable(Integer idResponsable) {
        this.idResponsable = idResponsable;
    }

    public ComunidadVulnerable getComunidad() {
        return comunidad;
    }

    public void setComunidad(ComunidadVulnerable comunidad) {
        this.comunidad = comunidad;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCargo() {
        return cargo;
    }

    public void setCargo(String cargo) {
        this.cargo = cargo;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }
}
