package com.donaciones.util;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

public final class JPAUtil {

    private static final String PERSISTENCE_UNIT = "sistemadonacionesPU";
    private static JPAUtil instance;
    private final EntityManagerFactory emf;

    private JPAUtil() {
        emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT);
    }

    public static synchronized JPAUtil getInstance() {
        if (instance == null) {
            instance = new JPAUtil();
        }
        return instance;
    }

    public static synchronized void shutdown() {
        if (instance != null) {
            instance.cerrar();
            instance = null;
        }
    }

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public EntityManager createEntityManager() {
        return getEntityManager();
    }

    public void cerrar() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }

    public void close() {
        cerrar();
    }
}
