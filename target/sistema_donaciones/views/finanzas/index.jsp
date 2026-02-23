<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Finanzas - Sistema Donaciones"/>
</jsp:include>
<%
    BigDecimal totalRecaudado = request.getAttribute("totalRecaudado") != null
            ? (BigDecimal) request.getAttribute("totalRecaudado") : BigDecimal.ZERO;
    BigDecimal totalEntregado = request.getAttribute("totalEntregado") != null
            ? (BigDecimal) request.getAttribute("totalEntregado") : BigDecimal.ZERO;
    BigDecimal saldoDisponible = request.getAttribute("saldoDisponible") != null
            ? (BigDecimal) request.getAttribute("saldoDisponible") : BigDecimal.ZERO;
    Integer totalDonaciones = request.getAttribute("totalDonaciones") != null
            ? (Integer) request.getAttribute("totalDonaciones") : 0;
    Integer totalEntregas = request.getAttribute("totalEntregas") != null
            ? (Integer) request.getAttribute("totalEntregas") : 0;

    List<Object[]> porCampania = (List<Object[]>) request.getAttribute("porCampania");
    List<Object[]> porComunidad = (List<Object[]>) request.getAttribute("porComunidad");
%>
<div class="dashboard-shell">
    <aside class="sidebar">
        <div>
            <h2>Donaciones</h2>
            <p>Sistema de Gestion</p>
        </div>

        <div class="user-box">
            <strong><%= session.getAttribute("usuarioNombre") %></strong>
            <span><%= session.getAttribute("usuarioRol") %></span>
        </div>

        <ul class="menu">
            <li><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/roles">Roles y Permisos</a></li>
            <li><a href="${pageContext.request.contextPath}/donaciones">Donaciones</a></li>
            <li><a href="${pageContext.request.contextPath}/comunidades">Comunidades</a></li>
            <li><a href="${pageContext.request.contextPath}/instituciones">Instituciones</a></li>
            <li><a href="${pageContext.request.contextPath}/voluntarios">Voluntarios</a></li>
            <li><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <li><a href="${pageContext.request.contextPath}/entregas">Entregas</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/finanzas">Finanzas</a></li>
            <li><a href="#">Reportes</a></li>
        </ul>

        <a class="logout" href="${pageContext.request.contextPath}/logout">Cerrar Sesion</a>
    </aside>

    <main class="main">
        <jsp:include page="/includes/alerts.jsp"/>
        <div class="top-title">
            <div>
                <h1>Gestion Financiera</h1>
                <p class="muted">Control del dinero recaudado, entregado y disponible</p>
            </div>
        </div>

        <section class="stats finance-stats">
            <article class="stat">
                <h3>Total Recaudado</h3>
                <strong>S/ <%= String.format("%,.2f", totalRecaudado) %></strong>
                <small>Donaciones monetarias activas</small>
            </article>
            <article class="stat">
                <h3>Total Entregado</h3>
                <strong>S/ <%= String.format("%,.2f", totalEntregado) %></strong>
                <small>Monto asociado a entregas completadas</small>
            </article>
            <article class="stat">
                <h3>Saldo Disponible</h3>
                <strong>S/ <%= String.format("%,.2f", saldoDisponible) %></strong>
                <small><%= totalDonaciones %> donaciones - <%= totalEntregas %> entregas</small>
            </article>
        </section>

        <section class="finance-grid">
            <article class="panel">
                <h3>Resumen por Campania</h3>
                <div class="table-wrap">
                    <table class="table-fin">
                        <thead>
                        <tr>
                            <th>Campania</th>
                            <th>Meta</th>
                            <th>Recaudado</th>
                            <th>Saldo</th>
                            <th>Donaciones</th>
                            <th>% Avance</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            if (porCampania != null && !porCampania.isEmpty()) {
                                for (Object[] row : porCampania) {
                                    String nombre = row[1] != null ? String.valueOf(row[1]) : "";
                                    BigDecimal meta = row[2] != null ? new BigDecimal(String.valueOf(row[2])) : BigDecimal.ZERO;
                                    BigDecimal recaudado = row[3] != null ? new BigDecimal(String.valueOf(row[3])) : BigDecimal.ZERO;
                                    BigDecimal saldo = row[4] != null ? new BigDecimal(String.valueOf(row[4])) : BigDecimal.ZERO;
                                    int donaciones = row[5] != null ? Integer.parseInt(String.valueOf(row[5])) : 0;
                                    int avance = 0;
                                    if (meta.compareTo(BigDecimal.ZERO) > 0) {
                                        avance = recaudado.multiply(new BigDecimal("100"))
                                                .divide(meta, 0, RoundingMode.HALF_UP).intValue();
                                        if (avance < 0) avance = 0;
                                        if (avance > 100) avance = 100;
                                    }
                        %>
                        <tr>
                            <td><%= nombre %></td>
                            <td>S/ <%= String.format("%,.2f", meta) %></td>
                            <td>S/ <%= String.format("%,.2f", recaudado) %></td>
                            <td>S/ <%= String.format("%,.2f", saldo) %></td>
                            <td><%= donaciones %></td>
                            <td>
                                <span class="badge badge-transito"><%= avance %>%</span>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="6" class="muted">No hay datos de campanias.</td>
                        </tr>
                        <%
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </article>

            <article class="panel">
                <h3>Resumen por Comunidad</h3>
                <div class="table-wrap">
                    <table class="table-fin">
                        <thead>
                        <tr>
                            <th>Comunidad</th>
                            <th>Beneficiarios</th>
                            <th>Entregas</th>
                            <th>Completadas</th>
                            <th>Monto recibido</th>
                        </tr>
                        </thead>
                        <tbody>
                        <%
                            if (porComunidad != null && !porComunidad.isEmpty()) {
                                for (Object[] row : porComunidad) {
                                    String nombre = row[1] != null ? String.valueOf(row[1]) : "";
                                    int beneficiarios = row[2] != null ? Integer.parseInt(String.valueOf(row[2])) : 0;
                                    int entregas = row[3] != null ? Integer.parseInt(String.valueOf(row[3])) : 0;
                                    int completadas = row[4] != null ? Integer.parseInt(String.valueOf(row[4])) : 0;
                                    BigDecimal monto = row[5] != null ? new BigDecimal(String.valueOf(row[5])) : BigDecimal.ZERO;
                        %>
                        <tr>
                            <td><%= nombre %></td>
                            <td><%= beneficiarios %></td>
                            <td><%= entregas %></td>
                            <td><%= completadas %></td>
                            <td>S/ <%= String.format("%,.2f", monto) %></td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" class="muted">No hay datos de comunidades.</td>
                        </tr>
                        <%
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </article>
        </section>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>
