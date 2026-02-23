package com.donaciones.dao;

import com.donaciones.model.EntregaDonacion;
import com.donaciones.model.EstadoEntrega;
import com.donaciones.util.JPAUtil;
import java.sql.Date;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.ParameterMode;
import javax.persistence.StoredProcedureQuery;

public class EntregaDAO {

    public ResultadoPaginado<EntregaDonacion> buscarYPaginar(
            String q, String estado, int pagina, int porPagina) {

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        ResultadoPaginado<EntregaDonacion> resultado = new ResultadoPaginado<EntregaDonacion>();
        try {
            int page = Math.max(1, pagina);
            int size = Math.max(1, porPagina);
            int offset = (page - 1) * size;

            StoredProcedureQuery spContar = em.createStoredProcedureQuery("sp_entrega_contar");
            spContar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spContar.registerStoredProcedureParameter("p_estado", String.class, ParameterMode.IN);
            spContar.setParameter("p_q", safe(q));
            spContar.setParameter("p_estado", safe(estado));
            spContar.execute();
            int total = toInt(spContar.getSingleResult());

            StoredProcedureQuery spListar =
                    em.createStoredProcedureQuery("sp_entrega_listar", EntregaDonacion.class);
            spListar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_estado", String.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_offset", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_limit", Integer.class, ParameterMode.IN);
            spListar.setParameter("p_q", safe(q));
            spListar.setParameter("p_estado", safe(estado));
            spListar.setParameter("p_offset", offset);
            spListar.setParameter("p_limit", size);
            spListar.execute();

            @SuppressWarnings("unchecked")
            List<EntregaDonacion> rows = spListar.getResultList();

            resultado.setDatos(rows);
            resultado.setTotalRegistros(total);
            resultado.setPaginaActual(page);
            resultado.setRegistrosPorPagina(size);
            resultado.setTotalPaginas(total == 0 ? 1 : (int) Math.ceil((double) total / size));
            return resultado;
        } finally {
            em.close();
        }
    }

    public EntregaDonacion buscarDetalle(Integer idEntrega) {
        if (idEntrega == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp =
                    em.createStoredProcedureQuery("sp_entrega_detalle", EntregaDonacion.class);
            sp.registerStoredProcedureParameter("p_id_entrega", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_entrega", idEntrega);
            sp.execute();

            @SuppressWarnings("unchecked")
            List<EntregaDonacion> rows = sp.getResultList();
            return rows.isEmpty() ? null : rows.get(0);
        } finally {
            em.close();
        }
    }

    public int crear(Integer idDonacion, Integer idComunidad, Integer idEstadoEntrega,
                     Date fechaProgramada, Date fechaEntrega, String observaciones) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_entrega_crear");
            sp.registerStoredProcedureParameter("p_id_donacion", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_comunidad", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_estado_entrega", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_programada", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_entrega", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_observaciones", String.class, ParameterMode.IN);
            sp.setParameter("p_id_donacion", idDonacion);
            sp.setParameter("p_id_comunidad", idComunidad);
            sp.setParameter("p_id_estado_entrega", idEstadoEntrega != null ? idEstadoEntrega : 1);
            sp.setParameter("p_fecha_programada", fechaProgramada);
            sp.setParameter("p_fecha_entrega", fechaEntrega);
            sp.setParameter("p_observaciones", safe(observaciones));
            sp.execute();
            int newId = extractGeneratedId(sp);
            tx.commit();
            return newId;
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public void editar(Integer idEntrega, Integer idDonacion, Integer idComunidad, Integer idEstadoEntrega,
                       Date fechaProgramada, Date fechaEntrega, String observaciones) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_entrega_editar");
            sp.registerStoredProcedureParameter("p_id_entrega", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_donacion", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_comunidad", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_estado_entrega", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_programada", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_entrega", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_observaciones", String.class, ParameterMode.IN);
            sp.setParameter("p_id_entrega", idEntrega);
            sp.setParameter("p_id_donacion", idDonacion);
            sp.setParameter("p_id_comunidad", idComunidad);
            sp.setParameter("p_id_estado_entrega", idEstadoEntrega);
            sp.setParameter("p_fecha_programada", fechaProgramada);
            sp.setParameter("p_fecha_entrega", fechaEntrega);
            sp.setParameter("p_observaciones", safe(observaciones));
            sp.execute();
            tx.commit();
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public void cambiarEstado(Integer idEntrega, Integer idEstadoEntrega,
                              Date fechaEntrega, String observaciones) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_entrega_cambiar_estado");
            sp.registerStoredProcedureParameter("p_id_entrega", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_estado_entrega", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_entrega", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_observaciones", String.class, ParameterMode.IN);
            sp.setParameter("p_id_entrega", idEntrega);
            sp.setParameter("p_id_estado_entrega", idEstadoEntrega);
            sp.setParameter("p_fecha_entrega", fechaEntrega);
            sp.setParameter("p_observaciones", safe(observaciones));
            sp.execute();
            tx.commit();
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public List<EstadoEntrega> listarEstados() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.createQuery(
                    "SELECT e FROM EstadoEntrega e ORDER BY e.idEstadoEntrega ASC",
                    EstadoEntrega.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    private int extractGeneratedId(StoredProcedureQuery sp) {
        @SuppressWarnings("unchecked")
        List<Object> rows = sp.getResultList();
        if (rows == null || rows.isEmpty()) {
            return 0;
        }
        Object first = rows.get(0);
        if (first instanceof Object[]) {
            Object[] arr = (Object[]) first;
            return arr.length == 0 ? 0 : toInt(arr[0]);
        }
        return toInt(first);
    }

    private int toInt(Object value) {
        if (value == null) {
            return 0;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    private String safe(Object value) {
        return value == null ? "" : String.valueOf(value);
    }
}
