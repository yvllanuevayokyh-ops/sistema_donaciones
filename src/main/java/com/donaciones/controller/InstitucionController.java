package com.donaciones.controller;

import com.donaciones.dao.DonanteDAO;
import com.donaciones.dao.PaisDAO;
import com.donaciones.dao.ResultadoPaginado;
import com.donaciones.model.Donante;
import com.donaciones.model.Pais;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class InstitucionController {

    private static final int PAGE_SIZE = 4;

    private final DonanteDAO donanteDAO = new DonanteDAO();
    private final PaisDAO paisDAO = new PaisDAO();

    @GetMapping("/instituciones")
    public String doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }
        if (isDonanteRole(request)) {
            denyForDonante(request, response);
            return null;
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

        Integer filtroActivo = toActivoFilter(situacion);
        Integer selectedId = parseInteger(request.getParameter("id"));
        Integer editarId = parseInteger(request.getParameter("editarId"));
        boolean showForm = "1".equals(safe(request.getParameter("nuevo"))) || editarId != null;

        List<Donante> instituciones = new ArrayList<Donante>();
        List<Pais> paises = new ArrayList<Pais>();
        Donante detalle = null;
        Donante edicion = null;
        int totalRows = 0;
        int totalPages = 1;
        int totalDonacionesDetalle = 0;
        Map<Integer, Integer> donacionesPorInstitucion = new LinkedHashMap<Integer, Integer>();

        try {
            ResultadoPaginado<Donante> resultado = donanteDAO.buscarYPaginar(q, filtroActivo, currentPage, PAGE_SIZE);
            if (currentPage > resultado.getTotalPaginas()) {
                currentPage = Math.max(1, resultado.getTotalPaginas());
                resultado = donanteDAO.buscarYPaginar(q, filtroActivo, currentPage, PAGE_SIZE);
            }

            instituciones = safeList(resultado.getDatos());
            totalRows = resultado.getTotalRegistros();
            totalPages = Math.max(1, resultado.getTotalPaginas());

            List<Integer> ids = new ArrayList<Integer>();
            for (Donante d : instituciones) {
                if (d != null && d.getIdDonante() != null) {
                    ids.add(d.getIdDonante());
                }
            }
            donacionesPorInstitucion = donanteDAO.contarDonacionesPorDonantes(ids);

            paises = safeList(paisDAO.listar());

            if (selectedId == null && !instituciones.isEmpty()) {
                selectedId = instituciones.get(0).getIdDonante();
            }
            if (editarId != null && selectedId == null) {
                selectedId = editarId;
            }
            if (selectedId != null) {
                detalle = donanteDAO.buscarDetalle(selectedId);
                totalDonacionesDetalle = donanteDAO.contarDonacionesPorDonante(selectedId);
            }
            if (editarId != null) {
                edicion = donanteDAO.buscarDetalle(editarId);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar modulo instituciones");
            totalPages = 1;
        }

        request.setAttribute("instituciones", instituciones);
        request.setAttribute("paises", paises);
        request.setAttribute("detalle", detalle);
        request.setAttribute("edicion", edicion);
        request.setAttribute("donacionesPorInstitucion", donacionesPorInstitucion);
        request.setAttribute("totalDonacionesDetalle", totalDonacionesDetalle);
        request.setAttribute("showForm", showForm);
        request.setAttribute("selectedId", selectedId);
        request.setAttribute("q", q);
        request.setAttribute("situacion", situacion);
        request.setAttribute("hoy", LocalDate.now().toString());
        request.setAttribute("totalRows", totalRows);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalPages", totalPages);

        return "instituciones/index";
    }

    @PostMapping("/instituciones")
    public void doPost(HttpServletRequest request, HttpServletResponse response)
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
                    crearInstitucion(request, response);
                    return;
                case "editar":
                    editarInstitucion(request, response);
                    return;
                case "eliminar":
                case "inactivar":
                    cambiarActivo(parseInteger(request.getParameter("id")), false, request, response);
                    return;
                case "restaurar":
                    cambiarActivo(parseInteger(request.getParameter("id")), true, request, response);
                    return;
                default:
                    response.sendRedirect(request.getContextPath() + "/instituciones");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: operacion no completada");
            response.sendRedirect(request.getContextPath() + "/instituciones");
        }
    }

    private void crearInstitucion(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String nombre = safe(request.getParameter("nombre"));
        String email = safe(request.getParameter("email"));
        String telefono = safe(request.getParameter("telefono"));
        String direccion = safe(request.getParameter("direccion"));
        String tipoDonante = safe(request.getParameter("tipo_donante"));
        String idPais = safe(request.getParameter("id_pais"));
        String fechaRegistro = safe(request.getParameter("fecha_registro"));
        Boolean estado = parseEstado(request.getParameter("estado"));

        if (nombre.isEmpty() || idPais.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: nombre y pais son requeridos");
            response.sendRedirect(request.getContextPath() + "/instituciones");
            return;
        }

        if (tipoDonante.isEmpty()) {
            tipoDonante = "Institucion";
        }
        if (fechaRegistro.isEmpty()) {
            fechaRegistro = LocalDate.now().toString();
        }

        int newId = donanteDAO.crear(
                nombre,
                email,
                telefono,
                direccion,
                tipoDonante,
                Integer.parseInt(idPais),
                Date.valueOf(LocalDate.parse(fechaRegistro))
        );
        if (newId > 0 && Boolean.FALSE.equals(estado)) {
            donanteDAO.cambiarActivo(newId, false);
        }

        request.getSession().setAttribute("mensaje", "Institucion registrada correctamente");
        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/instituciones?id=" + newId);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/instituciones");
    }

    private void editarInstitucion(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idDonante = parseInteger(request.getParameter("id_donante"));
        String nombre = safe(request.getParameter("nombre"));
        String email = safe(request.getParameter("email"));
        String telefono = safe(request.getParameter("telefono"));
        String direccion = safe(request.getParameter("direccion"));
        String tipoDonante = safe(request.getParameter("tipo_donante"));
        String idPais = safe(request.getParameter("id_pais"));
        Boolean estado = parseEstado(request.getParameter("estado"));

        if (idDonante == null || nombre.isEmpty() || idPais.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: datos incompletos para editar");
            response.sendRedirect(request.getContextPath() + "/instituciones");
            return;
        }

        if (tipoDonante.isEmpty()) {
            tipoDonante = "Institucion";
        }

        donanteDAO.editar(
                idDonante,
                nombre,
                email,
                telefono,
                direccion,
                tipoDonante,
                Integer.parseInt(idPais)
        );
        if (estado != null) {
            donanteDAO.cambiarActivo(idDonante, estado);
        }

        request.getSession().setAttribute("mensaje", "Institucion actualizada correctamente");
        response.sendRedirect(request.getContextPath() + "/instituciones?id=" + idDonante);
    }

    private void cambiarActivo(Integer id, boolean restaurar,
                               HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (id == null) {
            request.getSession().setAttribute("mensaje", "Error: id de institucion invalido");
            response.sendRedirect(request.getContextPath() + "/instituciones");
            return;
        }

        donanteDAO.cambiarActivo(id, restaurar);

        request.getSession().setAttribute("mensaje",
                restaurar ? "Institucion restaurada correctamente" : "Institucion eliminada correctamente");
        response.sendRedirect(request.getContextPath() + "/instituciones?id=" + id);
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

    private Integer toActivoFilter(String situacion) {
        if ("Inactivos".equalsIgnoreCase(situacion)) {
            return 0;
        }
        if ("Todos".equalsIgnoreCase(situacion)) {
            return null;
        }
        return 1;
    }

    private Boolean parseEstado(String value) {
        String v = safe(value).trim();
        if (v.isEmpty()) {
            return null;
        }
        if ("1".equals(v) || "ACTIVO".equalsIgnoreCase(v) || "TRUE".equalsIgnoreCase(v)) {
            return true;
        }
        if ("0".equals(v) || "INACTIVO".equalsIgnoreCase(v) || "FALSE".equalsIgnoreCase(v)) {
            return false;
        }
        return null;
    }

    private <T> List<T> safeList(List<T> rows) {
        return rows == null ? new ArrayList<T>() : rows;
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }
}

