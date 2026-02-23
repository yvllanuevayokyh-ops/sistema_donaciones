<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.donaciones.model.EntregaDonacion" %>
<%@ page import="com.donaciones.model.Donacion" %>
<%@ page import="com.donaciones.model.ComunidadVulnerable" %>
<%@ page import="com.donaciones.model.EstadoEntrega" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Entregas - Sistema Donaciones"/>
</jsp:include>
<%
    List<EntregaDonacion> entregas = (List<EntregaDonacion>) request.getAttribute("entregas");
    List<Donacion> donaciones = (List<Donacion>) request.getAttribute("donaciones");
    List<ComunidadVulnerable> comunidades = (List<ComunidadVulnerable>) request.getAttribute("comunidades");
    List<EstadoEntrega> estados = (List<EstadoEntrega>) request.getAttribute("estados");

    EntregaDonacion detalle = (EntregaDonacion) request.getAttribute("detalle");
    EntregaDonacion edicion = (EntregaDonacion) request.getAttribute("edicion");
    Boolean showFormObj = (Boolean) request.getAttribute("showForm");
    boolean showForm = showFormObj != null && showFormObj;

    Integer selectedId = (Integer) request.getAttribute("selectedId");
    String q = request.getAttribute("q") != null ? String.valueOf(request.getAttribute("q")) : "";
    String estado = request.getAttribute("estado") != null ? String.valueOf(request.getAttribute("estado")) : "Todos";
    String hoy = request.getAttribute("hoy") != null ? String.valueOf(request.getAttribute("hoy")) : "";

    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    Integer totalRowsObj = (Integer) request.getAttribute("totalRows");
    Integer pageSizeObj = (Integer) request.getAttribute("pageSize");
    int currentPage = currentPageObj != null ? currentPageObj : 1;
    int totalPages = totalPagesObj != null ? totalPagesObj : 1;
    int totalRows = totalRowsObj != null ? totalRowsObj : 0;
    int pageSize = pageSizeObj != null ? pageSizeObj : 6;

    Integer selectedDonacionId = edicion != null && edicion.getDonacion() != null
            ? edicion.getDonacion().getIdDonacion() : null;
    Integer selectedComunidadId = edicion != null && edicion.getComunidad() != null
            ? edicion.getComunidad().getIdComunidad() : null;
    Integer selectedEstadoId = edicion != null && edicion.getEstadoEntrega() != null
            ? edicion.getEstadoEntrega().getIdEstadoEntrega() : null;
    String fechaProgramada = edicion != null && edicion.getFechaProgramada() != null
            ? edicion.getFechaProgramada().toString() : hoy;
    String fechaEntrega = edicion != null && edicion.getFechaEntrega() != null
            ? edicion.getFechaEntrega().toString() : "";
    String observaciones = edicion != null && edicion.getObservaciones() != null ? edicion.getObservaciones() : "";

    String encQ = java.net.URLEncoder.encode(q, "UTF-8");
    String encEstado = java.net.URLEncoder.encode(estado, "UTF-8");
    String baseQuery = "q=" + encQ + "&estado=" + encEstado + "&page=" + currentPage;
    String newEntregaUrl = request.getContextPath() + "/entregas?nuevo=1&" + baseQuery;
    String backToListUrl = request.getContextPath() + "/entregas?" + baseQuery;
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
            <li class="active"><a href="${pageContext.request.contextPath}/entregas">Entregas</a></li>
            <li><a href="${pageContext.request.contextPath}/finanzas">Finanzas</a></li>
            <li><a href="#">Reportes</a></li>
        </ul>

        <a class="logout" href="${pageContext.request.contextPath}/logout">Cerrar Sesion</a>
    </aside>

    <main class="main">
        <jsp:include page="/includes/alerts.jsp"/>
        <div class="top-title">
            <div>
                <h1>Gestion de Entregas</h1>
                <p class="muted">Programa, actualiza y monitorea la entrega de donaciones</p>
            </div>
            <a class="btn-new" href="<%= newEntregaUrl %>">+ Nueva Entrega</a>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/entregas" class="toolbar toolbar-simple">
            <input type="hidden" name="page" value="1">
            <input type="text" name="q" value="<%= q %>" placeholder="Buscar por comunidad o descripcion de donacion">
            <select name="estado">
                <option value="Todos" <%= "Todos".equalsIgnoreCase(estado) ? "selected" : "" %>>Estado: Todos</option>
                <option value="Programado" <%= "Programado".equalsIgnoreCase(estado) ? "selected" : "" %>>Programado</option>
                <option value="En transito" <%= "En transito".equalsIgnoreCase(estado) ? "selected" : "" %>>En transito</option>
                <option value="Entregado" <%= "Entregado".equalsIgnoreCase(estado) ? "selected" : "" %>>Entregado</option>
                <option value="Cancelado" <%= "Cancelado".equalsIgnoreCase(estado) ? "selected" : "" %>>Cancelado</option>
            </select>
            <button type="submit">Buscar</button>
        </form>

        <section class="donaciones-layout">
            <%
                if (showForm) {
            %>
            <article class="panel">
                <h3><%= edicion != null ? "Editar Entrega" : "Nueva Entrega" %></h3>
                <form method="post" action="${pageContext.request.contextPath}/entregas" class="form-grid">
                    <input type="hidden" name="accion" value="<%= edicion != null ? "editar" : "crear" %>">
                    <%
                        if (edicion != null) {
                    %>
                    <input type="hidden" name="id_entrega" value="<%= edicion.getIdEntrega() %>">
                    <%
                        }
                    %>
                    <div>
                        <label>Donacion</label>
                        <select name="id_donacion" required>
                            <option value="">Selecciona donacion</option>
                            <%
                                if (donaciones != null) {
                                    for (Donacion d : donaciones) {
                                        Integer idD = d.getIdDonacion();
                                        String isSelected = selectedDonacionId != null && selectedDonacionId.equals(idD)
                                                ? "selected" : "";
                                        String codigo = "DON-" + String.format("%03d", idD);
                                        String donante = d.getDonante() != null && d.getDonante().getNombre() != null
                                                ? d.getDonante().getNombre() : "Sin donante";
                                        String desc = d.getDescripcion() != null ? d.getDescripcion() : "";
                            %>
                            <option value="<%= idD %>" <%= isSelected %>><%= codigo %> - <%= donante %> - <%= desc %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div>
                        <label>Comunidad</label>
                        <select name="id_comunidad" required>
                            <option value="">Selecciona comunidad</option>
                            <%
                                if (comunidades != null) {
                                    for (ComunidadVulnerable c : comunidades) {
                                        Integer idC = c.getIdComunidad();
                                        String isSelected = selectedComunidadId != null && selectedComunidadId.equals(idC)
                                                ? "selected" : "";
                            %>
                            <option value="<%= idC %>" <%= isSelected %>><%= c.getNombre() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div>
                        <label>Estado</label>
                        <select name="id_estado_entrega" required>
                            <%
                                if (estados != null) {
                                    for (EstadoEntrega e : estados) {
                                        Integer idE = e.getIdEstadoEntrega();
                                        String isSelected = selectedEstadoId != null && selectedEstadoId.equals(idE)
                                                ? "selected" : "";
                            %>
                            <option value="<%= idE %>" <%= isSelected %>><%= e.getDescripcion() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div>
                        <label>Fecha programada</label>
                        <input type="date" name="fecha_programada" value="<%= fechaProgramada %>">
                    </div>
                    <div>
                        <label>Fecha entrega</label>
                        <input type="date" name="fecha_entrega" value="<%= fechaEntrega %>">
                    </div>
                    <div class="full">
                        <label>Observaciones</label>
                        <textarea name="observaciones" rows="3"><%= observaciones %></textarea>
                    </div>
                    <div class="full form-actions">
                        <button type="submit"><%= edicion != null ? "Guardar Cambios" : "Guardar Entrega" %></button>
                        <a class="btn-cancel" href="<%= backToListUrl %>">Cancelar</a>
                    </div>
                </form>
            </article>
            <%
                } else {
            %>
            <article class="panel">
                <h3>Entregas (<%= totalRows %>)</h3>
                <p class="muted">Pagina <%= currentPage %> de <%= totalPages %> - <%= pageSize %> por pagina</p>
                <%
                    if (entregas != null && !entregas.isEmpty()) {
                        for (EntregaDonacion row : entregas) {
                            String estadoDesc = row.getEstadoEntrega() != null && row.getEstadoEntrega().getDescripcion() != null
                                    ? row.getEstadoEntrega().getDescripcion() : "Programado";
                            String badgeEstado = "badge-pendiente";
                            if ("Entregado".equalsIgnoreCase(estadoDesc)) {
                                badgeEstado = "badge-entregado";
                            } else if ("En transito".equalsIgnoreCase(estadoDesc)) {
                                badgeEstado = "badge-transito";
                            } else if ("Cancelado".equalsIgnoreCase(estadoDesc)) {
                                badgeEstado = "badge-cancelado";
                            }
                            boolean active = selectedId != null && row.getIdEntrega() != null && selectedId.equals(row.getIdEntrega());
                            String activeClass = active ? "ent-item active" : "ent-item";
                            String detailUrl = request.getContextPath() + "/entregas?id=" + row.getIdEntrega() + "&" + baseQuery;
                            String editUrl = request.getContextPath() + "/entregas?editarId=" + row.getIdEntrega() + "&" + baseQuery;
                            String codigo = "ENT-" + String.format("%03d", row.getIdEntrega());
                            String comunidadNombre = row.getComunidad() != null && row.getComunidad().getNombre() != null
                                    ? row.getComunidad().getNombre() : "Sin comunidad";
                            String donacionCodigo = row.getDonacion() != null && row.getDonacion().getIdDonacion() != null
                                    ? "DON-" + String.format("%03d", row.getDonacion().getIdDonacion()) : "Sin donacion";
                            String fechaProg = row.getFechaProgramada() != null ? row.getFechaProgramada().toString() : "-";
                            String fechaEnt = row.getFechaEntrega() != null ? row.getFechaEntrega().toString() : "-";
                %>
                <div class="<%= activeClass %>">
                    <div class="ent-item-head">
                        <a class="item-link" href="<%= detailUrl %>"><strong><%= codigo %></strong></a>
                        <span class="badge <%= badgeEstado %>"><%= estadoDesc %></span>
                    </div>
                    <p><%= comunidadNombre %></p>
                    <small><%= donacionCodigo %> - Programada: <%= fechaProg %> - Entrega: <%= fechaEnt %></small>
                    <div class="row-actions">
                        <a class="btn-mini btn-edit" href="<%= editUrl %>">Editar</a>
                        <%
                            if (!"Entregado".equalsIgnoreCase(estadoDesc)) {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/entregas" class="inline-form">
                            <input type="hidden" name="accion" value="cambiar_estado">
                            <input type="hidden" name="id" value="<%= row.getIdEntrega() %>">
                            <input type="hidden" name="id_estado_entrega" value="3">
                            <input type="hidden" name="fecha_entrega" value="<%= hoy %>">
                            <button class="btn-mini btn-ok" type="submit">Marcar Entregado</button>
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
                <p class="muted">No se encontraron entregas.</p>
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
                    <a class="page-link" href="${pageContext.request.contextPath}/entregas?page=<%= currentPage - 1 %>&q=<%= encQ %>&estado=<%= encEstado %>">Anterior</a>
                    <%
                        }
                        for (int p = start; p <= end; p++) {
                            String pageClass = p == currentPage ? "page-link current" : "page-link";
                    %>
                    <a class="<%= pageClass %>" href="${pageContext.request.contextPath}/entregas?page=<%= p %>&q=<%= encQ %>&estado=<%= encEstado %>"><%= p %></a>
                    <%
                        }
                        if (currentPage < totalPages) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/entregas?page=<%= currentPage + 1 %>&q=<%= encQ %>&estado=<%= encEstado %>">Siguiente</a>
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
                <h3>Detalle de Entrega</h3>
                <%
                    if (detalle != null) {
                        String estadoDet = detalle.getEstadoEntrega() != null && detalle.getEstadoEntrega().getDescripcion() != null
                                ? detalle.getEstadoEntrega().getDescripcion() : "Programado";
                        String donacionCodigo = detalle.getDonacion() != null && detalle.getDonacion().getIdDonacion() != null
                                ? "DON-" + String.format("%03d", detalle.getDonacion().getIdDonacion()) : "Sin donacion";
                        String donacionDesc = detalle.getDonacion() != null && detalle.getDonacion().getDescripcion() != null
                                ? detalle.getDonacion().getDescripcion() : "";
                        String tipoDonacionDet = detalle.getDonacion() != null && detalle.getDonacion().getTipoDonacion() != null
                                ? detalle.getDonacion().getTipoDonacion() : "";
                        String montoDonacionDet = "No monetaria";
                        if (detalle.getDonacion() != null && detalle.getDonacion().getMonto() != null) {
                            montoDonacionDet = "S/ " + String.format("%,.2f", detalle.getDonacion().getMonto());
                        }
                        String comunidadDet = detalle.getComunidad() != null && detalle.getComunidad().getNombre() != null
                                ? detalle.getComunidad().getNombre() : "";
                        String fechaProgDet = detalle.getFechaProgramada() != null ? detalle.getFechaProgramada().toString() : "-";
                        String fechaEntDet = detalle.getFechaEntrega() != null ? detalle.getFechaEntrega().toString() : "";
                        String obsDet = detalle.getObservaciones() != null ? detalle.getObservaciones() : "";
                %>
                <div class="detail-list">
                    <p><strong>Codigo:</strong> ENT-<%= String.format("%03d", detalle.getIdEntrega()) %></p>
                    <p><strong>Donacion:</strong> <%= donacionCodigo %></p>
                    <p><strong>Descripcion:</strong> <%= donacionDesc %></p>
                    <p><strong>Tipo:</strong> <%= tipoDonacionDet %></p>
                    <p><strong>Monto donado:</strong> <%= montoDonacionDet %></p>
                    <p><strong>Comunidad:</strong> <%= comunidadDet %></p>
                    <p><strong>Estado actual:</strong> <%= estadoDet %></p>
                    <p><strong>Fecha programada:</strong> <%= fechaProgDet %></p>
                    <p><strong>Fecha entrega:</strong> <%= fechaEntDet.isEmpty() ? "-" : fechaEntDet %></p>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/entregas" class="form-grid form-panel">
                    <input type="hidden" name="accion" value="cambiar_estado">
                    <input type="hidden" name="id" value="<%= detalle.getIdEntrega() %>">
                    <div>
                        <label>Actualizar estado</label>
                        <select name="id_estado_entrega" required>
                            <%
                                if (estados != null) {
                                    for (EstadoEntrega e : estados) {
                                        Integer idE = e.getIdEstadoEntrega();
                                        boolean isSelected = detalle.getEstadoEntrega() != null
                                                && idE != null
                                                && idE.equals(detalle.getEstadoEntrega().getIdEstadoEntrega());
                            %>
                            <option value="<%= idE %>" <%= isSelected ? "selected" : "" %>><%= e.getDescripcion() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div>
                        <label>Fecha entrega</label>
                        <input type="date" name="fecha_entrega" value="<%= fechaEntDet.isEmpty() ? hoy : fechaEntDet %>">
                    </div>
                    <div class="full">
                        <label>Observaciones</label>
                        <textarea name="observaciones" rows="3"><%= obsDet %></textarea>
                    </div>
                    <div class="full form-actions">
                        <button type="submit">Guardar Estado</button>
                    </div>
                </form>
                <%
                    } else {
                %>
                <p class="muted">Selecciona una entrega para ver detalles.</p>
                <%
                    }
                %>
            </aside>
        </section>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>
