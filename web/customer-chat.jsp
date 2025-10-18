<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("currentUser");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chat hỗ trợ khách hàng</title>
    <style>
        body {
            font-family: 'Quicksand', sans-serif;
            background: #f1f5f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .chat-container {
            width: 420px;
            height: 600px;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .chat-header {
            background: #38bdf8;
            color: white;
            padding: 15px;
            font-size: 18px;
            font-weight: bold;
            text-align: center;
        }
        .chat-body {
            flex: 1;
            overflow-y: auto;
            padding: 15px;
            background: #f8fafc;
        }
        .message { margin-bottom: 10px; display: flex; }
        .message.sent { justify-content: flex-end; }
        .message.received { justify-content: flex-start; }
        .bubble {
            padding: 10px 14px;
            border-radius: 18px;
            max-width: 70%;
            word-wrap: break-word;
        }
        .sent .bubble { background: #38bdf8; color: white; border-radius: 18px 18px 0 18px; }
        .received .bubble { background: #e2e8f0; color: #111; border-radius: 18px 18px 18px 0; }
        .chat-footer {
            display: flex;
            border-top: 1px solid #e2e8f0;
            padding: 10px;
            background: white;
        }
        .chat-footer input {
            flex: 1;
            border: none;
            outline: none;
            font-size: 14px;
            padding: 10px;
            border-radius: 8px;
            background: #f1f5f9;
        }
        .chat-footer button {
            background: #38bdf8;
            color: white;
            border: none;
            padding: 0 15px;
            margin-left: 10px;
            cursor: pointer;
            border-radius: 8px;
            font-weight: bold;
        }
        .chat-footer button:hover {
            background: #0ea5e9;
        }
    </style>
</head>

<body>
<div class="chat-container">
    <div class="chat-header">💬 Hỗ trợ khách hàng</div>
    <div class="chat-body" id="chatBody"></div>
    <div class="chat-footer">
        <input type="text" id="chatInput" placeholder="Nhập tin nhắn..." onkeydown="if(event.key==='Enter') sendChat()">
        <button onclick="sendChat()">Gửi</button>
    </div>
</div>

<script>
const customerId = <%= customer.getCustomerId() %>;
const chatBody = document.getElementById("chatBody");
const chatInput = document.getElementById("chatInput");

function loadMessages() {
    fetch("<%=request.getContextPath()%>/chat?action=get&customerId=" + customerId)
        .then(res => {
            if (!res.ok) throw new Error("Server returned " + res.status);
            return res.text();
        })
        .then(html => {
            chatBody.innerHTML = html;
            chatBody.scrollTop = chatBody.scrollHeight;
        })
        .catch(err => console.error("Load chat error:", err));
}

function sendChat() {
    const msg = chatInput.value.trim();
    if (!msg) return;

    fetch("<%=request.getContextPath()%>/chat", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: "action=send&customerId=" + customerId +
              "&senderType=customer&message=" + encodeURIComponent(msg)
    })
    .then(res => {
        if (res.ok) {
            chatInput.value = "";
            loadMessages();
        } else {
            alert("Không gửi được tin nhắn!");
        }
    })
    .catch(err => console.error("Send error:", err));
}

loadMessages();
setInterval(loadMessages, 3000);
</script>
</body>
</html>
