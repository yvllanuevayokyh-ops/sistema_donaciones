<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String msg = (String) session.getAttribute("mensaje");
    if (msg != null) {
        session.removeAttribute("mensaje");
%>
<p class="flash <%=msg.startsWith("Error") ? "flash-error" : "flash-ok"%>"><%= msg %></p>
<%
    }
%>
