<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<!-- Chatbox chính -->
<div id="ai-chatbox" 
     style="position:fixed;
     bottom:100px;
     right:100px;
     width:350px;
     height:500px;
     background:#fff;
     border-radius:18px;
     box-shadow:0 6px 18px rgba(0,0,0,0.15);
     display:none;
     flex-direction:column;
     overflow:hidden;
     z-index:99999;
     font-family:'Quicksand',sans-serif;">

    <!-- Header -->
    <div style="background:linear-gradient(135deg,#38bdf8,#60a5fa);
         color:white;
         padding:12px;
         text-align:center;
         font-weight:600;
         position:relative;">
        💬 Pet4Cares chatbot
        <span onclick="document.getElementById('ai-chatbox').style.display = 'none'"
              style="position:absolute;right:15px;top:6px;cursor:pointer;font-weight:bold;">×</span>
    </div>

    <!-- Nội dung chat -->
    <div id="ai-messages" 
         style="flex:1;padding:10px;overflow-y:auto;font-size:14px;line-height:1.5;color:#333;background:#f9fafb;">
    </div>

    <!-- Input -->
    <div style="display:flex;border-top:1px solid #e5e7eb;padding:8px;background:#fff;">
        <input id="ai-input" type="text" placeholder="Nhập tin nhắn..."
               style="flex:1;border:1px solid #e5e7eb;padding:8px 10px;border-radius:10px;outline:none;">
        <button onclick="sendAIMessage()"
                style="background:linear-gradient(135deg,#38bdf8,#60a5fa);
                color:white;border:none;padding:8px 12px;
                border-radius:10px;margin-left:6px;cursor:pointer;font-weight:600;">
            Gửi
        </button>
    </div>
</div>

<!-- Icon mở chatbot -->
<div onclick="toggleAIChat()"
     style="position:fixed;
     bottom:25px;
     right:100px;
     width:60px;
     height:60px;
     background:linear-gradient(135deg,#38bdf8,#60a5fa);
     color:white;
     border-radius:50%;
     display:flex;
     align-items:center;
     justify-content:center;
     font-size:28px;
     box-shadow:0 6px 18px rgba(0,0,0,0.25);
     cursor:pointer;
     z-index:99999;">
    🤖
</div>



<script>
    async function sendAIMessage() {
        const input = document.getElementById('ai-input');
        const text = input.value.trim();
        if (!text)
            return;

        const msgBox = document.getElementById('ai-messages');

        // Hiển thị tin nhắn người dùng
        const userMsg = document.createElement('div');
        userMsg.innerHTML = text;
        userMsg.style = `
        background: #38bdf8;
        color: white;
        padding: 8px 12px;
        border-radius: 16px 16px 0 16px;
        margin: 6px 0;
        max-width: 80%;
        align-self: flex-end;
        margin-left: auto;
        text-align: left;
        word-wrap: break-word;
    `;
        msgBox.appendChild(userMsg);

        input.value = '';

        // Hiển thị trạng thái đang gõ
        const typing = document.createElement('div');
        typing.textContent = '🤖 Đang trả lời...';
        typing.style = `
        font-style: italic;
        color: #999;
        margin: 6px 0;
    `;
        msgBox.appendChild(typing);
        msgBox.scrollTop = msgBox.scrollHeight;

        try {
            const res = await fetch("http://127.0.0.1:5000/chat", {
                method: "POST",
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({message: text})
            });

            const data = await res.json();
            typing.remove();

            // Hiển thị tin nhắn AI
            const botMsg = document.createElement('div');
            botMsg.innerHTML = data.reply;
            botMsg.style = `
            background: #e5e7eb;
            color: #111;
            padding: 8px 12px;
            border-radius: 16px 16px 16px 0;
            margin: 6px 0;
            max-width: 80%;
            align-self: flex-start;
            margin-right: auto;
            text-align: left;
            word-wrap: break-word;
        `;
            msgBox.appendChild(botMsg);
            msgBox.scrollTop = msgBox.scrollHeight;

        } catch (err) {
            typing.remove();
            const errMsg = document.createElement('div');
            errMsg.style.color = 'red';
            errMsg.textContent = '⚠️ Lỗi: không thể kết nối tới chatbot Flask.';
            msgBox.appendChild(errMsg);
        }
    }
    document.getElementById('ai-input').addEventListener('keypress', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault(); // chặn xuống dòng
            sendAIMessage();
        }
    });
    function toggleAIChat() {
        const aiBox = document.getElementById('ai-chatbox');
        const petChat = document.getElementById('chat-popup'); // nếu có chat khách hàng

        // Nếu chat khách hàng đang mở thì tắt
        if (petChat && petChat.style.display === "flex") {
            petChat.style.display = "none";
        }

        // Toggle AI chat
        if (aiBox.style.display === "none" || aiBox.style.display === "") {
            aiBox.style.display = "flex";
        } else {
            aiBox.style.display = "none";
        }
    }
</script>