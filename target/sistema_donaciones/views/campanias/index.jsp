<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="com.donaciones.model.Campania" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Campanias - Sistema Donaciones"/>
</jsp:include>
<%
    List<Campania> campanias = (List<Campania>) request.getAttribute("campanias");
    Campania detalle = (Campania) request.getAttribute("detalle");
    Campania edicion = (Campania) request.getAttribute("edicion");
    Map<Integer, BigDecimal> recaudadoPorCampania = (Map<Integer, BigDecimal>) request.getAttribute("recaudadoPorCampania");
    Map<Integer, Integer> donacionesPorCampania = (Map<Integer, Integer>) request.getAttribute("donacionesPorCampania");
    BigDecimal recaudadoDetalle = (BigDecimal) request.getAttribute("recaudadoDetalle");
    Integer totalDonacionesDetalleObj = (Integer) request.getAttribute("totalDonacionesDetalle");
    int totalDonacionesDetalle = totalDonacionesDetalleObj != null ? totalDonacionesDetalleObj : 0;

    Boolean showFormObj = (Boolean) request.getAttribute("showForm");
    boolean showForm = showFormObj != null && showFormObj;
    Boolean isDonanteViewObj = (Boolean) request.getAttribute("isDonanteView");
    boolean isDonanteView = isDonanteViewObj != null && isDonanteViewObj;
    Boolean isComunidadViewObj = (Boolean) request.getAttribute("isComunidadView");
    boolean isComunidadView = isComunidadViewObj != null && isComunidadViewObj;
    boolean soloLectura = isDonanteView || isComunidadView;

    Integer selectedId = (Integer) request.getAttribute("selectedId");
    String q = request.getAttribute("q") != null ? String.valueOf(request.getAttribute("q")) : "";
    String estado = request.getAttribute("estado") != null ? String.valueOf(request.getAttribute("estado")) : "Todas";
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
    String encEstado = java.net.URLEncoder.encode(estado, "UTF-8");
    String encSituacion = java.net.URLEncoder.encode(situacion, "UTF-8");
    String baseQuery = "q=" + encQ + "&estado=" + encEstado + "&situacion=" + encSituacion + "&page=" + currentPage;
    String newCampaniaUrl = request.getContextPath() + "/campanias?nuevo=1&" + baseQuery;
    String backToListUrl = request.getContextPath() + "/campanias?" + baseQuery;
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
            <%
                if (isDonanteView) {
            %>
            <li><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/donaciones">Mis Donaciones</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <%
                } else if (isComunidadView) {
            %>
            <li><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/comunidades">Comunidades</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <%
                } else {
            %>
            <li><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/roles">Roles y Permisos</a></li>
            <li><a href="${pageContext.request.contextPath}/donaciones">Donaciones</a></li>
            <li><a href="${pageContext.request.contextPath}/comunidades">Comunidades</a></li>
            <li><a href="${pageContext.request.contextPath}/instituciones">Instituciones</a></li>
            <li><a href="${pageContext.request.contextPath}/voluntarios">Voluntarios</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <li><a href="${pageContext.request.contextPath}/entregas">Entregas</a></li>
            <li><a href="${pageContext.request.contextPath}/finanzas">Finanzas</a></li>
            <li><a href="#">Reportes</a></li>
            <%
                }
            %>
        </ul>

        <a class="logout" href="${pageContext.request.contextPath}/logout">Cerrar Sesion</a>
    </aside>

    <main class="main">
        <jsp:include page="/includes/alerts.jsp"/>
        <div class="top-title">
            <div>
                <h1>Campanias de Donacion</h1>
                <p class="muted"><%= soloLectura
                        ? "Consulta campanias y su avance de recaudacion"
                        : "Gestiona campanias con busqueda, paginacion y eliminacion logica" %></p>
            </div>
            <%
                if (!soloLectura) {
            %>
            <a class="btn-new" href="<%= newCampaniaUrl %>">+ Nueva Campania</a>
            <%
                }
            %>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/campanias" class="toolbar">
            <input type="hidden" name="page" value="1">
            <input type="text" name="q" value="<%= q %>" placeholder="Buscar campanias por nombre o descripcion">
            <select name="estado">
                <option value="Todas" <%= "Todas".equalsIgnoreCase(estado) ? "selected" : "" %>>Estado: Todas</option>
                <option value="Activa" <%= "Activa".equalsIgnoreCase(estado) ? "selected" : "" %>>Activa</option>
                <option value="Pausada" <%= "Pausada".equalsIgnoreCase(estado) ? "selected" : "" %>>Pausada</option>
                <option value="Finalizada" <%= "Finalizada".equalsIgnoreCase(estado) ? "selected" : "" %>>Finalizada</option>
            </select>
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
                    String estadoEdit = edicion != null && edicion.getEstado() != null ? edicion.getEstado() : "Activa";
                    String fechaInicio = edicion != null && edicion.getFechaInicio() != null ? edicion.getFechaInicio().toString() : hoy;
                    String fechaFin = edicion != null && edicion.getFechaFin() != null ? edicion.getFechaFin().toString() : "";
                    String montoObjetivo = edicion != null && edicion.getMontoObjetivo() != null
                            ? edicion.getMontoObjetivo().toPlainString() : "5000.00";
                    BigDecimal recaudadoEdit = BigDecimal.ZERO;
                    if (edicion != null && edicion.getIdCampania() != null && recaudadoPorCampania != null) {
                        recaudadoEdit = recaudadoPorCampania.getOrDefault(edicion.getIdCampania(), BigDecimal.ZERO);
                    }
                    int progresoEdit = 0;
                    if (edicion != null && edicion.getMontoObjetivo() != null
                            && edicion.getMontoObjetivo().compareTo(BigDecimal.ZERO) > 0) {
                        progresoEdit = recaudadoEdit.multiply(new BigDecimal("100"))
                                .divide(edicion.getMontoObjetivo(), 0, RoundingMode.HALF_UP).intValue();
                        if (progresoEdit > 100) progresoEdit = 100;
                        if (progresoEdit < 0) progresoEdit = 0;
                    }
            %>
            <article class="panel">
                <h3><%= edicion != null ? "Editar Campania" : "Nueva Campania" %></h3>
                <form method="post" action="${pageContext.request.contextPath}/campanias" class="form-grid">
                    <input type="hidden" name="accion" value="<%= edicion != null ? "editar" : "crear" %>">
                    <%
                        if (edicion != null) {
                    %>
                    <input type="hidden" name="id_campania" value="<%= edicion.getIdCampania() %>">
                    <%
                        }
                    %>
                    <div>
                        <label>Nombre</label>
                        <input type="text" name="nombre" required value="<%= edicion != null && edicion.getNombre() != null ? edicion.getNombre() : "" %>">
                    </div>
                    <div>
                        <label>Estado</label>
                        <select name="estado">
                            <option value="Activa" <%= "Activa".equalsIgnoreCase(estadoEdit) ? "selected" : "" %>>Activa</option>
                            <option value="Pausada" <%= "Pausada".equalsIgnoreCase(estadoEdit) ? "selected" : "" %>>Pausada</option>
                            <option value="Finalizada" <%= "Finalizada".equalsIgnoreCase(estadoEdit) ? "selected" : "" %>>Finalizada</option>
                        </select>
                    </div>
                    <div>
                        <label>Fecha inicio</label>
                        <input type="date" name="fecha_inicio" required value="<%= fechaInicio %>">
                    </div>
                    <div>
                        <label>Fecha fin</label>
                        <input type="date" name="fecha_fin" value="<%= fechaFin %>">
                    </div>
                    <div>
                        <label>Monto objetivo</label>
                        <input type="number" name="monto_objetivo" min="0" step="0.01" value="<%= montoObjetivo %>">
                    </div>
                    <%
                        if (edicion != null) {
                    %>
                    <div>
                        <label>Monto objetivo actual</label>
                        <input type="text" value="$<%= String.format("%,.2f", edicion.getMontoObjetivo() != null ? edicion.getMontoObjetivo() : BigDecimal.ZERO) %>" readonly>
                    </div>
                    <div>
                        <label>Monto recaudado</label>
                        <input type="text" value="$<%= String.format("%,.2f", recaudadoEdit) %>" readonly>
                    </div>
                    <div>
                        <label>Avance</label>
                        <input type="text" value="<%= progresoEdit %>%" readonly>
                    </div>
                    <%
                        }
                    %>
                    <div class="full">
                        <label>Descripcion</label>
                        <textarea name="descripcion" rows="3"><%= edicion != null && edicion.getDescripcion() != null ? edicion.getDescripcion() : "" %></textarea>
                    </div>
                    <div class="full form-actions">
                        <button type="submit"><%= edicion != null ? "Guardar Cambios" : "Guardar Campania" %></button>
                        <a class="btn-cancel" href="<%= backToListUrl %>">Cancelar</a>
                    </div>
                </form>
            </article>
            <%
                } else {
            %>
            <article class="panel">
                <h3>Campanias (<%= totalRows %>)</h3>
                <p class="muted">Pagina <%= currentPage %> de <%= totalPages %> - <%= pageSize %> por pagina</p>
                <%
                    if (campanias != null && !campanias.isEmpty()) {
                        for (Campania row : campanias) {
                            boolean isActivo = row.getActivo() != null && row.getActivo();
                            BigDecimal objetivo = row.getMontoObjetivo() != null ? row.getMontoObjetivo() : BigDecimal.ZERO;
                            BigDecimal recaudado = BigDecimal.ZERO;
                            if (recaudadoPorCampania != null && row.getIdCampania() != null) {
                                recaudado = recaudadoPorCampania.getOrDefault(row.getIdCampania(), BigDecimal.ZERO);
                            }
                            int totalDonaciones = 0;
                            if (donacionesPorCampania != null && row.getIdCampania() != null) {
                                totalDonaciones = donacionesPorCampania.getOrDefault(row.getIdCampania(), 0);
                            }

                            int progreso = 0;
                            if (objetivo.compareTo(BigDecimal.ZERO) > 0) {
                                progreso = recaudado.multiply(new BigDecimal("100"))
                                        .divide(objetivo, 0, RoundingMode.HALF_UP).intValue();
                                if (progreso > 100) progreso = 100;
                                if (progreso < 0) progreso = 0;
                            }

                            String estadoRow = row.getEstado() != null ? row.getEstado() : "";
                            String badgeEstado = "badge-pendiente";
                            if ("Activa".equalsIgnoreCase(estadoRow)) {
                                badgeEstado = "badge-entregado";
                            } else if ("Pausada".equalsIgnoreCase(estadoRow)) {
                                badgeEstado = "badge-transito";
                            } else if ("Finalizada".equalsIgnoreCase(estadoRow)) {
                                badgeEstado = "badge-cancelado";
                            }
                            String badgeActivo = isActivo ? "badge-entregado" : "badge-cancelado";
                            boolean active = selectedId != null && row.getIdCampania() != null && selectedId.equals(row.getIdCampania());
                            String activeClass = active ? "camp-item active" : "camp-item";
                            String detailUrl = request.getContextPath() + "/campanias?id=" + row.getIdCampania() + "&" + baseQuery;
                            String editUrl = request.getContextPath() + "/campanias?editarId=" + row.getIdCampania() + "&" + baseQuery;
                            String fechaInicio = row.getFechaInicio() != null ? row.getFechaInicio().toString() : "";
                            String fechaFin = row.getFechaFin() != null ? row.getFechaFin().toString() : "";
                %>
                <div class="<%= activeClass %>">
                    <div class="camp-item-head">
                        <a class="item-link" href="<%= detailUrl %>"><strong><%= row.getNombre() != null ? row.getNombre() : "" %></strong></a>
                        <span class="badge <%= badgeEstado %>"><%= estadoRow %></span>
                        <span class="badge <%= badgeActivo %>"><%= isActivo ? "Activo" : "Inactivo" %></span>
                    </div>
                    <p><%= row.getDescripcion() != null ? row.getDescripcion() : "" %></p>
                    <small><%= fechaInicio %> <%= fechaFin.isEmpty() ? "" : "a " + fechaFin %></small>
                    <div class="money-line">
                        <span>$<%= String.format("%,.2f", recaudado) %> / $<%= String.format("%,.2f", objetivo) %></span>
                        <strong><%= progreso %>%</strong>
                    </div>
                    <div class="progress-track">
                        <div class="progress-fill" style="width:<%= progreso %>%;"></div>
                    </div>
                    <small><%= totalDonaciones %> donaciones</small>
                    <div class="row-actions">
                        <%
                            if (!soloLectura) {
                        %>
                        <a class="btn-mini btn-edit" href="<%= editUrl %>">Editar</a>
                        <%
                                if (isActivo) {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/campanias" class="inline-form">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= row.getIdCampania() %>">
                            <button class="btn-mini btn-danger" type="submit">Eliminar</button>
                        </form>
                        <%
                                } else {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/campanias" class="inline-form">
                            <input type="hidden" name="accion" value="restaurar">
                            <input type="hidden" name="id" value="<%= row.getIdCampania() %>">
                            <button class="btn-mini btn-ok" type="submit">Restaurar</button>
                        </form>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <p class="muted">No se encontraron campanias.</p>
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
                    <a class="page-link" href="${pageContext.request.contextPath}/campanias?page=<%= currentPage - 1 %>&q=<%= encQ %>&estado=<%= encEstado %>&situacion=<%= encSituacion %>">Anterior</a>
                    <%
                        }
                        for (int p = start; p <= end; p++) {
                            String pageClass = p == currentPage ? "page-link current" : "page-link";
                    %>
                    <a class="<%= pageClass %>" href="${pageContext.request.contextPath}/campanias?page=<%= p %>&q=<%= encQ %>&estado=<%= encEstado %>&situacion=<%= encSituacion %>"><%= p %></a>
                    <%
                        }
                        if (currentPage < totalPages) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/campanias?page=<%= currentPage + 1 %>&q=<%= encQ %>&estado=<%= encEstado %>&situacion=<%= encSituacion %>">Siguiente</a>
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
                <h3>Detalles de Campania</h3>
                <%
                    if (detalle != null) {
                        BigDecimal objetivo = detalle.getMontoObjetivo() != null ? detalle.getMontoObjetivo() : BigDecimal.ZERO;
                        BigDecimal recaudado = recaudadoDetalle != null ? recaudadoDetalle : BigDecimal.ZERO;
                        int progresoDetalle = 0;
                        if (objetivo.compareTo(BigDecimal.ZERO) > 0) {
                            progresoDetalle = recaudado.multiply(new BigDecimal("100"))
                                    .divide(objetivo, 0, RoundingMode.HALF_UP).intValue();
                            if (progresoDetalle > 100) progresoDetalle = 100;
                            if (progresoDetalle < 0) progresoDetalle = 0;
                        }
                        String fechaInicio = detalle.getFechaInicio() != null ? detalle.getFechaInicio().toString() : "";
                        String fechaFin = detalle.getFechaFin() != null ? detalle.getFechaFin().toString() : "";
                        boolean activo = detalle.getActivo() != null && detalle.getActivo();
                %>
                <div class="detail-list">
                    <p><strong>Nombre:</strong> <%= detalle.getNombre() != null ? detalle.getNombre() : "" %></p>
                    <p><strong>Descripcion:</strong> <%= detalle.getDescripcion() != null ? detalle.getDescripcion() : "" %></p>
                    <p><strong>Estado:</strong> <%= detalle.getEstado() != null ? detalle.getEstado() : "" %></p>
                    <p><strong>Rango:</strong> <%= fechaInicio %> <%= fechaFin.isEmpty() ? "" : "a " + fechaFin %></p>
                    <p><strong>Objetivo:</strong> $<%= String.format("%,.2f", objetivo) %></p>
                    <p><strong>Recaudado:</strong> $<%= String.format("%,.2f", recaudado) %></p>
                    <p><strong>Donaciones:</strong> <%= totalDonacionesDetalle %></p>
                    <p><strong>Situacion:</strong> <%= activo ? "Activo" : "Inactivo" %></p>
                </div>
                <div class="progress-track">
                    <div class="progress-fill" style="width:<%= progresoDetalle %>%;"></div>
                </div>
                <p class="muted">Progreso actual: <strong><%= progresoDetalle %>%</strong></p>
                <%
                    } else {
                %>
                <p class="muted">Selecciona una campania para ver detalles.</p>
                <%
                    }
                %>
            </aside>
        </section>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>
