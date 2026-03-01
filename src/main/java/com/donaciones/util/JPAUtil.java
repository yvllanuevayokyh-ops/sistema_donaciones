package com.donaciones.util;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;

public final class JPAUtil {

    private static final String PERSISTENCE_UNIT = "sistemadonacionesPU";
    private static JPAUtil instance;
    private final EntityManagerFactory emf;

    private JPAUtil() {
        Map<String, Object> overrides = new HashMap<String, Object>();
        putIfPresent(overrides, "javax.persistence.jdbc.url", readConfig("SD_DB_URL", "sd.db.url"));
        putIfPresent(overrides, "javax.persistence.jdbc.user", readConfig("SD_DB_USER", "sd.db.user"));
        putIfPresent(overrides, "javax.persistence.jdbc.password", readConfig("SD_DB_PASSWORD", "sd.db.password"));

        if (overrides.isEmpty()) {
            emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT);
        } else {
            emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT, overrides);
        }
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

    private void putIfPresent(Map<String, Object> target, String key, String value) {
        if (value != null && !value.isBlank()) {
            target.put(key, value);
        }
    }

    private String readConfig(String envKey, String propertyKey) {
        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) {
            return envValue.trim();
        }
        String propValue = System.getProperty(propertyKey);
        if (propValue != null && !propValue.isBlank()) {
            return propValue.trim();
        }
        return "";
    }
}
