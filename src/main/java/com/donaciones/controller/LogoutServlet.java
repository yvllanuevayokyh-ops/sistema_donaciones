package com.donaciones.controller;

import java.io.IOException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (request.getSession(false) != null) {
            request.getSession(false).invalidate();
        }
        request.getSession(true).setAttribute("mensaje", "Sesion cerrada correctamente");
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
