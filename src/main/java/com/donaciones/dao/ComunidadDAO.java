package com.donaciones.dao;

import com.donaciones.model.ComunidadVulnerable;
import com.donaciones.util.JPAUtil;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.ParameterMode;
import javax.persistence.StoredProcedureQuery;
import org.hibernate.procedure.ProcedureCall;

public class ComunidadDAO {

    public ResultadoPaginado<ComunidadVulnerable> buscarYPaginar(String q, Integer activo, int pagina, int porPagina) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        ResultadoPaginado<ComunidadVulnerable> resultado = new ResultadoPaginado<ComunidadVulnerable>();
        try {
            int page = Math.max(1, pagina);
            int size = Math.max(1, porPagina);
            int offset = (page - 1) * size;

            StoredProcedureQuery spContar = em.createStoredProcedureQuery("sp_comunidad_contar");
            spContar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spContar.registerStoredProcedureParameter("p_activo", Integer.class, ParameterMode.IN);
            enableNullParam(spContar, "p_activo");
            spContar.setParameter("p_q", safe(q));
            spContar.setParameter("p_activo", activo);
            spContar.execute();
            int totalRegistros = toInt(spContar.getSingleResult());

            StoredProcedureQuery spListar = em.createStoredProcedureQuery("sp_comunidad_listar", ComunidadVulnerable.class);
            spListar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_activo", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_offset", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_limit", Integer.class, ParameterMode.IN);
            enableNullParam(spListar, "p_activo");
            spListar.setParameter("p_q", safe(q));
            spListar.setParameter("p_activo", activo);
            spListar.setParameter("p_offset", offset);
            spListar.setParameter("p_limit", size);
            spListar.execute();

            @SuppressWarnings("unchecked")
            List<ComunidadVulnerable> rows = spListar.getResultList();

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

    public ComunidadVulnerable buscarDetalle(Integer idComunidad) {
        if (idComunidad == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_comunidad_detalle", ComunidadVulnerable.class);
            sp.registerStoredProcedureParameter("p_id_comunidad", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_comunidad", idComunidad);
            sp.execute();

            @SuppressWarnings("unchecked")
            List<ComunidadVulnerable> result = sp.getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    public int crear(String nombre, String ubicacion, String descripcion,
                     Integer cantidadBeneficiarios, Integer idPais) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_comunidad_crear");
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_ubicacion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_descripcion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_cantidad_beneficiarios", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_pais", Integer.class, ParameterMode.IN);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_ubicacion", safe(ubicacion));
            sp.setParameter("p_descripcion", safe(descripcion));
            sp.setParameter("p_cantidad_beneficiarios", cantidadBeneficiarios);
            sp.setParameter("p_id_pais", idPais);
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

    public void editar(Integer idComunidad, String nombre, String ubicacion, String descripcion,
                       Integer cantidadBeneficiarios, Integer idPais) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_comunidad_editar");
            sp.registerStoredProcedureParameter("p_id_comunidad", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_ubicacion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_descripcion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_cantidad_beneficiarios", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_pais", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_comunidad", idComunidad);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_ubicacion", safe(ubicacion));
            sp.setParameter("p_descripcion", safe(descripcion));
            sp.setParameter("p_cantidad_beneficiarios", cantidadBeneficiarios);
            sp.setParameter("p_id_pais", idPais);
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

    public void cambiarActivo(Integer idComunidad, boolean restaurar) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery(
                    restaurar ? "sp_comunidad_restaurar" : "sp_comunidad_inactivar"
            );
            sp.registerStoredProcedureParameter("p_id_comunidad", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_comunidad", idComunidad);
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

    public int contarDonacionesRecibidas(int idComunidad) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object total = em.createNativeQuery(
                    "SELECT COUNT(DISTINCT id_donacion) FROM entrega_donacion WHERE id_comunidad = ?"
            ).setParameter(1, idComunidad).getSingleResult();
            return toInt(total);
        } finally {
            em.close();
        }
    }

    public Map<Integer, Integer> contarDonacionesRecibidasPorComunidades(List<Integer> idsComunidad) {
        Map<Integer, Integer> conteos = new LinkedHashMap<Integer, Integer>();
        if (idsComunidad == null || idsComunidad.isEmpty()) {
            return conteos;
        }

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT id_comunidad, COUNT(DISTINCT id_donacion) AS total " +
                            "FROM entrega_donacion " +
                            "WHERE id_comunidad IN (:ids) " +
                            "GROUP BY id_comunidad"
            ).setParameter("ids", idsComunidad).getResultList();

            for (Object[] row : rows) {
                conteos.put(toInt(row[0]), toInt(row[1]));
            }
            return conteos;
        } finally {
            em.close();
        }
    }

