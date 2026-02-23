<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.donaciones.model.Donacion" %>
<%@ page import="com.donaciones.model.Donante" %>
<%@ page import="com.donaciones.model.Campania" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Donaciones - Sistema Donaciones"/>
</jsp:include>
<%
    List<Donacion> donaciones = (List<Donacion>) request.getAttribute("donaciones");
    List<Donante> donantes = (List<Donante>) request.getAttribute("donantes");
    List<Campania> campanias = (List<Campania>) request.getAttribute("campanias");
    Donacion detalle = (Donacion) request.getAttribute("detalle");
    Donacion edicion = (Donacion) request.getAttribute("edicion");
    Boolean showFormObj = (Boolean) request.getAttribute("showForm");
    boolean showForm = showFormObj != null && showFormObj;
    Boolean isDonanteViewObj = (Boolean) request.getAttribute("isDonanteView");
    boolean isDonanteView = isDonanteViewObj != null && isDonanteViewObj;
    Boolean perfilDonanteVinculadoObj = (Boolean) request.getAttribute("perfilDonanteVinculado");
    boolean perfilDonanteVinculado = perfilDonanteVinculadoObj != null && perfilDonanteVinculadoObj;
    String donanteActualNombre = request.getAttribute("donanteActualNombre") != null
            ? String.valueOf(request.getAttribute("donanteActualNombre")) : "";
    Integer idDonanteActual = (Integer) request.getAttribute("idDonanteActual");

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
    String newDonacionUrl = request.getContextPath() + "/donaciones?nuevo=1&" + baseQuery;
    String backToListUrl = request.getContextPath() + "/donaciones?" + baseQuery;
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
            <li class="active"><a href="${pageContext.request.contextPath}/donaciones">Mis Donaciones</a></li>
            <li><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <%
                } else {
            %>
            <li><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/roles">Roles y Permisos</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/donaciones">Donaciones</a></li>
            <li><a href="${pageContext.request.contextPath}/comunidades">Comunidades</a></li>
            <li><a href="${pageContext.request.contextPath}/instituciones">Instituciones</a></li>
            <li><a href="${pageContext.request.contextPath}/voluntarios">Voluntarios</a></li>
            <li><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
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
                <h1><%= isDonanteView ? "Mis Donaciones" : "Gestion de Donaciones" %></h1>
                <p class="muted"><%= isDonanteView
                        ? "Registra y revisa el estado de tus donaciones"
                        : "Listado, busqueda, edicion e inactivacion logica" %></p>
            </div>
            <a class="btn-new" href="<%= newDonacionUrl %>">+ Nueva Donacion</a>
        </div>

        <%
            if (isDonanteView && !perfilDonanteVinculado) {
        %>
        <p class="muted">No se encontro un perfil donante vinculado a tu cuenta. Solicita al administrador vincular tu email.</p>
        <%
            }
        %>

        <form method="get" action="${pageContext.request.contextPath}/donaciones" class="toolbar">
            <input type="hidden" name="page" value="1">
            <input type="text" name="q" value="<%= q %>" placeholder="Buscar por ID o descripcion">
            <select name="estado">
                <option value="Todas" <%= "Todas".equalsIgnoreCase(estado) ? "selected" : "" %>>Estado: Todas</option>
                <option value="Pendiente" <%= "Pendiente".equalsIgnoreCase(estado) ? "selected" : "" %>>Pendiente</option>
                <option value="En transito" <%= "En transito".equalsIgnoreCase(estado) ? "selected" : "" %>>En transito</option>
                <option value="Entregado" <%= "Entregado".equalsIgnoreCase(estado) ? "selected" : "" %>>Entregado</option>
                <option value="Cancelado" <%= "Cancelado".equalsIgnoreCase(estado) ? "selected" : "" %>>Cancelado</option>
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
                    Integer selectedDonanteId = edicion != null && edicion.getDonante() != null
                            ? edicion.getDonante().getIdDonante() : null;
                    Integer selectedCampaniaId = edicion != null && edicion.getCampania() != null
                            ? edicion.getCampania().getIdCampania() : null;
                    String fechaEdicion = edicion != null && edicion.getFechaDonacion() != null
                            ? edicion.getFechaDonacion().toString() : hoy;
                    String montoEdicion = edicion != null && edicion.getMonto() != null
                            ? edicion.getMonto().toPlainString() : "";
            %>
            <article class="panel">
                <h3><%= edicion != null ? "Editar Donacion" : "Nueva Donacion" %></h3>
                <form method="post" action="${pageContext.request.contextPath}/donaciones" class="form-grid">
                    <input type="hidden" name="accion" value="<%= edicion != null ? "editar" : "crear" %>">
                    <%
                        if (edicion != null) {
                    %>
                    <input type="hidden" name="id_donacion" value="<%= edicion.getIdDonacion() %>">
                    <%
                        }
                    %>
                    <div>
                        <label>Donante</label>
                        <%
                            if (isDonanteView) {
                                int idHidden = selectedDonanteId != null ? selectedDonanteId
                                        : (idDonanteActual != null ? idDonanteActual : 0);
                        %>
                        <input type="text" value="<%= donanteActualNombre %>" readonly>
                        <input type="hidden" name="id_donante" value="<%= idHidden %>">
                        <%
                            } else {
                        %>
                        <select name="id_donante" required>
                            <option value="">Selecciona donante</option>
                            <%
                                if (donantes != null) {
                                    for (Donante donante : donantes) {
                                        Integer id = donante.getIdDonante();
                                        String isSelected = selectedDonanteId != null && selectedDonanteId.equals(id)
                                                ? "selected" : "";
                            %>
                            <option value="<%= id %>" <%= isSelected %>><%= donante.getNombre() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                        <%
                            }
                        %>
                    </div>
                    <div>
                        <label>Campania (opcional)</label>
                        <select name="id_campania">
                            <option value="">Sin campania</option>
                            <%
                                if (campanias != null) {
                                    for (Campania campania : campanias) {
                                        Integer id = campania.getIdCampania();
                                        String isSelected = selectedCampaniaId != null && selectedCampaniaId.equals(id)
                                                ? "selected" : "";
                            %>
                            <option value="<%= id %>" <%= isSelected %>><%= campania.getNombre() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div>
                        <label>Tipo</label>
                        <%
                            String tipo = edicion != null ? edicion.getTipoDonacion() : "Recurso";
                        %>
                        <select name="tipo_donacion" required>
                            <option value="Recurso" <%= "Recurso".equalsIgnoreCase(tipo) ? "selected" : "" %>>Recurso</option>
                            <option value="Monetaria" <%= "Monetaria".equalsIgnoreCase(tipo) ? "selected" : "" %>>Monetaria</option>
                        </select>
                    </div>
                    <div>
                        <label>Estado</label>
                        <%
                            String estadoEdit = edicion != null ? edicion.getEstadoDonacion() : "Pendiente";
                        %>
                        <select name="estado_donacion" required>
                            <option value="Pendiente" <%= "Pendiente".equalsIgnoreCase(estadoEdit) ? "selected" : "" %>>Pendiente</option>
                            <option value="En transito" <%= "En transito".equalsIgnoreCase(estadoEdit) ? "selected" : "" %>>En transito</option>
                            <option value="Entregado" <%= "Entregado".equalsIgnoreCase(estadoEdit) ? "selected" : "" %>>Entregado</option>
                            <option value="Cancelado" <%= "Cancelado".equalsIgnoreCase(estadoEdit) ? "selected" : "" %>>Cancelado</option>
                        </select>
                    </div>
                    <div>
                        <label>Fecha</label>
                        <input type="date" name="fecha_donacion" required value="<%= fechaEdicion %>">
                    </div>
                    <div>
                        <label>Monto (opcional)</label>
                        <input type="number" name="monto" step="0.01" value="<%= montoEdicion %>" placeholder="0.00">
                    </div>
                    <div class="full">
                        <label>Descripcion</label>
                        <textarea name="descripcion" rows="3" required><%= edicion != null && edicion.getDescripcion() != null ? edicion.getDescripcion() : "" %></textarea>
                    </div>
                    <div class="full form-actions">
                        <button type="submit"><%= edicion != null ? "Guardar Cambios" : "Guardar Donacion" %></button>
                        <a class="btn-cancel" href="<%= backToListUrl %>">Cancelar</a>
                    </div>
                </form>
            </article>
            <%
                } else {
            %>
            <article class="panel">
                <h3>Donaciones (<%= totalRows %>)</h3>
                <p class="muted">Pagina <%= currentPage %> de <%= totalPages %> - <%= pageSize %> por pagina</p>
                <%
                    if (donaciones != null && !donaciones.isEmpty()) {
                        for (Donacion row : donaciones) {
                            boolean isActivo = row.getActivo() != null && row.getActivo();
                            String estadoRow = row.getEstadoDonacion() != null ? row.getEstadoDonacion() : "";
                            String badgeEstado = "badge-pendiente";
                            if ("Entregado".equalsIgnoreCase(estadoRow)) {
                                badgeEstado = "badge-entregado";
                            } else if ("En transito".equalsIgnoreCase(estadoRow)) {
                                badgeEstado = "badge-transito";
                            } else if ("Cancelado".equalsIgnoreCase(estadoRow)) {
                                badgeEstado = "badge-cancelado";
                            }
                            String badgeActivo = isActivo ? "badge-entregado" : "badge-cancelado";
                            boolean active = selectedId != null && row.getIdDonacion() != null && selectedId.equals(row.getIdDonacion());
                            String activeClass = active ? "don-item active" : "don-item";
                            String detailUrl = request.getContextPath() + "/donaciones?id=" + row.getIdDonacion() + "&" + baseQuery;
                            String editUrl = request.getContextPath() + "/donaciones?editarId=" + row.getIdDonacion() + "&" + baseQuery;
                            String codigo = "DON-" + String.format("%03d", row.getIdDonacion());
                            String fecha = row.getFechaDonacion() != null ? row.getFechaDonacion().toString() : "";
                            String donanteNombre = row.getDonante() != null ? row.getDonante().getNombre() : "Sin donante";
                            String descripcion = row.getDescripcion() != null ? row.getDescripcion() : "";
                            String detalleTexto = row.getMonto() != null
                                    ? "S/ " + String.format("%,.2f", row.getMonto())
                                    : (row.getTipoDonacion() != null ? row.getTipoDonacion() : "N/A");
                %>
                <div class="<%= activeClass %>">
                    <div class="don-item-head">
                        <a class="item-link" href="<%= detailUrl %>"><strong><%= codigo %></strong></a>
                        <span class="badge <%= badgeEstado %>"><%= estadoRow %></span>
                        <span class="badge <%= badgeActivo %>"><%= isActivo ? "Activo" : "Inactivo" %></span>
                        <span class="date"><%= fecha %></span>
                    </div>
                    <p><%= descripcion %></p>
                    <small><%= detalleTexto %> - <%= donanteNombre %></small>
                    <div class="row-actions">
                        <%
                            if (!isDonanteView) {
                        %>
                        <a class="btn-mini btn-edit" href="<%= editUrl %>">Editar</a>
                        <%
                                if (isActivo) {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/donaciones" class="inline-form">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= row.getIdDonacion() %>">
                            <button class="btn-mini btn-danger" type="submit">Eliminar</button>
                        </form>
                        <%
                                } else {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/donaciones" class="inline-form">
                            <input type="hidden" name="accion" value="restaurar">
                            <input type="hidden" name="id" value="<%= row.getIdDonacion() %>">
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
                <p class="muted">No se encontraron donaciones.</p>
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
                    <a class="page-link" href="${pageContext.request.contextPath}/donaciones?page=<%= currentPage - 1 %>&q=<%= encQ %>&estado=<%= encEstado %>&situacion=<%= encSituacion %>">Anterior</a>
                    <%
                        }
                        for (int p = start; p <= end; p++) {
                            String pageClass = p == currentPage ? "page-link current" : "page-link";
                    %>
                    <a class="<%= pageClass %>" href="${pageContext.request.contextPath}/donaciones?page=<%= p %>&q=<%= encQ %>&estado=<%= encEstado %>&situacion=<%= encSituacion %>"><%= p %></a>
                    <%
                        }
                        if (currentPage < totalPages) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/donaciones?page=<%= currentPage + 1 %>&q=<%= encQ %>&estado=<%= encEstado %>&situacion=<%= encSituacion %>">Siguiente</a>
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
                <h3>Detalles de Donacion</h3>
                <%
                    if (detalle != null) {
                        String codigo = "DON-" + String.format("%03d", detalle.getIdDonacion());
                        String fecha = detalle.getFechaDonacion() != null ? detalle.getFechaDonacion().toString() : "";
                        String descripcion = detalle.getDescripcion() != null ? detalle.getDescripcion() : "";
                        String tipo = detalle.getTipoDonacion() != null ? detalle.getTipoDonacion() : "";
                        String estadoDet = detalle.getEstadoDonacion() != null ? detalle.getEstadoDonacion() : "";
                        String monto = detalle.getMonto() != null ? "S/ " + String.format("%,.2f", detalle.getMonto()) : "N/A";
                        String donanteNombre = detalle.getDonante() != null ? detalle.getDonante().getNombre() : "N/A";
                        String email = (detalle.getDonante() != null && detalle.getDonante().getEmail() != null)
                                ? detalle.getDonante().getEmail() : "N/A";
                        String campania = (detalle.getCampania() != null && detalle.getCampania().getNombre() != null)
                                ? detalle.getCampania().getNombre() : "Sin campania";
                        boolean activoDet = detalle.getActivo() != null && detalle.getActivo();
                %>
                <div class="detail-list">
                    <p><strong>Codigo:</strong> <%= codigo %></p>
                    <p><strong>Descripcion:</strong> <%= descripcion %></p>
                    <p><strong>Estado:</strong> <%= estadoDet %></p>
                    <p><strong>Fecha:</strong> <%= fecha %></p>
                    <p><strong>Tipo:</strong> <%= tipo %></p>
                    <p><strong>Monto:</strong> <%= monto %></p>
                    <p><strong>Donante:</strong> <%= donanteNombre %></p>
                    <p><strong>Email:</strong> <%= email %></p>
                    <p><strong>Campania:</strong> <%= campania %></p>
                    <p><strong>Situacion:</strong> <%= activoDet ? "Activo" : "Inactivo" %></p>
                </div>
                <%
                    } else {
                %>
                <p class="muted">Selecciona una donacion para ver detalles.</p>
                <%
                    }
                %>
            </aside>
        </section>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>
