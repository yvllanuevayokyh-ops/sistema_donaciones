package com.donaciones.controller;

import com.donaciones.dao.ResultadoPaginado;
import com.donaciones.dao.VoluntarioDAO;
import com.donaciones.model.Voluntario;
import java.io.IOException;
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

@WebServlet(name = "VoluntarioServlet", urlPatterns = {"/voluntarios"})
public class VoluntarioServlet extends HttpServlet {

    private static final int PAGE_SIZE = 4;

    private final VoluntarioDAO voluntarioDAO = new VoluntarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }
        if (isDonanteRole(request)) {
            denyForDonante(request, response);
            return;
        }

        String q = safe(request.getParameter("q")).trim();
        String situacion = safe(request.getParameter("situacion")).trim();
        if (situacion.isEmpty()) {
            situacion = "Activos";
        }

        int currentPage = parseInt(request.getParameter("page"), 1);
        if (currentPage < 1) {
            currentPage = 1;
        }

        Integer filtroEstado = toEstadoFilter(situacion);
        Integer selectedId = parseInteger(request.getParameter("id"));
        Integer editarId = parseInteger(request.getParameter("editarId"));
        boolean showForm = "1".equals(safe(request.getParameter("nuevo"))) || editarId != null;

        List<Voluntario> voluntarios = new ArrayList<Voluntario>();
        Voluntario detalle = null;
        Voluntario edicion = null;
        int totalRows = 0;
        int totalPages = 1;
        int totalActivos = 0;
        int entregasCompletadas = 0;

        Map<Integer, Integer> entregasTotalesPorVoluntario = new LinkedHashMap<Integer, Integer>();
        Map<Integer, Integer> entregasCompletadasPorVoluntario = new LinkedHashMap<Integer, Integer>();
        int entregasDetalle = 0;
        int entregasCompletadasDetalle = 0;

        try {
            ResultadoPaginado<Voluntario> resultado = voluntarioDAO.buscarYPaginar(
                    q, filtroEstado, currentPage, PAGE_SIZE
            );
            if (currentPage > resultado.getTotalPaginas()) {
                currentPage = Math.max(1, resultado.getTotalPaginas());
                resultado = voluntarioDAO.buscarYPaginar(q, filtroEstado, currentPage, PAGE_SIZE);
            }

            voluntarios = safeList(resultado.getDatos());
            totalRows = resultado.getTotalRegistros();
            totalPages = Math.max(1, resultado.getTotalPaginas());

            List<Integer> ids = new ArrayList<Integer>();
            for (Voluntario v : voluntarios) {
                if (v != null && v.getIdVoluntario() != null) {
                    ids.add(v.getIdVoluntario());
                }
            }
            entregasTotalesPorVoluntario = voluntarioDAO.contarEntregasTotalesPorVoluntarios(ids);
            entregasCompletadasPorVoluntario = voluntarioDAO.contarEntregasCompletadasPorVoluntarios(ids);

            totalActivos = voluntarioDAO.buscarYPaginar("", 1, 1, 1).getTotalRegistros();
            entregasCompletadas = voluntarioDAO.contarEntregasCompletadas();

            if (selectedId == null && !voluntarios.isEmpty()) {
                selectedId = voluntarios.get(0).getIdVoluntario();
            }
            if (editarId != null && selectedId == null) {
                selectedId = editarId;
            }
            if (selectedId != null) {
                detalle = voluntarioDAO.buscarDetalle(selectedId);
                entregasDetalle = voluntarioDAO.contarEntregasTotalesPorVoluntario(selectedId);
                entregasCompletadasDetalle = voluntarioDAO.contarEntregasCompletadasPorVoluntario(selectedId);
            }
            if (editarId != null) {
                edicion = voluntarioDAO.buscarDetalle(editarId);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar modulo voluntarios");
            totalPages = 1;
        }

        request.setAttribute("voluntarios", voluntarios);
        request.setAttribute("detalle", detalle);
        request.setAttribute("edicion", edicion);
        request.setAttribute("showForm", showForm);
        request.setAttribute("selectedId", selectedId);
        request.setAttribute("q", q);
        request.setAttribute("situacion", situacion);
        request.setAttribute("hoy", LocalDate.now().toString());
        request.setAttribute("totalRows", totalRows);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalActivos", totalActivos);
        request.setAttribute("entregasCompletadas", entregasCompletadas);
        request.setAttribute("horasVoluntariado", entregasCompletadas * 4);
        request.setAttribute("entregasTotalesPorVoluntario", entregasTotalesPorVoluntario);
        request.setAttribute("entregasCompletadasPorVoluntario", entregasCompletadasPorVoluntario);
        request.setAttribute("entregasDetalle", entregasDetalle);
        request.setAttribute("entregasCompletadasDetalle", entregasCompletadasDetalle);

        String view = showForm ? "/views/voluntarios/formulario.jsp" : "/views/voluntarios/lista.jsp";
        request.getRequestDispatcher(view).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }
        if (isDonanteRole(request)) {
            denyForDonante(request, response);
            return;
        }

        String accion = safe(request.getParameter("accion")).toLowerCase();
        try {
            switch (accion) {
                case "crear":
                    crearVoluntario(request, response);
                    return;
                case "editar":
                    editarVoluntario(request, response);
                    return;
                case "eliminar":
                    cambiarEstado(parseInteger(request.getParameter("id")), false, request, response);
                    return;
                case "restaurar":
                    cambiarEstado(parseInteger(request.getParameter("id")), true, request, response);
                    return;
                default:
                    response.sendRedirect(request.getContextPath() + "/voluntarios");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: operacion no completada");
            response.sendRedirect(request.getContextPath() + "/voluntarios");
        }
    }

    private void crearVoluntario(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String nombre = safe(request.getParameter("nombre"));
        String telefono = safe(request.getParameter("telefono"));
        String email = safe(request.getParameter("email"));
        String fechaIngreso = safe(request.getParameter("fecha_ingreso"));
        if (fechaIngreso.isEmpty()) {
            fechaIngreso = LocalDate.now().toString();
        }

        if (nombre.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: nombre es requerido");
            response.sendRedirect(request.getContextPath() + "/voluntarios");
            return;
        }

        int newId = voluntarioDAO.crear(
                nombre,
                telefono,
                email,
                Date.valueOf(LocalDate.parse(fechaIngreso))
        );

        request.getSession().setAttribute("mensaje", "Voluntario registrado correctamente");
        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/voluntarios?id=" + newId);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/voluntarios");
    }

    private void editarVoluntario(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idVoluntario = parseInteger(request.getParameter("id_voluntario"));
        String nombre = safe(request.getParameter("nombre"));
        String telefono = safe(request.getParameter("telefono"));
        String email = safe(request.getParameter("email"));
        String fechaIngreso = safe(request.getParameter("fecha_ingreso"));

        if (idVoluntario == null || nombre.isEmpty() || fechaIngreso.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: datos incompletos para editar");
            response.sendRedirect(request.getContextPath() + "/voluntarios");
            return;
        }

        voluntarioDAO.editar(
                idVoluntario,
                nombre,
                telefono,
                email,
                Date.valueOf(LocalDate.parse(fechaIngreso))
        );

        request.getSession().setAttribute("mensaje", "Voluntario actualizado correctamente");
        response.sendRedirect(request.getContextPath() + "/voluntarios?id=" + idVoluntario);
    }

    private void cambiarEstado(Integer id, boolean restaurar,
                               HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (id == null) {
            request.getSession().setAttribute("mensaje", "Error: id de voluntario invalido");
            response.sendRedirect(request.getContextPath() + "/voluntarios");
            return;
        }

        voluntarioDAO.cambiarEstado(id, restaurar);

        request.getSession().setAttribute("mensaje",
                restaurar ? "Voluntario restaurado correctamente" : "Voluntario eliminado correctamente");
        response.sendRedirect(request.getContextPath() + "/voluntarios?id=" + id);
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
        return "Institucion Donante".equalsIgnoreCase(rol)
                || "Persona Natural".equalsIgnoreCase(rol)
                || "Comunidad".equalsIgnoreCase(rol);
    }

    private void denyForDonante(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession().setAttribute("mensaje", "Acceso restringido para este rol");
        response.sendRedirect(request.getContextPath() + "/home");
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

    private Integer toEstadoFilter(String situacion) {
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
