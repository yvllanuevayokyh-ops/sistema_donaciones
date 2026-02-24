package com.donaciones.model;

import java.sql.Timestamp;
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
@Table(name = "entrega_donacion")
public class EntregaDonacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_entrega")
    private Integer idEntrega;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_donacion", nullable = false)
    private Donacion donacion;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_comunidad", nullable = false)
    private ComunidadVulnerable comunidad;

    @Column(name = "fecha_programada")
    private Timestamp fechaProgramada;

    @Column(name = "fecha_entrega")
    private Timestamp fechaEntrega;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_estado_entrega", nullable = false)
    private EstadoEntrega estadoEntrega;

    @Column(name = "observaciones")
    private String observaciones;

    public Integer getIdEntrega() {
        return idEntrega;
    }

    public void setIdEntrega(Integer idEntrega) {
        this.idEntrega = idEntrega;
    }

    public Donacion getDonacion() {
        return donacion;
    }

    public void setDonacion(Donacion donacion) {
        this.donacion = donacion;
    }

    public ComunidadVulnerable getComunidad() {
        return comunidad;
    }

    public void setComunidad(ComunidadVulnerable comunidad) {
        this.comunidad = comunidad;
    }

    public Timestamp getFechaProgramada() {
        return fechaProgramada;
    }

    public void setFechaProgramada(Timestamp fechaProgramada) {
        this.fechaProgramada = fechaProgramada;
    }

    public Timestamp getFechaEntrega() {
        return fechaEntrega;
    }

    public void setFechaEntrega(Timestamp fechaEntrega) {
        this.fechaEntrega = fechaEntrega;
    }

    public EstadoEntrega getEstadoEntrega() {
        return estadoEntrega;
    }

    public void setEstadoEntrega(EstadoEntrega estadoEntrega) {
        this.estadoEntrega = estadoEntrega;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
}
