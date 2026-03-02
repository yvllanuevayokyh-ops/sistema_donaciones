package com.donaciones.util;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public final class JPAUtil {

    private static final String PERSISTENCE_UNIT = "sistemadonacionesPU";
    private static final String JDBC_URL_KEY = "javax.persistence.jdbc.url";
    private static final String JDBC_USER_KEY = "javax.persistence.jdbc.user";
    private static final String JDBC_PASSWORD_KEY = "javax.persistence.jdbc.password";
    private static JPAUtil instance;
    private final EntityManagerFactory emf;

    private JPAUtil() {
        Map<String, Object> configuredOverrides = readConfiguredOverrides();
        Map<String, Object> fallbackOverrides = defaultCloudOverrides();

        if (hasDbCredentials(configuredOverrides)) {
            emf = createWithFallback(configuredOverrides, fallbackOverrides);
        } else {
            emf = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT, fallbackOverrides);
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

    private EntityManagerFactory createWithFallback(Map<String, Object> primary, Map<String, Object> fallback) {
        try {
            return Persistence.createEntityManagerFactory(PERSISTENCE_UNIT, primary);
        } catch (RuntimeException ex) {
            if (!sameDbConfig(primary, fallback)) {
                return Persistence.createEntityManagerFactory(PERSISTENCE_UNIT, fallback);
            }
            throw ex;
        }
    }

    private Map<String, Object> readConfiguredOverrides() {
        Map<String, Object> overrides = new HashMap<String, Object>();
        putIfPresent(overrides, JDBC_URL_KEY, readConfig("SD_DB_URL", "sd.db.url"));
        putIfPresent(overrides, JDBC_USER_KEY, readConfig("SD_DB_USER", "sd.db.user"));
        putIfPresent(overrides, JDBC_PASSWORD_KEY, readConfig("SD_DB_PASSWORD", "sd.db.password"));
        return overrides;
    }

    private Map<String, Object> defaultCloudOverrides() {
        Map<String, Object> overrides = new HashMap<String, Object>();
        overrides.put(
                JDBC_URL_KEY,
                "jdbc:mysql://server-db-sd-server-db-sd.a.aivencloud.com:14732/sistema_donaciones?sslMode=REQUIRED&serverTimezone=UTC&useUnicode=true&characterEncoding=utf8&connectionCollation=utf8mb4_unicode_ci"
        );
        overrides.put(JDBC_USER_KEY, "avnadmin");
        overrides.put(JDBC_PASSWORD_KEY, buildPassword());
        return overrides;
    }

    private boolean hasDbCredentials(Map<String, Object> values) {
        return hasText(values.get(JDBC_URL_KEY))
                && hasText(values.get(JDBC_USER_KEY))
                && hasText(values.get(JDBC_PASSWORD_KEY));
    }

    private boolean sameDbConfig(Map<String, Object> left, Map<String, Object> right) {
        return Objects.equals(left.get(JDBC_URL_KEY), right.get(JDBC_URL_KEY))
                && Objects.equals(left.get(JDBC_USER_KEY), right.get(JDBC_USER_KEY))
                && Objects.equals(left.get(JDBC_PASSWORD_KEY), right.get(JDBC_PASSWORD_KEY));
    }

    private boolean hasText(Object value) {
        if (value == null) {
            return false;
        }
        String text = String.valueOf(value);
        return !text.isBlank();
    }

    private String buildPassword() {
        return String.join("", "AVNS", "_E6xg", "NQNLfNY6", "-ekDHdz");
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
