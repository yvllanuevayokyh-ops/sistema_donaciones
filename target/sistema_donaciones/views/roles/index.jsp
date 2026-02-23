<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Roles y Permisos - Sistema Donaciones"/>
</jsp:include>
<%
    List<String[]> roles = (List<String[]>) request.getAttribute("roles");
    List<String[]> permisosRol = (List<String[]>) request.getAttribute("permisosRol");
    String[] detalle = (String[]) request.getAttribute("detalle");
    String[] edicion = (String[]) request.getAttribute("edicion");
    Boolean showFormObj = (Boolean) request.getAttribute("showForm");
    Boolean showPermissionFormObj = (Boolean) request.getAttribute("showPermissionForm");
    boolean showForm = showFormObj != null && showFormObj;
    boolean showPermissionForm = showPermissionFormObj != null && showPermissionFormObj;

    Integer selectedId = (Integer) request.getAttribute("selectedId");
    String q = request.getAttribute("q") != null ? String.valueOf(request.getAttribute("q")) : "";
    int totalRoles = request.getAttribute("totalRoles") != null ? (Integer) request.getAttribute("totalRoles") : 0;
    int totalRows = request.getAttribute("totalRows") != null ? (Integer) request.getAttribute("totalRows") : 0;
    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
    int totalPermisos = request.getAttribute("totalPermisos") != null ? (Integer) request.getAttribute("totalPermisos") : 0;
    int totalAsignaciones = request.getAttribute("totalAsignaciones") != null ? (Integer) request.getAttribute("totalAsignaciones") : 0;

    String encQ = java.net.URLEncoder.encode(q, "UTF-8");
    String nuevoRolUrl = request.getContextPath() + "/roles?nuevo=1&page=" + currentPage + "&q=" + encQ + (selectedId != null ? "&id=" + selectedId : "");
    String nuevoPermisoUrl = request.getContextPath() + "/roles?nuevoPermiso=1&page=" + currentPage + "&q=" + encQ + (selectedId != null ? "&id=" + selectedId : "");
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
            <li class="active"><a href="${pageContext.request.contextPath}/roles">Roles y Permisos</a></li>
            <li><a href="${pageContext.request.contextPath}/donaciones">Donaciones</a></li>
            <li><a href="${pageContext.request.contextPath}/comunidades">Comunidades</a></li>
            <li><a href="${pageContext.request.contextPath}/instituciones">Instituciones</a></li>
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
                <h1>Roles y Permisos</h1>
                <p class="muted">Administra roles del sistema y su matriz de accesos</p>
            </div>
            <div class="top-actions">
                <a class="btn-new" href="<%= nuevoRolUrl %>">+ Nuevo Rol</a>
                <a class="btn-new btn-alt" href="<%= nuevoPermisoUrl %>">+ Nuevo Permiso</a>
            </div>
        </div>

        <section class="stats">
            <article class="stat">
                <h3>Total Roles</h3>
                <strong><%= totalRoles %></strong>
                <small>Roles en catalogo</small>
            </article>
            <article class="stat">
                <h3>Total Permisos</h3>
                <strong><%= totalPermisos %></strong>
                <small>Permisos disponibles</small>
            </article>
            <article class="stat">
                <h3>Asignaciones</h3>
                <strong><%= totalAsignaciones %></strong>
                <small>Permisos activos asignados</small>
            </article>
            <article class="stat">
                <h3>Rol Seleccionado</h3>
                <strong><%= detalle != null ? detalle[1] : "-" %></strong>
                <small><%= detalle != null ? detalle[2] + "/" + detalle[3] + " permisos" : "Sin seleccion" %></small>
            </article>
        </section>

        <form method="get" action="${pageContext.request.contextPath}/roles" class="toolbar toolbar-simple">
            <input type="hidden" name="page" value="1">
            <input type="text" name="q" value="<%= q %>" placeholder="Buscar rol por nombre">
            <button type="submit">Buscar</button>
            <a class="btn-cancel" href="${pageContext.request.contextPath}/roles">Limpiar</a>
        </form>

        <section class="donaciones-layout">
            <article class="panel">
                <h3>Roles (<%= totalRows %>)</h3>
                <p class="muted">Pagina <%= currentPage %> de <%= totalPages %> - <%= request.getAttribute("pageSize") %> por pagina</p>
                <%
                    if (roles != null && !roles.isEmpty()) {
                        for (String[] row : roles) {
                            String activeClass = (selectedId != null && String.valueOf(selectedId).equals(row[0])) ? "rol-item active" : "rol-item";
                            String detailUrl = request.getContextPath() + "/roles?id=" + row[0] + "&q=" + encQ + "&page=" + currentPage;
                            String editUrl = request.getContextPath() + "/roles?editarId=" + row[0] + "&q=" + encQ + "&page=" + currentPage;
                %>
                <div class="<%= activeClass %>">
                    <div class="rol-item-head">
                        <a class="item-link" href="<%= detailUrl %>"><strong><%= row[1] %></strong></a>
                        <span class="badge badge-entregado"><%= row[2] %>/<%= row[3] %> permisos</span>
                        <span class="date"><%= row[4] %> usuarios</span>
                    </div>
                    <div class="row-actions">
                        <a class="btn-mini btn-edit" href="<%= editUrl %>">Editar</a>
                        <%
                            if (!"1".equals(row[0])) {
                        %>
                        <form method="post" action="${pageContext.request.contextPath}/roles" class="inline-form">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="id" value="<%= row[0] %>">
                            <button class="btn-mini btn-danger" type="submit">Eliminar</button>
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
                <p class="muted">No se encontraron roles.</p>
                <%
                    }
                %>
                <%
                    if (totalPages > 1) {
                %>
                <div class="pagination pagination-tight">
                    <%
                        if (currentPage > 1) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/roles?page=<%= currentPage - 1 %>&q=<%= encQ %>">Anterior</a>
                    <%
                        }
                    %>
                    <span class="page-link current"><%= currentPage %> / <%= totalPages %></span>
                    <%
                        if (currentPage < totalPages) {
                    %>
                    <a class="page-link" href="${pageContext.request.contextPath}/roles?page=<%= currentPage + 1 %>&q=<%= encQ %>">Siguiente</a>
                    <%
                        }
                    %>
                </div>
                <%
                    }
                %>
            </article>

            <aside class="panel">
                <%
                    if (showForm) {
                %>
                <h3><%= edicion != null ? "Editar Rol" : "Nuevo Rol" %></h3>
                <form method="post" action="${pageContext.request.contextPath}/roles" class="form-grid">
                    <input type="hidden" name="accion" value="<%= edicion != null ? "editar" : "crear" %>">
                    <%
                        if (edicion != null) {
                    %>
                    <input type="hidden" name="id_rol" value="<%= edicion[0] %>">
                    <%
                        }
                    %>
                    <div class="full">
                        <label>Nombre del rol</label>
                        <input type="text" name="nombre" required value="<%= edicion != null ? edicion[1] : "" %>">
                    </div>
                    <div class="full form-actions">
                        <button type="submit"><%= edicion != null ? "Guardar Cambios" : "Crear Rol" %></button>
                        <a class="btn-cancel" href="${pageContext.request.contextPath}/roles?<%= selectedId != null ? ("id=" + selectedId + "&") : "" %>page=<%= currentPage %>&q=<%= encQ %>">Cancelar</a>
                    </div>
                </form>
                <%
                    } else if (showPermissionForm) {
                %>
                <h3>Nuevo Permiso</h3>
                <form method="post" action="${pageContext.request.contextPath}/roles" class="form-grid">
                    <input type="hidden" name="accion" value="crear_permiso">
                    <input type="hidden" name="selected_id" value="<%= selectedId != null ? selectedId : "" %>">
                    <div>
                        <label>Codigo</label>
                        <input type="text" name="codigo" required placeholder="Ej: DONACIONES_EXPORTAR">
                    </div>
                    <div>
                        <label>Nombre</label>
                        <input type="text" name="nombre" required placeholder="Ej: Exportar Donaciones">
                    </div>
                    <div class="full">
                        <label>Descripcion</label>
                        <textarea name="descripcion" rows="3" placeholder="Describe para que sirve este permiso"></textarea>
                    </div>
                    <div class="full form-actions">
                        <button type="submit">Crear Permiso</button>
                        <a class="btn-cancel" href="${pageContext.request.contextPath}/roles?<%= selectedId != null ? ("id=" + selectedId + "&") : "" %>page=<%= currentPage %>&q=<%= encQ %>">Cancelar</a>
                    </div>
                </form>
                <%
                    } else {
                %>
                <h3>Permisos del Rol</h3>
                <%
                    if (detalle != null) {
                %>
                <div class="detail-list">
                    <p><strong>Rol:</strong> <%= detalle[1] %></p>
                    <p><strong>Permisos activos:</strong> <%= detalle[2] %> / <%= detalle[3] %></p>
                    <p><strong>Usuarios asignados:</strong> <%= detalle[4] %></p>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/roles">
                    <input type="hidden" name="accion" value="guardar_permisos">
                    <input type="hidden" name="id_rol" value="<%= detalle[0] %>">
                    <div class="perm-grid">
                        <%
                            if (permisosRol != null && !permisosRol.isEmpty()) {
                                for (String[] permiso : permisosRol) {
                                    boolean checked = "1".equals(permiso[4]);
                        %>
                        <label class="perm-row">
                            <input type="checkbox" name="permiso" value="<%= permiso[0] %>" <%= checked ? "checked" : "" %>>
                            <span>
                                <strong><%= permiso[2] %></strong>
                                <small><%= permiso[1] %> - <%= permiso[3] %></small>
                            </span>
                        </label>
                        <%
                                }
                            }
                        %>
                    </div>
                    <button type="submit">Guardar Permisos</button>
                </form>
                <%
                    } else {
                %>
                <p class="muted">Selecciona un rol para administrar permisos.</p>
                <%
                    }
                %>
                <%
                    }
                %>
            </aside>
        </section>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>

