package com.donaciones.dao;

import com.donaciones.util.JPAUtil;
import java.util.ArrayList;
import java.util.List;
import javax.persistence.EntityManager;
import javax.persistence.StoredProcedureQuery;

public class FinanzasDAO {

    public Object[] resumenGeneral() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_finanzas_resumen");
            sp.execute();
            Object raw = sp.getSingleResult();
            if (raw instanceof Object[]) {
                return (Object[]) raw;
            }
            return new Object[]{raw, 0, 0, 0};
        } finally {
            em.close();
        }
    }

    public List<Object[]> resumenPorCampania() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_finanzas_por_campania");
            sp.execute();
            @SuppressWarnings("unchecked")
            List<Object[]> rows = sp.getResultList();
            return rows == null ? new ArrayList<Object[]>() : rows;
        } finally {
            em.close();
        }
    }

    public List<Object[]> resumenPorComunidad() {
        EntityManager em = JPAUtil.getInstance().getEntityManager();
        try {
            StoredProcedureQuery sp = em.createStoredProcedureQuery("sp_finanzas_por_comunidad");
            sp.execute();
            @SuppressWarnings("unchecked")
            List<Object[]> rows = sp.getResultList();
            return rows == null ? new ArrayList<Object[]>() : rows;
        } finally {
            em.close();
        }
    }
}
