package com.donaciones.dao;

import com.donaciones.model.UsuarioSistema;
import com.donaciones.util.JPAUtil;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.Query;

public class UsuarioSistemaDAO {

    public UsuarioSistema autenticar(String usuario, String password) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Query query = em.createNativeQuery(
                    "SELECT * FROM usuario_sistema " +
                            "WHERE usuario = ? AND password = ? AND estado = 1 " +
                            "LIMIT 1",
                    UsuarioSistema.class
            );
            query.setParameter(1, usuario);
            query.setParameter(2, password);

            @SuppressWarnings("unchecked")
            List<UsuarioSistema> result = query.getResultList();
            if (result == null || result.isEmpty()) {
                return null;
            }
            return result.get(0);
        } finally {
            em.close();
        }
    }

    public boolean existeUsuario(String usuario) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object value = em.createNativeQuery(
                    "SELECT COUNT(*) FROM usuario_sistema WHERE LOWER(usuario) = LOWER(?)"
            ).setParameter(1, safe(usuario)).getSingleResult();
            return toInt(value) > 0;
        } finally {
            em.close();
        }
    }

    public int registrar(String nombre, String usuario, String password, int idRol) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Query q = em.createNativeQuery(
                    "INSERT INTO usuario_sistema(nombre, usuario, password, id_rol, estado) VALUES(?,?,?,?,1)"
            );
            q.setParameter(1, safe(nombre));
            q.setParameter(2, safe(usuario));
            q.setParameter(3, safe(password));
            q.setParameter(4, idRol);
            q.executeUpdate();

            Object newId = em.createNativeQuery("SELECT LAST_INSERT_ID()").getSingleResult();
            tx.commit();
            return toInt(newId);
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
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

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }
}
