package com.donaciones.dao;

import java.util.List;

public class ResultadoPaginado<T> {

    private List<T> datos;
    private int totalRegistros;
    private int paginaActual;
    private int registrosPorPagina;
    private int totalPaginas;

    public ResultadoPaginado() {
    }

    public ResultadoPaginado(List<T> datos, int totalRegistros,
                             int paginaActual, int registrosPorPagina) {
        this.datos = datos;
        this.totalRegistros = totalRegistros;
        this.paginaActual = paginaActual;
        this.registrosPorPagina = registrosPorPagina;
        this.totalPaginas = calcularTotalPaginas();
    }

    private int calcularTotalPaginas() {
        if (registrosPorPagina <= 0) {
            return 0;
        }
        return (int) Math.ceil((double) totalRegistros / registrosPorPagina);
    }

    public List<T> getDatos() {
        return datos;
    }

    public void setDatos(List<T> datos) {
        this.datos = datos;
    }

    public int getTotalRegistros() {
        return totalRegistros;
    }

    public void setTotalRegistros(int totalRegistros) {
        this.totalRegistros = totalRegistros;
        this.totalPaginas = calcularTotalPaginas();
    }

    public int getPaginaActual() {
        return paginaActual;
    }

    public void setPaginaActual(int paginaActual) {
        this.paginaActual = paginaActual;
    }

    public int getRegistrosPorPagina() {
        return registrosPorPagina;
    }

    public void setRegistrosPorPagina(int registrosPorPagina) {
        this.registrosPorPagina = registrosPorPagina;
        this.totalPaginas = calcularTotalPaginas();
    }

    public int getTotalPaginas() {
        return totalPaginas;
    }

    public void setTotalPaginas(int totalPaginas) {
        this.totalPaginas = totalPaginas;
    }
}
