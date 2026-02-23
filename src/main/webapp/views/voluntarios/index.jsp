<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.donaciones.model.Voluntario" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Voluntarios - Sistema Donaciones"/>
</jsp:include>
<%
    List<Voluntario> voluntarios = (List<Voluntario>) request.getAttribute("voluntarios");
    Voluntario detalle = (Voluntario) request.getAttribute("detalle");
    Voluntario edicion = (Voluntario) request.getAttribute("edicion");
    Map<Integer, Integer> entregasTotalesPorVoluntario = (Map<Integer, Integer>) request.getAttribute("entregasTotalesPorVoluntario");
    Map<Integer, Integer> entregasCompletadasPorVoluntario = (Map<Integer, Integer>) request.getAttribute("entregasCompletadasPorVoluntario");
    Integer entregasDetalleObj = (Integer) request.getAttribute("entregasDetalle");
    Integer entregasCompletadasDetalleObj = (Integer) request.getAttribute("entregasCompletadasDetalle");
    int entregasDetalle = entregasDetalleObj != null ? entregasDetalleObj : 0;
    int entregasCompletadasDetalle = entregasCompletadasDetalleObj != null ? entregasCompletadasDetalleObj : 0;

    Boolean showFormObj = (Boolean) request.getAttribute("showForm");
    boolean showForm = showFormObj != null && showFormObj;

    Integer selectedId = (Integer) request.getAttribute("selectedId");
    String q = request.getAttribute("q") != null ? String.valueOf(request.getAttribute("q")) : "";
    String situacion = request.getAttribute("situacion") != null ? String.valueOf(request.getAttribute("situacion")) : "Activos";
    String hoy = request.getAttribute("hoy") != null ? String.valueOf(request.getAttribute("hoy")) : "";

    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    Integer totalRowsObj = (Integer) request.getAttribute("totalRows");
    Integer pageSizeObj = (Integer) request.getAttribute("pageSize");
    int currentPage = currentPageObj != null ? currentPageObj : 1;
    int totalPages = totalPagesObj != null ? totalPagesObj : 1;
    int totalRows = totalRowsObj != null ? totalRowsObj : 0;
    int pageSize = pageSizeObj != null ? pageSizeObj : 4;

    String encQ = java.net.URLEncoder.encode(q, "UTF-8");
    String encSituacion = java.net.URLEncoder.encode(situacion, "UTF-8");
    String baseQuery = "q=" + encQ + "&situacion=" + encSituacion + "&page=" + currentPage;
    String newVoluntarioUrl = request.getContextPath() + "/voluntarios?nuevo=1&" + baseQuery;
    String backToListUrl = request.getContextPath() + "/voluntarios?" + baseQuery;
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
            <li class="active"><a href="${pageContext.request.contextPath}/voluntarios">Voluntarios</a></li>
            <li><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <li><a href="${pageContext.request.contextPath}/entregas">Entregas</a></li>
            <li><a href="${pageContext.request.contextPath}/finanzas">Finanzas</a></li>
            <li><a href="#">Reportes</a></li>
        </ul>

        <a class="logout" href="${pageContext.request.contextPath}/logout">Cerrar Sesion</a>
    </aside>

    <main class="main">
        <jsp:include page="/includes/alerts.jsp"/>
        <div class="top-title">
            <div>
                <h1>Voluntarios</h1>
                <p class="muted">Gestiona el equipo de voluntarios</p>
            </div>
            <a class="btn-new" href="<%= newVoluntarioUrl %>">+ Agregar Voluntario</a>
        </div>

        <section class="stats">
            <article class="stat">
                <h3>Voluntarios Activos</h3>
                <strong><%= request.getAttribute("totalActivos") %></strong>
                <small>En estado activo</small>
            </article>
            <article class="stat">
                <h3>Entregas Completadas</h3>
                <strong><%= request.getAttribute("entregasCompletadas") %></strong>
                <small>Asignaciones cerradas</small>
            </article>
            <article class="stat">
                <h3>Horas de Voluntariado</h3>
                <strong><%= request.getAttribute("horasVoluntariado") %></strong>
                <small>Estimado (4h por entrega)</small>
            </article>
        </section>

        <form method="get" action="${pageContext.request.contextPath}/voluntarios" class="toolbar toolbar-simple">
            <input type="hidden" name="page" value="1">
            <input type="text" name="q" value="<%= q %>" placeholder="Buscar voluntarios por nombre, email o telefono">
            <select name="situacion">
                <option value="Activos" <%= "Activos".equalsIgnoreCase(situacion) ? "selected" : "" %>>Activos</option>
                <option value="Inactivos" <%= "Inactivos".equalsIgnoreCase(situacion) ? "selected" : "" %>>Inactivos</option>
                <option value="Todos" <%= "Todos".equalsIgnoreCase(situacion) ? "selected" : "" %>>Todos</option>
            </select>
            <button type="submit">Buscar</button>
        </form>

        <section class="donaciones-layout">
            <%
                if (showForm) {
                    String fechaIngreso = edicion != null && edicion.getFechaIngreso() != null ? edicion.getFechaIngreso().toString() : hoy;
            %>
            <article class="panel">
                <h3><%= edicion != null ? "Editar Voluntario" : "Agregar Voluntario" %></h3>
                <form method="post" action="${pageContext.request.contextPath}/voluntarios" class="form-grid">
                    <input type="hidden" name="accion" value="<%= edicion != null ? "editar" : "crear" %>">
                    <%
                        if (edicion != null) {
                    %>
                    <input type="hidden" name="id_voluntario" value="<%= edicion.getIdVoluntario() %>">
                    <%
                        }
                    %>
                    <div>
                        <label>Nombre</label>
                        <input type="text" name="nombre" required value="<%= edicion != null && edicion.getNombre() != null ? edicion.getNombre() : "" %>">
                    </div>
                    <div>
                        <label>Email</label>
                        <input type="email" name="email" value="<%= edicion != null && edicion.getEmail() != null ? edicion.getEmail() : "" %>">
                    </div>
                    <div>
                        <label>Telefono</label>
                        <input type="text" name="telefono" value="<%= edicion != null && edicion.getTelefono() != null ? edicion.getTelefono() : "" %>">
                    </div>
                    <div>
                        <label>Fecha ingreso</label>
                        <input type="date" name="fecha_ingreso" required value="<%= fechaIngreso %>">
                    </div>
                    <div class="full form-actions">
                        <button type="submit"><%= edicion != null ? "Guardar Cambios" : "Guardar Voluntario" %></button>
                        <a class="btn-cancel" href="<%= backToListUrl %>">Cancelar</a>
                    </div>
                </form>
            </article>
            <%
                } else {
            %>
            <article class="panel">
                <h3>Voluntarios (<%= totalRows %>)</h3>
                <p class="muted">Pagina <%= currentPage %> de <%= totalPages %> - <%= pageSize %> por pagina</p>
                <%
                    if (voluntarios != null && !voluntarios.isEmpty()) {
                        for (Voluntario row : voluntarios) {
                            boolean isActivo = row.getEstado() != null && row.getEstado();
                            String badgeActivo = isActivo ? "badge-entregado" : "badge-cancelado";
                            boolean active = selectedId != null && row.getIdVoluntario() != null && selectedId.equals(row.getIdVoluntario());
                            String activeClass = active ? "vol-item active" : "vol-item";
                            String detailUrl = request.getContextPath() + "/voluntarios?id=" + row.getIdVoluntario() + "&" + baseQuery;
                            String editUrl = request.getContextPath() + "/voluntarios?editarId=" + row.getIdVoluntario() + "&" + baseQuery;
                            int entregasTotales = entregasTotalesPorVoluntario != null && row.getIdVoluntario() != null
                                    ? entregasTotalesPorVoluntario.getOrDefault(row.getIdVoluntario(), 0) : 0;
                            String fechaIngreso = row.getFechaIngreso() != null ? row.getFechaIngreso().toString() : "";
                %>
                <div class="<%= activeClass %>">
                    <div class="vol-item-head">
                        <a class="item-link" href="<%= detailUrl %>"><strong><%= row.getNombre() != null ? row.getNombre() : "" %></strong></a>
                        <span class="badge <%= badgeActivo %>"><%= isActivo ? "Activo" : "Inactivo" %></span>
                        <span class="date"><%= entregasTotales %> entregas</span>
                    </div>
                    <p><%= row.getEmail() != null ? row.getEmail() : "" %></p>
                    <small><%= row.getTelefono() != null ? row.getTelefono() : "" %> - Ingreso: <%= fechaIngreso %></small>
                    <div class="row-actions">
                        <a class="btn-mini btn-edit" href="<%= editUrl %>">Editar</a>
                        <%
                            if (isActivo) {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/voluntarios" class="inline-form">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= row.getIdVoluntario() %>">
                            <button class="btn-mini btn-danger" type="submit">Eliminar</button>
                        </form>
                        <%
                            } else {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/voluntarios" class="inline-form">
                            <input type="hidden" name="accion" value="restaurar">
                            <input type="hidden" name="id" value="<%= row.getIdVoluntario() %>">
                            <button class="btn-mini btn-ok" type="submit">Restaurar</button>
                        </form>
                        <%
                            }
                        %>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <p class="muted">No se encontraron voluntarios.</p>
                <%
                    }
                %>

                <%
                    if (totalPages > 1) {
                        int start = Math.max(1, currentPage - 2);
                        int end = Math.min(totalPages, currentPage + 2);
                %>
                <div class="pagination">
                    <%
                        if (currentPage > 1) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/voluntarios?page=<%= currentPage - 1 %>&q=<%= encQ %>&situacion=<%= encSituacion %>">Anterior</a>
                    <%
                        }
                        for (int p = start; p <= end; p++) {
                            String pageClass = p == currentPage ? "page-link current" : "page-link";
                    %>
                    <a class="<%= pageClass %>" href="${pageContext.request.contextPath}/voluntarios?page=<%= p %>&q=<%= encQ %>&situacion=<%= encSituacion %>"><%= p %></a>
                    <%
                        }
                        if (currentPage < totalPages) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/voluntarios?page=<%= currentPage + 1 %>&q=<%= encQ %>&situacion=<%= encSituacion %>">Siguiente</a>
                    <%
                        }
                    %>
                </div>
                <%
                    }
                %>
            </article>
            <%
                }
            %>

            <aside class="panel">
                <h3>Informacion del Voluntario</h3>
                <%
                    if (detalle != null) {
                        String fechaIngreso = detalle.getFechaIngreso() != null ? detalle.getFechaIngreso().toString() : "";
                        boolean activo = detalle.getEstado() != null && detalle.getEstado();
                %>
                <div class="detail-list">
                    <p><strong>Nombre:</strong> <%= detalle.getNombre() != null ? detalle.getNombre() : "" %></p>
                    <p><strong>Email:</strong> <%= detalle.getEmail() != null ? detalle.getEmail() : "" %></p>
                    <p><strong>Telefono:</strong> <%= detalle.getTelefono() != null ? detalle.getTelefono() : "" %></p>
                    <p><strong>Ingreso:</strong> <%= fechaIngreso %></p>
                    <p><strong>Estado:</strong> <%= activo ? "Activo" : "Inactivo" %></p>
                    <p><strong>Entregas:</strong> <%= entregasDetalle %></p>
                    <p><strong>Completadas:</strong> <%= entregasCompletadasDetalle %></p>
                    <p><strong>Horas estimadas:</strong> <%= entregasCompletadasDetalle * 4 %></p>
                </div>
                <%
                    } else {
                %>
                <p class="muted">Selecciona un voluntario para ver detalles.</p>
                <%
                    }
                %>
            </aside>
        </section>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>
