package com.donaciones.dao;

import com.donaciones.model.RolUsuario;
import com.donaciones.model.Permiso;
import com.donaciones.util.JPAUtil;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.Query;

public class RolesPermisosDAO {

    private static final String[][] DEFAULT_PERMISSIONS = {
            {"DASHBOARD_VER", "Ver Dashboard", "Acceso al panel principal"},
            {"DONACIONES_GESTIONAR", "Gestionar Donaciones", "Crear, editar y cambiar estado de donaciones"},
            {"COMUNIDADES_GESTIONAR", "Gestionar Comunidades", "Crear, editar y cambiar estado de comunidades"},
            {"INSTITUCIONES_GESTIONAR", "Gestionar Instituciones", "Crear, editar y cambiar estado de instituciones"},
            {"VOLUNTARIOS_GESTIONAR", "Gestionar Voluntarios", "Crear, editar y cambiar estado de voluntarios"},
            {"CAMPANIAS_GESTIONAR", "Gestionar Campanias", "Crear, editar y cambiar estado de campanias"},
            {"ROLES_PERMISOS_GESTIONAR", "Gestionar Roles y Permisos", "Administrar roles y su matriz de permisos"},
            {"REPORTES_VER", "Ver Reportes", "Acceso a reportes del sistema"}
    };

