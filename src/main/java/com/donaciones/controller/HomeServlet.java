package com.donaciones.controller;

import com.donaciones.dao.DashboardDAO;
import com.donaciones.dao.DonanteDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final DonanteDAO donanteDAO = new DonanteDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("usuarioNombre") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String usuarioRol = safe((String) request.getSession(false).getAttribute("usuarioRol"));
        String usuarioEmail = safe((String) request.getSession(false).getAttribute("usuarioEmail"));
        String usuarioNombre = safe((String) request.getSession(false).getAttribute("usuarioNombre"));
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
                dashboardData.totalComunidades = dashboardDAO.contar("SELECT COUNT(*) FROM comunidad_vulnerable");
                dashboardData.totalBeneficiarios = dashboardDAO.contar(
                        "SELECT COALESCE(SUM(cantidad_beneficiarios),0) FROM comunidad_vulnerable"
                );
                dashboardData.totalCampaniasActivas = dashboardDAO.contar(
                        "SELECT COUNT(*) FROM campania WHERE activo = 1 AND UPPER(estado) = 'ACTIVA'"
                );
                dashboardData.donacionesRecientes = dashboardDAO.donacionesRecientes();
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
            request.getSession().setAttribute("mensaje", "Error: no se pudieron cargar datos del dashboard");
        }

        int tasaEntregas = 0;
        if (!donanteView && !comunidadView && dashboardData.entregasTotales > 0) {
            tasaEntregas = (dashboardData.entregasEntregadas * 100) / dashboardData.entregasTotales;
        }

        request.setAttribute("isDonanteView", dashboardData.donanteView);
        request.setAttribute("isComunidadView", dashboardData.comunidadView);
        request.setAttribute("perfilDonanteVinculado", dashboardData.perfilDonanteVinculado);
        request.setAttribute("fechaActual", dashboardData.fechaActual);
        request.setAttribute("totalDonaciones", dashboardData.totalDonaciones);
        request.setAttribute("totalComunidades", dashboardData.totalComunidades);
        request.setAttribute("totalInstituciones", dashboardData.totalInstituciones);
        request.setAttribute("totalCampaniasActivas", dashboardData.totalCampaniasActivas);
        request.setAttribute("totalBeneficiarios", dashboardData.totalBeneficiarios);
        request.setAttribute("voluntariosActivos", dashboardData.voluntariosActivos);
        request.setAttribute("tasaEntregas", tasaEntregas);
        request.setAttribute("campaniasCompletadas", dashboardData.campaniasCompletadas);
        request.setAttribute("totalCampanias", dashboardData.totalCampanias);
        request.setAttribute("donacionesRecientes", dashboardData.donacionesRecientes);
        request.setAttribute("misDonaciones", dashboardData.misDonaciones);
        request.setAttribute("misDonacionesPendientes", dashboardData.misDonacionesPendientes);
        request.setAttribute("montoDonado", dashboardData.montoDonado);

        request.getRequestDispatcher("/views/home.jsp").forward(request, response);
    }

    private boolean isDonanteRole(String rol) {
        return "Institucion Donante".equalsIgnoreCase(rol) || "Persona Natural".equalsIgnoreCase(rol);
    }

    private boolean isComunidadRole(String rol) {
        return "Comunidad".equalsIgnoreCase(rol);
    }

    private String safe(String value) {
        return value == null ? "" : value;
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
        int misDonaciones;
        int misDonacionesPendientes;
        String montoDonado = "0.00";
        List<String[]> donacionesRecientes = new ArrayList<String[]>();
    }
}