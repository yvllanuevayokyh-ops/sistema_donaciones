package com.donaciones.dao;

import com.donaciones.model.Pais;
import com.donaciones.util.JPAUtil;
import java.util.List;
import javax.persistence.EntityManager;

public class PaisDAO {

    public List<Pais> listar() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.createQuery("SELECT p FROM Pais p ORDER BY p.nombre ASC", Pais.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}