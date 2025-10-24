<%@page import="service.SpaBookingService"%>
<%@page import="model.PetServiceModel"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    SpaBookingService spaService = new SpaBookingService();
    List<PetServiceModel> spaServices = spaService.getActiveSpaServices();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Test Spa Services</title>
</head>
<body>
    <h1>Test Spa Services</h1>
    <p>Số lượng dịch vụ spa: <%= spaServices != null ? spaServices.size() : "null" %></p>
    
    <% if (spaServices != null && !spaServices.isEmpty()) { %>
        <h2>Danh sách dịch vụ spa:</h2>
        <ul>
            <% for (PetServiceModel service : spaServices) { %>
                <li>
                    <strong><%= service.getName() %></strong> - 
                    <%= service.getPrice() %>₫ - 
                    <%= service.getDuration() %> phút
                    <br>
                    <em><%= service.getDescription() %></em>
                </li>
            <% } %>
        </ul>
    <% } else { %>
        <p>Không có dịch vụ spa nào được tìm thấy.</p>
    <% } %>
</body>
</html>
