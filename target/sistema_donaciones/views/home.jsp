<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Inicio - Sistema Donaciones"/>
</jsp:include>
<%
    Boolean isDonanteViewObj = (Boolean) request.getAttribute("isDonanteView");
    boolean isDonanteView = isDonanteViewObj != null && isDonanteViewObj;
    Boolean isComunidadViewObj = (Boolean) request.getAttribute("isComunidadView");
    boolean isComunidadView = isComunidadViewObj != null && isComunidadViewObj;
    Boolean perfilDonanteVinculadoObj = (Boolean) request.getAttribute("perfilDonanteVinculado");
    boolean perfilDonanteVinculado = perfilDonanteVinculadoObj != null && perfilDonanteVinculadoObj;
    List<String[]> donacionesRecientes = (List<String[]>) request.getAttribute("donacionesRecientes");
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
            <li class="active"><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/donaciones">Mis Donaciones</a></li>
            <li><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <%
                } else if (isComunidadView) {
            %>
            <li class="active"><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/comunidades">Comunidades</a></li>
            <li><a href="${pageContext.request.contextPath}/campanias">Campanias</a></li>
            <%
                } else {
            %>
            <li class="active"><a href="${pageContext.request.contextPath}/home">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/roles">Roles y Permisos</a></li>
            <li><a href="${pageContext.request.contextPath}/donaciones">Donaciones</a></li>
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
        <h1>Buenas noches, <%= session.getAttribute("usuarioNombre") %></h1>
        <p class="muted">Fecha: <%= request.getAttribute("fechaActual") %></p>

        <%
            if (isDonanteView) {
        %>
        <section class="stats">
            <article class="stat">
                <h3>Mis Donaciones</h3>
                <strong><%= request.getAttribute("misDonaciones") %></strong>
                <small>Donaciones activas registradas</small>
            </article>
            <article class="stat">
                <h3>Pendientes</h3>
                <strong><%= request.getAttribute("misDonacionesPendientes") %></strong>
                <small>Estado pendiente o en transito</small>
            </article>
            <article class="stat">
                <h3>Monto Donado</h3>
                <strong>S/ <%= request.getAttribute("montoDonado") %></strong>
                <small>Aportes monetarios acumulados</small>
            </article>
            <article class="stat">
                <h3>Campanias Activas</h3>
                <strong><%= request.getAttribute("totalCampaniasActivas") %></strong>
                <small>Disponibles para donar</small>
            </article>
        </section>

        <section class="content-grid">
            <article class="panel">
                <h3>Mis Ultimas Donaciones</h3>
                <p class="muted">Resumen de tus aportes recientes</p>
                <%
                    if (!perfilDonanteVinculado) {
                %>
                <p class="muted">No se encontro un perfil donante vinculado a tu cuenta. Solicita al administrador vincular tu email.</p>
                <%
                    } else if (donacionesRecientes != null && !donacionesRecientes.isEmpty()) {
                        for (String[] fila : donacionesRecientes) {
                %>
                <div class="donacion-item">
                    <div>
                        <strong><%= fila[0] %></strong>
                        <span><%= fila[1] %> - <%= fila[4] %></span>
                    </div>
                    <div class="item-right">
                        <strong><%= fila[2] %></strong>
                        <span><%= fila[3] %></span>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <p class="muted">Aun no tienes donaciones registradas.</p>
                <%
                    }
                %>
            </article>

            <article class="panel quick">
                <h3>Accesos Rapidos</h3>
                <div class="metric">
                    <span>Registrar una nueva donacion</span>
                    <strong><a href="${pageContext.request.contextPath}/donaciones?nuevo=1">Ir a Donaciones</a></strong>
                </div>
                <div class="metric">
                    <span>Revisar campanias disponibles</span>
                    <strong><a href="${pageContext.request.contextPath}/campanias">Ver Campanias</a></strong>
                </div>
            </article>
        </section>
        <%
            } else if (isComunidadView) {
        %>
        <section class="stats">
            <article class="stat">
                <h3>Comunidades</h3>
                <strong><%= request.getAttribute("totalComunidades") %></strong>
                <small>Registros disponibles</small>
            </article>
            <article class="stat">
                <h3>Beneficiarios</h3>
                <strong><%= request.getAttribute("totalBeneficiarios") %></strong>
                <small>Poblacion estimada</small>
            </article>
            <article class="stat">
                <h3>Campanias Activas</h3>
                <strong><%= request.getAttribute("totalCampaniasActivas") %></strong>
                <small>Seguimiento de apoyo</small>
            </article>
        </section>

        <section class="content-grid">
            <article class="panel">
                <h3>Donaciones Recientes</h3>
                <p class="muted">Referencia general del sistema</p>
                <%
                    if (donacionesRecientes != null && !donacionesRecientes.isEmpty()) {
                        for (String[] fila : donacionesRecientes) {
                %>
                <div class="donacion-item">
                    <div>
                        <strong><%= fila[0] %></strong>
                        <span><%= fila[1] %> - <%= fila[4] %></span>
                    </div>
                    <div class="item-right">
                        <strong><%= fila[2] %></strong>
                        <span><%= fila[3] %></span>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <p class="muted">No hay donaciones registradas.</p>
                <%
                    }
                %>
            </article>
        </section>
        <%
            } else {
        %>
        <section class="stats">
            <article class="stat">
                <h3>Donaciones Activas</h3>
                <strong><%= request.getAttribute("totalDonaciones") %></strong>
                <small>Total registradas</small>
            </article>
            <article class="stat">
                <h3>Comunidades</h3>
                <strong><%= request.getAttribute("totalComunidades") %></strong>
                <small><%= request.getAttribute("totalBeneficiarios") %> beneficiarios</small>
            </article>
            <article class="stat">
                <h3>Instituciones Donantes</h3>
                <strong><%= request.getAttribute("totalInstituciones") %></strong>
                <small>Donantes institucionales</small>
            </article>
            <article class="stat">
                <h3>Campanias Activas</h3>
                <strong><%= request.getAttribute("totalCampaniasActivas") %></strong>
                <small>Recaudacion en curso</small>
            </article>
        </section>

        <section class="content-grid">
            <article class="panel">
                <h3>Donaciones Recientes</h3>
                <p class="muted">Ultimas donaciones registradas</p>
                <%
                    if (donacionesRecientes != null && !donacionesRecientes.isEmpty()) {
                        for (String[] fila : donacionesRecientes) {
                %>
                <div class="donacion-item">
                    <div>
                        <strong><%= fila[0] %></strong>
                        <span><%= fila[1] %> - <%= fila[4] %></span>
                    </div>
                    <div class="item-right">
                        <strong><%= fila[2] %></strong>
                        <span><%= fila[3] %></span>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <p class="muted">No hay donaciones registradas.</p>
                <%
                    }
                %>
            </article>

            <article class="panel quick">
                <h3>Resumen Rapido</h3>
                <div class="metric">
                    <span>Voluntarios Activos</span>
                    <strong><%= request.getAttribute("voluntariosActivos") %></strong>
                </div>
                <div class="metric">
                    <span>Tasa de Entregas</span>
                    <strong><%= request.getAttribute("tasaEntregas") %>%</strong>
                </div>
                <div class="metric">
                    <span>Campanias Completadas</span>
                    <strong><%= request.getAttribute("campaniasCompletadas") %> / <%= request.getAttribute("totalCampanias") %></strong>
                </div>
            </article>
        </section>
        <%
            }
        %>
    </main>
</div>
<jsp:include page="/includes/footer.jsp"/>

