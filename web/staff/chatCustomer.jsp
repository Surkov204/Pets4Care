<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Chat with Customer</title>
    <script src="${pageContext.request.contextPath}/js/chat.js"></script>
</head>
<body>
    <h2>Chat with Customer</h2>
    <div id="chat-box"></div>
    <form id="chat-form">
        <input type="text" id="message" placeholder="Type message...">
        <button type="submit">Send</button>
    </form>
</body>
</html>
