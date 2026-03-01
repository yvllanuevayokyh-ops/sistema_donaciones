package com.donaciones.filter;

import com.donaciones.dao.AuditoriaDAO;
import java.io.IOException;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class AuditoriaFilter extends OncePerRequestFilter {

    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @Override
    protected boolean shouldNotFilter(@NonNull HttpServletRequest request) {
        String uri = request.getRequestURI();
        return uri == null
                || uri.contains("/css/")
                || uri.contains("/js/")
                || uri.contains("/images/")
                || uri.contains(".ico")
                || uri.contains(".png")
                || uri.contains(".jpg")
                || uri.contains(".jpeg")
                || uri.contains(".svg");
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain)
            throws ServletException, IOException {
        filterChain.doFilter(request, response);

        String method = safe(request.getMethod()).toUpperCase();
        String uri = safe(request.getRequestURI());
        String query = safe(request.getQueryString());
        String accion = resolveAccion(request, method, uri);
        if (accion.isEmpty()) {
            return;
        }

        HttpSession session = request.getSession(false);
        String usuario = session != null ? safeObj(session.getAttribute("usuarioNombre")) : safe(request.getParameter("email"));
        String rol = session != null ? safeObj(session.getAttribute("usuarioRol")) : "";
        String modulo = resolveModulo(uri);
        String detalle = (query.isEmpty() ? "" : query);
        auditoriaDAO.registrar(usuario, rol, modulo, accion, detalle, response.getStatus());
    }

    private String resolveAccion(HttpServletRequest request, String method, String uri) {
        String accionParam = safe(request.getParameter("accion")).trim().toLowerCase();
        if (!accionParam.isEmpty()) {
            if ("crear".equals(accionParam) || "agregar_responsable".equals(accionParam)) {
                return "CREATE";
            }
            if ("editar".equals(accionParam) || "guardar_permisos".equals(accionParam) || "cambiar_estado".equals(accionParam)) {
                return "UPDATE";
            }
            if ("eliminar".equals(accionParam) || "inactivar".equals(accionParam) || "desactivar_responsable".equals(accionParam)) {
                return "DELETE";
            }
            if ("restaurar".equals(accionParam)) {
                return "RESTORE";
            }
            if ("crear_permiso".equals(accionParam)) {
                return "CREATE";
            }
            return accionParam.toUpperCase();
        }

        if ("POST".equals(method) && uri.endsWith("/login")) {
            return "LOGIN";
        }
        if ("POST".equals(method) && uri.endsWith("/registro")) {
            return "REGISTER";
        }
        if (uri.endsWith("/logout")) {
            return "LOGOUT";
        }
        if (uri.endsWith("/excel")) {
            return "EXPORT";
        }
        return "";
    }

    private String resolveModulo(String uri) {
        if (uri == null || uri.isEmpty()) {
            return "GENERAL";
        }
        String clean = uri.startsWith("/") ? uri.substring(1) : uri;
        if (clean.contains("/")) {
            clean = clean.substring(0, clean.indexOf('/'));
        }
        return clean.isEmpty() ? "GENERAL" : clean.toUpperCase();
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }

    private String safeObj(Object value) {
        return value == null ? "" : String.valueOf(value);
    }
}
