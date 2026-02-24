package com.donaciones.dao;

import com.donaciones.model.Voluntario;
import com.donaciones.util.JPAUtil;
import java.sql.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.ParameterMode;
import javax.persistence.Query;
import javax.persistence.StoredProcedureQuery;
import org.hibernate.procedure.ProcedureCall;

public class VoluntarioDAO {

    public ResultadoPaginado<Voluntario> buscarYPaginar(String q, Integer estado, int pagina, int porPagina) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        ResultadoPaginado<Voluntario> resultado = new ResultadoPaginado<Voluntario>();
        try {
            int page = Math.max(1, pagina);
            int size = Math.max(1, porPagina);
            int offset = (page - 1) * size;

            StoredProcedureQuery spContar = em.createStoredProcedureQuery("sp_voluntario_contar");
            spContar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spContar.registerStoredProcedureParameter("p_estado", Integer.class, ParameterMode.IN);
            enableNullParam(spContar, "p_estado");
            spContar.setParameter("p_q", safe(q));
            spContar.setParameter("p_estado", estado);
            spContar.execute();
            int totalRegistros = toInt(spContar.getSingleResult());

            StoredProcedureQuery spListar = em.createStoredProcedureQuery("sp_voluntario_listar", Voluntario.class);
            spListar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_estado", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_offset", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_limit", Integer.class, ParameterMode.IN);
            enableNullParam(spListar, "p_estado");
            spListar.setParameter("p_q", safe(q));
            spListar.setParameter("p_estado", estado);
            spListar.setParameter("p_offset", offset);
            spListar.setParameter("p_limit", size);
            spListar.execute();

            @SuppressWarnings("unchecked")
            List<Voluntario> rows = spListar.getResultList();

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

    public Voluntario buscarDetalle(Integer idVoluntario) {
        if (idVoluntario == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_voluntario_detalle", Voluntario.class);
            sp.registerStoredProcedureParameter("p_id_voluntario", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_voluntario", idVoluntario);
            sp.execute();

            @SuppressWarnings("unchecked")
            List<Voluntario> result = sp.getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    public int crear(String nombre, String telefono, String email, Date fechaIngreso) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_voluntario_crear");
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_telefono", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_email", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_ingreso", Date.class, ParameterMode.IN);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_telefono", safe(telefono));
            sp.setParameter("p_email", safe(email));
            sp.setParameter("p_fecha_ingreso", fechaIngreso);
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

    public void editar(Integer idVoluntario, String nombre, String telefono, String email, Date fechaIngreso) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_voluntario_editar");
            sp.registerStoredProcedureParameter("p_id_voluntario", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_telefono", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_email", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_ingreso", Date.class, ParameterMode.IN);
            sp.setParameter("p_id_voluntario", idVoluntario);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_telefono", safe(telefono));
            sp.setParameter("p_email", safe(email));
            sp.setParameter("p_fecha_ingreso", fechaIngreso);
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

    public void cambiarEstado(Integer idVoluntario, boolean restaurar) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery(
                    restaurar ? "sp_voluntario_restaurar" : "sp_voluntario_eliminar"
            );
            sp.registerStoredProcedureParameter("p_id_voluntario", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_voluntario", idVoluntario);
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

    public int contarEntregasCompletadas() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Query query = em.createNativeQuery(
                    "SELECT COUNT(*) " +
                            "FROM asignacion_voluntario_entrega ave " +
                            "INNER JOIN entrega_donacion ed ON ed.id_entrega = ave.id_entrega " +
                            "INNER JOIN estado_entrega ee ON ee.id_estado_entrega = ed.id_estado_entrega " +
                            "WHERE UPPER(ee.descripcion) = 'ENTREGADO'"
            );
            return toInt(query.getSingleResult());
        } finally {
            em.close();
        }
    }

    public int contarEntregasTotalesPorVoluntario(int idVoluntario) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object total = em.createNativeQuery(
                    "SELECT COUNT(DISTINCT id_entrega) FROM asignacion_voluntario_entrega WHERE id_voluntario = ?"
            ).setParameter(1, idVoluntario).getSingleResult();
            return toInt(total);
        } finally {
            em.close();
        }
    }

    public int contarEntregasCompletadasPorVoluntario(int idVoluntario) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object total = em.createNativeQuery(
                    "SELECT COUNT(DISTINCT ave.id_entrega) " +
                            "FROM asignacion_voluntario_entrega ave " +
                            "INNER JOIN entrega_donacion ed ON ed.id_entrega = ave.id_entrega " +
                            "INNER JOIN estado_entrega ee ON ee.id_estado_entrega = ed.id_estado_entrega " +
                            "WHERE ave.id_voluntario = ? AND UPPER(COALESCE(ee.descripcion,'')) = 'ENTREGADO'"
            ).setParameter(1, idVoluntario).getSingleResult();
            return toInt(total);
        } finally {
            em.close();
        }
    }

    public Map<Integer, Integer> contarEntregasTotalesPorVoluntarios(List<Integer> idsVoluntario) {
        Map<Integer, Integer> conteos = new LinkedHashMap<Integer, Integer>();
        if (idsVoluntario == null || idsVoluntario.isEmpty()) {
            return conteos;
        }

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT id_voluntario, COUNT(DISTINCT id_entrega) AS total " +
                            "FROM asignacion_voluntario_entrega " +
                            "WHERE id_voluntario IN (:ids) " +
                            "GROUP BY id_voluntario"
            ).setParameter("ids", idsVoluntario).getResultList();

            for (Object[] row : rows) {
                conteos.put(toInt(row[0]), toInt(row[1]));
            }
            return conteos;
        } finally {
            em.close();
        }
    }

    public Map<Integer, Integer> contarEntregasCompletadasPorVoluntarios(List<Integer> idsVoluntario) {
        Map<Integer, Integer> conteos = new LinkedHashMap<Integer, Integer>();
        if (idsVoluntario == null || idsVoluntario.isEmpty()) {
            return conteos;
        }

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT ave.id_voluntario, COUNT(DISTINCT ave.id_entrega) AS total " +
                            "FROM asignacion_voluntario_entrega ave " +
                            "INNER JOIN entrega_donacion ed ON ed.id_entrega = ave.id_entrega " +
                            "INNER JOIN estado_entrega ee ON ee.id_estado_entrega = ed.id_estado_entrega " +
                            "WHERE ave.id_voluntario IN (:ids) " +
                            "AND UPPER(COALESCE(ee.descripcion,'')) = 'ENTREGADO' " +
                            "GROUP BY ave.id_voluntario"
            ).setParameter("ids", idsVoluntario).getResultList();

            for (Object[] row : rows) {
                conteos.put(toInt(row[0]), toInt(row[1]));
            }
            return conteos;
        } finally {
            em.close();
        }
    }

    private int extractGeneratedId(StoredProcedureQuery sp) {
        @SuppressWarnings("unchecked")
        List<Object> result = sp.getResultList();
        if (result == null || result.isEmpty()) {
            return 0;
        }

        Object first = result.get(0);
        if (first instanceof Object[]) {
            Object[] row = (Object[]) first;
            return row.length == 0 ? 0 : toInt(row[0]);
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

    private void enableNullParam(StoredProcedureQuery sp, String paramName) {
        try {
            sp.unwrap(ProcedureCall.class)
                    .getParameterRegistration(paramName)
                    .enablePassingNulls(true);
        } catch (RuntimeException ignored) {
            // Fallback: if provider does not support this, keep default behavior.
        }
    }
}
