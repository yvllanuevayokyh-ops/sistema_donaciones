package com.donaciones.controller;

import com.donaciones.dao.FinanzasDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "FinanzasServlet", urlPatterns = {"/finanzas"})
public class FinanzasServlet extends HttpServlet {

    private final FinanzasDAO finanzasDAO = new FinanzasDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }
        if (isDonanteRole(request) || isComunidadRole(request)) {
            request.getSession().setAttribute("mensaje", "Acceso restringido");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        BigDecimal totalRecaudado = BigDecimal.ZERO;
        BigDecimal totalEntregado = BigDecimal.ZERO;
        BigDecimal saldoDisponible = BigDecimal.ZERO;
        int totalDonaciones = 0;
        int totalEntregas = 0;
        List<Object[]> porCampania = new ArrayList<Object[]>();
        List<Object[]> porComunidad = new ArrayList<Object[]>();

        try {
            Object[] resumen = finanzasDAO.resumenGeneral();
            if (resumen != null && resumen.length >= 4) {
                totalRecaudado = toBD(resumen[0]);
                totalEntregado = toBD(resumen[1]);
                totalDonaciones = toInt(resumen[2]);
                totalEntregas = toInt(resumen[3]);
                saldoDisponible = totalRecaudado.subtract(totalEntregado);
            }

            porCampania = safeList(finanzasDAO.resumenPorCampania());
            porComunidad = safeList(finanzasDAO.resumenPorComunidad());
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar finanzas");
        }

        request.setAttribute("totalRecaudado", totalRecaudado);
        request.setAttribute("totalEntregado", totalEntregado);
        request.setAttribute("saldoDisponible", saldoDisponible);
        request.setAttribute("totalDonaciones", totalDonaciones);
        request.setAttribute("totalEntregas", totalEntregas);
        request.setAttribute("porCampania", porCampania);
        request.setAttribute("porComunidad", porComunidad);

        request.getRequestDispatcher("/views/finanzas/index.jsp").forward(request, response);
    }

    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("usuarioNombre") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    private boolean isDonanteRole(HttpServletRequest request) {
        Object roleObj = request.getSession(false) != null ? request.getSession(false).getAttribute("usuarioRol") : null;
        String rol = roleObj == null ? "" : String.valueOf(roleObj);
        return "Institucion Donante".equalsIgnoreCase(rol) || "Persona Natural".equalsIgnoreCase(rol);
    }

    private boolean isComunidadRole(HttpServletRequest request) {
        Object roleObj = request.getSession(false) != null ? request.getSession(false).getAttribute("usuarioRol") : null;
        String rol = roleObj == null ? "" : String.valueOf(roleObj);
        return "Comunidad".equalsIgnoreCase(rol);
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

    private BigDecimal toBD(Object value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        }
        if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue());
        }
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (Exception ex) {
            return BigDecimal.ZERO;
        }
    }

    private <T> List<T> safeList(List<T> rows) {
        return rows == null ? new ArrayList<T>() : rows;
    }
}
