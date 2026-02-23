<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.donaciones.model.ComunidadVulnerable" %>
<%@ page import="com.donaciones.model.Pais" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Comunidades - Sistema Donaciones"/>
</jsp:include>
<%
    List<ComunidadVulnerable> comunidades = (List<ComunidadVulnerable>) request.getAttribute("comunidades");
    List<Pais> paises = (List<Pais>) request.getAttribute("paises");
    ComunidadVulnerable detalle = (ComunidadVulnerable) request.getAttribute("detalle");
    ComunidadVulnerable edicion = (ComunidadVulnerable) request.getAttribute("edicion");
    Map<Integer, Integer> donacionesPorComunidad = (Map<Integer, Integer>) request.getAttribute("donacionesPorComunidad");
    Integer donacionesDetalleObj = (Integer) request.getAttribute("donacionesDetalle");
    int donacionesDetalle = donacionesDetalleObj != null ? donacionesDetalleObj : 0;

    Boolean showFormObj = (Boolean) request.getAttribute("showForm");
    boolean showForm = showFormObj != null && showFormObj;
    Boolean isComunidadViewObj = (Boolean) request.getAttribute("isComunidadView");
    boolean isComunidadView = isComunidadViewObj != null && isComunidadViewObj;

    Integer selectedId = (Integer) request.getAttribute("selectedId");
    String q = request.getAttribute("q") != null ? String.valueOf(request.getAttribute("q")) : "";
    String situacion = request.getAttribute("situacion") != null ? String.valueOf(request.getAttribute("situacion")) : "Activos";

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
    String newComunidadUrl = request.getContextPath() + "/comunidades?nuevo=1&" + baseQuery;
    String backToListUrl = request.getContextPath() + "/comunidades?" + baseQuery;
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
                if (isComunidadView) {
            %>
            <li><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/comunidades">Comunidades</a></li>
            <li><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <%
                } else {
            %>
            <li><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/roles">Roles y Permisos</a></li>
            <li><a href="${pageContext.request.contextPath}/donaciones">Donaciones</a></li>
            <li class="active"><a href="${pageContext.request.contextPath}/comunidades">Comunidades</a></li>
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
                <h1>Comunidades Vulnerables</h1>
                <p class="muted"><%= isComunidadView
                        ? "Consulta de comunidades y beneficiarios"
                        : "Listado, busqueda, edicion e inactivacion logica" %></p>
            </div>
            <%
                if (!isComunidadView) {
            %>
            <a class="btn-new" href="<%= newComunidadUrl %>">+ Nueva Comunidad</a>
            <%
                }
            %>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/comunidades" class="toolbar toolbar-simple">
            <input type="hidden" name="page" value="1">
            <input type="text" name="q" value="<%= q %>" placeholder="Buscar por nombre o ubicacion">
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
                    Integer selectedPais = edicion != null && edicion.getPais() != null
                            ? edicion.getPais().getIdPais() : null;
            %>
            <article class="panel">
                <h3><%= edicion != null ? "Editar Comunidad" : "Nueva Comunidad" %></h3>
                <form method="post" action="${pageContext.request.contextPath}/comunidades" class="form-grid">
                    <input type="hidden" name="accion" value="<%= edicion != null ? "editar" : "crear" %>">
                    <%
                        if (edicion != null) {
                    %>
                    <input type="hidden" name="id_comunidad" value="<%= edicion.getIdComunidad() %>">
                    <%
                        }
                    %>
                    <div>
                        <label>Nombre</label>
                        <input type="text" name="nombre" required value="<%= edicion != null && edicion.getNombre() != null ? edicion.getNombre() : "" %>">
                    </div>
                    <div>
                        <label>Ubicacion</label>
                        <input type="text" name="ubicacion" value="<%= edicion != null && edicion.getUbicacion() != null ? edicion.getUbicacion() : "" %>">
                    </div>
                    <div>
                        <label>Poblacion beneficiaria</label>
                        <input type="number" name="cantidad_beneficiarios" min="0"
                               value="<%= edicion != null && edicion.getCantidadBeneficiarios() != null ? edicion.getCantidadBeneficiarios() : 0 %>">
                    </div>
                    <div>
                        <label>Pais</label>
                        <select name="id_pais" required>
                            <option value="">Selecciona pais</option>
                            <%
                                if (paises != null) {
                                    for (Pais pais : paises) {
                                        Integer idPais = pais.getIdPais();
                                        String isSelected = selectedPais != null && selectedPais.equals(idPais)
                                                ? "selected" : "";
                            %>
                            <option value="<%= idPais %>" <%= isSelected %>><%= pais.getNombre() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div class="full">
                        <label>Descripcion</label>
                        <textarea name="descripcion" rows="3"><%= edicion != null && edicion.getDescripcion() != null ? edicion.getDescripcion() : "" %></textarea>
                    </div>
                    <div class="full form-actions">
                        <button type="submit"><%= edicion != null ? "Guardar Cambios" : "Guardar Comunidad" %></button>
                        <a class="btn-cancel" href="<%= backToListUrl %>">Cancelar</a>
                    </div>
                </form>
            </article>
            <%
                } else {
            %>
            <article class="panel">
                <h3>Comunidades (<%= totalRows %>)</h3>
                <p class="muted">Pagina <%= currentPage %> de <%= totalPages %> - <%= pageSize %> por pagina</p>
                <%
                    if (comunidades != null && !comunidades.isEmpty()) {
                        for (ComunidadVulnerable row : comunidades) {
                            boolean isActivo = row.getActivo() != null && row.getActivo();
                            String badgeActivo = isActivo ? "badge-entregado" : "badge-cancelado";
                            boolean active = selectedId != null && row.getIdComunidad() != null && selectedId.equals(row.getIdComunidad());
                            String activeClass = active ? "com-item active" : "com-item";
                            String detailUrl = request.getContextPath() + "/comunidades?id=" + row.getIdComunidad() + "&" + baseQuery;
                            String editUrl = request.getContextPath() + "/comunidades?editarId=" + row.getIdComunidad() + "&" + baseQuery;
                            int donRecibidas = donacionesPorComunidad != null && row.getIdComunidad() != null
                                    ? donacionesPorComunidad.getOrDefault(row.getIdComunidad(), 0) : 0;
                            String paisNombre = row.getPais() != null && row.getPais().getNombre() != null
                                    ? row.getPais().getNombre() : "";
                %>
                <div class="<%= activeClass %>">
                    <div class="com-item-head">
                        <a class="item-link" href="<%= detailUrl %>"><strong><%= row.getNombre() != null ? row.getNombre() : "" %></strong></a>
                        <span class="badge <%= badgeActivo %>"><%= isActivo ? "Activo" : "Inactivo" %></span>
                    </div>
                    <p><%= row.getUbicacion() != null ? row.getUbicacion() : "" %></p>
                    <small><%= row.getCantidadBeneficiarios() != null ? row.getCantidadBeneficiarios() : 0 %> habitantes - <%= donRecibidas %> donaciones - <%= paisNombre %></small>
                    <div class="row-actions">
                        <%
                            if (!isComunidadView) {
                        %>
                        <a class="btn-mini btn-edit" href="<%= editUrl %>">Editar</a>
                        <%
                                if (isActivo) {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/comunidades" class="inline-form">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= row.getIdComunidad() %>">
                            <button class="btn-mini btn-danger" type="submit">Eliminar</button>
                        </form>
                        <%
                                } else {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/comunidades" class="inline-form">
                            <input type="hidden" name="accion" value="restaurar">
                            <input type="hidden" name="id" value="<%= row.getIdComunidad() %>">
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
                <p class="muted">No se encontraron comunidades.</p>
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
                    <a class="page-link" href="${pageContext.request.contextPath}/comunidades?page=<%= currentPage - 1 %>&q=<%= encQ %>&situacion=<%= encSituacion %>">Anterior</a>
                    <%
                        }
                        for (int p = start; p <= end; p++) {
                            String pageClass = p == currentPage ? "page-link current" : "page-link";
                    %>
                    <a class="<%= pageClass %>" href="${pageContext.request.contextPath}/comunidades?page=<%= p %>&q=<%= encQ %>&situacion=<%= encSituacion %>"><%= p %></a>
                    <%
                        }
                        if (currentPage < totalPages) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/comunidades?page=<%= currentPage + 1 %>&q=<%= encQ %>&situacion=<%= encSituacion %>">Siguiente</a>
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
                <h3>Informacion de Comunidad</h3>
                <%
                    if (detalle != null) {
                        String paisNombre = detalle.getPais() != null && detalle.getPais().getNombre() != null
                                ? detalle.getPais().getNombre() : "";
                        boolean activo = detalle.getActivo() != null && detalle.getActivo();
                %>
                <div class="detail-list">
                    <p><strong>Nombre:</strong> <%= detalle.getNombre() != null ? detalle.getNombre() : "" %></p>
                    <p><strong>Ubicacion:</strong> <%= detalle.getUbicacion() != null ? detalle.getUbicacion() : "" %></p>
                    <p><strong>Poblacion:</strong> <%= detalle.getCantidadBeneficiarios() != null ? detalle.getCantidadBeneficiarios() : 0 %> habitantes</p>
                    <p><strong>Pais:</strong> <%= paisNombre %></p>
                    <p><strong>Descripcion:</strong> <%= detalle.getDescripcion() != null ? detalle.getDescripcion() : "" %></p>
                    <p><strong>Donaciones recibidas:</strong> <%= donacionesDetalle %></p>
                    <p><strong>Situacion:</strong> <%= activo ? "Activo" : "Inactivo" %></p>
                </div>
                <%
                    } else {
                %>
                <p class="muted">Selecciona una comunidad para ver detalles.</p>
                <%
                    }
                %>
            </aside>
        </section>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>
