<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!-- Floating Chat Icon -->
<div id="chat-icon" onclick="toggleChatBox()">💬</div>

<!-- Chat Window -->
<div id="chat-box">
    <div id="chat-header">
        🐾 Pet4Care AI Assistant
        <span id="chat-close" onclick="toggleChatBox()">×</span>
    </div>

    <div id="chat-messages"></div>

    <div class="chat-input-area">
        <input type="text" id="chat-input" placeholder="Hỏi gì đó về thú cưng..." onkeydown="handleKey(event)">
        <button id="chat-send" onclick="sendMessage()">Gửi</button>
    </div>
</div>

<!-- Toast -->
<div id="chat-toast"></div>

<style>
    :root {
        --main-bg: #fffdf8;
        --primary: #6FD5DD;
        --secondary: #FFD6C0;
        --accent: #FFC94D;
        --text: #2f3640;
        --radius: 18px;
        --shadow: 0 4px 12px rgba(0,0,0,0.1);
    }

    #chat-icon {
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: linear-gradient(135deg, var(--primary), var(--secondary));
        color: white;
        padding: 16px;
        font-size: 22px;
        border-radius: 50%;
        cursor: pointer;
        box-shadow: var(--shadow);
        z-index: 5000;
        transition: transform 0.2s;
    }
    #chat-icon:hover {
        transform: scale(1.1);
    }

    #chat-box {
        display: none;
        flex-direction: column;
        position: fixed;
        bottom: 90px;
        right: 20px;
        width: 360px;
        max-height: 80vh;
        background: var(--main-bg);
        border-radius: var(--radius);
        box-shadow: var(--shadow);
        overflow: hidden;
        z-index: 5000;
    }

    #chat-header {
        background: linear-gradient(135deg, var(--primary), var(--secondary));
        color: white;
        font-weight: 700;
        text-align: center;
        padding: 10px;
        position: relative;
    }
    #chat-close {
        position: absolute;
        right: 12px;
        top: 6px;
        cursor: pointer;
        font-size: 18px;
    }

    #chat-messages {
        flex: 1;
        padding: 10px;
        overflow-y: auto;
        font-size: 14px;
    }

    .user-msg, .bot-msg {
        margin: 8px 0;
        padding: 8px 12px;
        border-radius: var(--radius);
        display: inline-block;
        max-width: 80%;
        word-wrap: break-word;
    }
    .user-msg {
        background: #e1f7f9;
        color: #333;
        float: right;
        clear: both;
    }
    .bot-msg {
        background: #fff;
        border-left: 3px solid var(--primary);
        color: #333;
        float: left;
        clear: both;
    }

    .chat-input-area {
        display: flex;
        border-top: 1px solid #ddd;
    }
    .chat-input-area input {
        flex: 1;
        padding: 10px;
        border: none;
        outline: none;
        font-size: 14px;
    }
    .chat-input-area button {
        background: linear-gradient(135deg, var(--primary), var(--secondary));
        color: white;
        border: none;
        padding: 10px 16px;
        cursor: pointer;
        font-weight: 600;
    }
    .chat-input-area button:hover {
        opacity: 0.9;
    }

    #chat-toast {
        display: none;
        position: fixed;
        bottom: 120px;
        right: 40px;
        background: linear-gradient(135deg, var(--primary), var(--secondary));
        color: white;
        padding: 10px 16px;
        border-radius: var(--radius);
        font-weight: 600;
        z-index: 6000;
        box-shadow: var(--shadow);
    }
</style>

<script>
    const messages = document.getElementById("chat-messages");
    const input = document.getElementById("chat-input");

    function toggleChatBox() {
        const box = document.getElementById("chat-box");
        box.style.display = box.style.display === "none" || box.style.display === "" ? "flex" : "none";
    }

    function handleKey(e) {
        if (e.key === "Enter")
            sendMessage();
    }

    function appendMessage(text, isUser = false) {
        const msg = document.createElement("div");
        msg.className = isUser ? "user-msg" : "bot-msg";
        msg.innerHTML = text;
        messages.appendChild(msg);
        messages.scrollTop = messages.scrollHeight;
    }

    function showToast(text) {
        const toast = document.getElementById("chat-toast");
        toast.textContent = text;
        toast.style.display = "block";
        setTimeout(() => toast.style.display = "none", 2000);
    }

    function sendMessage() {
        const text = input.value.trim();
        if (!text)
            return;

        appendMessage("👤 " + text, true);
        input.value = "";

        const typing = document.createElement("div");
        typing.className = "bot-msg";
        typing.textContent = "🤖 Đang gõ...";
        messages.appendChild(typing);
        messages.scrollTop = messages.scrollHeight;

        fetch("<%= request.getContextPath()%>/chatbot", {
            method: "POST",
            headers: {"Content-Type": "text/plain; charset=UTF-8"},
            body: text
        })
                .then(res => res.json())
                .then(data => {
                    typing.remove();
                    appendMessage("🤖 " + data.reply);
                })
                .catch(err => {
                    typing.remove();
                    appendMessage("⚠️ Lỗi khi kết nối máy chủ.");
                    console.error(err);
                });
    }
</script>
