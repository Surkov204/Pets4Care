<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Deploy</title>
</head>
<body>
    <h1>✅ Deploy thành công!</h1>
    <p>Thời gian: <%= new java.util.Date() %></p>
    <p>Session ID: <%= session.getId() %></p>
    <a href="<%= request.getContextPath()%>/home">Về trang chủ</a>
</body>
</html>
