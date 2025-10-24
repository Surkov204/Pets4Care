<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,model.ChatMessage" %>
<%
    List<ChatMessage> messages = (List<ChatMessage>) request.getAttribute("messages");
    if (messages != null) {
        for (ChatMessage msg : messages) {
            String cls = msg.getSenderType().equals("customer") ? "customer" : "staff";
%>
<div class="chat-msg <%= cls %>">
    <div class="bubble"><%= msg.getMessage() %></div>
</div>
<%
        }
    }
%>
