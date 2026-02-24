package com.donaciones.controller;

import javax.servlet.http.HttpSession;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalViewAdvice {

    @ModelAttribute
    public void exposeSessionData(HttpSession session, Model model) {
        if (session == null) {
            return;
        }

        Object nombre = session.getAttribute("usuarioNombre");
        Object rol = session.getAttribute("usuarioRol");
        model.addAttribute("usuarioNombre", nombre == null ? "" : String.valueOf(nombre));
        model.addAttribute("usuarioRol", rol == null ? "" : String.valueOf(rol));

        String rolValue = rol == null ? "" : String.valueOf(rol);
        boolean isDonante = "Institucion Donante".equalsIgnoreCase(rolValue)
                || "Persona Natural".equalsIgnoreCase(rolValue);
        boolean isComunidad = "Comunidad".equalsIgnoreCase(rolValue);
        model.addAttribute("isRoleDonante", isDonante);
        model.addAttribute("isRoleComunidad", isComunidad);
        model.addAttribute("isRoleAdmin", !isDonante && !isComunidad);

        Object msg = session.getAttribute("mensaje");
        if (msg instanceof String) {
            String value = (String) msg;
            model.addAttribute("flashMessage", value);
            model.addAttribute("flashError", value.startsWith("Error"));
            session.removeAttribute("mensaje");
        }
    }
}
