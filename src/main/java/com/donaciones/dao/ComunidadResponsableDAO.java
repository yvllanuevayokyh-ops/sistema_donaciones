package com.donaciones.dao;

import com.donaciones.model.ComunidadResponsable;
import com.donaciones.model.ComunidadVulnerable;
import com.donaciones.util.JPAUtil;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;

public class ComunidadResponsableDAO {

    public List<ComunidadResponsable> listarActivos() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.createQuery(
                    "SELECT r FROM ComunidadResponsable r " +
                            "WHERE r.activo = TRUE " +
                            "ORDER BY r.comunidad.nombre ASC, r.nombre ASC",
                    ComunidadResponsable.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    public List<ComunidadResponsable> listarPorComunidad(Integer idComunidad, boolean soloActivos) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            String jpql = "SELECT r FROM ComunidadResponsable r WHERE r.comunidad.idComunidad = :id " +
                    (soloActivos ? "AND r.activo = TRUE " : "") +
                    "ORDER BY r.nombre ASC";
            return em.createQuery(jpql, ComunidadResponsable.class)
                    .setParameter("id", idComunidad)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public ComunidadResponsable buscarPorId(Integer idResponsable) {
        if (idResponsable == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.find(ComunidadResponsable.class, idResponsable);
        } finally {
            em.close();
        }
    }

    public int crear(Integer idComunidad, String nombre, String telefono, String email, String cargo) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            ComunidadVulnerable comunidad = em.find(ComunidadVulnerable.class, idComunidad);
            if (comunidad == null) {
                throw new IllegalArgumentException("Comunidad no encontrada");
            }

            ComunidadResponsable responsable = new ComunidadResponsable();
            responsable.setComunidad(comunidad);
            responsable.setNombre(safe(nombre));
            responsable.setTelefono(safe(telefono));
            responsable.setEmail(safe(email));
            responsable.setCargo(safe(cargo));
            responsable.setActivo(Boolean.TRUE);
            em.persist(responsable);
            em.flush();
            tx.commit();
            return responsable.getIdResponsable() == null ? 0 : responsable.getIdResponsable();
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public void cambiarActivo(Integer idResponsable, boolean activo) {
        if (idResponsable == null) {
            return;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            ComunidadResponsable responsable = em.find(ComunidadResponsable.class, idResponsable);
            if (responsable != null) {
                responsable.setActivo(activo);
            }
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

    public boolean perteneceAComunidad(Integer idResponsable, Integer idComunidad) {
        if (idResponsable == null || idComunidad == null) {
            return false;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Long total = em.createQuery(
                            "SELECT COUNT(r) FROM ComunidadResponsable r " +
                                    "WHERE r.idResponsable = :idResponsable " +
                                    "AND r.comunidad.idComunidad = :idComunidad " +
                                    "AND r.activo = TRUE",
                            Long.class
                    ).setParameter("idResponsable", idResponsable)
                    .setParameter("idComunidad", idComunidad)
                    .getSingleResult();
            return total != null && total > 0;
        } finally {
            em.close();
        }
    }

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }
}
