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
@Table(name = "comunidad_vulnerable")
public class ComunidadVulnerable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_comunidad")
    private Integer idComunidad;

    @Column(name = "nombre", nullable = false, length = 150)
    private String nombre;

    @Column(name = "ubicacion", length = 200)
    private String ubicacion;

    @Column(name = "descripcion")
    private String descripcion;

    @Column(name = "cantidad_beneficiarios")
    private Integer cantidadBeneficiarios;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_pais", nullable = false)
    private Pais pais;

    @Column(name = "activo", nullable = false)
    private Boolean activo;

    public Integer getIdComunidad() {
        return idComunidad;
    }

    public void setIdComunidad(Integer idComunidad) {
        this.idComunidad = idComunidad;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getUbicacion() {
        return ubicacion;
    }

    public void setUbicacion(String ubicacion) {
        this.ubicacion = ubicacion;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Integer getCantidadBeneficiarios() {
        return cantidadBeneficiarios;
    }

    public void setCantidadBeneficiarios(Integer cantidadBeneficiarios) {
        this.cantidadBeneficiarios = cantidadBeneficiarios;
    }

    public Pais getPais() {
        return pais;
    }

    public void setPais(Pais pais) {
        this.pais = pais;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }
}
