package com.donaciones.dao;

import com.donaciones.model.ComunidadVulnerable;
import com.donaciones.util.JPAUtil;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.ParameterMode;
import javax.persistence.StoredProcedureQuery;

public class ComunidadDAO {

    public ResultadoPaginado<ComunidadVulnerable> buscarYPaginar(String q, Integer activo, int pagina, int porPagina) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        ResultadoPaginado<ComunidadVulnerable> resultado = new ResultadoPaginado<ComunidadVulnerable>();
        try {
            int page = Math.max(1, pagina);
            int size = Math.max(1, porPagina);
            int offset = (page - 1) * size;

            StoredProcedureQuery spContar = em.createStoredProcedureQuery("sp_comunidad_contar");
            spContar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spContar.registerStoredProcedureParameter("p_activo", Integer.class, ParameterMode.IN);
            spContar.setParameter("p_q", safe(q));
            spContar.setParameter("p_activo", activo);
            spContar.execute();
            int totalRegistros = toInt(spContar.getSingleResult());

            StoredProcedureQuery spListar = em.createStoredProcedureQuery("sp_comunidad_listar", ComunidadVulnerable.class);
            spListar.registerStoredProcedureParameter("p_q", String.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_activo", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_offset", Integer.class, ParameterMode.IN);
            spListar.registerStoredProcedureParameter("p_limit", Integer.class, ParameterMode.IN);
            spListar.setParameter("p_q", safe(q));
            spListar.setParameter("p_activo", activo);
            spListar.setParameter("p_offset", offset);
            spListar.setParameter("p_limit", size);
            spListar.execute();

            @SuppressWarnings("unchecked")
            List<ComunidadVulnerable> rows = spListar.getResultList();

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

    public ComunidadVulnerable buscarDetalle(Integer idComunidad) {
        if (idComunidad == null) {
            return null;
        }
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_comunidad_detalle", ComunidadVulnerable.class);
            sp.registerStoredProcedureParameter("p_id_comunidad", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_comunidad", idComunidad);
            sp.execute();

            @SuppressWarnings("unchecked")
            List<ComunidadVulnerable> result = sp.getResultList();
            return result.isEmpty() ? null : result.get(0);
        } finally {
            em.close();
        }
    }

    public int crear(String nombre, String ubicacion, String descripcion,
                     Integer cantidadBeneficiarios, Integer idPais) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_comunidad_crear");
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_ubicacion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_descripcion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_cantidad_beneficiarios", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_pais", Integer.class, ParameterMode.IN);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_ubicacion", safe(ubicacion));
            sp.setParameter("p_descripcion", safe(descripcion));
            sp.setParameter("p_cantidad_beneficiarios", cantidadBeneficiarios);
            sp.setParameter("p_id_pais", idPais);
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

    public void editar(Integer idComunidad, String nombre, String ubicacion, String descripcion,
                       Integer cantidadBeneficiarios, Integer idPais) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_comunidad_editar");
            sp.registerStoredProcedureParameter("p_id_comunidad", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_nombre", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_ubicacion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_descripcion", String.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_cantidad_beneficiarios", Integer.class, ParameterMode.IN);
            sp.registerStoredProcedureParameter("p_id_pais", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_comunidad", idComunidad);
            sp.setParameter("p_nombre", safe(nombre));
            sp.setParameter("p_ubicacion", safe(ubicacion));
            sp.setParameter("p_descripcion", safe(descripcion));
            sp.setParameter("p_cantidad_beneficiarios", cantidadBeneficiarios);
            sp.setParameter("p_id_pais", idPais);
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

    public void cambiarActivo(Integer idComunidad, boolean restaurar) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            StoredProcedureQuery sp = em.createStoredProcedureQuery(
                    restaurar ? "sp_comunidad_restaurar" : "sp_comunidad_inactivar"
            );
            sp.registerStoredProcedureParameter("p_id_comunidad", Integer.class, ParameterMode.IN);
            sp.setParameter("p_id_comunidad", idComunidad);
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

    public int contarDonacionesRecibidas(int idComunidad) {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            Object total = em.createNativeQuery(
                    "SELECT COUNT(DISTINCT id_donacion) FROM entrega_donacion WHERE id_comunidad = ?"
            ).setParameter(1, idComunidad).getSingleResult();
            return toInt(total);
        } finally {
            em.close();
        }
    }

    public Map<Integer, Integer> contarDonacionesRecibidasPorComunidades(List<Integer> idsComunidad) {
        Map<Integer, Integer> conteos = new LinkedHashMap<Integer, Integer>();
        if (idsComunidad == null || idsComunidad.isEmpty()) {
            return conteos;
        }

        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            @SuppressWarnings("unchecked")
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT id_comunidad, COUNT(DISTINCT id_donacion) AS total " +
                            "FROM entrega_donacion " +
                            "WHERE id_comunidad IN (:ids) " +
                            "GROUP BY id_comunidad"
            ).setParameter("ids", idsComunidad).getResultList();

            for (Object[] row : rows) {
                conteos.put(toInt(row[0]), toInt(row[1]));
            }
            return conteos;
        } finally {
            em.close();
        }
    }

    public List<ComunidadVulnerable> listarComunidadesCatalogo() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM ComunidadVulnerable c WHERE c.activo = TRUE ORDER BY c.nombre ASC",
                    ComunidadVulnerable.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    private int extractGeneratedId(StoredProcedureQuery sp) {
        @SuppressWarnings("unchecked")
        List<Object[]> result = sp.getResultList();
        if (result == null || result.isEmpty() || result.get(0).length == 0) {
            return 0;
        }
        return toInt(result.get(0)[0]);
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
