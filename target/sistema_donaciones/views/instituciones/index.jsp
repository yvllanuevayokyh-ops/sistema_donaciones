<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.donaciones.model.Donante" %>
<%@ page import="com.donaciones.model.Pais" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Instituciones - Sistema Donaciones"/>
</jsp:include>
<%
    List<Donante> instituciones = (List<Donante>) request.getAttribute("instituciones");
    List<Pais> paises = (List<Pais>) request.getAttribute("paises");
    Donante detalle = (Donante) request.getAttribute("detalle");
    Donante edicion = (Donante) request.getAttribute("edicion");
    Map<Integer, Integer> donacionesPorInstitucion = (Map<Integer, Integer>) request.getAttribute("donacionesPorInstitucion");
    Integer totalDonacionesDetalleObj = (Integer) request.getAttribute("totalDonacionesDetalle");
    int totalDonacionesDetalle = totalDonacionesDetalleObj != null ? totalDonacionesDetalleObj : 0;

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
    String newInstitucionUrl = request.getContextPath() + "/instituciones?nuevo=1&" + baseQuery;
    String backToListUrl = request.getContextPath() + "/instituciones?" + baseQuery;
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
            <li class="active"><a href="${pageContext.request.contextPath}/instituciones">Instituciones</a></li>
            <li><a href="${pageContext.request.contextPath}/voluntarios">Voluntarios</a></li>
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
                <h1>Instituciones Donantes</h1>
                <p class="muted">Listado, busqueda, edicion e inactivacion logica</p>
            </div>
            <a class="btn-new" href="<%= newInstitucionUrl %>">+ Nueva Institucion</a>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/instituciones" class="toolbar toolbar-simple">
            <input type="hidden" name="page" value="1">
            <input type="text" name="q" value="<%= q %>" placeholder="Buscar por nombre, pais o direccion">
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
                    Integer selectedPaisId = edicion != null && edicion.getPais() != null
                            ? edicion.getPais().getIdPais() : null;
                    String tipo = edicion != null && edicion.getTipoDonante() != null ? edicion.getTipoDonante() : "Institucion";
            %>
            <article class="panel">
                <h3><%= edicion != null ? "Editar Institucion" : "Nueva Institucion" %></h3>
                <form method="post" action="${pageContext.request.contextPath}/instituciones" class="form-grid">
                    <input type="hidden" name="accion" value="<%= edicion != null ? "editar" : "crear" %>">
                    <%
                        if (edicion != null) {
                    %>
                    <input type="hidden" name="id_donante" value="<%= edicion.getIdDonante() %>">
                    <%
                        }
                    %>
                    <div>
                        <label>Nombre</label>
                        <input type="text" name="nombre" required value="<%= edicion != null && edicion.getNombre() != null ? edicion.getNombre() : "" %>">
                    </div>
                    <div>
                        <label>Tipo</label>
                        <select name="tipo_donante">
                            <option value="Institucion" <%= "Institucion".equalsIgnoreCase(tipo) ? "selected" : "" %>>Institucion</option>
                            <option value="ONG" <%= "ONG".equalsIgnoreCase(tipo) ? "selected" : "" %>>ONG</option>
                            <option value="Fundacion" <%= "Fundacion".equalsIgnoreCase(tipo) ? "selected" : "" %>>Fundacion</option>
                            <option value="Organizacion Internacional" <%= "Organizacion Internacional".equalsIgnoreCase(tipo) ? "selected" : "" %>>Organizacion Internacional</option>
                        </select>
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
                        <label>Direccion</label>
                        <input type="text" name="direccion" value="<%= edicion != null && edicion.getDireccion() != null ? edicion.getDireccion() : "" %>">
                    </div>
                    <div>
                        <label>Pais</label>
                        <select name="id_pais" required>
                            <option value="">Selecciona pais</option>
                            <%
                                if (paises != null) {
                                    for (Pais pais : paises) {
                                        Integer idPais = pais.getIdPais();
                                        String isSelected = selectedPaisId != null && selectedPaisId.equals(idPais) ? "selected" : "";
                            %>
                            <option value="<%= idPais %>" <%= isSelected %>><%= pais.getNombre() %></option>
                            <%
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <%
                        if (edicion == null) {
                    %>
                    <div>
                        <label>Fecha registro</label>
                        <input type="date" name="fecha_registro" value="<%= hoy %>">
                    </div>
                    <%
                        }
                    %>
                    <div class="full form-actions">
                        <button type="submit"><%= edicion != null ? "Guardar Cambios" : "Guardar Institucion" %></button>
                        <a class="btn-cancel" href="<%= backToListUrl %>">Cancelar</a>
                    </div>
                </form>
            </article>
            <%
                } else {
            %>
            <article class="panel">
                <h3>Instituciones (<%= totalRows %>)</h3>
                <p class="muted">Pagina <%= currentPage %> de <%= totalPages %> - <%= pageSize %> por pagina</p>
                <%
                    if (instituciones != null && !instituciones.isEmpty()) {
                        for (Donante row : instituciones) {
                            boolean isActivo = row.getActivo() != null && row.getActivo();
                            String badgeActivo = isActivo ? "badge-entregado" : "badge-cancelado";
                            boolean active = selectedId != null && row.getIdDonante() != null && selectedId.equals(row.getIdDonante());
                            String activeClass = active ? "inst-item active" : "inst-item";
                            String detailUrl = request.getContextPath() + "/instituciones?id=" + row.getIdDonante() + "&" + baseQuery;
                            String editUrl = request.getContextPath() + "/instituciones?editarId=" + row.getIdDonante() + "&" + baseQuery;
                            int totalDonaciones = donacionesPorInstitucion != null && row.getIdDonante() != null
                                    ? donacionesPorInstitucion.getOrDefault(row.getIdDonante(), 0) : 0;
                            String paisNombre = row.getPais() != null && row.getPais().getNombre() != null
                                    ? row.getPais().getNombre() : "";
                %>
                <div class="<%= activeClass %>">
                    <div class="inst-item-head">
                        <a class="item-link" href="<%= detailUrl %>"><strong><%= row.getNombre() %></strong></a>
                        <span class="badge <%= badgeActivo %>"><%= isActivo ? "Activo" : "Inactivo" %></span>
                        <span class="date"><%= totalDonaciones %> donaciones</span>
                    </div>
                    <p><%= row.getTipoDonante() != null ? row.getTipoDonante() : "" %></p>
                    <small><%= row.getDireccion() != null ? row.getDireccion() : "" %>, <%= paisNombre %></small>
                    <div class="row-actions">
                        <a class="btn-mini btn-edit" href="<%= editUrl %>">Editar</a>
                        <%
                            if (isActivo) {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/instituciones" class="inline-form">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= row.getIdDonante() %>">
                            <button class="btn-mini btn-danger" type="submit">Eliminar</button>
                        </form>
                        <%
                            } else {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/instituciones" class="inline-form">
                            <input type="hidden" name="accion" value="restaurar">
                            <input type="hidden" name="id" value="<%= row.getIdDonante() %>">
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
                <p class="muted">No se encontraron instituciones.</p>
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
                    <a class="page-link" href="${pageContext.request.contextPath}/instituciones?page=<%= currentPage - 1 %>&q=<%= encQ %>&situacion=<%= encSituacion %>">Anterior</a>
                    <%
                        }
                        for (int p = start; p <= end; p++) {
                            String pageClass = p == currentPage ? "page-link current" : "page-link";
                    %>
                    <a class="<%= pageClass %>" href="${pageContext.request.contextPath}/instituciones?page=<%= p %>&q=<%= encQ %>&situacion=<%= encSituacion %>"><%= p %></a>
                    <%
                        }
                        if (currentPage < totalPages) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/instituciones?page=<%= currentPage + 1 %>&q=<%= encQ %>&situacion=<%= encSituacion %>">Siguiente</a>
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
                <h3>Informacion de Institucion</h3>
                <%
                    if (detalle != null) {
                        String paisNombre = detalle.getPais() != null && detalle.getPais().getNombre() != null
                                ? detalle.getPais().getNombre() : "";
                        String fechaReg = detalle.getFechaRegistro() != null ? detalle.getFechaRegistro().toString() : "";
                        boolean activo = detalle.getActivo() != null && detalle.getActivo();
                %>
                <div class="detail-list">
                    <p><strong>Nombre:</strong> <%= detalle.getNombre() != null ? detalle.getNombre() : "" %></p>
                    <p><strong>Tipo:</strong> <%= detalle.getTipoDonante() != null ? detalle.getTipoDonante() : "" %></p>
                    <p><strong>Ubicacion:</strong> <%= detalle.getDireccion() != null ? detalle.getDireccion() : "" %>, <%= paisNombre %></p>
                    <p><strong>Email:</strong> <%= detalle.getEmail() != null ? detalle.getEmail() : "" %></p>
                    <p><strong>Telefono:</strong> <%= detalle.getTelefono() != null ? detalle.getTelefono() : "" %></p>
                    <p><strong>Registro:</strong> <%= fechaReg %></p>
                    <p><strong>Donaciones:</strong> <%= totalDonacionesDetalle %></p>
                    <p><strong>Situacion:</strong> <%= activo ? "Activo" : "Inactivo" %></p>
                </div>
                <%
                    } else {
                %>
                <p class="muted">Selecciona una institucion para ver detalles.</p>
                <%
                    }
                %>
            </aside>
        </section>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>
