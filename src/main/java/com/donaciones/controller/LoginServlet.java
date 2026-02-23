package com.donaciones.controller;

import com.donaciones.dao.UsuarioSistemaDAO;
import com.donaciones.model.UsuarioSistema;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final UsuarioSistemaDAO usuarioSistemaDAO = new UsuarioSistemaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/login?error=1");
            return;
        }

        try {
            UsuarioSistema usuario = usuarioSistemaDAO.autenticar(email.trim(), password);
            if (usuario != null) {
                request.getSession(true).setAttribute("usuarioNombre", usuario.getNombre());
                request.getSession().setAttribute("usuarioEmail", usuario.getUsuario());
                request.getSession().setAttribute("usuarioRol",
                        usuario.getRol() != null ? usuario.getRol().getNombre() : "");
                request.getSession().setAttribute("mensaje", "Sesion iniciada correctamente");
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession(true).setAttribute("mensaje", "Error de conexion con base de datos: " + ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/login?error=db");
            return;
        }

        request.getSession(true).setAttribute("mensaje", "Error: credenciales invalidas");
        response.sendRedirect(request.getContextPath() + "/login?error=1");
    }
}