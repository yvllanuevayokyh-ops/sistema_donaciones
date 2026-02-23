<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:include page="/includes/header.jsp">
    <jsp:param name="titulo" value="Iniciar Sesion - Sistema Donaciones"/>
</jsp:include>
<div class="login-shell">
    <section class="intro">
        <h2>Donaciones</h2>
        <h1>Gestion de Donaciones para Comunidades Vulnerables</h1>
        <p>Sistema simple para probar autenticacion y flujo base del backend.</p>
        <ul>
            <li>Gestion de donaciones</li>
            <li>Multi-rol</li>
            <li>Reportes basicos</li>
        </ul>
    </section>

    <section class="card">
        <h3>Iniciar Sesion</h3>
        <p class="muted">Ingresa tus credenciales para acceder</p>
        <jsp:include page="/includes/alerts.jsp"/>

        <% String error = request.getParameter("error"); %>
        <% if ("1".equals(error)) { %>
            <p class="error">Credenciales invalidas</p>
        <% } else if ("db".equals(error)) { %>
            <p class="error">Error de conexion con base de datos</p>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/login">
            <label>Email</label>
            <input type="email" name="email" required value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
            <label>Contrasena</label>
            <input type="password" name="password" required>
            <button type="submit">Iniciar Sesion</button>
        </form>

        <p class="muted divider">Credenciales de prueba</p>
        <div class="demo-list">
            <div><strong>Administrador</strong><span>admin@donaciones.org / 123456</span></div>
            <div><strong>Institucion Donante</strong><span>institucion@donaciones.org / 123456</span></div>
            <div><strong>Persona Natural</strong><span>persona@email.com / 123456</span></div>
            <div><strong>Comunidad</strong><span>comunidad@donaciones.org / 123456</span></div>
        </div>
    </section>
</div>
<jsp:include page="/includes/footer.jsp"/>
