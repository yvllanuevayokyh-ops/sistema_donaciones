package com.donaciones.dao;

import com.donaciones.model.Donacion;
import com.donaciones.util.JPAUtil;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.ParameterMode;
import javax.persistence.Query;
import javax.persistence.StoredProcedureQuery;
import org.hibernate.procedure.ProcedureCall;

public class DonacionDAO {

    public ResultadoPaginado<Donacion> buscarYPaginar(
            String q, String estado, Integer activo, int pagina, int porPagina) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        ResultadoPaginado<Donacion> resultado = new ResultadoPaginado<Donacion>();
        try {
            int page = Math.max(1, pagina);
            int size = Math.max(1, porPagina);
            int offset = (page - 1) * size;
            String normalizedQ = safe(q).trim();
            String normalizedEstado = safe(estado).trim();
            String idLike = normalizedQ.toUpperCase().replace("DON-", "").replace(" ", "");
            String textLike = "%" + normalizedQ.toUpperCase() + "%";

            StringBuilder sqlCount = new StringBuilder(
                    "SELECT COUNT(*) FROM donacion d " +
                            "INNER JOIN donante dn ON dn.id_donante = d.id_donante WHERE 1=1"
            );
            List<Object> countParams = new ArrayList<Object>();

            if (!normalizedQ.isEmpty()) {
                sqlCount.append(" AND (CAST(d.id_donacion AS CHAR) LIKE ? ")
                        .append("OR CONCAT('DON-', LPAD(d.id_donacion, 3, '0')) LIKE ? ")
                        .append("OR UPPER(COALESCE(d.descripcion, '')) LIKE ? ")
                        .append("OR UPPER(COALESCE(dn.nombre, '')) LIKE ? ")
                        .append("OR UPPER(COALESCE(dn.email, '')) LIKE ?)");
                countParams.add("%" + idLike + "%");
                countParams.add(textLike);
                countParams.add(textLike);
                countParams.add(textLike);
                countParams.add(textLike);
            }

            if (!normalizedEstado.isEmpty() && !"TODAS".equalsIgnoreCase(normalizedEstado)) {
                sqlCount.append(" AND UPPER(d.estado_donacion) = ?");
                countParams.add(normalizedEstado.toUpperCase());
            }

            if (activo != null) {
                sqlCount.append(" AND d.activo = ?");
                countParams.add(activo);
            }

            Query qCount = em.createNativeQuery(sqlCount.toString());
            setPositionalParams(qCount, countParams);
            int totalRegistros = toInt(qCount.getSingleResult());

            StringBuilder sqlList = new StringBuilder(
                    "SELECT d.* FROM donacion d " +
                            "INNER JOIN donante dn ON dn.id_donante = d.id_donante WHERE 1=1"
            );
            List<Object> listParams = new ArrayList<Object>();

            if (!normalizedQ.isEmpty()) {
                sqlList.append(" AND (CAST(d.id_donacion AS CHAR) LIKE ? ")
                        .append("OR CONCAT('DON-', LPAD(d.id_donacion, 3, '0')) LIKE ? ")
                        .append("OR UPPER(COALESCE(d.descripcion, '')) LIKE ? ")
                        .append("OR UPPER(COALESCE(dn.nombre, '')) LIKE ? ")
                        .append("OR UPPER(COALESCE(dn.email, '')) LIKE ?)");
                listParams.add("%" + idLike + "%");
                listParams.add(textLike);
                listParams.add(textLike);
                listParams.add(textLike);
                listParams.add(textLike);
            }

            if (!normalizedEstado.isEmpty() && !"TODAS".equalsIgnoreCase(normalizedEstado)) {
                sqlList.append(" AND UPPER(d.estado_donacion) = ?");
                listParams.add(normalizedEstado.toUpperCase());
            }

            if (activo != null) {
                sqlList.append(" AND d.activo = ?");
                listParams.add(activo);
            }

            sqlList.append(" ORDER BY d.fecha_donacion DESC, d.id_donacion DESC LIMIT ?, ?");
            listParams.add(offset);
            listParams.add(size);

            Query qList = em.createNativeQuery(sqlList.toString(), Donacion.class);
            setPositionalParams(qList, listParams);

            @SuppressWarnings("unchecked")
            List<Donacion> rows = qList.getResultList();

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

    public ResultadoPaginado<Donacion> buscarYPaginarPorDonante(
            String q, String estado, Integer activo, int pagina, int porPagina, int idDonante) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        ResultadoPaginado<Donacion> resultado = new ResultadoPaginado<Donacion>();
        try {
            int page = Math.max(1, pagina);
            int size = Math.max(1, porPagina);
            int offset = (page - 1) * size;

            String normalizedQ = safe(q).trim();
            String normalizedEstado = safe(estado).trim();
            String idLike = normalizedQ.toUpperCase().replace("DON-", "").replace(" ", "");
            String textLike = "%" + normalizedQ.toUpperCase() + "%";

            StringBuilder sqlCount = new StringBuilder("SELECT COUNT(*) FROM donacion d WHERE d.id_donante = ?");
            List<Object> countParams = new ArrayList<Object>();
            countParams.add(idDonante);

            if (!normalizedQ.isEmpty()) {
                sqlCount.append(" AND (CAST(d.id_donacion AS CHAR) LIKE ? ")
                        .append("OR CONCAT('DON-', LPAD(d.id_donacion, 3, '0')) LIKE ? ")
                        .append("OR UPPER(d.descripcion) LIKE ?)");
                countParams.add("%" + idLike + "%");
                countParams.add(textLike);
                countParams.add(textLike);
            }
            if (!normalizedEstado.isEmpty() && !"TODAS".equalsIgnoreCase(normalizedEstado)) {
                sqlCount.append(" AND UPPER(d.estado_donacion) = ?");
                countParams.add(normalizedEstado.toUpperCase());
            }
            if (activo != null) {
                sqlCount.append(" AND d.activo = ?");
                countParams.add(activo);
            }

            Query qCount = em.createNativeQuery(sqlCount.toString());
            setPositionalParams(qCount, countParams);
            int totalRegistros = toInt(qCount.getSingleResult());

            StringBuilder sqlList = new StringBuilder("SELECT d.* FROM donacion d WHERE d.id_donante = ?");
            List<Object> listParams = new ArrayList<Object>();
            listParams.add(idDonante);

            if (!normalizedQ.isEmpty()) {
                sqlList.append(" AND (CAST(d.id_donacion AS CHAR) LIKE ? ")
                        .append("OR CONCAT('DON-', LPAD(d.id_donacion, 3, '0')) LIKE ? ")
                        .append("OR UPPER(d.descripcion) LIKE ?)");
                listParams.add("%" + idLike + "%");
                listParams.add(textLike);
                listParams.add(textLike);
            }
            if (!normalizedEstado.isEmpty() && !"TODAS".equalsIgnoreCase(normalizedEstado)) {
                sqlList.append(" AND UPPER(d.estado_donacion) = ?");
                listParams.add(normalizedEstado.toUpperCase());
            }
            if (activo != null) {
                sqlList.append(" AND d.activo = ?");
                listParams.add(activo);
            }
            sqlList.append(" ORDER BY d.fecha_donacion DESC, d.id_donacion DESC LIMIT ?, ?");
            listParams.add(offset);
            listParams.add(size);

            Query qList = em.createNativeQuery(sqlList.toString(), Donacion.class);
            setPositionalParams(qList, listParams);

            @SuppressWarnings("unchecked")
            List<Donacion> rows = qList.getResultList();

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

    public Donacion buscarDetalle(Integer idDonacion) {
        if (idDonacion == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_donacion_detalle", Donacion.class);
            sp.registerStoredProcedureParameter("p_id_donacion", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_donacion", idDonacion);
            sp.execute();

            @SuppressWarnings("unchecked")
            List<Donacion> result = sp.getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    public Donacion buscarDetallePorDonante(Integer idDonacion, int idDonante) {
        if (idDonacion == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Query query = em.createNativeQuery(
                    "SELECT d.* FROM donacion d WHERE d.id_donacion = ? AND d.id_donante = ? LIMIT 1",
                    Donacion.class
            );
            query.setParameter(1, idDonacion);
            query.setParameter(2, idDonante);

            @SuppressWarnings("unchecked")
            List<Donacion> result = query.getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    public int crear(Integer idDonante, Integer idCampania, String tipoDonacion, String estadoDonacion,
                     Date fechaDonacion, BigDecimal monto, String descripcion) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_donacion_crear");
            sp.registerStoredProcedureParameter("p_id_donante", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_campania", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_tipo_donacion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_estado_donacion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_donacion", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_monto", BigDecimal.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_descripcion", String.class, ParameterMode.IN);
            sp.setParameter("p_id_donante", idDonante);
            sp.setParameter("p_id_campania", idCampania);
            sp.setParameter("p_tipo_donacion", safe(tipoDonacion));
            sp.setParameter("p_estado_donacion", safe(estadoDonacion));
            sp.setParameter("p_fecha_donacion", fechaDonacion);
            sp.setParameter("p_monto", monto);
            sp.setParameter("p_descripcion", safe(descripcion));
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

    public void editar(Integer idDonacion, Integer idDonante, Integer idCampania, String tipoDonacion,
                       String estadoDonacion, Date fechaDonacion, BigDecimal monto, String descripcion) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_donacion_editar");
            sp.registerStoredProcedureParameter("p_id_donacion", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_donante", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_campania", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_tipo_donacion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_estado_donacion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_donacion", Date.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_monto", BigDecimal.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_descripcion", String.class, ParameterMode.IN);
            sp.setParameter("p_id_donacion", idDonacion);
            sp.setParameter("p_id_donante", idDonante);
            sp.setParameter("p_id_campania", idCampania);
            sp.setParameter("p_tipo_donacion", safe(tipoDonacion));
            sp.setParameter("p_estado_donacion", safe(estadoDonacion));
            sp.setParameter("p_fecha_donacion", fechaDonacion);
            sp.setParameter("p_monto", monto);
            sp.setParameter("p_descripcion", safe(descripcion));
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

    public void cambiarActivo(Integer idDonacion, boolean restaurar) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery(
                    restaurar ? "sp_donacion_restaurar" : "sp_donacion_inactivar"
            );
            sp.registerStoredProcedureParameter("p_id_donacion", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_donacion", idDonacion);
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

    public List<Donacion> listarDonacionesCatalogo() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.createQuery(
                    "SELECT d FROM Donacion d " +
                            "WHERE d.activo = TRUE " +
                            "ORDER BY d.fechaDonacion DESC, d.idDonacion DESC",
                    Donacion.class
            ).getResultList();
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

    private void setPositionalParams(Query query, List<Object> values) {
        for (int i = 0; i < values.size(); i++) {
            query.setParameter(i + 1, values.get(i));
        }
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
