<%@ page import="jakarta.servlet.http.Cookie" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    if (session != null) {
        session.invalidate();
    }

    Cookie justLoggedOut = new Cookie("justLoggedOut", "true");
    justLoggedOut.setMaxAge(60); 
    justLoggedOut.setPath("/");
    response.addCookie(justLoggedOut);

    response.sendRedirect("login");
%>
