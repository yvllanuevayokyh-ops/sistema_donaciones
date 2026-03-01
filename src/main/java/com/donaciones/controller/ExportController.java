package com.donaciones.controller;

import com.donaciones.dao.CampaniaDAO;
import com.donaciones.dao.ComunidadDAO;
import com.donaciones.dao.DonacionDAO;
import com.donaciones.dao.DonanteDAO;
import com.donaciones.dao.EntregaDAO;
import com.donaciones.dao.ResultadoPaginado;
import com.donaciones.dao.VoluntarioDAO;
import com.donaciones.model.Campania;
import com.donaciones.model.ComunidadVulnerable;
import com.donaciones.model.Donacion;
import com.donaciones.model.Donante;
import com.donaciones.model.EntregaDonacion;
import com.donaciones.model.Voluntario;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ExportController {

    private static final int LIMIT = 10000;

    private final DonacionDAO donacionDAO = new DonacionDAO();
    private final DonanteDAO donanteDAO = new DonanteDAO();
    private final ComunidadDAO comunidadDAO = new ComunidadDAO();
    private final VoluntarioDAO voluntarioDAO = new VoluntarioDAO();
    private final CampaniaDAO campaniaDAO = new CampaniaDAO();
    private final EntregaDAO entregaDAO = new EntregaDAO();

    @GetMapping("/export/excel")
    public void exportar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }

        String modulo = safe(request.getParameter("modulo")).trim().toLowerCase();
        if (modulo.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        Workbook wb = null;
        try {
            switch (modulo) {
                case "donaciones":
                    wb = exportDonaciones(request);
                    break;
                case "comunidades":
                    wb = exportComunidades(request);
                    break;
                case "instituciones":
                    wb = exportInstituciones(request);
                    break;
                case "voluntarios":
                    wb = exportVoluntarios(request);
                    break;
                case "campanias":
                    wb = exportCampanias(request);
                    break;
                case "entregas":
                    wb = exportEntregas(request);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo exportar el modulo");
            response.sendRedirect(request.getContextPath() + "/" + modulo);
            return;
        }

        String filename = modulo + "_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")) + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        try (Workbook out = wb) {
            out.write(response.getOutputStream());
            response.flushBuffer();
        }
    }

    private Workbook exportDonaciones(HttpServletRequest request) {
        String rol = sessionVal(request, "usuarioRol");
        String q = safe(request.getParameter("q"));
        String estado = safe(request.getParameter("estado"));
        String situacion = safe(request.getParameter("situacion"));
        String tipoDonante = safe(request.getParameter("tipoDonante"));
        Integer activo = toActivoFilter(situacion);
        List<Donacion> rows;

        if (isDonanteRole(rol)) {
            Integer idDonante = donanteDAO.buscarDonanteIdPorUsuario(
                    sessionVal(request, "usuarioEmail"),
                    sessionVal(request, "usuarioNombre")
            );
            if (idDonante == null) {
                rows = new ArrayList<Donacion>();
            } else {
                ResultadoPaginado<Donacion> result = donacionDAO.buscarYPaginarPorDonante(
                        q, estado, activo, 1, LIMIT, idDonante
                );
                rows = safeList(result.getDatos());
            }
        } else {
            ResultadoPaginado<Donacion> result = donacionDAO.buscarYPaginar(
                    q, estado, activo, tipoDonante, 1, LIMIT
            );
            rows = safeList(result.getDatos());
        }

        String[] headers = {"ID", "Fecha", "Estado", "Tipo", "Monto", "Donante", "Campania", "Descripcion"};
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("Donaciones");
        writeHeader(sheet, headers, wb);
        int i = 1;
        for (Donacion d : rows) {
            Row r = sheet.createRow(i++);
            r.createCell(0).setCellValue(d.getIdDonacion() == null ? 0 : d.getIdDonacion());
            r.createCell(1).setCellValue(d.getFechaDonacion() == null ? "" : String.valueOf(d.getFechaDonacion()));
            r.createCell(2).setCellValue(safe(d.getEstadoDonacion()));
            r.createCell(3).setCellValue(safe(d.getTipoDonacion()));
            r.createCell(4).setCellValue(d.getMonto() == null ? 0d : d.getMonto().doubleValue());
            r.createCell(5).setCellValue(d.getDonante() == null ? "" : safe(d.getDonante().getNombre()));
            r.createCell(6).setCellValue(d.getCampania() == null ? "" : safe(d.getCampania().getNombre()));
            r.createCell(7).setCellValue(safe(d.getDescripcion()));
        }
        autosize(sheet, headers.length);
        return wb;
    }

    private Workbook exportComunidades(HttpServletRequest request) {
        String q = safe(request.getParameter("q"));
        String situacion = safe(request.getParameter("situacion"));
        Integer activo = toActivoFilter(situacion);
        ResultadoPaginado<ComunidadVulnerable> result = comunidadDAO.buscarYPaginar(q, activo, 1, LIMIT);
        List<ComunidadVulnerable> rows = safeList(result.getDatos());

        String[] headers = {"ID", "Nombre", "Ubicacion", "Beneficiarios", "Pais", "Estado"};
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("Comunidades");
        writeHeader(sheet, headers, wb);
        int i = 1;
        for (ComunidadVulnerable c : rows) {
            Row r = sheet.createRow(i++);
            r.createCell(0).setCellValue(c.getIdComunidad() == null ? 0 : c.getIdComunidad());
            r.createCell(1).setCellValue(safe(c.getNombre()));
            r.createCell(2).setCellValue(safe(c.getUbicacion()));
            r.createCell(3).setCellValue(c.getCantidadBeneficiarios() == null ? 0 : c.getCantidadBeneficiarios());
            r.createCell(4).setCellValue(c.getPais() == null ? "" : safe(c.getPais().getNombre()));
            r.createCell(5).setCellValue(Boolean.TRUE.equals(c.getActivo()) ? "Activo" : "Inactivo");
        }
        autosize(sheet, headers.length);
        return wb;
    }

    private Workbook exportInstituciones(HttpServletRequest request) {
        String q = safe(request.getParameter("q"));
        String situacion = safe(request.getParameter("situacion"));
        Integer activo = toActivoFilter(situacion);
        ResultadoPaginado<Donante> result = donanteDAO.buscarYPaginar(q, activo, 1, LIMIT);
        List<Donante> rows = safeList(result.getDatos());

        String[] headers = {"ID", "Nombre", "Tipo", "Email", "Telefono", "Pais", "Estado"};
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("Instituciones");
        writeHeader(sheet, headers, wb);
        int i = 1;
        for (Donante d : rows) {
            Row r = sheet.createRow(i++);
            r.createCell(0).setCellValue(d.getIdDonante() == null ? 0 : d.getIdDonante());
            r.createCell(1).setCellValue(safe(d.getNombre()));
            r.createCell(2).setCellValue(safe(d.getTipoDonante()));
            r.createCell(3).setCellValue(safe(d.getEmail()));
            r.createCell(4).setCellValue(safe(d.getTelefono()));
            r.createCell(5).setCellValue(d.getPais() == null ? "" : safe(d.getPais().getNombre()));
            r.createCell(6).setCellValue(Boolean.TRUE.equals(d.getActivo()) ? "Activo" : "Inactivo");
        }
        autosize(sheet, headers.length);
        return wb;
    }

    private Workbook exportVoluntarios(HttpServletRequest request) {
        String q = safe(request.getParameter("q"));
        String situacion = safe(request.getParameter("situacion"));
        Integer estado = toActivoFilter(situacion);
        ResultadoPaginado<Voluntario> result = voluntarioDAO.buscarYPaginar(q, estado, 1, LIMIT);
        List<Voluntario> rows = safeList(result.getDatos());

        String[] headers = {"ID", "Nombre", "Email", "Telefono", "Ingreso", "Campania", "Estado"};
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("Voluntarios");
        writeHeader(sheet, headers, wb);
        int i = 1;
        for (Voluntario v : rows) {
            Row r = sheet.createRow(i++);
            r.createCell(0).setCellValue(v.getIdVoluntario() == null ? 0 : v.getIdVoluntario());
            r.createCell(1).setCellValue(safe(v.getNombre()));
            r.createCell(2).setCellValue(safe(v.getEmail()));
            r.createCell(3).setCellValue(safe(v.getTelefono()));
            r.createCell(4).setCellValue(v.getFechaIngreso() == null ? "" : String.valueOf(v.getFechaIngreso()));
            r.createCell(5).setCellValue(v.getCampania() == null ? "" : safe(v.getCampania().getNombre()));
            r.createCell(6).setCellValue(Boolean.TRUE.equals(v.getEstado()) ? "Activo" : "Inactivo");
        }
        autosize(sheet, headers.length);
        return wb;
    }

    private Workbook exportCampanias(HttpServletRequest request) {
        String q = safe(request.getParameter("q"));
        String estado = safe(request.getParameter("estado"));
        String situacion = safe(request.getParameter("situacion"));
        Integer activo = toActivoFilter(situacion);
        ResultadoPaginado<Campania> result = campaniaDAO.buscarYPaginar(q, estado, activo, 1, LIMIT);
        List<Campania> rows = safeList(result.getDatos());

        String[] headers = {"ID", "Nombre", "Estado", "Inicio", "Fin", "Meta", "Comunidad"};
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("Campanias");
        writeHeader(sheet, headers, wb);
        int i = 1;
        for (Campania c : rows) {
            Row r = sheet.createRow(i++);
            r.createCell(0).setCellValue(c.getIdCampania() == null ? 0 : c.getIdCampania());
            r.createCell(1).setCellValue(safe(c.getNombre()));
            r.createCell(2).setCellValue(safe(c.getEstado()));
            r.createCell(3).setCellValue(c.getFechaInicio() == null ? "" : String.valueOf(c.getFechaInicio()));
            r.createCell(4).setCellValue(c.getFechaFin() == null ? "" : String.valueOf(c.getFechaFin()));
            r.createCell(5).setCellValue(c.getMontoObjetivo() == null ? 0d : c.getMontoObjetivo().doubleValue());
            r.createCell(6).setCellValue(c.getComunidad() == null ? "" : safe(c.getComunidad().getNombre()));
        }
        autosize(sheet, headers.length);
        return wb;
    }

    private Workbook exportEntregas(HttpServletRequest request) {
        String q = safe(request.getParameter("q"));
        String estado = safe(request.getParameter("estado"));
        ResultadoPaginado<EntregaDonacion> result = entregaDAO.buscarYPaginar(q, estado, 1, LIMIT);
        List<EntregaDonacion> rows = safeList(result.getDatos());
        Map<Integer, String> entregadores = entregaDAO.obtenerEntregadoresPorEntregas(extractEntregaIds(rows));
        Map<Integer, String> responsables = entregaDAO.obtenerResponsablesPorEntregas(extractEntregaIds(rows));

        String[] headers = {"ID", "Donacion", "Comunidad", "Estado", "Programada", "Entrego", "Recibio"};
        Workbook wb = new XSSFWorkbook();
        Sheet sheet = wb.createSheet("Entregas");
        writeHeader(sheet, headers, wb);
        int i = 1;
        for (EntregaDonacion e : rows) {
            Row r = sheet.createRow(i++);
            Integer idEntrega = e.getIdEntrega();
            r.createCell(0).setCellValue(idEntrega == null ? 0 : idEntrega);
            r.createCell(1).setCellValue(e.getDonacion() == null || e.getDonacion().getIdDonacion() == null ? "" : "DON-" + e.getDonacion().getIdDonacion());
            r.createCell(2).setCellValue(e.getComunidad() == null ? "" : safe(e.getComunidad().getNombre()));
            r.createCell(3).setCellValue(e.getEstadoEntrega() == null ? "" : safe(e.getEstadoEntrega().getDescripcion()));
            r.createCell(4).setCellValue(e.getFechaProgramada() == null ? "" : String.valueOf(e.getFechaProgramada()));
            r.createCell(5).setCellValue(idEntrega == null ? "" : safe(entregadores.get(idEntrega)));
            r.createCell(6).setCellValue(idEntrega == null ? "" : safe(responsables.get(idEntrega)));
        }
        autosize(sheet, headers.length);
        return wb;
    }

    private void writeHeader(Sheet sheet, String[] headers, Workbook wb) {
        CellStyle headerStyle = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = wb.createFont();
        font.setBold(true);
        headerStyle.setFont(font);

        Row row = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }
    }

    private void autosize(Sheet sheet, int cols) {
        for (int i = 0; i < cols; i++) {
            sheet.autoSizeColumn(i);
        }
    }

    private List<Integer> extractEntregaIds(List<EntregaDonacion> rows) {
        List<Integer> ids = new ArrayList<Integer>();
        if (rows == null) {
            return ids;
        }
        for (EntregaDonacion e : rows) {
            if (e != null && e.getIdEntrega() != null) {
                ids.add(e.getIdEntrega());
            }
        }
        return ids;
    }

    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("usuarioNombre") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    private boolean isDonanteRole(String rol) {
        return "Institucion Donante".equalsIgnoreCase(rol) || "Persona Natural".equalsIgnoreCase(rol);
    }

    private Integer toActivoFilter(String situacion) {
        if ("Inactivos".equalsIgnoreCase(situacion)) {
            return 0;
        }
        if ("Todos".equalsIgnoreCase(situacion)) {
            return null;
        }
        return 1;
    }

    private String sessionVal(HttpServletRequest request, String key) {
        if (request.getSession(false) == null) {
            return "";
        }
        Object value = request.getSession(false).getAttribute(key);
        return value == null ? "" : String.valueOf(value);
    }

    private <T> List<T> safeList(List<T> rows) {
        return rows == null ? new ArrayList<T>() : rows;
    }

    private String safe(String value) {
        return value == null ? "" : value;
    }
}
