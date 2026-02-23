package com.donaciones.dao;

import com.donaciones.model.Campania;
import com.donaciones.util.JPAUtil;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.ParameterMode;
import javax.persistence.StoredProcedureQuery;

public class CampaniaDAO {

    public ResultadoPaginado<Campania> buscarYPaginar(
            String q, String estado, Integer activo, int pagina, int porPagina) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        ResultadoPaginado<Campania> resultado = new ResultadoPaginado<Campania>();
        try {
            int page = Math.max(1, pagina);
            int size = Math.max(1, porPagina);
            int offset = (page - 1) * size;

            StoredProcedureQuery spContar = em.createStoredProcedureQuery("sp_campania_contar");
            spContar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spContar.registerStoredProcedureParameter("p_estado", String.class, ParameterMode.IN);
            spContar.registerStoredProcedureParameter("p_activo", Integer.class, ParameterMode.IN);
            spContar.setParameter("p_q", safe(q));
            spContar.setParameter("p_estado", safe(estado));
            spContar.setParameter("p_activo", activo);
            spContar.execute();
            int totalRegistros = toInt(spContar.getSingleResult());

            StoredProcedureQuery spListar = em.createStoredProcedureQuery("sp_campania_listar", Campania.class);
            spListar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_estado", String.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_activo", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_offset", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_limit", Integer.class, ParameterMode.IN);
            spListar.setParameter("p_q", safe(q));
            spListar.setParameter("p_estado", safe(estado));
            spListar.setParameter("p_activo", activo);
            spListar.setParameter("p_offset", offset);
            spListar.setParameter("p_limit", size);
            spListar.execute();

            @SuppressWarnings("unchecked")
            List<Campania> rows = spListar.getResultList();

            resultado.setDatos(rows);
            resultado.setTotalRegistros(totalRegistros);
            resultado.setPaginaActual(page);
            resultado.setRegistrosPorPagina(size);
            resultado.setTotalPaginas(totalRegistros == 0 ? 1 : (int) Math.ceil((double) totalRegistros / size));
            return resultado;
        } finally {
            em.close();
        }
    }

    public Campania buscarDetalle(Integer idCampania) {
        if (idCampania == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_campania_detalle", Campania.class);
            sp.registerStoredProcedureParameter("p_id_campania", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_campania", idCampania);
            sp.execute();

            @SuppressWarnings("unchecked")
            List<Campania> result = sp.getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    public int crear(String nombre, String descripcion, Date fechaInicio, Date fechaFin,
                     String estado, BigDecimal montoObjetivo) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_campania_crear");
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_descripcion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_inicio", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_fin", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_estado", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_monto_objetivo", BigDecimal.class, ParameterMode.IN);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_descripcion", safe(descripcion));
            sp.setParameter("p_fecha_inicio", fechaInicio);
            sp.setParameter("p_fecha_fin", fechaFin);
            sp.setParameter("p_estado", safe(estado));
            sp.setParameter("p_monto_objetivo", montoObjetivo);
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

    public void editar(Integer idCampania, String nombre, String descripcion, Date fechaInicio,
                       Date fechaFin, String estado, BigDecimal montoObjetivo) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_campania_editar");
            sp.registerStoredProcedureParameter("p_id_campania", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_descripcion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_inicio", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_fin", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_estado", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_monto_objetivo", BigDecimal.class, ParameterMode.IN);
            sp.setParameter("p_id_campania", idCampania);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_descripcion", safe(descripcion));
            sp.setParameter("p_fecha_inicio", fechaInicio);
            sp.setParameter("p_fecha_fin", fechaFin);
            sp.setParameter("p_estado", safe(estado));
            sp.setParameter("p_monto_objetivo", montoObjetivo);
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

    public void cambiarActivo(Integer idCampania, boolean restaurar) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery(
                    restaurar ? "sp_campania_restaurar" : "sp_campania_eliminar"
            );
            sp.registerStoredProcedureParameter("p_id_campania", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_campania", idCampania);
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

    public List<Campania> listarActivas() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM Campania c WHERE c.activo = TRUE ORDER BY c.nombre ASC",
                    Campania.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    public Map<Integer, BigDecimal> obtenerMontosRecaudados(List<Integer> idsCampania) {
        Map<Integer, BigDecimal> montos = new LinkedHashMap<Integer, BigDecimal>();
        if (idsCampania == null || idsCampania.isEmpty()) {
            return montos;
        }

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT d.id_campania, COALESCE(SUM(COALESCE(d.monto, 0)), 0) AS monto_recaudado " +
                            "FROM donacion d " +
                            "WHERE d.id_campania IN (:ids) AND (d.activo = 1 OR d.activo IS NULL) " +
                            "GROUP BY d.id_campania"
            ).setParameter("ids", idsCampania).getResultList();

            for (Object[] row : rows) {
                montos.put(toInt(row[0]), toBigDecimal(row[1]));
            }
            return montos;
        } finally {
            em.close();
        }
    }

    public Map<Integer, Integer> contarDonacionesPorCampania(List<Integer> idsCampania) {
        Map<Integer, Integer> totales = new LinkedHashMap<Integer, Integer>();
        if (idsCampania == null || idsCampania.isEmpty()) {
            return totales;
        }

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT d.id_campania, COUNT(*) AS total " +
                            "FROM donacion d " +
                            "WHERE d.id_campania IN (:ids) AND (d.activo = 1 OR d.activo IS NULL) " +
                            "GROUP BY d.id_campania"
            ).setParameter("ids", idsCampania).getResultList();

            for (Object[] row : rows) {
                totales.put(toInt(row[0]), toInt(row[1]));
            }
            return totales;
        } finally {
            em.close();
        }
    }

    private int extractGeneratedId(StoredProcedureQuery sp) {
        @SuppressWarnings("unchecked")
        List<Object[]> result = sp.getResultList();
        if (result == null || result.isEmpty() || result.get(0).length == 0) {
            return 0;
        }
        return toInt(result.get(0)[0]);
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

    private BigDecimal toBigDecimal(Object value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        }
        if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue());
        }
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return BigDecimal.ZERO;
        }
    }

    private String safe(Object value) {
        return value == null ? "" : String.valueOf(value);
    }
}