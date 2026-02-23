package com.donaciones.dao;

import com.donaciones.model.UsuarioSistema;
import com.donaciones.util.JPAUtil;
import java.util.List;
import javax.persistence.EntityManager;
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
}
