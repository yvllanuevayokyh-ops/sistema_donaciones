package com.donaciones.controller;

import com.donaciones.dao.ComunidadDAO;
import com.donaciones.dao.ComunidadResponsableDAO;
import com.donaciones.dao.DonacionDAO;
import com.donaciones.dao.EntregaDAO;
import com.donaciones.dao.ResultadoPaginado;
import com.donaciones.dao.VoluntarioDAO;
import com.donaciones.model.ComunidadResponsable;
import com.donaciones.model.ComunidadVulnerable;
import com.donaciones.model.Donacion;
import com.donaciones.model.EntregaDonacion;
import com.donaciones.model.EstadoEntrega;
import com.donaciones.model.Voluntario;
import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
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
public class EntregaController {

    private static final int PAGE_SIZE = 6;

    private final EntregaDAO entregaDAO = new EntregaDAO();
    private final DonacionDAO donacionDAO = new DonacionDAO();
    private final ComunidadDAO comunidadDAO = new ComunidadDAO();
    private final ComunidadResponsableDAO responsableDAO = new ComunidadResponsableDAO();
    private final VoluntarioDAO voluntarioDAO = new VoluntarioDAO();

    @GetMapping("/entregas")
    public String doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }
        if (isDonanteRole(request) || isComunidadRole(request)) {
            request.getSession().setAttribute("mensaje", "Acceso restringido");
            return "redirect:/home";
        }

        String q = safe(request.getParameter("q")).trim();
        String estado = safe(request.getParameter("estado")).trim();
        if (estado.isEmpty()) {
            estado = "Todos";
        }

        int currentPage = parseInt(request.getParameter("page"), 1);
        if (currentPage < 1) {
            currentPage = 1;
        }
        Integer selectedId = parseInteger(request.getParameter("id"));
        Integer editarId = parseInteger(request.getParameter("editarId"));
        boolean showForm = "1".equals(safe(request.getParameter("nuevo"))) || editarId != null;

        List<EntregaDonacion> entregas = new ArrayList<EntregaDonacion>();
        List<Donacion> donaciones = new ArrayList<Donacion>();
        List<ComunidadVulnerable> comunidades = new ArrayList<ComunidadVulnerable>();
        List<ComunidadResponsable> responsables = new ArrayList<ComunidadResponsable>();
        List<Voluntario> voluntarios = new ArrayList<Voluntario>();
        List<EstadoEntrega> estados = new ArrayList<EstadoEntrega>();
        EntregaDonacion detalle = null;
        EntregaDonacion edicion = null;
        Integer voluntarioAsignadoDetalle = null;
        Integer voluntarioAsignadoEdicion = null;
        String entregadorDetalle = "";
        String responsableDetalle = "";
        int totalRows = 0;
        int totalPages = 1;
        Map<Integer, String> entregadorPorEntrega = new LinkedHashMap<Integer, String>();
        Map<Integer, String> responsablePorEntrega = new LinkedHashMap<Integer, String>();

        try {
            ResultadoPaginado<EntregaDonacion> resultado =
                    entregaDAO.buscarYPaginar(q, estado, currentPage, PAGE_SIZE);
            if (currentPage > resultado.getTotalPaginas()) {
                currentPage = Math.max(1, resultado.getTotalPaginas());
                resultado = entregaDAO.buscarYPaginar(q, estado, currentPage, PAGE_SIZE);
            }

            entregas = safeList(resultado.getDatos());
            totalRows = resultado.getTotalRegistros();
            totalPages = Math.max(1, resultado.getTotalPaginas());

            estados = safeList(entregaDAO.listarEstados());
            donaciones = safeList(donacionDAO.listarDonacionesCatalogo());
            comunidades = safeList(comunidadDAO.listarComunidadesCatalogo());
            responsables = safeList(responsableDAO.listarActivos());
            voluntarios = safeList(voluntarioDAO.listarActivosCatalogo());
            entregadorPorEntrega = entregaDAO.obtenerEntregadoresPorEntregas(extractIds(entregas));
            responsablePorEntrega = entregaDAO.obtenerResponsablesPorEntregas(extractIds(entregas));

            if (selectedId == null && !entregas.isEmpty()) {
                selectedId = entregas.get(0).getIdEntrega();
            }
            if (editarId != null && selectedId == null) {
                selectedId = editarId;
            }
            if (selectedId != null) {
                detalle = entregaDAO.buscarDetalle(selectedId);
                voluntarioAsignadoDetalle = entregaDAO.obtenerVoluntarioAsignado(selectedId);
                entregadorDetalle = entregadorPorEntrega.getOrDefault(selectedId, "");
                if (entregadorDetalle.isEmpty() && voluntarioAsignadoDetalle != null) {
                    entregadorDetalle = buscarNombreVoluntario(voluntarios, voluntarioAsignadoDetalle);
                }
                responsableDetalle = responsablePorEntrega.getOrDefault(selectedId, "");
            }
            if (editarId != null) {
                edicion = entregaDAO.buscarDetalle(editarId);
                voluntarioAsignadoEdicion = entregaDAO.obtenerVoluntarioAsignado(editarId);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar entregas");
            totalPages = 1;
        }

        request.setAttribute("entregas", entregas);
        request.setAttribute("donaciones", donaciones);
        request.setAttribute("comunidades", comunidades);
        request.setAttribute("responsables", responsables);
        request.setAttribute("voluntarios", voluntarios);
        request.setAttribute("estados", estados);
        request.setAttribute("detalle", detalle);
        request.setAttribute("edicion", edicion);
        request.setAttribute("voluntarioAsignadoDetalle", voluntarioAsignadoDetalle);
        request.setAttribute("voluntarioAsignadoEdicion", voluntarioAsignadoEdicion);
        request.setAttribute("entregadorPorEntrega", entregadorPorEntrega);
        request.setAttribute("responsablePorEntrega", responsablePorEntrega);
        request.setAttribute("entregadorDetalle", entregadorDetalle);
        request.setAttribute("responsableDetalle", responsableDetalle);
        request.setAttribute("showForm", showForm);
        request.setAttribute("selectedId", selectedId);
        request.setAttribute("q", q);
        request.setAttribute("estado", estado);
        request.setAttribute("hoy", LocalDate.now().toString());
        request.setAttribute("ahora", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRows", totalRows);
        request.setAttribute("pageSize", PAGE_SIZE);

        return "entregas/index";
    }

    @PostMapping("/entregas")
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }
        if (isDonanteRole(request) || isComunidadRole(request)) {
            request.getSession().setAttribute("mensaje", "Acceso restringido");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String accion = safe(request.getParameter("accion")).toLowerCase();
        try {
            switch (accion) {
                case "crear":
                    crearEntrega(request, response);
                    return;
                case "editar":
                    editarEntrega(request, response);
                    return;
                case "cambiar_estado":
                    cambiarEstado(request, response);
                    return;
                default:
                    response.sendRedirect(request.getContextPath() + "/entregas");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: operacion no completada");
            response.sendRedirect(request.getContextPath() + "/entregas");
        }
    }

    private void crearEntrega(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idDonacion = parseInteger(request.getParameter("id_donacion"));
        Integer idComunidad = parseInteger(request.getParameter("id_comunidad"));
        Integer idResponsable = parseInteger(request.getParameter("id_responsable"));
        Integer idEstado = parseInteger(request.getParameter("id_estado_entrega"));
        Timestamp fechaProgramada = parseTimestamp(request.getParameter("fecha_programada"));
        Timestamp fechaEntrega = parseTimestamp(request.getParameter("fecha_entrega"));
        Integer idVoluntario = parseInteger(request.getParameter("id_voluntario"));
        String observaciones = safe(request.getParameter("observaciones"));

        if (idDonacion == null || idComunidad == null) {
            request.getSession().setAttribute("mensaje", "Error: selecciona donacion y comunidad");
            response.sendRedirect(request.getContextPath() + "/entregas");
            return;
        }
        if (idResponsable != null && !responsableDAO.perteneceAComunidad(idResponsable, idComunidad)) {
            request.getSession().setAttribute("mensaje", "Error: el responsable no pertenece a la comunidad seleccionada");
            response.sendRedirect(request.getContextPath() + "/entregas?nuevo=1");
            return;
        }
        if (idEstado == null) {
            idEstado = 1;
        }
        if (idEstado == 3 && fechaEntrega == null) {
            fechaEntrega = nowTimestamp();
        }

        int newId = entregaDAO.crear(idDonacion, idComunidad, idResponsable, idEstado, fechaProgramada, fechaEntrega, observaciones);
        if (newId > 0) {
            entregaDAO.asignarVoluntario(newId, idVoluntario);
        }
        request.getSession().setAttribute("mensaje", "Entrega registrada correctamente");
        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/entregas?id=" + newId);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/entregas");
    }

    private void editarEntrega(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idEntrega = parseInteger(request.getParameter("id_entrega"));
        Integer idDonacion = parseInteger(request.getParameter("id_donacion"));
        Integer idComunidad = parseInteger(request.getParameter("id_comunidad"));
        Integer idResponsable = parseInteger(request.getParameter("id_responsable"));
        Integer idEstado = parseInteger(request.getParameter("id_estado_entrega"));
        Timestamp fechaProgramada = parseTimestamp(request.getParameter("fecha_programada"));
        Timestamp fechaEntrega = parseTimestamp(request.getParameter("fecha_entrega"));
        Integer idVoluntario = parseInteger(request.getParameter("id_voluntario"));
        String observaciones = safe(request.getParameter("observaciones"));

        if (idEntrega == null || idDonacion == null || idComunidad == null || idEstado == null) {
            request.getSession().setAttribute("mensaje", "Error: datos incompletos para editar");
            response.sendRedirect(request.getContextPath() + "/entregas");
            return;
        }
        if (idResponsable != null && !responsableDAO.perteneceAComunidad(idResponsable, idComunidad)) {
            request.getSession().setAttribute("mensaje", "Error: el responsable no pertenece a la comunidad seleccionada");
            response.sendRedirect(request.getContextPath() + "/entregas?editarId=" + idEntrega);
            return;
        }
        if (idEstado == 3 && fechaEntrega == null) {
            fechaEntrega = nowTimestamp();
        }

        entregaDAO.editar(idEntrega, idDonacion, idComunidad, idResponsable, idEstado, fechaProgramada, fechaEntrega, observaciones);
        entregaDAO.asignarVoluntario(idEntrega, idVoluntario);
        request.getSession().setAttribute("mensaje", "Entrega actualizada correctamente");
        response.sendRedirect(request.getContextPath() + "/entregas?id=" + idEntrega);
    }

    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idEntrega = parseInteger(request.getParameter("id"));
        Integer idEstado = parseInteger(request.getParameter("id_estado_entrega"));
        Timestamp fechaEntrega = parseTimestamp(request.getParameter("fecha_entrega"));
        String observaciones = safe(request.getParameter("observaciones"));

        if (idEntrega == null || idEstado == null) {
            request.getSession().setAttribute("mensaje", "Error: datos incompletos para cambiar estado");
            response.sendRedirect(request.getContextPath() + "/entregas");
            return;
        }
        if (idEstado == 3 && fechaEntrega == null) {
            fechaEntrega = nowTimestamp();
        }

        entregaDAO.cambiarEstado(idEntrega, idEstado, fechaEntrega, observaciones);
        request.getSession().setAttribute("mensaje", "Estado de entrega actualizado");
        response.sendRedirect(request.getContextPath() + "/entregas?id=" + idEntrega);
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

    private Timestamp parseTimestamp(String value) {
        try {
            if (value == null || value.isBlank()) {
                return null;
            }
            String normalized = value.trim().replace('T', ' ');
            if (normalized.length() == 16) {
                normalized = normalized + ":00";
            }
            return Timestamp.valueOf(normalized);
        } catch (Exception ex) {
            return null;
        }
    }

    private Timestamp nowTimestamp() {
        LocalDateTime now = LocalDateTime.now().withSecond(0).withNano(0);
        return Timestamp.valueOf(now);
    }

    private List<Integer> extractIds(List<EntregaDonacion> rows) {
        List<Integer> ids = new ArrayList<Integer>();
        if (rows == null) {
            return ids;
        }
        for (EntregaDonacion e : rows) {
            if (e != null && e.getIdEntrega() != null) {
                ids.add(e.getIdEntrega());
            }
        }
        return ids;
    }

    private String buscarNombreVoluntario(List<Voluntario> voluntarios, Integer idVoluntario) {
        if (voluntarios == null || idVoluntario == null) {
            return "";
        }
        for (Voluntario v : voluntarios) {
            if (v != null && v.getIdVoluntario() != null && v.getIdVoluntario().intValue() == idVoluntario.intValue()) {
                return safe(v.getNombre());
            }
        }
        return "";
    }

    private <T> List<T> safeList(List<T> rows) {
        return rows == null ? new ArrayList<T>() : rows;
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }
}

