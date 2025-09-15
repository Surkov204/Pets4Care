<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Admin Login</title>
</head>
<body>
    <h2>Login</h2>
    <form action="login" method="post">
        Username: <input type="text" name="username"/><br/>
        Password: <input type="password" name="password"/><br/>
        <input type="submit" value="Login"/>
    </form>
    <p style="color:red">${error}</p>
</body>
</html>