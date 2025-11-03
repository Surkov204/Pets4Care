<%@ page contentType="text/html;charset=UTF-8" language="java" import="model.Customer" %>
<%
    model.Customer customer = (model.Customer) session.getAttribute("currentUser");
%>

<!-- Nút icon chat nổi -->
<div id="chat-icon" onclick="toggleChat()">💬</div>

<!-- Chatbox popup (ẩn mặc định) -->
<div id="chat-popup" class="chat-container" style="display:none;">
    <div class="chat-header">
        💬 Hỗ trợ khách hàng
        <button class="close-btn" onclick="toggleChat()">−</button>
    </div>
    <div class="chat-body" id="chatBody"></div>
    <div class="chat-footer">
        <input type="text" id="chatInput" placeholder="Nhập tin nhắn..." 
               onkeydown="if (event.key === 'Enter')
                           sendChat()">
        <button onclick="sendChat()">Gửi</button>
    </div>
</div>

<style>
    /* === Popup style === */
    #chat-icon {
        position: fixed;
        bottom: 25px;
        right: 25px;
        background: #38bdf8;
        color: white;
        width: 60px;
        height: 60px;
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 28px;
        cursor: pointer;
        box-shadow: 0 6px 12px rgba(0,0,0,0.2);
        z-index: 9999;
        transition: transform 0.25s ease;
    }
    #chat-icon:hover {
        transform: scale(1.1);
    }

    .chat-container {
        position: fixed;
        bottom: 100px;
        right: 25px;
        width: 360px;
        height: 520px;
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 8px 20px rgba(0,0,0,0.25);
        display: flex;
        flex-direction: column;
        font-family: 'Quicksand', sans-serif;
        overflow: hidden;
        z-index: 9998;
        animation: slideUp 0.3s ease;
    }
    @keyframes slideUp {
        from {
            transform: translateY(60px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
    .chat-header {
        background: #38bdf8;
        color: white;
        padding: 15px;
        font-size: 16px;
        font-weight: bold;
        text-align: center;
        position: relative;
    }
    .chat-header .close-btn {
        position: absolute;
        top: 8px;
        right: 15px;
        background: none;
        border: none;
        color: white;
        font-size: 20px;
        cursor: pointer;
    }
    .chat-body {
        flex: 1;
        overflow-y: auto;
        padding: 10px;
        background: #f8fafc;
    }
    .chat-footer {
        display: flex;
        border-top: 1px solid #e2e8f0;
        padding: 10px;
        background: #fff;
    }
    .chat-footer input {
        flex: 1;
        border: none;
        outline: none;
        background: #f1f5f9;
        padding: 10px;
        font-size: 14px;
        border-radius: 8px;
    }
    .chat-footer button {
        background: #38bdf8;
        color: white;
        border: none;
        padding: 0 15px;
        margin-left: 8px;
        border-radius: 8px;
        font-weight: bold;
        cursor: pointer;
    }
    .chat-footer button:hover {
        background: #0ea5e9;
    }
    .message {
        margin-bottom: 10px;
        display: flex;
    }
    .message.sent {
        justify-content: flex-end;
    }
    .message.received {
        justify-content: flex-start;
    }
    .bubble {
        padding: 10px 14px;
        border-radius: 18px;
        max-width: 70%;
        word-wrap: break-word;
    }
    .sent .bubble {
        background: #38bdf8;
        color: white;
        border-radius: 18px 18px 0 18px;
    }
    .received .bubble {
        background: #e2e8f0;
        color: #111;
        border-radius: 18px 18px 18px 0;
    }
</style>

<script>
    const customerId = <%= (customer != null) ? customer.getCustomerId() : -1%>;
    const chatBody = document.getElementById("chatBody");
    const chatInput = document.getElementById("chatInput");
    const popup = document.getElementById("chat-popup");

    function toggleChat() {
        // Lấy box AI chatbot (nếu có)
        const aiBox = document.getElementById("ai-chatbox");

        // Nếu AI chatbot đang mở thì ẩn đi
        if (aiBox && aiBox.style.display === "flex") {
            aiBox.style.display = "none";
        }

        // Toggle chat khách hàng
        if (popup.style.display === "none" || popup.style.display === "") {
            popup.style.display = "flex";
            popup.style.zIndex = "100001"; // Đảm bảo nằm trên AI
        } else {
            popup.style.display = "none";
        }
    }


    function loadMessages() {
        if (customerId <= 0)
            return;

        fetch("<%=request.getContextPath()%>/chat?action=get&customerId=" + customerId)
                .then(res => res.json())
                .then(messages => {
                    chatBody.innerHTML = "";

                    messages.forEach(m => {
                        const div = document.createElement("div");
                        div.classList.add("message");

                        if (m.senderType.toLowerCase() === "customer") {
                            div.classList.add("sent");
                        } else {
                            div.classList.add("received");
                        }

                        const bubble = document.createElement("div");
                        bubble.classList.add("bubble");
                        bubble.textContent = m.message;

                        div.appendChild(bubble);
                        chatBody.appendChild(div);
                    });

                    chatBody.scrollTop = chatBody.scrollHeight;
                })
                .catch(err => console.error("Load chat error:", err));
    }

    function sendChat() {
        const msg = chatInput.value.trim();
        if (!msg || customerId <= 0)
            return;

        // 👇 hiển thị tạm tin nhắn mới gửi trên giao diện
        const div = document.createElement("div");
        div.classList.add("message", "sent");

        const bubble = document.createElement("div");
        bubble.classList.add("bubble");
        bubble.textContent = msg;

        div.appendChild(bubble);
        chatBody.appendChild(div);
        chatBody.scrollTop = chatBody.scrollHeight;

        // reset input
        chatInput.value = "";

        // gửi về server
        const params = "action=send"
                + "&customerId=" + customerId
                + "&senderType=customer"
                + "&message=" + encodeURIComponent(msg);

        fetch("<%=request.getContextPath()%>/chat", {
            method: "POST",
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: params
        }).catch(err => console.error("Send error:", err));
    }

    if (customerId > 0) {
        loadMessages();
        setInterval(loadMessages, 3000); // 3 giây cập nhật lại tin nhắn
    }

    // ✅ Enter = gửi, Shift+Enter = xuống dòng
    chatInput.addEventListener("keydown", function (e) {
        if (e.key === "Enter" && !e.shiftKey) {
            e.preventDefault();
            sendChat();
        }
    });
</script>
