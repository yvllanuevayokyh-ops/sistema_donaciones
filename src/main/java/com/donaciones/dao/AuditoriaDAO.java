package com.donaciones.dao;

import com.donaciones.util.JPAUtil;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.Query;

public class AuditoriaDAO {

    private static volatile boolean schemaReady = false;

    public void asegurarEsquema() {
        if (schemaReady) {
            return;
        }
        synchronized (AuditoriaDAO.class) {
            if (schemaReady) {
                return;
            }
            EntityManager em = JPAUtil.getInstance().getEntityManager();
            EntityTransaction tx = em.getTransaction();
            try {
                tx.begin();
                em.createNativeQuery(
                        "CREATE TABLE IF NOT EXISTS auditoria_log (" +
                                "id_auditoria INT AUTO_INCREMENT PRIMARY KEY," +
                                "fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
                                "usuario VARCHAR(120) NULL," +
                                "rol VARCHAR(80) NULL," +
                                "modulo VARCHAR(80) NULL," +
                                "accion VARCHAR(80) NULL," +
                                "detalle VARCHAR(500) NULL," +
                                "estado_http INT NULL," +
                                "KEY idx_auditoria_fecha (fecha_evento)," +
                                "KEY idx_auditoria_modulo (modulo)," +
                                "KEY idx_auditoria_accion (accion)" +
                                ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
                ).executeUpdate();
                tx.commit();
                schemaReady = true;
            } catch (RuntimeException ex) {
                if (tx.isActive()) {
                    tx.rollback();
                }
                throw ex;
            } finally {
                em.close();
            }
        }
    }

    public void registrar(String usuario, String rol, String modulo, String accion, String detalle, Integer estadoHttp) {
        try {
            asegurarEsquema();
        } catch (RuntimeException ex) {
            return;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Query q = em.createNativeQuery(
                    "INSERT INTO auditoria_log(fecha_evento, usuario, rol, modulo, accion, detalle, estado_http) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?)"
            );
            q.setParameter(1, new Timestamp(System.currentTimeMillis()));
            q.setParameter(2, safe(usuario));
            q.setParameter(3, safe(rol));
            q.setParameter(4, safe(modulo));
            q.setParameter(5, safe(accion));
            q.setParameter(6, truncate(safe(detalle), 500));
            q.setParameter(7, estadoHttp);
            q.executeUpdate();
            tx.commit();
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
        } finally {
            em.close();
        }
    }

    public List<Object[]> listar(String q, String modulo, String accion, int limit) {
        asegurarEsquema();
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            String filterQ = safe(q).trim();
            String filterModulo = safe(modulo).trim();
            String filterAccion = safe(accion).trim();
            Query query = em.createNativeQuery(
                    "SELECT id_auditoria, fecha_evento, usuario, rol, modulo, accion, detalle, estado_http " +
                            "FROM auditoria_log " +
                            "WHERE (? = '' OR UPPER(COALESCE(usuario,'')) LIKE CONCAT('%', UPPER(?), '%') " +
                            "OR UPPER(COALESCE(detalle,'')) LIKE CONCAT('%', UPPER(?), '%')) " +
                            "AND (? = '' OR UPPER(COALESCE(modulo,'')) = UPPER(?)) " +
                            "AND (? = '' OR UPPER(COALESCE(accion,'')) = UPPER(?)) " +
                            "ORDER BY id_auditoria DESC"
            );
            query.setParameter(1, filterQ);
            query.setParameter(2, filterQ);
            query.setParameter(3, filterQ);
            query.setParameter(4, filterModulo);
            query.setParameter(5, filterModulo);
            query.setParameter(6, filterAccion);
            query.setParameter(7, filterAccion);
            query.setMaxResults(Math.max(1, limit));
            @SuppressWarnings("unchecked")
            List<Object[]> rows = query.getResultList();
            return rows == null ? new ArrayList<Object[]>() : rows;
        } finally {
            em.close();
        }
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }

    private String truncate(String value, int maxLen) {
        if (value == null) {
            return "";
        }
        return value.length() <= maxLen ? value : value.substring(0, maxLen);
    }
}
