package com.donaciones.controller;

import com.donaciones.dao.ComunidadDAO;
import com.donaciones.dao.ComunidadResponsableDAO;
import com.donaciones.dao.DonacionDAO;
import com.donaciones.dao.DonanteDAO;
import com.donaciones.dao.PaisDAO;
import com.donaciones.model.ComunidadResponsable;
import com.donaciones.model.ComunidadVulnerable;
import com.donaciones.model.Donacion;
import com.donaciones.model.Donante;
import com.donaciones.model.Pais;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class PerfilReportesController {

    private final DonanteDAO donanteDAO = new DonanteDAO();
    private final DonacionDAO donacionDAO = new DonacionDAO();
    private final ComunidadDAO comunidadDAO = new ComunidadDAO();
    private final ComunidadResponsableDAO responsableDAO = new ComunidadResponsableDAO();
    private final PaisDAO paisDAO = new PaisDAO();

    @GetMapping("/mi-perfil")
    public String perfilGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }

        String rol = getSessionString(request, "usuarioRol");
        List<Pais> paises = safeList(paisDAO.listar());
        request.setAttribute("paises", paises);

        if (isDonanteRole(rol)) {
            Integer idDonante = donanteDAO.buscarDonanteIdPorUsuario(
                    getSessionString(request, "usuarioEmail"),
                    getSessionString(request, "usuarioNombre")
            );
            Donante perfil = idDonante == null ? null : donanteDAO.buscarDetalle(idDonante);
            request.setAttribute("perfilDonante", perfil);
            request.setAttribute("perfilTipo", "donante");
            return "perfil/index";
        }

        if (isComunidadRole(rol)) {
            ComunidadVulnerable comunidad = comunidadDAO.buscarPorNombreExacto(
                    getSessionString(request, "usuarioNombre")
            );
            List<ComunidadResponsable> responsables = comunidad != null && comunidad.getIdComunidad() != null
                    ? safeList(responsableDAO.listarPorComunidad(comunidad.getIdComunidad(), false))
                    : new ArrayList<ComunidadResponsable>();
            request.setAttribute("perfilComunidad", comunidad);
            request.setAttribute("responsablesComunidad", responsables);
            request.setAttribute("perfilTipo", "comunidad");
            return "perfil/index";
        }

        request.getSession().setAttribute("mensaje", "Acceso restringido para este rol");
        return "redirect:/home";
    }

    @PostMapping("/mi-perfil")
    public void perfilPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }

        String rol = getSessionString(request, "usuarioRol");
        try {
            if (isDonanteRole(rol)) {
                actualizarPerfilDonante(request, response);
                return;
            }
            if (isComunidadRole(rol)) {
                String accion = safe(request.getParameter("accion")).toLowerCase();
                if ("agregar_responsable".equals(accion)) {
                    agregarResponsableComunidad(request, response);
                    return;
                }
                if ("desactivar_responsable".equals(accion)) {
                    desactivarResponsableComunidad(request, response);
                    return;
                }
                actualizarPerfilComunidad(request, response);
                return;
            }
            request.getSession().setAttribute("mensaje", "Acceso restringido para este rol");
            response.sendRedirect(request.getContextPath() + "/home");
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo actualizar el perfil");
            response.sendRedirect(request.getContextPath() + "/mi-perfil");
        }
    }

    @GetMapping("/mis-reportes")
    public String reportesGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }

        String rol = getSessionString(request, "usuarioRol");
        if (isDonanteRole(rol)) {
            Integer idDonante = donanteDAO.buscarDonanteIdPorUsuario(
                    getSessionString(request, "usuarioEmail"),
                    getSessionString(request, "usuarioNombre")
            );
            if (idDonante == null) {
                request.setAttribute("perfilVinculado", false);
                request.setAttribute("reporteTipo", "donante");
                return "reportes/index";
            }

            List<Donacion> donaciones = donacionDAO.listarPorDonante(idDonante);
            Map<Integer, String> entregadores = donacionDAO.obtenerEntregadorPorDonaciones(extractIds(donaciones));
            BigDecimal montoTotal = BigDecimal.ZERO;
            for (Donacion d : donaciones) {
                if (d != null && d.getMonto() != null) {
                    montoTotal = montoTotal.add(d.getMonto());
                }
            }

            request.setAttribute("perfilVinculado", true);
            request.setAttribute("reporteTipo", "donante");
            request.setAttribute("reporteDonaciones", donaciones);
            request.setAttribute("reporteDonacionesTotal", donaciones == null ? 0 : donaciones.size());
            request.setAttribute("reporteMontoTotal", montoTotal);
            request.setAttribute("entregadorPorDonacion", entregadores);
            return "reportes/index";
        }

        if (isComunidadRole(rol)) {
            ComunidadVulnerable comunidad = comunidadDAO.buscarPorNombreExacto(
                    getSessionString(request, "usuarioNombre")
            );
            if (comunidad == null || comunidad.getIdComunidad() == null) {
                request.setAttribute("perfilVinculado", false);
                request.setAttribute("reporteTipo", "comunidad");
                return "reportes/index";
            }

            List<Object[]> reporteRecepciones = comunidadDAO.listarReporteRecepciones(comunidad.getIdComunidad());
            BigDecimal montoRecibido = comunidadDAO.montoRecibidoComunidad(comunidad.getIdComunidad());
            int entregasRecibidas = reporteRecepciones == null ? 0 : reporteRecepciones.size();
            int entregasCompletadas = 0;
            if (reporteRecepciones != null) {
                for (Object[] row : reporteRecepciones) {
                    if (row != null && row.length > 6 && "ENTREGADO".equalsIgnoreCase(safe(row[6]))) {
                        entregasCompletadas++;
                    }
                }
            }

            request.setAttribute("perfilVinculado", true);
            request.setAttribute("reporteTipo", "comunidad");
            request.setAttribute("reporteComunidad", comunidad);
            request.setAttribute("reporteRecepciones", reporteRecepciones);
            request.setAttribute("reporteMontoRecibido", montoRecibido);
            request.setAttribute("reporteEntregas", entregasRecibidas);
            request.setAttribute("reporteEntregasCompletadas", entregasCompletadas);
            return "reportes/index";
        }

        request.getSession().setAttribute("mensaje", "Acceso restringido para este rol");
        return "redirect:/home";
    }

    private void actualizarPerfilDonante(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idDonante = parseInteger(request.getParameter("id_donante"));
        String nombre = safe(request.getParameter("nombre"));
        String email = safe(request.getParameter("email"));
        String telefono = safe(request.getParameter("telefono"));
        String direccion = safe(request.getParameter("direccion"));
        String tipoDonante = safe(request.getParameter("tipo_donante"));
        Integer idPais = parseInteger(request.getParameter("id_pais"));

        if (idDonante == null || nombre.isEmpty() || idPais == null) {
            request.getSession().setAttribute("mensaje", "Error: faltan datos requeridos del perfil");
            response.sendRedirect(request.getContextPath() + "/mi-perfil");
            return;
        }
        if (tipoDonante.isEmpty()) {
            tipoDonante = "Institucion";
        }

        donanteDAO.editar(idDonante, nombre, email, telefono, direccion, tipoDonante, idPais);
        request.getSession().setAttribute("mensaje", "Perfil actualizado correctamente");
        response.sendRedirect(request.getContextPath() + "/mi-perfil");
    }

    private void actualizarPerfilComunidad(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idComunidad = parseInteger(request.getParameter("id_comunidad"));
        String nombre = safe(request.getParameter("nombre"));
        String ubicacion = safe(request.getParameter("ubicacion"));
        String descripcion = safe(request.getParameter("descripcion"));
        Integer beneficiarios = parseInteger(request.getParameter("cantidad_beneficiarios"));
        Integer idPais = parseInteger(request.getParameter("id_pais"));

        if (idComunidad == null || nombre.isEmpty() || idPais == null) {
            request.getSession().setAttribute("mensaje", "Error: faltan datos requeridos del perfil");
            response.sendRedirect(request.getContextPath() + "/mi-perfil");
            return;
        }
        if (beneficiarios == null) {
            beneficiarios = 0;
        }

        comunidadDAO.editar(idComunidad, nombre, ubicacion, descripcion, beneficiarios, idPais);
        request.getSession().setAttribute("mensaje", "Perfil actualizado correctamente");
        response.sendRedirect(request.getContextPath() + "/mi-perfil");
    }

    private void agregarResponsableComunidad(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idComunidad = parseInteger(request.getParameter("id_comunidad"));
        String nombre = safe(request.getParameter("nombre_responsable"));
        String telefono = safe(request.getParameter("telefono_responsable"));
        String email = safe(request.getParameter("email_responsable"));
        String cargo = safe(request.getParameter("cargo_responsable"));

        if (idComunidad == null || nombre.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: nombre del responsable es requerido");
            response.sendRedirect(request.getContextPath() + "/mi-perfil");
            return;
        }

        responsableDAO.crear(idComunidad, nombre, telefono, email, cargo);
        request.getSession().setAttribute("mensaje", "Responsable agregado correctamente");
        response.sendRedirect(request.getContextPath() + "/mi-perfil");
    }

    private void desactivarResponsableComunidad(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer idResponsable = parseInteger(request.getParameter("id_responsable"));
        if (idResponsable == null) {
            request.getSession().setAttribute("mensaje", "Error: responsable invalido");
            response.sendRedirect(request.getContextPath() + "/mi-perfil");
            return;
        }

        responsableDAO.cambiarActivo(idResponsable, false);
        request.getSession().setAttribute("mensaje", "Responsable desactivado correctamente");
        response.sendRedirect(request.getContextPath() + "/mi-perfil");
    }

    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("usuarioNombre") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    private boolean isDonanteRole(String rol) {
        return "Institucion Donante".equalsIgnoreCase(rol) || "Persona Natural".equalsIgnoreCase(rol);
    }

    private boolean isComunidadRole(String rol) {
        return "Comunidad".equalsIgnoreCase(rol);
    }

    private String getSessionString(HttpServletRequest request, String key) {
        if (request.getSession(false) == null) {
            return "";
        }
        Object value = request.getSession(false).getAttribute(key);
        return value == null ? "" : String.valueOf(value);
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

    private <T> List<T> safeList(List<T> rows) {
        return rows == null ? new ArrayList<T>() : rows;
    }

    private String safe(Object value) {
        return value == null ? "" : String.valueOf(value);
    }
}