    public void bootstrapSchemaAndData() {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            em.createNativeQuery(
                    "CREATE TABLE IF NOT EXISTS permiso (" +
                            "id_permiso INT AUTO_INCREMENT PRIMARY KEY," +
                            "codigo VARCHAR(80) NOT NULL," +
                            "nombre VARCHAR(120) NOT NULL," +
                            "descripcion VARCHAR(250) NULL," +
                            "activo TINYINT NOT NULL DEFAULT 1," +
                            "UNIQUE KEY uk_permiso_codigo (codigo)" +
                            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            ).executeUpdate();

            em.createNativeQuery(
                    "CREATE TABLE IF NOT EXISTS rol_permiso (" +
                            "id_rol INT NOT NULL," +
                            "id_permiso INT NOT NULL," +
                            "permitido TINYINT NOT NULL DEFAULT 0," +
                            "PRIMARY KEY (id_rol, id_permiso)," +
                            "CONSTRAINT fk_rol_permiso_rol FOREIGN KEY (id_rol) REFERENCES rol_usuario(id_rol) ON DELETE CASCADE ON UPDATE CASCADE," +
                            "CONSTRAINT fk_rol_permiso_permiso FOREIGN KEY (id_permiso) REFERENCES permiso(id_permiso) ON DELETE CASCADE ON UPDATE CASCADE" +
                            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            ).executeUpdate();

            for (String[] permission : DEFAULT_PERMISSIONS) {
                Query query = em.createNativeQuery(
                        "INSERT INTO permiso (codigo, nombre, descripcion, activo) VALUES (?,?,?,1) " +
                                "ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), descripcion = VALUES(descripcion), activo = 1"
                );
                query.setParameter(1, permission[0]);
                query.setParameter(2, permission[1]);
                query.setParameter(3, permission[2]);
                query.executeUpdate();
            }

            em.createNativeQuery(
                    "INSERT INTO rol_permiso (id_rol, id_permiso, permitido) " +
                            "SELECT r.id_rol, p.id_permiso, CASE WHEN r.id_rol = 1 THEN 1 ELSE 0 END " +
                            "FROM rol_usuario r " +
                            "CROSS JOIN permiso p " +
                            "LEFT JOIN rol_permiso rp ON rp.id_rol = r.id_rol AND rp.id_permiso = p.id_permiso " +
                            "WHERE rp.id_rol IS NULL"
            ).executeUpdate();

            em.createNativeQuery("UPDATE rol_permiso SET permitido = 1 WHERE id_rol = 1").executeUpdate();

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

    public int contarRoles(String q) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            String filter = q == null ? "" : q.trim();
            Object value = em.createNativeQuery(
                    "SELECT COUNT(*) " +
                            "FROM rol_usuario r " +
                            "WHERE (? = '' OR UPPER(r.nombre) LIKE CONCAT('%', UPPER(?), '%'))"
            ).setParameter(1, filter).setParameter(2, filter).getSingleResult();
            return toInt(value);
        } finally {
            em.close();
        }
    }

    public List<String[]> listarRoles(String q, int offset, int limit) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            String filter = q == null ? "" : q.trim();
            Query query = em.createNativeQuery(
                    "SELECT r.id_rol, r.nombre, " +
                            "COUNT(DISTINCT CASE WHEN rp.permitido = 1 THEN rp.id_permiso END) AS permisos_activos, " +
                            "COUNT(DISTINCT rp.id_permiso) AS permisos_total, " +
                            "COUNT(DISTINCT u.id_usuario) AS usuarios " +
                            "FROM rol_usuario r " +
                            "LEFT JOIN rol_permiso rp ON rp.id_rol = r.id_rol " +
                            "LEFT JOIN usuario_sistema u ON u.id_rol = r.id_rol " +
                            "WHERE (? = '' OR UPPER(r.nombre) LIKE CONCAT('%', UPPER(?), '%')) " +
                            "GROUP BY r.id_rol, r.nombre " +
                            "ORDER BY r.id_rol ASC"
            ).setParameter(1, filter).setParameter(2, filter);
            query.setFirstResult(Math.max(offset, 0));
            query.setMaxResults(Math.max(limit, 1));

            @SuppressWarnings("unchecked")
            List<Object[]> result = query.getResultList();

            List<String[]> rows = new ArrayList<String[]>();
            for (Object[] row : result) {
                rows.add(new String[]{
                        String.valueOf(toInt(row[0])),
                        safe(row[1]),
                        String.valueOf(toInt(row[2])),
                        String.valueOf(toInt(row[3])),
                        String.valueOf(toInt(row[4]))
                });
            }
            return rows;
        } finally {
            em.close();
        }
    }

    public String[] obtenerDetalleRol(Integer idRol) {
        if (idRol == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> result = em.createNativeQuery(
                    "SELECT r.id_rol, r.nombre, " +
                            "COUNT(DISTINCT CASE WHEN rp.permitido = 1 THEN rp.id_permiso END) AS permisos_activos, " +
                            "COUNT(DISTINCT rp.id_permiso) AS permisos_total, " +
                            "COUNT(DISTINCT u.id_usuario) AS usuarios " +
                            "FROM rol_usuario r " +
                            "LEFT JOIN rol_permiso rp ON rp.id_rol = r.id_rol " +
                            "LEFT JOIN usuario_sistema u ON u.id_rol = r.id_rol " +
                            "WHERE r.id_rol = ? " +
                            "GROUP BY r.id_rol, r.nombre"
            ).setParameter(1, idRol).getResultList();

            if (result.isEmpty()) {
                return null;
            }
            Object[] row = result.get(0);
            return new String[]{
                    String.valueOf(toInt(row[0])),
                    safe(row[1]),
                    String.valueOf(toInt(row[2])),
                    String.valueOf(toInt(row[3])),
                    String.valueOf(toInt(row[4]))
            };
        } finally {
            em.close();
        }
    }

    public List<String[]> listarPermisosPorRol(Integer idRol) {
        List<String[]> rows = new ArrayList<String[]>();
        if (idRol == null) {
            return rows;
        }

        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> result = em.createNativeQuery(
                    "SELECT p.id_permiso, p.codigo, p.nombre, COALESCE(p.descripcion, '') AS descripcion, " +
                            "COALESCE(rp.permitido, 0) AS permitido " +
                            "FROM permiso p " +
                            "LEFT JOIN rol_permiso rp ON rp.id_permiso = p.id_permiso AND rp.id_rol = ? " +
                            "WHERE p.activo = 1 " +
                            "ORDER BY p.id_permiso ASC"
            ).setParameter(1, idRol).getResultList();

            for (Object[] row : result) {
                rows.add(new String[]{
                        String.valueOf(toInt(row[0])),
                        safe(row[1]),
                        safe(row[2]),
                        safe(row[3]),
                        String.valueOf(toInt(row[4]))
                });
            }
            return rows;
        } finally {
            em.close();
        }
    }

    public int contarPermisos() {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            Object value = em.createNativeQuery("SELECT COUNT(*) FROM permiso WHERE activo = 1").getSingleResult();
            return toInt(value);
        } finally {
            em.close();
        }
    }

    public int contarAsignaciones() {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            Object value = em.createNativeQuery("SELECT COUNT(*) FROM rol_permiso WHERE permitido = 1").getSingleResult();
            return toInt(value);
        } finally {
            em.close();
        }
    }

    public boolean existeRolPorNombre(String nombre, Integer exceptId) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            String filter = safe(nombre).trim();
            if (exceptId == null) {
                Long total = em.createQuery(
                        "SELECT COUNT(r) FROM RolUsuario r WHERE UPPER(r.nombre) = UPPER(:nombre)", Long.class)
                        .setParameter("nombre", filter)
                        .getSingleResult();
                return total != null && total > 0;
            }

            Long total = em.createQuery(
                    "SELECT COUNT(r) FROM RolUsuario r WHERE UPPER(r.nombre) = UPPER(:nombre) AND r.idRol <> :id", Long.class)
                    .setParameter("nombre", filter)
                    .setParameter("id", exceptId)
                    .getSingleResult();
            return total != null && total > 0;
        } finally {
            em.close();
        }
    }

    public int crearRol(String nombre) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            RolUsuario rol = new RolUsuario();
            rol.setNombre(safe(nombre).trim());
            em.persist(rol);
            em.flush();

            Integer newId = rol.getIdRol();
            Query query = em.createNativeQuery(
                    "INSERT INTO rol_permiso (id_rol, id_permiso, permitido) " +
                            "SELECT ?, p.id_permiso, 0 FROM permiso p " +
                            "WHERE NOT EXISTS (" +
                            "  SELECT 1 FROM rol_permiso rp WHERE rp.id_rol = ? AND rp.id_permiso = p.id_permiso" +
                            ")"
            );
            query.setParameter(1, newId);
            query.setParameter(2, newId);
            query.executeUpdate();

            tx.commit();
            return newId != null ? newId : 0;
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public void editarRol(Integer idRol, String nombre) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            RolUsuario rol = em.find(RolUsuario.class, idRol);
            if (rol == null) {
                throw new IllegalArgumentException("Rol no encontrado");
            }
            rol.setNombre(safe(nombre).trim());
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

    public int contarUsuariosPorRol(int idRol) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            Long total = em.createQuery(
                    "SELECT COUNT(u) FROM UsuarioSistema u WHERE u.rol.idRol = :idRol", Long.class)
                    .setParameter("idRol", idRol)
                    .getSingleResult();
            return total == null ? 0 : total.intValue();
        } finally {
            em.close();
        }
    }

    public void eliminarRol(int idRol) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.createNativeQuery("DELETE FROM rol_permiso WHERE id_rol = ?")
                    .setParameter(1, idRol)
                    .executeUpdate();
            em.createNativeQuery("DELETE FROM rol_usuario WHERE id_rol = ?")
                    .setParameter(1, idRol)
                    .executeUpdate();
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

    public void guardarPermisos(Integer idRol, List<Integer> permisosSeleccionados) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.createNativeQuery("UPDATE rol_permiso SET permitido = 0 WHERE id_rol = ?")
                    .setParameter(1, idRol)
                    .executeUpdate();

            if (permisosSeleccionados != null) {
                for (Integer idPermiso : permisosSeleccionados) {
                    if (idPermiso == null) {
                        continue;
                    }
                    em.createNativeQuery("UPDATE rol_permiso SET permitido = 1 WHERE id_rol = ? AND id_permiso = ?")
                            .setParameter(1, idRol)
                            .setParameter(2, idPermiso)
                            .executeUpdate();
                }
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

    public boolean existePermisoPorCodigo(String codigo) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        try {
            Long total = em.createQuery(
                            "SELECT COUNT(p) FROM Permiso p WHERE UPPER(p.codigo) = UPPER(:codigo)", Long.class)
                    .setParameter("codigo", safe(codigo).trim())
                    .getSingleResult();
            return total != null && total > 0;
        } finally {
            em.close();
        }
    }

    public int crearPermiso(String codigo, String nombre, String descripcion) {
        EntityManager em = JPAUtil.getInstance().createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            Permiso permiso = new Permiso();
            permiso.setCodigo(safe(codigo).trim().toUpperCase());
            permiso.setNombre(safe(nombre).trim());
            permiso.setDescripcion(safe(descripcion).trim());
            permiso.setActivo(Boolean.TRUE);
            em.persist(permiso);
            em.flush();

            Integer idPermiso = permiso.getIdPermiso();
            Query query = em.createNativeQuery(
                    "INSERT INTO rol_permiso (id_rol, id_permiso, permitido) " +
                            "SELECT r.id_rol, ?, CASE WHEN r.id_rol = 1 THEN 1 ELSE 0 END " +
                            "FROM rol_usuario r " +
                            "LEFT JOIN rol_permiso rp ON rp.id_rol = r.id_rol AND rp.id_permiso = ? " +
                            "WHERE rp.id_rol IS NULL"
            );
            query.setParameter(1, idPermiso);
            query.setParameter(2, idPermiso);
            query.executeUpdate();

            tx.commit();
            return idPermiso != null ? idPermiso : 0;
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

    private String safe(Object value) {
        return value == null ? "" : String.valueOf(value);
    }
}
