package com.donaciones.controller;

import com.donaciones.dao.UsuarioSistemaDAO;
import com.donaciones.model.UsuarioSistema;
import javax.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    private final UsuarioSistemaDAO usuarioSistemaDAO = new UsuarioSistemaDAO();

    @GetMapping("/login")
    public String mostrarLogin(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "email", required = false) String email,
            HttpSession session,
            Model model) {
        model.addAttribute("error", error);
        model.addAttribute("email", email == null ? "" : email);
        consumeFlash(session, model);
        return "auth/login";
    }

    @PostMapping("/login")
    public String iniciarSesion(
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "password", required = false) String password,
            HttpSession session) {

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            return "redirect:/login?error=1";
        }

        try {
            UsuarioSistema usuario = usuarioSistemaDAO.autenticar(email.trim(), password);
            if (usuario != null) {
                session.setAttribute("usuarioNombre", usuario.getNombre());
                session.setAttribute("usuarioEmail", usuario.getUsuario());
                session.setAttribute("usuarioRol",
                        usuario.getRol() != null ? usuario.getRol().getNombre() : "");
                session.setAttribute("mensaje", "Sesion iniciada correctamente");
                return "redirect:/home";
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("mensaje", "Error de conexion con base de datos: " + ex.getMessage());
            return "redirect:/login?error=db";
        }

        session.setAttribute("mensaje", "Error: credenciales invalidas");
        return "redirect:/login?error=1";
    }

    private void consumeFlash(HttpSession session, Model model) {
        Object msg = session.getAttribute("mensaje");
        if (msg instanceof String) {
            String value = (String) msg;
            model.addAttribute("flashMessage", value);
            model.addAttribute("flashError", value.startsWith("Error"));
            session.removeAttribute("mensaje");
        }
    }
}

