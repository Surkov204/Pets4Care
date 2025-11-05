<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Giữ nguyên các tham số truy vấn hiện có và chuyển hướng tới trang hoá đơn huỷ chuẩn
    String query = request.getQueryString();
    String target = request.getContextPath() + "/order/invoice-cancelled.jsp" + (query != null ? ("?" + query) : "");
    response.sendRedirect(target);
%>
