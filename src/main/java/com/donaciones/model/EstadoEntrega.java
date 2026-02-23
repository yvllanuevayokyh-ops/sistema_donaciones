package com.donaciones.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "estado_entrega")
public class EstadoEntrega {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_estado_entrega")
    private Integer idEstadoEntrega;

    @Column(name = "descripcion", nullable = false, length = 50)
    private String descripcion;

    public Integer getIdEstadoEntrega() {
        return idEstadoEntrega;
    }

    public void setIdEstadoEntrega(Integer idEstadoEntrega) {
        this.idEstadoEntrega = idEstadoEntrega;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
}
