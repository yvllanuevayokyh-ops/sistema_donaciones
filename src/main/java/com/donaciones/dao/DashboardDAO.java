package com.donaciones.dao;

import com.donaciones.util.JPAUtil;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.Query;

public class DashboardDAO {

    public int contar(String sql) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return toInt(em.createNativeQuery(sql).getSingleResult());
        } finally {
            em.close();
        }
    }

    public int contarPorId(String sql, int id) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return toInt(em.createNativeQuery(sql).setParameter(1, id).getSingleResult());
        } finally {
            em.close();
        }
    }

    public String montoPorId(String sql, int id) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object value = em.createNativeQuery(sql).setParameter(1, id).getSingleResult();
            return safe(value);
        } finally {
            em.close();
        }
    }

    public List<String[]> donacionesRecientes() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Query query = em.createNativeQuery(
                    "SELECT d.descripcion, " +
                            "COALESCE(CONCAT('S/ ', FORMAT(d.monto, 2)), d.tipo_donacion) AS detalle, " +
                            "d.estado_donacion, DATE_FORMAT(d.fecha_donacion, '%Y-%m-%d') AS fecha, dn.nombre " +
                            "FROM donacion d " +
                            "INNER JOIN donante dn ON dn.id_donante = d.id_donante " +
                            "ORDER BY d.fecha_donacion DESC, d.id_donacion DESC " +
                            "LIMIT 5"
            );

            @SuppressWarnings("unchecked")
            List<Object[]> rows = query.getResultList();
            List<String[]> result = new ArrayList<String[]>();
            for (Object[] row : rows) {
                result.add(new String[]{
                        safe(row[0]),
                        safe(row[1]),
                        safe(row[2]),
                        safe(row[3]),
                        safe(row[4])
                });
            }
            return result;
        } finally {
            em.close();
        }
    }

    public List<String[]> donacionesRecientesPorDonante(int idDonante) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Query query = em.createNativeQuery(
                    "SELECT d.descripcion, " +
                            "COALESCE(CONCAT('S/ ', FORMAT(d.monto, 2)), d.tipo_donacion) AS detalle, " +
                            "d.estado_donacion, DATE_FORMAT(d.fecha_donacion, '%Y-%m-%d') AS fecha, " +
                            "COALESCE(c.nombre, 'Sin campania') " +
                            "FROM donacion d " +
                            "LEFT JOIN campania c ON c.id_campania = d.id_campania " +
                            "WHERE d.id_donante = ? AND d.activo = 1 " +
                            "ORDER BY d.fecha_donacion DESC, d.id_donacion DESC " +
                            "LIMIT 5"
            );
            query.setParameter(1, idDonante);

            @SuppressWarnings("unchecked")
            List<Object[]> rows = query.getResultList();
            List<String[]> result = new ArrayList<String[]>();
            for (Object[] row : rows) {
                result.add(new String[]{
                        safe(row[0]),
                        safe(row[1]),
                        safe(row[2]),
                        safe(row[3]),
                        safe(row[4])
                });
            }
            return result;
        } finally {
            em.close();
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
}
