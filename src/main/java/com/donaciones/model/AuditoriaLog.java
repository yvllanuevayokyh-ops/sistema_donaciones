package com.donaciones.model;

import java.sql.Timestamp;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "auditoria_log")
public class AuditoriaLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_auditoria")
    private Integer idAuditoria;

    @Column(name = "fecha_evento", nullable = false)
    private Timestamp fechaEvento;

    @Column(name = "usuario", length = 120)
    private String usuario;

    @Column(name = "rol", length = 80)
    private String rol;

    @Column(name = "modulo", length = 80)
    private String modulo;

    @Column(name = "accion", length = 80)
    private String accion;

    @Column(name = "detalle", length = 500)
    private String detalle;

    @Column(name = "estado_http")
    private Integer estadoHttp;

    public Integer getIdAuditoria() {
        return idAuditoria;
    }

    public void setIdAuditoria(Integer idAuditoria) {
        this.idAuditoria = idAuditoria;
    }

    public Timestamp getFechaEvento() {
        return fechaEvento;
    }

    public void setFechaEvento(Timestamp fechaEvento) {
        this.fechaEvento = fechaEvento;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getModulo() {
        return modulo;
    }

    public void setModulo(String modulo) {
        this.modulo = modulo;
    }

    public String getAccion() {
        return accion;
    }

    public void setAccion(String accion) {
        this.accion = accion;
    }

    public String getDetalle() {
        return detalle;
    }

    public void setDetalle(String detalle) {
        this.detalle = detalle;
    }

    public Integer getEstadoHttp() {
        return estadoHttp;
    }

    public void setEstadoHttp(Integer estadoHttp) {
        this.estadoHttp = estadoHttp;
    }
}
