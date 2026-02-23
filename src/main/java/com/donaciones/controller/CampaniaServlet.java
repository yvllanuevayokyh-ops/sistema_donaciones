package com.donaciones.controller;

import com.donaciones.dao.CampaniaDAO;
import com.donaciones.dao.ResultadoPaginado;
import com.donaciones.model.Campania;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "CampaniaServlet", urlPatterns = {"/campanias"})
public class CampaniaServlet extends HttpServlet {

    private static final int PAGE_SIZE = 4;

    private final CampaniaDAO campaniaDAO = new CampaniaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }

        boolean donanteView = isDonanteRole(request);
        boolean comunidadView = isComunidadRole(request);
        boolean readOnlyView = donanteView || comunidadView;

        String q = safe(request.getParameter("q")).trim();
        String estado = safe(request.getParameter("estado")).trim();
        if (estado.isEmpty()) {
            estado = "Todas";
        }
        String situacion = safe(request.getParameter("situacion")).trim();
        if (situacion.isEmpty()) {
            situacion = "Activos";
        }

        int currentPage = parseInt(request.getParameter("page"), 1);
        if (currentPage < 1) {
            currentPage = 1;
        }

        Integer filtroActivo = toActivoFilter(situacion);
        Integer selectedId = parseInteger(request.getParameter("id"));
        Integer editarId = parseInteger(request.getParameter("editarId"));
        if (readOnlyView) {
            editarId = null;
        }
        boolean showForm = "1".equals(safe(request.getParameter("nuevo"))) || editarId != null;
        if (readOnlyView) {
            showForm = false;
        }

        List<Campania> campanias = new ArrayList<Campania>();
        Campania detalle = null;
        Campania edicion = null;
        int totalRows = 0;
        int totalPages = 1;

        Map<Integer, BigDecimal> recaudadoPorCampania = new LinkedHashMap<Integer, BigDecimal>();
        Map<Integer, Integer> donacionesPorCampania = new LinkedHashMap<Integer, Integer>();
        BigDecimal recaudadoDetalle = BigDecimal.ZERO;
        int totalDonacionesDetalle = 0;

        try {
            ResultadoPaginado<Campania> resultado = campaniaDAO.buscarYPaginar(
                    q, estado, filtroActivo, currentPage, PAGE_SIZE
            );
            if (currentPage > resultado.getTotalPaginas()) {
                currentPage = Math.max(1, resultado.getTotalPaginas());
                resultado = campaniaDAO.buscarYPaginar(q, estado, filtroActivo, currentPage, PAGE_SIZE);
            }

            campanias = safeList(resultado.getDatos());
            totalRows = resultado.getTotalRegistros();
            totalPages = Math.max(1, resultado.getTotalPaginas());

            List<Integer> ids = new ArrayList<Integer>();
            for (Campania c : campanias) {
                if (c != null && c.getIdCampania() != null) {
                    ids.add(c.getIdCampania());
                }
            }
            recaudadoPorCampania = campaniaDAO.obtenerMontosRecaudados(ids);
            donacionesPorCampania = campaniaDAO.contarDonacionesPorCampania(ids);

            if (selectedId == null && !campanias.isEmpty()) {
                selectedId = campanias.get(0).getIdCampania();
            }
            if (editarId != null && selectedId == null) {
                selectedId = editarId;
            }
            if (selectedId != null) {
                detalle = campaniaDAO.buscarDetalle(selectedId);
                recaudadoDetalle = recaudadoPorCampania.getOrDefault(selectedId, BigDecimal.ZERO);
                totalDonacionesDetalle = donacionesPorCampania.getOrDefault(selectedId, 0);
            }
            if (editarId != null) {
                edicion = campaniaDAO.buscarDetalle(editarId);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar modulo campanias");
            totalPages = 1;
        }

        request.setAttribute("campanias", campanias);
        request.setAttribute("detalle", detalle);
        request.setAttribute("edicion", edicion);
        request.setAttribute("showForm", showForm);
        request.setAttribute("isDonanteView", donanteView);
        request.setAttribute("isComunidadView", comunidadView);
        request.setAttribute("selectedId", selectedId);
        request.setAttribute("q", q);
        request.setAttribute("estado", estado);
        request.setAttribute("situacion", situacion);
        request.setAttribute("hoy", LocalDate.now().toString());
        request.setAttribute("totalRows", totalRows);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("recaudadoPorCampania", recaudadoPorCampania);
        request.setAttribute("donacionesPorCampania", donacionesPorCampania);
        request.setAttribute("recaudadoDetalle", recaudadoDetalle);
        request.setAttribute("totalDonacionesDetalle", totalDonacionesDetalle);

        String view = showForm ? "/views/campanias/formulario.jsp" : "/views/campanias/lista.jsp";
        request.getRequestDispatcher(view).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }
        if (isDonanteRole(request) || isComunidadRole(request)) {
            denyForDonante(request, response);
            return;
        }

        String accion = safe(request.getParameter("accion")).toLowerCase();
        try {
            switch (accion) {
                case "crear":
                    crearCampania(request, response);
                    return;
                case "editar":
                    editarCampania(request, response);
                    return;
                case "eliminar":
                    cambiarActivo(parseInteger(request.getParameter("id")), false, request, response);
                    return;
                case "restaurar":
                    cambiarActivo(parseInteger(request.getParameter("id")), true, request, response);
                    return;
                default:
                    response.sendRedirect(request.getContextPath() + "/campanias");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: operacion no completada");
            response.sendRedirect(request.getContextPath() + "/campanias");
        }
    }

    private void crearCampania(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String nombre = safe(request.getParameter("nombre"));
        String descripcion = safe(request.getParameter("descripcion"));
        String fechaInicio = safe(request.getParameter("fecha_inicio"));
        String fechaFin = safe(request.getParameter("fecha_fin"));
        String estado = safe(request.getParameter("estado"));
        BigDecimal montoObjetivo = parseDecimal(request.getParameter("monto_objetivo"));

        if (nombre.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: nombre es requerido");
            response.sendRedirect(request.getContextPath() + "/campanias");
            return;
        }
        if (fechaInicio.isEmpty()) {
            fechaInicio = LocalDate.now().toString();
        }
        if (estado.isEmpty()) {
            estado = "Activa";
        }
        if (montoObjetivo == null) {
            montoObjetivo = BigDecimal.ZERO;
        }

        int newId = campaniaDAO.crear(
                nombre,
                descripcion,
                Date.valueOf(LocalDate.parse(fechaInicio)),
                fechaFin.isEmpty() ? null : Date.valueOf(LocalDate.parse(fechaFin)),
                estado,
                montoObjetivo
        );

        request.getSession().setAttribute("mensaje", "Campania registrada correctamente");
        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/campanias?id=" + newId);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/campanias");
    }

    private void editarCampania(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idCampania = parseInteger(request.getParameter("id_campania"));
        String nombre = safe(request.getParameter("nombre"));
        String descripcion = safe(request.getParameter("descripcion"));
        String fechaInicio = safe(request.getParameter("fecha_inicio"));
        String fechaFin = safe(request.getParameter("fecha_fin"));
        String estado = safe(request.getParameter("estado"));
        BigDecimal montoObjetivo = parseDecimal(request.getParameter("monto_objetivo"));

        if (idCampania == null || nombre.isEmpty() || fechaInicio.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: datos incompletos para editar");
            response.sendRedirect(request.getContextPath() + "/campanias");
            return;
        }
        if (estado.isEmpty()) {
            estado = "Activa";
        }
        if (montoObjetivo == null) {
            montoObjetivo = BigDecimal.ZERO;
        }

        campaniaDAO.editar(
                idCampania,
                nombre,
                descripcion,
                Date.valueOf(LocalDate.parse(fechaInicio)),
                fechaFin.isEmpty() ? null : Date.valueOf(LocalDate.parse(fechaFin)),
                estado,
                montoObjetivo
        );

        request.getSession().setAttribute("mensaje", "Campania actualizada correctamente");
        response.sendRedirect(request.getContextPath() + "/campanias?id=" + idCampania);
    }

    private void cambiarActivo(Integer id, boolean restaurar,
                               HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (id == null) {
            request.getSession().setAttribute("mensaje", "Error: id de campania invalido");
            response.sendRedirect(request.getContextPath() + "/campanias");
            return;
        }

        campaniaDAO.cambiarActivo(id, restaurar);

        request.getSession().setAttribute("mensaje",
                restaurar ? "Campania restaurada correctamente" : "Campania eliminada correctamente");
        response.sendRedirect(request.getContextPath() + "/campanias?id=" + id);
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

    private void denyForDonante(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession().setAttribute("mensaje", "Accion no permitida para este rol");
        response.sendRedirect(request.getContextPath() + "/campanias");
    }

    private Integer parseInteger(String value) {
        try {
            if (value == null || value.isBlank()) {
                return null;
            }
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private int parseInt(String value, int fallback) {
        try {
            if (value == null || value.isBlank()) {
                return fallback;
            }
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }

    private BigDecimal parseDecimal(String value) {
        try {
            if (value == null || value.isBlank()) {
                return null;
            }
            return new BigDecimal(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Integer toActivoFilter(String situacion) {
        if ("Inactivos".equalsIgnoreCase(situacion)) {
            return 0;
        }
        if ("Todos".equalsIgnoreCase(situacion)) {
            return null;
        }
        return 1;
    }

    private <T> List<T> safeList(List<T> rows) {
        return rows == null ? new ArrayList<T>() : rows;
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }
}
