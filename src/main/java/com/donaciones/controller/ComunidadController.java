package com.donaciones.controller;

import com.donaciones.dao.ComunidadDAO;
import com.donaciones.dao.PaisDAO;
import com.donaciones.dao.ResultadoPaginado;
import com.donaciones.model.ComunidadVulnerable;
import com.donaciones.model.Pais;
import java.io.IOException;
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
public class ComunidadController {

    private static final int PAGE_SIZE = 4;

    private final ComunidadDAO comunidadDAO = new ComunidadDAO();
    private final PaisDAO paisDAO = new PaisDAO();

    @GetMapping("/comunidades")
    public String doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }

        boolean comunidadView = isComunidadRole(request);
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
        if (comunidadView) {
            editarId = null;
        }
        boolean showForm = "1".equals(safe(request.getParameter("nuevo"))) || editarId != null;
        if (comunidadView) {
            showForm = false;
        }

        List<ComunidadVulnerable> comunidades = new ArrayList<ComunidadVulnerable>();
        List<Pais> paises = new ArrayList<Pais>();
        ComunidadVulnerable detalle = null;
        ComunidadVulnerable edicion = null;
        int totalRows = 0;
        int totalPages = 1;
        int donacionesDetalle = 0;
        Map<Integer, Integer> donacionesPorComunidad = new LinkedHashMap<Integer, Integer>();

        try {
            ResultadoPaginado<ComunidadVulnerable> resultado = comunidadDAO.buscarYPaginar(
                    q, filtroActivo, currentPage, PAGE_SIZE
            );
            if (currentPage > resultado.getTotalPaginas()) {
                currentPage = Math.max(1, resultado.getTotalPaginas());
                resultado = comunidadDAO.buscarYPaginar(q, filtroActivo, currentPage, PAGE_SIZE);
            }

            comunidades = safeList(resultado.getDatos());
            totalRows = resultado.getTotalRegistros();
            totalPages = Math.max(1, resultado.getTotalPaginas());

            List<Integer> ids = new ArrayList<Integer>();
            for (ComunidadVulnerable c : comunidades) {
                if (c != null && c.getIdComunidad() != null) {
                    ids.add(c.getIdComunidad());
                }
            }
            donacionesPorComunidad = comunidadDAO.contarDonacionesRecibidasPorComunidades(ids);

            paises = safeList(paisDAO.listar());

            if (selectedId == null && !comunidades.isEmpty()) {
                selectedId = comunidades.get(0).getIdComunidad();
            }
            if (editarId != null && selectedId == null) {
                selectedId = editarId;
            }
            if (selectedId != null) {
                detalle = comunidadDAO.buscarDetalle(selectedId);
                donacionesDetalle = comunidadDAO.contarDonacionesRecibidas(selectedId);
            }
            if (editarId != null) {
                edicion = comunidadDAO.buscarDetalle(editarId);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar modulo comunidades");
            totalPages = 1;
        }

        request.setAttribute("comunidades", comunidades);
        request.setAttribute("paises", paises);
        request.setAttribute("detalle", detalle);
        request.setAttribute("edicion", edicion);
        request.setAttribute("donacionesPorComunidad", donacionesPorComunidad);
        request.setAttribute("donacionesDetalle", donacionesDetalle);
        request.setAttribute("showForm", showForm);
        request.setAttribute("selectedId", selectedId);
        request.setAttribute("q", q);
        request.setAttribute("situacion", situacion);
        request.setAttribute("isComunidadView", comunidadView);
        request.setAttribute("hoy", LocalDate.now().toString());
        request.setAttribute("totalRows", totalRows);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalPages", totalPages);

        return "comunidades/index";
    }

    @PostMapping("/comunidades")
    public void doPost(HttpServletRequest request, HttpServletResponse response)
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
                    crearComunidad(request, response);
                    return;
                case "editar":
                    editarComunidad(request, response);
                    return;
                case "eliminar":
                case "inactivar":
                    cambiarActivo(parseInteger(request.getParameter("id")), false, request, response);
                    return;
                case "restaurar":
                    cambiarActivo(parseInteger(request.getParameter("id")), true, request, response);
                    return;
                default:
                    response.sendRedirect(request.getContextPath() + "/comunidades");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: operacion no completada");
            response.sendRedirect(request.getContextPath() + "/comunidades");
        }
    }

    private void crearComunidad(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String nombre = safe(request.getParameter("nombre"));
        String ubicacion = safe(request.getParameter("ubicacion"));
        String descripcion = safe(request.getParameter("descripcion"));
        String beneficiarios = safe(request.getParameter("cantidad_beneficiarios"));
        String idPais = safe(request.getParameter("id_pais"));
        Boolean estado = parseEstado(request.getParameter("estado"));

        if (nombre.isEmpty() || idPais.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: nombre y pais son requeridos");
            response.sendRedirect(request.getContextPath() + "/comunidades");
            return;
        }

        int newId = comunidadDAO.crear(
                nombre,
                ubicacion,
                descripcion,
                parseInt(beneficiarios, 0),
                Integer.parseInt(idPais)
        );
        if (newId > 0 && Boolean.FALSE.equals(estado)) {
            comunidadDAO.cambiarActivo(newId, false);
        }

        request.getSession().setAttribute("mensaje", "Comunidad registrada correctamente");
        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/comunidades?id=" + newId);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/comunidades");
    }

    private void editarComunidad(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idComunidad = parseInteger(request.getParameter("id_comunidad"));
        String nombre = safe(request.getParameter("nombre"));
        String ubicacion = safe(request.getParameter("ubicacion"));
        String descripcion = safe(request.getParameter("descripcion"));
        String beneficiarios = safe(request.getParameter("cantidad_beneficiarios"));
        String idPais = safe(request.getParameter("id_pais"));
        Boolean estado = parseEstado(request.getParameter("estado"));

        if (idComunidad == null || nombre.isEmpty() || idPais.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: datos incompletos para editar");
            response.sendRedirect(request.getContextPath() + "/comunidades");
            return;
        }

        comunidadDAO.editar(
                idComunidad,
                nombre,
                ubicacion,
                descripcion,
                parseInt(beneficiarios, 0),
                Integer.parseInt(idPais)
        );
        if (estado != null) {
            comunidadDAO.cambiarActivo(idComunidad, estado);
        }

        request.getSession().setAttribute("mensaje", "Comunidad actualizada correctamente");
        response.sendRedirect(request.getContextPath() + "/comunidades?id=" + idComunidad);
    }

    private void cambiarActivo(Integer id, boolean restaurar,
                               HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (id == null) {
            request.getSession().setAttribute("mensaje", "Error: id de comunidad invalido");
            response.sendRedirect(request.getContextPath() + "/comunidades");
            return;
        }

        comunidadDAO.cambiarActivo(id, restaurar);

        request.getSession().setAttribute("mensaje",
                restaurar ? "Comunidad restaurada correctamente" : "Comunidad eliminada correctamente");
        response.sendRedirect(request.getContextPath() + "/comunidades?id=" + id);
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

