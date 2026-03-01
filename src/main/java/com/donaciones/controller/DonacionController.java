package com.donaciones.controller;

import com.donaciones.dao.CampaniaDAO;
import com.donaciones.dao.DonacionDAO;
import com.donaciones.dao.DonanteDAO;
import com.donaciones.dao.ResultadoPaginado;
import com.donaciones.model.Campania;
import com.donaciones.model.Donacion;
import com.donaciones.model.Donante;
import java.io.IOException;
import java.math.BigDecimal;
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
public class DonacionController {

    private static final int PAGE_SIZE = 4;

    private final DonacionDAO donacionDAO = new DonacionDAO();
    private final DonanteDAO donanteDAO = new DonanteDAO();
    private final CampaniaDAO campaniaDAO = new CampaniaDAO();

    @GetMapping("/donaciones")
    public String doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }
        if (isComunidadRole(request)) {
            request.getSession().setAttribute("mensaje", "Acceso restringido para rol Comunidad");
            return "redirect:/home";
        }

        boolean donanteView = isDonanteRole(request);

        String q = safe(request.getParameter("q")).trim();
        String estado = safe(request.getParameter("estado")).trim();
        if (estado.isEmpty()) {
            estado = "Todas";
        }

        String situacion = safe(request.getParameter("situacion")).trim();
        if (situacion.isEmpty()) {
            situacion = "Activos";
        }
        String tipoDonante = safe(request.getParameter("tipoDonante")).trim();
        if (tipoDonante.isEmpty()) {
            tipoDonante = "Todos";
        }
        if (donanteView) {
            tipoDonante = "Todos";
        }

        int currentPage = parseInt(request.getParameter("page"), 1);
        if (currentPage < 1) {
            currentPage = 1;
        }

        Integer filtroActivo = toActivoFilter(situacion);
        Integer selectedId = parseInteger(request.getParameter("id"));
        Integer editarId = parseInteger(request.getParameter("editarId"));
        if (donanteView) {
            editarId = null;
        }
        boolean showForm = "1".equals(safe(request.getParameter("nuevo"))) || editarId != null;

        List<Donacion> donaciones = new ArrayList<Donacion>();
        List<Donante> donantes = new ArrayList<Donante>();
        List<Campania> campanias = new ArrayList<Campania>();
        Donacion detalle = null;
        Donacion edicion = null;
        int totalRows = 0;
        int totalPages = 1;
        boolean perfilDonanteVinculado = true;
        String donanteActualNombre = "";
        Integer idDonanteActual = null;
        Map<Integer, String> entregadorPorDonacion = new LinkedHashMap<Integer, String>();
        String entregadorDetalle = "";

        try {
            campanias = safeList(campaniaDAO.listarActivas());

            if (donanteView) {
                idDonanteActual = donanteDAO.buscarDonanteIdPorUsuario(
                        getSessionString(request, "usuarioEmail"),
                        getSessionString(request, "usuarioNombre")
                );
                perfilDonanteVinculado = idDonanteActual != null;

                if (idDonanteActual != null) {
                    Donante donante = donanteDAO.buscarPorId(idDonanteActual);
                    donanteActualNombre = donante != null ? safe(donante.getNombre()) : "";
                    if (donante != null) {
                        donantes.add(donante);
                    }

                    ResultadoPaginado<Donacion> resultado = donacionDAO.buscarYPaginarPorDonante(
                            q, estado, filtroActivo, currentPage, PAGE_SIZE, idDonanteActual
                    );
                    if (currentPage > resultado.getTotalPaginas()) {
                        currentPage = Math.max(1, resultado.getTotalPaginas());
                        resultado = donacionDAO.buscarYPaginarPorDonante(
                                q, estado, filtroActivo, currentPage, PAGE_SIZE, idDonanteActual
                        );
                    }

                    donaciones = safeList(resultado.getDatos());
                    totalRows = resultado.getTotalRegistros();
                    totalPages = Math.max(1, resultado.getTotalPaginas());

                    if (selectedId == null && !donaciones.isEmpty()) {
                        selectedId = donaciones.get(0).getIdDonacion();
                    }
                    entregadorPorDonacion = donacionDAO.obtenerEntregadorPorDonaciones(extractIds(donaciones));
                    if (selectedId != null) {
                        detalle = donacionDAO.buscarDetallePorDonante(selectedId, idDonanteActual);
                        if (detalle == null && !donaciones.isEmpty()) {
                            selectedId = donaciones.get(0).getIdDonacion();
                            detalle = donacionDAO.buscarDetallePorDonante(selectedId, idDonanteActual);
                        }
                        entregadorDetalle = entregadorPorDonacion.getOrDefault(selectedId, "");
                    }
                } else {
                    perfilDonanteVinculado = false;
                    showForm = false;
                    totalRows = 0;
                    totalPages = 1;
                }
            } else {
                    ResultadoPaginado<Donacion> resultado = donacionDAO.buscarYPaginar(
                        q, estado, filtroActivo, tipoDonante, currentPage, PAGE_SIZE
                );
                if (currentPage > resultado.getTotalPaginas()) {
                    currentPage = Math.max(1, resultado.getTotalPaginas());
                    resultado = donacionDAO.buscarYPaginar(q, estado, filtroActivo, tipoDonante, currentPage, PAGE_SIZE);
                }

                donaciones = safeList(resultado.getDatos());
                entregadorPorDonacion = donacionDAO.obtenerEntregadorPorDonaciones(extractIds(donaciones));
                totalRows = resultado.getTotalRegistros();
                totalPages = Math.max(1, resultado.getTotalPaginas());

                donantes = safeList(donanteDAO.listarDonantesCatalogo());

                if (selectedId == null && !donaciones.isEmpty()) {
                    selectedId = donaciones.get(0).getIdDonacion();
                }
                if (editarId != null && selectedId == null) {
                    selectedId = editarId;
                }
                if (selectedId != null) {
                    detalle = donacionDAO.buscarDetalle(selectedId);
                    entregadorDetalle = entregadorPorDonacion.getOrDefault(selectedId, "");
                }
                if (editarId != null) {
                    edicion = donacionDAO.buscarDetalle(editarId);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar modulo donaciones");
            totalPages = 1;
        }

        request.setAttribute("donaciones", donaciones);
        request.setAttribute("donantes", donantes);
        request.setAttribute("campanias", campanias);
        request.setAttribute("detalle", detalle);
        request.setAttribute("edicion", edicion);
        request.setAttribute("showForm", showForm);
        request.setAttribute("isDonanteView", donanteView);
        request.setAttribute("perfilDonanteVinculado", perfilDonanteVinculado);
        request.setAttribute("donanteActualNombre", donanteActualNombre);
        request.setAttribute("idDonanteActual", idDonanteActual);
        request.setAttribute("selectedId", selectedId);
        request.setAttribute("q", q);
        request.setAttribute("estado", estado);
        request.setAttribute("situacion", situacion);
        request.setAttribute("tipoDonante", tipoDonante);
        request.setAttribute("entregadorPorDonacion", entregadorPorDonacion);
        request.setAttribute("entregadorDetalle", entregadorDetalle);
        request.setAttribute("hoy", LocalDate.now().toString());
        request.setAttribute("totalRows", totalRows);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalPages", totalPages);

        return "donaciones/index";
    }

    @PostMapping("/donaciones")
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }

        String accion = safe(request.getParameter("accion")).toLowerCase();
        try {
            if (isComunidadRole(request)) {
                request.getSession().setAttribute("mensaje", "Accion no permitida para rol Comunidad");
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            if (isDonanteRole(request)) {
                Integer idDonanteActual = donanteDAO.buscarDonanteIdPorUsuario(
                        getSessionString(request, "usuarioEmail"),
                        getSessionString(request, "usuarioNombre")
                );
                if (idDonanteActual == null) {
                    request.getSession().setAttribute("mensaje",
                            "No se encontro un perfil donante vinculado a tu cuenta");
                    response.sendRedirect(request.getContextPath() + "/donaciones");
                    return;
                }
                if (!"crear".equals(accion)) {
                    request.getSession().setAttribute("mensaje",
                            "Accion no permitida para perfil donante");
                    response.sendRedirect(request.getContextPath() + "/donaciones");
                    return;
                }
                crearDonacion(request, response, idDonanteActual);
                return;
            }

            switch (accion) {
                case "crear":
                    crearDonacion(request, response, null);
                    return;
                case "editar":
                    editarDonacion(request, response);
                    return;
                case "eliminar":
                case "inactivar":
                    cambiarActivo(parseInteger(request.getParameter("id")), false, request, response);
                    return;
                case "restaurar":
                    cambiarActivo(parseInteger(request.getParameter("id")), true, request, response);
                    return;
                default:
                    response.sendRedirect(request.getContextPath() + "/donaciones");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: operacion no completada");
            response.sendRedirect(request.getContextPath() + "/donaciones");
        }
    }

    private void crearDonacion(HttpServletRequest request, HttpServletResponse response,
                               Integer forcedDonanteId) throws Exception {
        String idDonante = forcedDonanteId != null
                ? String.valueOf(forcedDonanteId)
                : safe(request.getParameter("id_donante"));
        String idCampania = safe(request.getParameter("id_campania"));
        String tipoDonacion = safe(request.getParameter("tipo_donacion"));
        String estadoDonacion = safe(request.getParameter("estado_donacion"));
        String fechaDonacion = safe(request.getParameter("fecha_donacion"));
        String monto = safe(request.getParameter("monto"));
        String descripcion = safe(request.getParameter("descripcion"));

        if (idDonante.isEmpty() || idCampania.isEmpty() || tipoDonacion.isEmpty() || estadoDonacion.isEmpty()
                || fechaDonacion.isEmpty() || descripcion.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: completa los campos requeridos");
            response.sendRedirect(request.getContextPath() + "/donaciones");
            return;
        }
        BigDecimal montoParsed = parseDecimalOrNull(monto);
        if ("Monetaria".equalsIgnoreCase(tipoDonacion) && montoParsed == null) {
            request.getSession().setAttribute("mensaje", "Error: monto es obligatorio para donaciones monetarias");
            response.sendRedirect(request.getContextPath() + "/donaciones?nuevo=1");
            return;
        }

        int newId = donacionDAO.crear(
                Integer.parseInt(idDonante),
                Integer.parseInt(idCampania),
                tipoDonacion,
                estadoDonacion,
                Date.valueOf(LocalDate.parse(fechaDonacion)),
                montoParsed,
                descripcion
        );

        request.getSession().setAttribute("mensaje", "Donacion registrada correctamente");
        if (newId > 0) {
            response.sendRedirect(request.getContextPath() + "/donaciones?id=" + newId);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/donaciones");
    }

    private void editarDonacion(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idDonacion = parseInteger(request.getParameter("id_donacion"));
        String idDonante = safe(request.getParameter("id_donante"));
        String idCampania = safe(request.getParameter("id_campania"));
        String tipoDonacion = safe(request.getParameter("tipo_donacion"));
        String estadoDonacion = safe(request.getParameter("estado_donacion"));
        String fechaDonacion = safe(request.getParameter("fecha_donacion"));
        String monto = safe(request.getParameter("monto"));
        String descripcion = safe(request.getParameter("descripcion"));

        if (idDonacion == null || idDonante.isEmpty() || idCampania.isEmpty() || tipoDonacion.isEmpty() || estadoDonacion.isEmpty()
                || fechaDonacion.isEmpty() || descripcion.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: datos incompletos para editar");
            response.sendRedirect(request.getContextPath() + "/donaciones");
            return;
        }
        BigDecimal montoParsed = parseDecimalOrNull(monto);
        if ("Monetaria".equalsIgnoreCase(tipoDonacion) && montoParsed == null) {
            request.getSession().setAttribute("mensaje", "Error: monto es obligatorio para donaciones monetarias");
            response.sendRedirect(request.getContextPath() + "/donaciones?editarId=" + idDonacion);
            return;
        }

        donacionDAO.editar(
                idDonacion,
                Integer.parseInt(idDonante),
                Integer.parseInt(idCampania),
                tipoDonacion,
                estadoDonacion,
                Date.valueOf(LocalDate.parse(fechaDonacion)),
                montoParsed,
                descripcion
        );

        request.getSession().setAttribute("mensaje", "Donacion actualizada correctamente");
        response.sendRedirect(request.getContextPath() + "/donaciones?id=" + idDonacion);
    }

    private void cambiarActivo(Integer id, boolean restaurar,
                               HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (id == null) {
            request.getSession().setAttribute("mensaje", "Error: id de donacion invalido");
            response.sendRedirect(request.getContextPath() + "/donaciones");
            return;
        }

        donacionDAO.cambiarActivo(id, restaurar);

        request.getSession().setAttribute("mensaje",
                restaurar ? "Donacion restaurada correctamente" : "Donacion eliminada correctamente");
        response.sendRedirect(request.getContextPath() + "/donaciones?id=" + id);
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

    private Integer toActivoFilter(String situacion) {
        if ("Inactivos".equalsIgnoreCase(situacion)) {
            return 0;
        }
        if ("Todos".equalsIgnoreCase(situacion)) {
            return null;
        }
        return 1;
    }

    private BigDecimal parseDecimalOrNull(String value) {
        try {
            if (value == null || value.isBlank()) {
                return null;
            }
            return new BigDecimal(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String getSessionString(HttpServletRequest request, String key) {
        if (request.getSession(false) == null) {
            return "";
        }
        Object value = request.getSession(false).getAttribute(key);
        return value == null ? "" : String.valueOf(value);
    }

    private <T> List<T> safeList(List<T> rows) {
        return rows == null ? new ArrayList<T>() : rows;
    }

    private List<Integer> extractIds(List<Donacion> rows) {
        List<Integer> ids = new ArrayList<Integer>();
        if (rows == null) {
            return ids;
        }
        for (Donacion d : rows) {
            if (d != null && d.getIdDonacion() != null) {
                ids.add(d.getIdDonacion());
            }
        }
        return ids;
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }
}

