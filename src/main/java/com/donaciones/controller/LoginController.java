package com.donaciones.controller;

import com.donaciones.dao.DonanteDAO;
import com.donaciones.dao.PaisDAO;
import com.donaciones.dao.UsuarioSistemaDAO;
import com.donaciones.model.Pais;
import com.donaciones.model.UsuarioSistema;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    private final UsuarioSistemaDAO usuarioSistemaDAO = new UsuarioSistemaDAO();
    private final DonanteDAO donanteDAO = new DonanteDAO();
    private final PaisDAO paisDAO = new PaisDAO();

    @GetMapping("/login")
    public String mostrarLogin(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "registro", required = false) String registro,
            HttpSession session,
            Model model) {
        List<Pais> paises;
        try {
            paises = paisDAO.listar();
        } catch (Exception ex) {
            paises = new ArrayList<Pais>();
        }
        model.addAttribute("error", error);
        model.addAttribute("email", email == null ? "" : email);
        model.addAttribute("showRegistro", "1".equals(registro));
        model.addAttribute("paises", paises);
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

    @PostMapping("/registro")
    public String registrar(
            @RequestParam(value = "nombre", required = false) String nombre,
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "password", required = false) String password,
            @RequestParam(value = "confirm_password", required = false) String confirmPassword,
            @RequestParam(value = "tipo_donante", required = false) String tipoDonante,
            @RequestParam(value = "id_pais", required = false) String idPais,
            @RequestParam(value = "telefono", required = false) String telefono,
            @RequestParam(value = "direccion", required = false) String direccion,
            HttpSession session) {

        String nombreV = safe(nombre);
        String emailV = safe(email);
        String passwordV = safe(password);
        String confirmV = safe(confirmPassword);
        String tipoV = safe(tipoDonante);
        Integer idPaisV = parseInt(idPais);

        if (nombreV.isEmpty() || emailV.isEmpty() || passwordV.isEmpty() || idPaisV == null) {
            session.setAttribute("mensaje", "Error: completa los campos requeridos de registro");
            return "redirect:/login?registro=1";
        }
        if (!passwordV.equals(confirmV)) {
            session.setAttribute("mensaje", "Error: las contrasenas no coinciden");
            return "redirect:/login?registro=1";
        }
        if (passwordV.length() < 6) {
            session.setAttribute("mensaje", "Error: la contrasena debe tener al menos 6 caracteres");
            return "redirect:/login?registro=1";
        }

        int idRol = "PERSONA".equalsIgnoreCase(tipoV) ? 3 : 2;
        String tipoDonanteDb = "PERSONA".equalsIgnoreCase(tipoV) ? "Persona Natural" : "Institucion";

        try {
            if (usuarioSistemaDAO.existeUsuario(emailV)) {
                session.setAttribute("mensaje", "Error: el email ya esta registrado");
                return "redirect:/login?registro=1";
            }
            if (donanteDAO.existeEmail(emailV)) {
                session.setAttribute("mensaje", "Error: el email ya existe en donantes");
                return "redirect:/login?registro=1";
            }

            donanteDAO.crear(
                    nombreV,
                    emailV,
                    safe(telefono),
                    safe(direccion),
                    tipoDonanteDb,
                    idPaisV,
                    Date.valueOf(LocalDate.now())
            );
            usuarioSistemaDAO.registrar(nombreV, emailV, passwordV, idRol);
            session.setAttribute("mensaje", "Registro completado. Ahora puedes iniciar sesion.");
            return "redirect:/login?email=" + emailV;
        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("mensaje", "Error: no se pudo completar el registro");
            return "redirect:/login?registro=1";
        }
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

    private String safe(String value) {
        return value == null ? "" : value.trim();
    }

    private Integer parseInt(String value) {
        try {
            if (value == null || value.isBlank()) {
                return null;
            }
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}

