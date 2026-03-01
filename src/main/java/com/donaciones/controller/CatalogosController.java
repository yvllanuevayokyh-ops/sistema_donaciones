package com.donaciones.controller;

import com.donaciones.dao.AuditoriaDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CatalogosController {

    private final AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

    @GetMapping("/catalogos")
    public String doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }
        if (!isAdminRole(request)) {
            request.getSession().setAttribute("mensaje", "Acceso restringido para este rol");
            return "redirect:/home";
        }

        String q = safe(request.getParameter("q")).trim();
        String modulo = safe(request.getParameter("modulo")).trim();
        String accion = safe(request.getParameter("accion")).trim();

        List<Object[]> auditoria = auditoriaDAO.listar(q, modulo, accion, 400);
        request.setAttribute("auditoriaRows", auditoria);
        request.setAttribute("q", q);
        request.setAttribute("modulo", modulo);
        request.setAttribute("accion", accion);
        return "catalogos/index";
    }

    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("usuarioNombre") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    private boolean isAdminRole(HttpServletRequest request) {
        Object roleObj = request.getSession(false) != null ? request.getSession(false).getAttribute("usuarioRol") : null;
        String rol = roleObj == null ? "" : String.valueOf(roleObj);
        return "Administrador".equalsIgnoreCase(rol);
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }
}
