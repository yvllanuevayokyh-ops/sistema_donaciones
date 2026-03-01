package com.donaciones.controller;

import com.donaciones.dao.ComunidadDAO;
import com.donaciones.dao.DashboardDAO;
import com.donaciones.dao.DonanteDAO;
import com.donaciones.model.ComunidadVulnerable;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final DonanteDAO donanteDAO = new DonanteDAO();
    private final ComunidadDAO comunidadDAO = new ComunidadDAO();

    @GetMapping("/home")
    public String mostrarHome(HttpSession session, Model model) {
        if (session == null || session.getAttribute("usuarioNombre") == null) {
            return "redirect:/login";
        }

        String usuarioRol = safe((String) session.getAttribute("usuarioRol"));
        String usuarioEmail = safe((String) session.getAttribute("usuarioEmail"));
        String usuarioNombre = safe((String) session.getAttribute("usuarioNombre"));
        boolean donanteView = isDonanteRole(usuarioRol);
        boolean comunidadView = isComunidadRole(usuarioRol);

        DashboardData dashboardData = new DashboardData();
        dashboardData.fechaActual = LocalDate.now().toString();
        dashboardData.donanteView = donanteView;
        dashboardData.comunidadView = comunidadView;

        try {
            if (donanteView) {
                Integer idDonante = donanteDAO.buscarDonanteIdPorUsuario(usuarioEmail, usuarioNombre);
                dashboardData.perfilDonanteVinculado = idDonante != null;
                dashboardData.totalCampaniasActivas = dashboardDAO.contar(
                        "SELECT COUNT(*) FROM campania WHERE activo = 1 AND UPPER(estado) = 'ACTIVA'"
                );
                if (idDonante != null) {
                    dashboardData.misDonaciones = dashboardDAO.contarPorId(
                            "SELECT COUNT(*) FROM donacion WHERE id_donante = ? AND activo = 1", idDonante
                    );
                    dashboardData.misDonacionesPendientes = dashboardDAO.contarPorId(
                            "SELECT COUNT(*) FROM donacion WHERE id_donante = ? AND activo = 1 " +
                                    "AND UPPER(estado_donacion) IN ('PENDIENTE','EN TRANSITO')",
                            idDonante
                    );
                    dashboardData.montoDonado = dashboardDAO.montoPorId(
                            "SELECT FORMAT(COALESCE(SUM(COALESCE(monto,0)),0),2) " +
                                    "FROM donacion WHERE id_donante = ? AND activo = 1",
                            idDonante
                    );
                    dashboardData.donacionesRecientes = dashboardDAO.donacionesRecientesPorDonante(idDonante);
                }
            } else if (comunidadView) {
                ComunidadVulnerable comunidadActual = comunidadDAO.buscarPorNombreExacto(usuarioNombre);
                if (comunidadActual != null && comunidadActual.getIdComunidad() != null) {
                    dashboardData.idComunidadActual = comunidadActual.getIdComunidad();
                    dashboardData.comunidadNombre = safe(comunidadActual.getNombre());
                    dashboardData.totalBeneficiarios = comunidadActual.getCantidadBeneficiarios() != null
                            ? comunidadActual.getCantidadBeneficiarios() : 0;
                    dashboardData.totalDonacionesRecibidas = comunidadDAO.contarDonacionesRecibidas(
                            comunidadActual.getIdComunidad()
                    );
                    dashboardData.montoRecibidoComunidad = comunidadDAO.montoRecibidoComunidad(
                            comunidadActual.getIdComunidad()
                    );
                    dashboardData.totalCampaniasActivas = dashboardDAO.contarPorId(
                            "SELECT COUNT(*) FROM campania c WHERE c.activo = 1 AND c.id_comunidad = ?",
                            comunidadActual.getIdComunidad()
                    );

                    List<Object[]> reporte = comunidadDAO.listarReporteRecepciones(comunidadActual.getIdComunidad());
                    dashboardData.entregasTotales = reporte == null ? 0 : reporte.size();
                    dashboardData.entregasEntregadas = 0;
                    dashboardData.donacionesRecientes = new ArrayList<String[]>();
                    if (reporte != null) {
                        int limit = Math.min(5, reporte.size());
                        for (int i = 0; i < reporte.size(); i++) {
                            Object[] row = reporte.get(i);
                            if (row != null && row.length > 6 && "ENTREGADO".equalsIgnoreCase(safe(row[6]))) {
                                dashboardData.entregasEntregadas++;
                            }
                            if (i < limit && row != null && row.length >= 10) {
                                dashboardData.donacionesRecientes.add(new String[]{
                                        "DON-" + safe(row[1]),
                                        "S/ " + safe(row[9]),
                                        safe(row[6]),
                                        safe(row[8]),
                                        safe(row[3])
                                });
                            }
                        }
                    }
                } else {
                    dashboardData.totalComunidades = dashboardDAO.contar("SELECT COUNT(*) FROM comunidad_vulnerable");
                    dashboardData.totalBeneficiarios = dashboardDAO.contar(
                            "SELECT COALESCE(SUM(cantidad_beneficiarios),0) FROM comunidad_vulnerable"
                    );
                    dashboardData.totalCampaniasActivas = dashboardDAO.contar(
                            "SELECT COUNT(*) FROM campania WHERE activo = 1 AND UPPER(estado) = 'ACTIVA'"
                    );
                    dashboardData.donacionesRecientes = dashboardDAO.donacionesRecientes();
                }
            } else {
                dashboardData.totalDonaciones = dashboardDAO.contar("SELECT COUNT(*) FROM donacion");
                dashboardData.totalComunidades = dashboardDAO.contar("SELECT COUNT(*) FROM comunidad_vulnerable");
                dashboardData.totalInstituciones = dashboardDAO.contar(
                        "SELECT COUNT(*) FROM donante WHERE UPPER(tipo_donante) LIKE 'INSTITUCION%'"
                );
                dashboardData.totalCampaniasActivas = dashboardDAO.contar(
                        "SELECT COUNT(*) FROM campania WHERE activo = 1 AND UPPER(estado) = 'ACTIVA'"
                );
                dashboardData.totalBeneficiarios = dashboardDAO.contar(
                        "SELECT COALESCE(SUM(cantidad_beneficiarios),0) FROM comunidad_vulnerable"
                );
                dashboardData.voluntariosActivos = dashboardDAO.contar(
                        "SELECT COUNT(*) FROM voluntario WHERE estado = 1"
                );
                dashboardData.entregasTotales = dashboardDAO.contar("SELECT COUNT(*) FROM entrega_donacion");
                dashboardData.entregasEntregadas = dashboardDAO.contar(
                        "SELECT COUNT(*) FROM entrega_donacion ed " +
                                "INNER JOIN estado_entrega ee ON ee.id_estado_entrega = ed.id_estado_entrega " +
                                "WHERE UPPER(ee.descripcion) = 'ENTREGADO'"
                );
                dashboardData.campaniasCompletadas = dashboardDAO.contar(
                        "SELECT COUNT(*) FROM campania WHERE activo = 1 AND UPPER(estado) IN ('FINALIZADA','COMPLETADA','CERRADA')"
                );
                dashboardData.totalCampanias = dashboardDAO.contar("SELECT COUNT(*) FROM campania WHERE activo = 1");
                dashboardData.donacionesRecientes = dashboardDAO.donacionesRecientes();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("mensaje", "Error: no se pudieron cargar datos del dashboard");
        }

        int tasaEntregas = 0;
        if (!donanteView && !comunidadView && dashboardData.entregasTotales > 0) {
            tasaEntregas = (dashboardData.entregasEntregadas * 100) / dashboardData.entregasTotales;
        }

        model.addAttribute("usuarioNombre", usuarioNombre);
        model.addAttribute("usuarioRol", usuarioRol);
        model.addAttribute("isDonanteView", dashboardData.donanteView);
        model.addAttribute("isComunidadView", dashboardData.comunidadView);
        model.addAttribute("perfilDonanteVinculado", dashboardData.perfilDonanteVinculado);
        model.addAttribute("fechaActual", dashboardData.fechaActual);
        model.addAttribute("totalDonaciones", dashboardData.totalDonaciones);
        model.addAttribute("totalComunidades", dashboardData.totalComunidades);
        model.addAttribute("totalInstituciones", dashboardData.totalInstituciones);
        model.addAttribute("totalCampaniasActivas", dashboardData.totalCampaniasActivas);
        model.addAttribute("totalBeneficiarios", dashboardData.totalBeneficiarios);
        model.addAttribute("voluntariosActivos", dashboardData.voluntariosActivos);
        model.addAttribute("tasaEntregas", tasaEntregas);
        model.addAttribute("campaniasCompletadas", dashboardData.campaniasCompletadas);
        model.addAttribute("totalCampanias", dashboardData.totalCampanias);
        model.addAttribute("donacionesRecientes", dashboardData.donacionesRecientes);
        model.addAttribute("misDonaciones", dashboardData.misDonaciones);
        model.addAttribute("misDonacionesPendientes", dashboardData.misDonacionesPendientes);
        model.addAttribute("montoDonado", dashboardData.montoDonado);
        model.addAttribute("idComunidadActual", dashboardData.idComunidadActual);
        model.addAttribute("comunidadNombre", dashboardData.comunidadNombre);
        model.addAttribute("totalDonacionesRecibidas", dashboardData.totalDonacionesRecibidas);
        model.addAttribute("montoRecibidoComunidad", dashboardData.montoRecibidoComunidad);
        model.addAttribute("entregasTotales", dashboardData.entregasTotales);
        model.addAttribute("entregasEntregadas", dashboardData.entregasEntregadas);

        consumeFlash(session, model);
        return "home/index";
    }

    private boolean isDonanteRole(String rol) {
        return "Institucion Donante".equalsIgnoreCase(rol) || "Persona Natural".equalsIgnoreCase(rol);
    }

    private boolean isComunidadRole(String rol) {
        return "Comunidad".equalsIgnoreCase(rol);
    }

    private String safe(Object value) {
        return value == null ? "" : String.valueOf(value);
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

    private static class DashboardData {
        boolean donanteView;
        boolean comunidadView;
        boolean perfilDonanteVinculado;
        String fechaActual;
        int totalDonaciones;
        int totalComunidades;
        int totalInstituciones;
        int totalCampaniasActivas;
        int totalBeneficiarios;
        int voluntariosActivos;
        int entregasTotales;
        int entregasEntregadas;
        int campaniasCompletadas;
        int totalCampanias;
        int idComunidadActual;
        String comunidadNombre = "";
        int totalDonacionesRecibidas;
        BigDecimal montoRecibidoComunidad = BigDecimal.ZERO;
        int misDonaciones;
        int misDonacionesPendientes;
        String montoDonado = "0.00";
        List<String[]> donacionesRecientes = new ArrayList<String[]>();
    }
}

