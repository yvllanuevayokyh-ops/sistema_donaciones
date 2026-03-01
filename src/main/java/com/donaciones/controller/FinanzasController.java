package com.donaciones.controller;

import com.donaciones.dao.CampaniaDAO;
import com.donaciones.dao.ComunidadDAO;
import com.donaciones.dao.FinanzasDAO;
import com.donaciones.model.Campania;
import com.donaciones.model.ComunidadVulnerable;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FinanzasController {

    private final FinanzasDAO finanzasDAO = new FinanzasDAO();
    private final CampaniaDAO campaniaDAO = new CampaniaDAO();
    private final ComunidadDAO comunidadDAO = new ComunidadDAO();

    @GetMapping("/finanzas")
    public String doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return null;
        }
        if (isDonanteRole(request) || isComunidadRole(request)) {
            request.getSession().setAttribute("mensaje", "Acceso restringido");
            return "redirect:/home";
        }

        BigDecimal totalRecaudado = BigDecimal.ZERO;
        BigDecimal totalEntregado = BigDecimal.ZERO;
        BigDecimal saldoDisponible = BigDecimal.ZERO;
        int totalDonaciones = 0;
        int totalEntregas = 0;
        java.util.Date fechaReporteDateTime = new java.util.Date();
        String ultimaDonacion = formatDateTime(fechaReporteDateTime);
        String ultimaEntrega = formatDateTime(fechaReporteDateTime);
        List<Object[]> porCampania = new ArrayList<Object[]>();
        List<Object[]> porComunidad = new ArrayList<Object[]>();
        List<Campania> campanias = new ArrayList<Campania>();
        List<ComunidadVulnerable> comunidades = new ArrayList<ComunidadVulnerable>();
        Integer idCampania = parseInteger(request.getParameter("id_campania"));
        Integer idComunidad = parseInteger(request.getParameter("id_comunidad"));

        try {
            Object[] resumen = finanzasDAO.resumenGeneral();
            if (resumen != null && resumen.length >= 4) {
                totalRecaudado = toBD(resumen[0]);
                totalEntregado = toBD(resumen[1]);
                totalDonaciones = toInt(resumen[2]);
                totalEntregas = toInt(resumen[3]);
                saldoDisponible = totalRecaudado.subtract(totalEntregado);
                if (resumen.length >= 6) {
                    ultimaDonacion = formatDateTime(resumen[4]);
                    ultimaEntrega = formatDateTime(resumen[5]);
                }
            }

            porCampania = safeList(finanzasDAO.resumenPorCampania());
            porComunidad = safeList(finanzasDAO.resumenPorComunidad());
            campanias = safeList(campaniaDAO.listarActivas());
            comunidades = safeList(comunidadDAO.listarComunidadesCatalogo());

            if (idCampania != null) {
                porCampania = filtrarPorId(porCampania, idCampania);
            }
            if (idComunidad != null) {
                porComunidad = filtrarPorId(porComunidad, idComunidad);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo cargar finanzas");
        }

        request.setAttribute("totalRecaudado", totalRecaudado);
        request.setAttribute("totalEntregado", totalEntregado);
        request.setAttribute("saldoDisponible", saldoDisponible);
        request.setAttribute("totalDonaciones", totalDonaciones);
        request.setAttribute("totalEntregas", totalEntregas);
        request.setAttribute("ultimaDonacion", ultimaDonacion);
        request.setAttribute("ultimaEntrega", ultimaEntrega);
        request.setAttribute("porCampania", porCampania);
        request.setAttribute("porComunidad", porComunidad);
        request.setAttribute("campanias", campanias);
        request.setAttribute("comunidades", comunidades);
        request.setAttribute("idCampania", idCampania);
        request.setAttribute("idComunidad", idComunidad);
        request.setAttribute("fechaReporteDateTime", fechaReporteDateTime);
        request.setAttribute("ordenCampania", "Mayor recaudado");
        request.setAttribute("ordenComunidad", "Mayor monto recibido");
        request.setAttribute("fechaReporte", LocalDate.now().toString());
        request.setAttribute("horaReporte", LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss")));

        return "finanzas/index";
    }

    @GetMapping("/finanzas/excel")
    public void descargarExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (!isAuthenticated(request, response)) {
            return;
        }
        if (isDonanteRole(request) || isComunidadRole(request)) {
            request.getSession().setAttribute("mensaje", "Acceso restringido");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        Integer idCampania = parseInteger(request.getParameter("id_campania"));
        Integer idComunidad = parseInteger(request.getParameter("id_comunidad"));

        Object[] resumen;
        List<Object[]> porCampania;
        List<Object[]> porComunidad;
        try {
            resumen = finanzasDAO.resumenGeneral();
            porCampania = safeList(finanzasDAO.resumenPorCampania());
            porComunidad = safeList(finanzasDAO.resumenPorComunidad());
            if (idCampania != null) {
                porCampania = filtrarPorId(porCampania, idCampania);
            }
            if (idComunidad != null) {
                porComunidad = filtrarPorId(porComunidad, idComunidad);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("mensaje", "Error: no se pudo generar el Excel de finanzas");
            response.sendRedirect(request.getContextPath() + "/finanzas");
            return;
        }

        String filename = "finanzas_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")) + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (Workbook wb = buildWorkbook(resumen, porCampania, porComunidad)) {
            wb.write(response.getOutputStream());
            response.flushBuffer();
        }
    }

    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || request.getSession(false).getAttribute("usuarioNombre") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    private boolean isDonanteRole(HttpServletRequest request) {
        Object roleObj = request.getSession(false) != null ? request.getSession(false).getAttribute("usuarioRol") : null;
        String rol = roleObj == null ? "" : String.valueOf(roleObj);
        return "Institucion Donante".equalsIgnoreCase(rol) || "Persona Natural".equalsIgnoreCase(rol);
    }

    private boolean isComunidadRole(HttpServletRequest request) {
        Object roleObj = request.getSession(false) != null ? request.getSession(false).getAttribute("usuarioRol") : null;
        String rol = roleObj == null ? "" : String.valueOf(roleObj);
        return "Comunidad".equalsIgnoreCase(rol);
    }

    private int toInt(Object value) {
        if (value == null) {
            return 0;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    private BigDecimal toBD(Object value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        }
        if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue());
        }
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (Exception ex) {
            return BigDecimal.ZERO;
        }
    }

    private <T> List<T> safeList(List<T> rows) {
        return rows == null ? new ArrayList<T>() : rows;
    }

    private String formatDateTime(Object value) {
        if (value == null) {
            return "";
        }
        try {
            java.util.Date date = (java.util.Date) value;
            return new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(date);
        } catch (Exception ex) {
            return String.valueOf(value);
        }
    }

    private Workbook buildWorkbook(Object[] resumen, List<Object[]> porCampania, List<Object[]> porComunidad) {
        Workbook wb = new XSSFWorkbook();
        DataFormat dataFormat = wb.createDataFormat();

        CellStyle headerStyle = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font headerFont = wb.createFont();
        headerFont.setBold(true);
        headerStyle.setFont(headerFont);

        CellStyle moneyStyle = wb.createCellStyle();
        moneyStyle.setDataFormat(dataFormat.getFormat("#,##0.00"));

        CellStyle dateStyle = wb.createCellStyle();
        dateStyle.setDataFormat(dataFormat.getFormat("dd/MM/yyyy HH:mm"));

        buildResumenSheet(wb, resumen, headerStyle, moneyStyle, dateStyle);
        buildCampaniaSheet(wb, porCampania, headerStyle, moneyStyle, dateStyle);
        buildComunidadSheet(wb, porComunidad, headerStyle, moneyStyle, dateStyle);
        return wb;
    }

    private void buildResumenSheet(Workbook wb, Object[] resumen, CellStyle headerStyle, CellStyle moneyStyle, CellStyle dateStyle) {
        Sheet sheet = wb.createSheet("Resumen");
        int rowIndex = 0;

        Row titleRow = sheet.createRow(rowIndex++);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("Reporte financiero");
        titleCell.setCellStyle(headerStyle);

        Row genRow = sheet.createRow(rowIndex++);
        genRow.createCell(0).setCellValue("Generado");
        genRow.createCell(1).setCellValue(LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")));

        rowIndex++;

        BigDecimal totalRecaudado = resumen != null && resumen.length > 0 ? toBD(resumen[0]) : BigDecimal.ZERO;
        BigDecimal totalEntregado = resumen != null && resumen.length > 1 ? toBD(resumen[1]) : BigDecimal.ZERO;
        BigDecimal saldo = totalRecaudado.subtract(totalEntregado);
        int totalDonaciones = resumen != null && resumen.length > 2 ? toInt(resumen[2]) : 0;
        int totalEntregas = resumen != null && resumen.length > 3 ? toInt(resumen[3]) : 0;
        Date ultimaDonacion = resumen != null && resumen.length > 4 ? toDate(resumen[4]) : null;
        Date ultimaEntrega = resumen != null && resumen.length > 5 ? toDate(resumen[5]) : null;

        rowIndex = addMoneyRow(sheet, rowIndex, "Total recaudado", totalRecaudado.doubleValue(), moneyStyle);
        rowIndex = addMoneyRow(sheet, rowIndex, "Total entregado", totalEntregado.doubleValue(), moneyStyle);
        rowIndex = addMoneyRow(sheet, rowIndex, "Saldo disponible", saldo.doubleValue(), moneyStyle);
        rowIndex = addIntRow(sheet, rowIndex, "Total donaciones", totalDonaciones);
        rowIndex = addIntRow(sheet, rowIndex, "Total entregas", totalEntregas);
        rowIndex = addDateRow(sheet, rowIndex, "Ultima donacion", ultimaDonacion, dateStyle);
        addDateRow(sheet, rowIndex, "Ultima entrega", ultimaEntrega, dateStyle);

        sheet.autoSizeColumn(0);
        sheet.autoSizeColumn(1);
    }

    private void buildCampaniaSheet(Workbook wb, List<Object[]> rows, CellStyle headerStyle, CellStyle moneyStyle, CellStyle dateStyle) {
        Sheet sheet = wb.createSheet("Campanias");
        String[] headers = new String[]{
                "Orden", "Campania", "Meta", "Recaudado", "Saldo", "Donaciones", "Ult. donacion", "Ult. entrega"
        };
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        int rowIndex = 1;
        for (Object[] row : rows) {
            Row excelRow = sheet.createRow(rowIndex);
            excelRow.createCell(0).setCellValue(rowIndex);
            excelRow.createCell(1).setCellValue(toStringValue(row, 1));
            setMoneyCell(excelRow.createCell(2), rowValue(row, 2), moneyStyle);
            setMoneyCell(excelRow.createCell(3), rowValue(row, 3), moneyStyle);
            setMoneyCell(excelRow.createCell(4), rowValue(row, 4), moneyStyle);
            excelRow.createCell(5).setCellValue(toInt(rowValue(row, 5)));
            setDateCell(excelRow.createCell(6), toDate(rowValue(row, 6)), dateStyle);
            setDateCell(excelRow.createCell(7), toDate(rowValue(row, 7)), dateStyle);
            rowIndex++;
        }

        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }
    }

    private void buildComunidadSheet(Workbook wb, List<Object[]> rows, CellStyle headerStyle, CellStyle moneyStyle, CellStyle dateStyle) {
        Sheet sheet = wb.createSheet("Comunidades");
        String[] headers = new String[]{
                "Orden", "Comunidad", "Beneficiarios", "Entregas", "Completadas", "Monto recibido", "Ult. programada", "Ult. entrega"
        };
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }

        int rowIndex = 1;
        for (Object[] row : rows) {
            Row excelRow = sheet.createRow(rowIndex);
            excelRow.createCell(0).setCellValue(rowIndex);
            excelRow.createCell(1).setCellValue(toStringValue(row, 1));
            excelRow.createCell(2).setCellValue(toInt(rowValue(row, 2)));
            excelRow.createCell(3).setCellValue(toInt(rowValue(row, 3)));
            excelRow.createCell(4).setCellValue(toInt(rowValue(row, 4)));
            setMoneyCell(excelRow.createCell(5), rowValue(row, 5), moneyStyle);
            setDateCell(excelRow.createCell(6), toDate(rowValue(row, 6)), dateStyle);
            setDateCell(excelRow.createCell(7), toDate(rowValue(row, 7)), dateStyle);
            rowIndex++;
        }

        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }
    }

    private int addMoneyRow(Sheet sheet, int rowIndex, String label, double value, CellStyle moneyStyle) {
        Row row = sheet.createRow(rowIndex);
        row.createCell(0).setCellValue(label);
        Cell valueCell = row.createCell(1);
        valueCell.setCellValue(value);
        valueCell.setCellStyle(moneyStyle);
        return rowIndex + 1;
    }

    private int addIntRow(Sheet sheet, int rowIndex, String label, int value) {
        Row row = sheet.createRow(rowIndex);
        row.createCell(0).setCellValue(label);
        row.createCell(1).setCellValue(value);
        return rowIndex + 1;
    }

    private int addDateRow(Sheet sheet, int rowIndex, String label, Date value, CellStyle dateStyle) {
        Row row = sheet.createRow(rowIndex);
        row.createCell(0).setCellValue(label);
        setDateCell(row.createCell(1), value, dateStyle);
        return rowIndex + 1;
    }

    private void setMoneyCell(Cell cell, Object rawValue, CellStyle style) {
        cell.setCellValue(toBD(rawValue).doubleValue());
        cell.setCellStyle(style);
    }

    private void setDateCell(Cell cell, Date date, CellStyle style) {
        if (date != null) {
            cell.setCellValue(date);
            cell.setCellStyle(style);
        } else {
            cell.setCellValue("Sin registro");
        }
    }

    private Object rowValue(Object[] row, int index) {
        if (row == null || index < 0 || index >= row.length) {
            return null;
        }
        return row[index];
    }

    private String toStringValue(Object[] row, int index) {
        Object value = rowValue(row, index);
        return value == null ? "" : String.valueOf(value);
    }

    private Date toDate(Object value) {
        if (value instanceof Date) {
            return (Date) value;
        }
        if (value instanceof LocalDateTime) {
            return Date.from(((LocalDateTime) value).atZone(ZoneId.systemDefault()).toInstant());
        }
        if (value instanceof LocalDate) {
            return Date.from(((LocalDate) value).atStartOfDay(ZoneId.systemDefault()).toInstant());
        }
        if (value instanceof Number) {
            return new Date(((Number) value).longValue());
        }
        if (value != null) {
            String text = String.valueOf(value).trim();
            if (text.isEmpty()) {
                return null;
            }
            Date parsed = parseDateText(text);
            if (parsed != null) {
                return parsed;
            }
        }
        return null;
    }

    private Date parseDateText(String text) {
        DateTimeFormatter[] dateTimeFormats = new DateTimeFormatter[]{
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"),
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"),
                DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"),
                DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")
        };
        for (DateTimeFormatter formatter : dateTimeFormats) {
            try {
                LocalDateTime dt = LocalDateTime.parse(text, formatter);
                return Date.from(dt.atZone(ZoneId.systemDefault()).toInstant());
            } catch (DateTimeParseException ignored) {
            }
        }

        DateTimeFormatter[] dateFormats = new DateTimeFormatter[]{
                DateTimeFormatter.ofPattern("yyyy-MM-dd"),
                DateTimeFormatter.ofPattern("dd/MM/yyyy")
        };
        for (DateTimeFormatter formatter : dateFormats) {
            try {
                LocalDate d = LocalDate.parse(text, formatter);
                return Date.from(d.atStartOfDay(ZoneId.systemDefault()).toInstant());
            } catch (DateTimeParseException ignored) {
            }
        }
        return null;
    }

    private Integer parseInteger(String value) {
        try {
            if (value == null || value.isBlank()) {
                return null;
            }
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private List<Object[]> filtrarPorId(List<Object[]> rows, Integer id) {
        List<Object[]> filtrado = new ArrayList<Object[]>();
        if (rows == null || id == null) {
            return filtrado;
        }
        for (Object[] row : rows) {
            if (row != null && row.length > 0 && toInt(row[0]) == id) {
                filtrado.add(row);
            }
        }
        return filtrado;
    }
}

