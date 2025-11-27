// File: logout.jsp
<%@ page language="java" %>
<%
    if (session != null) {
        session.invalidate();
    }
    // Redirects to the login page (which is loaded via safe GET)
    response.sendRedirect("login.jsp"); 
%>