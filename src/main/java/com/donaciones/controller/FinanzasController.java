package com.donaciones.controller;

import com.donaciones.dao.FinanzasDAO;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FinanzasController {

    private final FinanzasDAO finanzasDAO = new FinanzasDAO();

    @GetMapping("/finanzas")
    public String doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }
        if (isDonanteRole(request) || isComunidadRole(request)) {
            request.getSession().setAttribute("mensaje", "Acceso restringido");
            return "redirect:/home";
        }

        BigDecimal totalRecaudado = BigDecimal.ZERO;
        BigDecimal totalEntregado = BigDecimal.ZERO;
        BigDecimal saldoDisponible = BigDecimal.ZERO;
        int totalDonaciones = 0;
        int totalEntregas = 0;
        java.util.Date fechaReporteDateTime = new java.util.Date();
        String ultimaDonacion = formatDateTime(fechaReporteDateTime);
        String ultimaEntrega = formatDateTime(fechaReporteDateTime);
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
                if (resumen.length >= 6) {
                    ultimaDonacion = formatDateTime(resumen[4]);
                    ultimaEntrega = formatDateTime(resumen[5]);
                }
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
        request.setAttribute("ultimaDonacion", ultimaDonacion);
        request.setAttribute("ultimaEntrega", ultimaEntrega);
        request.setAttribute("porCampania", porCampania);
        request.setAttribute("porComunidad", porComunidad);
        request.setAttribute("fechaReporteDateTime", fechaReporteDateTime);
        request.setAttribute("ordenCampania", "Mayor recaudado");
        request.setAttribute("ordenComunidad", "Mayor monto recibido");
        request.setAttribute("fechaReporte", LocalDate.now().toString());
        request.setAttribute("horaReporte", LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss")));

        return "finanzas/index";
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

    private String formatDateTime(Object value) {
        if (value == null) {
            return "";
        }
        try {
            java.util.Date date = (java.util.Date) value;
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(date);
        } catch (Exception ex) {
            return String.valueOf(value);
        }
    }
}