    public List<ComunidadVulnerable> listarComunidadesCatalogo() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM ComunidadVulnerable c WHERE c.activo = TRUE ORDER BY c.nombre ASC",
                    ComunidadVulnerable.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    public ComunidadVulnerable buscarPorNombreExacto(String nombre) {
        String filter = safe(nombre).trim();
        if (filter.isEmpty()) {
            return null;
        }

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<ComunidadVulnerable> rows = em.createNativeQuery(
                            "SELECT * FROM comunidad_vulnerable WHERE LOWER(nombre) = LOWER(?) LIMIT 1",
                            ComunidadVulnerable.class
                    ).setParameter(1, filter)
                    .getResultList();
            return rows.isEmpty() ? null : rows.get(0);
        } finally {
            em.close();
        }
    }

    public List<Object[]> listarReporteRecepciones(Integer idComunidad) {
        if (idComunidad == null) {
            return new ArrayList<Object[]>();
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT e.id_entrega, d.id_donacion, COALESCE(d.descripcion, ''), " +
                            "COALESCE(dn.nombre, ''), COALESCE(v.nombre, 'Sin asignar'), " +
                            "COALESCE(r.nombre, 'Sin asignar'), " +
                            "COALESCE(ee.descripcion, ''), d.fecha_donacion, e.fecha_entrega, " +
                            "COALESCE(d.monto, 0) " +
                            "FROM entrega_donacion e " +
                            "INNER JOIN donacion d ON d.id_donacion = e.id_donacion " +
                            "INNER JOIN donante dn ON dn.id_donante = d.id_donante " +
                            "LEFT JOIN estado_entrega ee ON ee.id_estado_entrega = e.id_estado_entrega " +
                            "LEFT JOIN asignacion_voluntario_entrega ave ON ave.id_entrega = e.id_entrega " +
                            "LEFT JOIN voluntario v ON v.id_voluntario = ave.id_voluntario " +
                            "LEFT JOIN comunidad_responsable r ON r.id_responsable = e.id_responsable " +
                            "WHERE e.id_comunidad = ? " +
                            "ORDER BY COALESCE(e.fecha_entrega, e.fecha_programada) DESC, e.id_entrega DESC"
            ).setParameter(1, idComunidad).getResultList();
            return rows == null ? new ArrayList<Object[]>() : rows;
        } finally {
            em.close();
        }
    }

    public BigDecimal montoRecibidoComunidad(Integer idComunidad) {
        if (idComunidad == null) {
            return BigDecimal.ZERO;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object value = em.createNativeQuery(
                    "SELECT COALESCE(SUM(COALESCE(d.monto,0)),0) " +
                            "FROM entrega_donacion e " +
                            "INNER JOIN donacion d ON d.id_donacion = e.id_donacion " +
                            "INNER JOIN estado_entrega ee ON ee.id_estado_entrega = e.id_estado_entrega " +
                            "WHERE e.id_comunidad = ? AND UPPER(ee.descripcion) = 'ENTREGADO'"
            ).setParameter(1, idComunidad).getSingleResult();
            return toBigDecimal(value);
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
