package com.donaciones.controller;

import com.donaciones.dao.RolesPermisosDAO;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class RolesPermisosServlet {

    private final RolesPermisosDAO dao = new RolesPermisosDAO();
    private static final int PAGE_SIZE = 8;

    @GetMapping("/roles")
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
        Integer selectedId = parseInteger(request.getParameter("id"));
        Integer editarId = parseInteger(request.getParameter("editarId"));
        boolean showForm = "1".equals(safe(request.getParameter("nuevo"))) || editarId != null;
        boolean showPermissionForm = "1".equals(safe(request.getParameter("nuevoPermiso")));
        int currentPage = parseInt(request.getParameter("page"), 1);
        if (currentPage < 1) {
            currentPage = 1;
        }

        List<String[]> roles = new ArrayList<String[]>();
        List<String[]> permisosRol = new ArrayList<String[]>();
        String[] detalle = null;
        String[] edicion = null;
        int totalRoles = 0;
        int totalPages = 1;
        int totalPermisos = 0;
        int totalAsignaciones = 0;

        try {
            dao.bootstrapSchemaAndData();

            totalRoles = dao.contarRoles(q);
            totalPages = totalRoles == 0 ? 1 : (int) Math.ceil((double) totalRoles / PAGE_SIZE);
            if (currentPage > totalPages) {
                currentPage = totalPages;
            }
            int offset = (currentPage - 1) * PAGE_SIZE;
            roles = dao.listarRoles(q, offset, PAGE_SIZE);
            totalPermisos = dao.contarPermisos();
            totalAsignaciones = dao.contarAsignaciones();

            if (selectedId == null && !roles.isEmpty()) {
                selectedId = Integer.parseInt(roles.get(0)[0]);
            }
            if (editarId != null) {
                selectedId = editarId;
            }
            if (selectedId != null) {
                detalle = dao.obtenerDetalleRol(selectedId);
                permisosRol = dao.listarPermisosPorRol(selectedId);
            }
            if (editarId != null) {
                edicion = dao.obtenerDetalleRol(editarId);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar modulo roles y permisos");
        }

        request.setAttribute("roles", roles);
        request.setAttribute("permisosRol", permisosRol);
        request.setAttribute("detalle", detalle);
        request.setAttribute("edicion", edicion);
        request.setAttribute("selectedId", selectedId);
        request.setAttribute("showForm", showForm);
        request.setAttribute("showPermissionForm", showPermissionForm);
        request.setAttribute("q", q);
        request.setAttribute("totalRoles", totalRoles);
        request.setAttribute("totalRows", totalRoles);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalPermisos", totalPermisos);
        request.setAttribute("totalAsignaciones", totalAsignaciones);

        return "roles/index";
    }

    @PostMapping("/roles")
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
            dao.bootstrapSchemaAndData();
            switch (accion) {
                case "crear":
                    crearRol(request, response);
                    return;
                case "editar":
                    editarRol(request, response);
                    return;
                case "eliminar":
                    eliminarRol(request, response);
                    return;
                case "guardar_permisos":
                    guardarPermisos(request, response);
                    return;
                case "crear_permiso":
                    crearPermiso(request, response);
                    return;
                default:
                    response.sendRedirect(request.getContextPath() + "/roles");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: operacion no completada");
            response.sendRedirect(request.getContextPath() + "/roles");
        }
    }

    private void crearRol(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String nombre = safe(request.getParameter("nombre")).trim();
        if (nombre.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: nombre de rol es requerido");
            response.sendRedirect(request.getContextPath() + "/roles");
            return;
        }
        if (dao.existeRolPorNombre(nombre, null)) {
            request.getSession().setAttribute("mensaje", "Error: ya existe un rol con ese nombre");
            response.sendRedirect(request.getContextPath() + "/roles");
            return;
        }

        int newId = dao.crearRol(nombre);
        request.getSession().setAttribute("mensaje", "Rol creado correctamente");
        response.sendRedirect(request.getContextPath() + "/roles?id=" + newId);
    }

    private void editarRol(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer idRol = parseInteger(request.getParameter("id_rol"));
        String nombre = safe(request.getParameter("nombre")).trim();
        if (idRol == null || nombre.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: datos incompletos para editar rol");
            response.sendRedirect(request.getContextPath() + "/roles");
            return;
        }
        if (dao.existeRolPorNombre(nombre, idRol)) {
            request.getSession().setAttribute("mensaje", "Error: ya existe un rol con ese nombre");
            response.sendRedirect(request.getContextPath() + "/roles?id=" + idRol);
            return;
        }

        dao.editarRol(idRol, nombre);
        request.getSession().setAttribute("mensaje", "Rol actualizado correctamente");
        response.sendRedirect(request.getContextPath() + "/roles?id=" + idRol);
    }

    private void eliminarRol(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer idRol = parseInteger(request.getParameter("id"));
        if (idRol == null) {
            request.getSession().setAttribute("mensaje", "Error: id de rol invalido");
            response.sendRedirect(request.getContextPath() + "/roles");
            return;
        }
        if (idRol == 1) {
            request.getSession().setAttribute("mensaje", "Error: no se puede eliminar el rol Administrador");
            response.sendRedirect(request.getContextPath() + "/roles?id=" + idRol);
            return;
        }

        int usuariosAsignados = dao.contarUsuariosPorRol(idRol);
        if (usuariosAsignados > 0) {
            request.getSession().setAttribute("mensaje",
                    "Error: no se puede eliminar el rol porque tiene " + usuariosAsignados + " usuario(s) asignado(s)");
            response.sendRedirect(request.getContextPath() + "/roles?id=" + idRol);
            return;
        }

        dao.eliminarRol(idRol);
        request.getSession().setAttribute("mensaje", "Rol eliminado correctamente");
        response.sendRedirect(request.getContextPath() + "/roles");
    }

    private void guardarPermisos(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer idRol = parseInteger(request.getParameter("id_rol"));
        if (idRol == null) {
            request.getSession().setAttribute("mensaje", "Error: id de rol invalido para permisos");
            response.sendRedirect(request.getContextPath() + "/roles");
            return;
        }

        String[] permisosSeleccionados = request.getParameterValues("permiso");
        List<Integer> permisos = new ArrayList<Integer>();
        if (permisosSeleccionados != null) {
            for (String permisoId : permisosSeleccionados) {
                Integer parsed = parseInteger(permisoId);
                if (parsed != null) {
                    permisos.add(parsed);
                }
            }
        }

        dao.guardarPermisos(idRol, permisos);
        request.getSession().setAttribute("mensaje", "Permisos actualizados correctamente");
        response.sendRedirect(request.getContextPath() + "/roles?id=" + idRol);
    }

    private void crearPermiso(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String codigo = safe(request.getParameter("codigo")).trim().toUpperCase().replace(' ', '_');
        String nombre = safe(request.getParameter("nombre")).trim();
        String descripcion = safe(request.getParameter("descripcion")).trim();
        Integer selectedId = parseInteger(request.getParameter("selected_id"));

        if (codigo.isEmpty() || nombre.isEmpty()) {
            request.getSession().setAttribute("mensaje", "Error: codigo y nombre del permiso son requeridos");
            response.sendRedirect(request.getContextPath() + "/roles?nuevoPermiso=1" +
                    (selectedId != null ? "&id=" + selectedId : ""));
            return;
        }

        if (dao.existePermisoPorCodigo(codigo)) {
            request.getSession().setAttribute("mensaje", "Error: ya existe un permiso con ese codigo");
            response.sendRedirect(request.getContextPath() + "/roles?nuevoPermiso=1" +
                    (selectedId != null ? "&id=" + selectedId : ""));
            return;
        }

        dao.crearPermiso(codigo, nombre, descripcion);
        request.getSession().setAttribute("mensaje", "Permiso creado correctamente");
        response.sendRedirect(request.getContextPath() + "/roles" +
                (selectedId != null ? "?id=" + selectedId : ""));
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
        return "Institucion Donante".equalsIgnoreCase(rol) || "Persona Natural".equalsIgnoreCase(rol) || "Comunidad".equalsIgnoreCase(rol);
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

    private String safe(String value) {
        return value == null ? "" : value;
    }
}



