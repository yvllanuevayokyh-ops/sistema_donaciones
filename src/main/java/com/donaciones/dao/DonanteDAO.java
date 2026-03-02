package com.donaciones.dao;

import com.donaciones.model.Donante;
import com.donaciones.util.JPAUtil;
import java.sql.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.ParameterMode;
import javax.persistence.StoredProcedureQuery;
import org.hibernate.procedure.ProcedureCall;

public class DonanteDAO {

    public ResultadoPaginado<Donante> buscarYPaginar(String q, Integer activo, int pagina, int porPagina) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        ResultadoPaginado<Donante> resultado = new ResultadoPaginado<Donante>();
        try {
            int page = Math.max(1, pagina);
            int size = Math.max(1, porPagina);
            int offset = (page - 1) * size;

            StoredProcedureQuery spContar = em.createStoredProcedureQuery("sp_institucion_contar");
            spContar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spContar.registerStoredProcedureParameter("p_activo", Integer.class, ParameterMode.IN);
            enableNullParam(spContar, "p_activo");
            spContar.setParameter("p_q", safe(q));
            spContar.setParameter("p_activo", activo);
            spContar.execute();
            int totalRegistros = toInt(spContar.getSingleResult());

            StoredProcedureQuery spListar = em.createStoredProcedureQuery("sp_institucion_listar", Donante.class);
            spListar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_activo", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_offset", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_limit", Integer.class, ParameterMode.IN);
            enableNullParam(spListar, "p_activo");
            spListar.setParameter("p_q", safe(q));
            spListar.setParameter("p_activo", activo);
            spListar.setParameter("p_offset", offset);
            spListar.setParameter("p_limit", size);
            spListar.execute();

            @SuppressWarnings("unchecked")
            List<Donante> rows = spListar.getResultList();

            resultado.setDatos(rows);
            resultado.setTotalRegistros(totalRegistros);
            resultado.setPaginaActual(page);
            resultado.setRegistrosPorPagina(size);
            resultado.setTotalPaginas(totalRegistros == 0 ? 1 : (int) Math.ceil((double) totalRegistros / size));
            return resultado;
        } finally {
            em.close();
        }
    }

    public Donante buscarDetalle(Integer idDonante) {
        if (idDonante == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_institucion_detalle", Donante.class);
            sp.registerStoredProcedureParameter("p_id_donante", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_donante", idDonante);
            sp.execute();

            @SuppressWarnings("unchecked")
            List<Donante> result = sp.getResultList();
            if (!result.isEmpty()) {
                return result.get(0);
            }
            // Fallback: perfil de Persona Natural no es devuelto por el SP de instituciones.
            return em.find(Donante.class, idDonante);
        } finally {
            em.close();
        }
    }

    public int crear(String nombre, String email, String telefono, String direccion,
                     String tipoDonante, Integer idPais, Date fechaRegistro) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_institucion_crear");
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_email", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_telefono", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_direccion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_tipo_donante", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_pais", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_fecha_registro", Date.class, ParameterMode.IN);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_email", safe(email));
            sp.setParameter("p_telefono", safe(telefono));
            sp.setParameter("p_direccion", safe(direccion));
            sp.setParameter("p_tipo_donante", safe(tipoDonante));
            sp.setParameter("p_id_pais", idPais);
            sp.setParameter("p_fecha_registro", fechaRegistro);
            sp.execute();

            int newId = extractGeneratedId(sp);

            tx.commit();
            return newId;
        } catch (RuntimeException ex) {
            if (tx.isActive()) {
                tx.rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    public void editar(Integer idDonante, String nombre, String email, String telefono,
                       String direccion, String tipoDonante, Integer idPais) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.createNativeQuery(
                            "UPDATE donante SET nombre = ?, email = ?, telefono = ?, direccion = ?, " +
                                    "tipo_donante = ?, id_pais = ? WHERE id_donante = ?"
                    )
                    .setParameter(1, safe(nombre))
                    .setParameter(2, safe(email))
                    .setParameter(3, safe(telefono))
                    .setParameter(4, safe(direccion))
                    .setParameter(5, safe(tipoDonante))
                    .setParameter(6, idPais)
                    .setParameter(7, idDonante)
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

    public void cambiarActivo(Integer idDonante, boolean restaurar) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery(
                    restaurar ? "sp_institucion_restaurar" : "sp_institucion_inactivar"
            );
            sp.registerStoredProcedureParameter("p_id_donante", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_donante", idDonante);
            sp.execute();
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

    public List<Donante> listarDonantesCatalogo() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.createQuery("SELECT d FROM Donante d ORDER BY d.nombre ASC", Donante.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public Donante buscarPorId(int idDonante) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.find(Donante.class, idDonante);
        } finally {
            em.close();
        }
    }

    public Integer buscarDonanteIdPorUsuario(String usuarioEmail, String usuarioNombre) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            String email = safe(usuarioEmail).trim();
            if (!email.isEmpty()) {
                @SuppressWarnings("unchecked")
                List<Object> byEmail = em.createNativeQuery(
                        "SELECT id_donante FROM donante WHERE LOWER(COALESCE(email,'')) = LOWER(?) LIMIT 1"
                ).setParameter(1, email).getResultList();
                if (!byEmail.isEmpty()) {
                    return toInt(byEmail.get(0));
                }
            }

            String nombre = safe(usuarioNombre).trim();
            if (!nombre.isEmpty()) {
                @SuppressWarnings("unchecked")
                List<Object> byNombre = em.createNativeQuery(
                        "SELECT id_donante FROM donante WHERE LOWER(nombre) = LOWER(?) LIMIT 1"
                ).setParameter(1, nombre).getResultList();
                if (!byNombre.isEmpty()) {
                    return toInt(byNombre.get(0));
                }
            }
            return null;
        } finally {
            em.close();
        }
    }

    public boolean existeEmail(String email) {
        String filter = safe(email).trim();
        if (filter.isEmpty()) {
            return false;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object total = em.createNativeQuery(
                    "SELECT COUNT(*) FROM donante WHERE LOWER(COALESCE(email,'')) = LOWER(?)"
            ).setParameter(1, filter).getSingleResult();
            return toInt(total) > 0;
        } finally {
            em.close();
        }
    }

    public String buscarNombrePorId(int idDonante) {
        Donante d = buscarPorId(idDonante);
        return d == null ? "" : safe(d.getNombre());
    }

    public int contarDonacionesPorDonante(int idDonante) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object total = em.createNativeQuery(
                    "SELECT COUNT(*) FROM donacion WHERE id_donante = ?"
            ).setParameter(1, idDonante).getSingleResult();
            return toInt(total);
        } finally {
            em.close();
        }
    }

    public Map<Integer, Integer> contarDonacionesPorDonantes(List<Integer> idsDonante) {
        Map<Integer, Integer> conteos = new LinkedHashMap<Integer, Integer>();
        if (idsDonante == null || idsDonante.isEmpty()) {
            return conteos;
        }

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT id_donante, COUNT(*) AS total FROM donacion " +
                            "WHERE id_donante IN (:ids) GROUP BY id_donante"
            ).setParameter("ids", idsDonante).getResultList();

            for (Object[] row : rows) {
                conteos.put(toInt(row[0]), toInt(row[1]));
            }
            return conteos;
        } finally {
            em.close();
        }
    }

    private int extractGeneratedId(StoredProcedureQuery sp) {
        @SuppressWarnings("unchecked")
        List<Object> result = sp.getResultList();
        if (result == null || result.isEmpty()) {
            return 0;
        }

        Object first = result.get(0);
        if (first instanceof Object[]) {
            Object[] row = (Object[]) first;
            return row.length == 0 ? 0 : toInt(row[0]);
        }
        return toInt(first);
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

    private void enableNullParam(StoredProcedureQuery sp, String paramName) {
        try {
            sp.unwrap(ProcedureCall.class)
                    .getParameterRegistration(paramName)
                    .enablePassingNulls(true);
        } catch (RuntimeException ignored) {
            // Fallback: if provider does not support this, keep default behavior.
        }
    }
}
