<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>💬 Chat with Customer | Pet4Care</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            /* Layout tổng thể */
            .messenger-container {
                display: flex;
                height: calc(100vh - 120px);
                background: #f0f2f5;
                border-radius: 12px;
                overflow: hidden;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            /* Sidebar danh sách cuộc trò chuyện */
            .conversations-sidebar {
                width: 350px;
                background: white;
                border-right: 1px solid #e4e6ea;
                display: flex;
                flex-direction: column;
            }
            .conversations-header {
                padding: 20px;
                border-bottom: 1px solid #e4e6ea;
                background: #f8f9fa;
            }
            .conversations-header h3 {
                margin: 0;
                color: #1c1e21;
                font-size: 20px;
                font-weight: 600;
            }
            .search-conversations {
                margin-top: 15px;
                position: relative;
            }
            .search-conversations input {
                width: 100%;
                padding: 10px 15px 10px 40px;
                border: 1px solid #e4e6ea;
                border-radius: 20px;
                font-size: 14px;
            }
            .search-conversations i {
                position: absolute;
                left: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #8a8d91;
            }
            .conversations-list {
                flex: 1;
                overflow-y: auto;
            }
            .conversation-item {
                display: flex;
                align-items: center;
                padding: 12px 20px;
                cursor: pointer;
                border-bottom: 1px solid #f0f2f5;
                transition: background-color 0.2s;
            }
            .conversation-item:hover {
                background: #f8f9fa;
            }
            .conversation-item.active {
                background: #e7f3ff;
                border-right: 3px solid #1877f2;
            }
            .conversation-avatar {
                width: 50px;
                height: 50px;
                border-radius: 50%;
                background: linear-gradient(45deg, #1877f2, #42a5f5);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: 600;
                font-size: 18px;
                margin-right: 12px;
            }
            .conversation-info {
                flex: 1;
                min-width: 0;
            }
            .conversation-name {
                font-weight: 600;
                color: #1c1e21;
                font-size: 15px;
            }
            .conversation-preview {
                color: #8a8d91;
                font-size: 13px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            .conversation-time {
                color: #8a8d91;
                font-size: 12px;
                margin-top: 2px;
            }
            /* Khu vực chat */
            .chat-area {
                flex: 1;
                display: flex;
                flex-direction: column;
                background: white;
            }
            .chat-header {
                padding: 15px 20px;
                border-bottom: 1px solid #e4e6ea;
                background: white;
                display: flex;
                align-items: center;
                justify-content: space-between;
            }
            .chat-user-info {
                display: flex;
                align-items: center;
            }
            .chat-user-avatar {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background: linear-gradient(45deg, #1877f2, #42a5f5);
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: 600;
                margin-right: 12px;
            }
            .chat-user-details h4 {
                margin: 0;
                color: #1c1e21;
                font-size: 16px;
                font-weight: 600;
            }
            .messages-container {
                flex: 1;
                padding: 20px;
                overflow-y: auto;
                background: #f0f2f5;
            }
            .message-input-area {
                padding: 15px 20px;
                border-top: 1px solid #e4e6ea;
                background: white;
            }
            .message-input-container {
                display: flex;
                align-items: center;
                background: #f0f2f5;
                border-radius: 20px;
                padding: 8px 15px;
            }
            .message-input {
                flex: 1;
                border: none;
                background: transparent;
                padding: 8px 0;
                font-size: 14px;
                outline: none;
                resize: none;
                max-height: 100px;
            }
            .send-button {
                width: 35px;
                height: 35px;
                border-radius: 50%;
                border: none;
                background: #1877f2;
                color: white;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-left: 10px;
                transition: background-color 0.2s;
            }
            .send-button:hover {
                background: #166fe5;
            }
            .search-conversations {
                margin-top: 15px;
                position: relative;
                width: 100%;
                box-sizing: border-box;
                padding-right: 10px;
            }
            .search-conversations input {
                width: 100%;
                box-sizing: border-box;
            }
        </style>
    </head>
    <body>
        <header class="staff-header">
            <div class="logo-section">
                <img src="${pageContext.request.contextPath}/images/logo.png" alt="Pet4Care">
                <div>
                    <h1>Pet4Care</h1>
                    <p>Staff Dashboard</p>
                </div>
            </div>
            <div class="user-section">
                <div class="notif"><i class="fas fa-bell"></i></div>
                <div class="chat"><i class="fas fa-comments"></i></div>
                <div class="avatar">
                    <img src="${pageContext.request.contextPath}/images/staff-avatar.png" alt="Staff">
                    <span>${sessionScope.staff.name}</span>
                </div>
                <form action="logout" method="post">
                    <button class="logout-btn"><i class="fas fa-sign-out-alt"></i></button>
                </form>
            </div>
        </header>

        <div class="staff-wrapper">
            <aside class="staff-sidebar">
                <ul>
                    <li><a href="${pageContext.request.contextPath}/staff/dashboard.jsp">
                            <i class="fas fa-home"></i> Dashboard
                        </a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/viewOrder"><i class="fas fa-receipt"></i> View Orders</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/mySchedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a>
                    <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-user"></i> Customer Profile</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Services Booking</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/chatCustomer" class="active"><i class="fas fa-comments"></i> Chat with Customer</a></li>
                    <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
                </ul>
            </aside>

            <main class="staff-content">
                <section class="recent-section">
                    <h2><i class="fas fa-comments"></i> Chat with Customers</h2>
                    <p style="color: var(--text-light); margin-bottom: 1rem;">Giao tiếp với khách hàng một cách dễ dàng và nhanh chóng 💬</p>

                    <div class="messenger-container">
                        <!-- Sidebar -->
                        <div class="conversations-sidebar">
                            <div class="conversations-header">
                                <h3>Cuộc trò chuyện</h3>
                                <div class="search-conversations">
                                    <i class="fas fa-search"></i>
                                    <input type="text" placeholder="Tìm kiếm..." id="searchConversations">
                                </div>
                            </div>
                            <div class="conversations-list" id="conversationsList">
                                <p style="padding:15px;color:#888;">Đang tải danh sách...</p>
                            </div>
                        </div>

                        <!-- Chat area -->
                        <div class="chat-area">
                            <div class="chat-header">
                                <div class="chat-user-info">
                                    <div class="chat-user-avatar" id="chatUserAvatar">?</div>
                                    <div class="chat-user-details">
                                        <h4 id="chatUserName">Chưa chọn khách</h4>
                                        <p id="chatUserStatus">Chọn khách hàng bên trái để bắt đầu chat</p>
                                    </div>

                                </div>
                            </div>
                            <div class="messages-container" id="messagesContainer">
                                <p style="color:#999;text-align:center;margin-top:50px;">Chưa có tin nhắn nào</p>
                            </div>
                            <div class="message-input-area">
                                <div class="message-input-container">
                                    <textarea class="message-input" placeholder="Nhập tin nhắn..." id="messageInput" rows="1"></textarea>
                                    <button class="send-button" id="sendButton" onclick="sendStaffMessage()">
                                        <i class="fas fa-paper-plane"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            </main>
        </div>

        <footer class="staff-footer">
            <p>© 2025 Pet4Care — Where Pets Feel Loved 🐶🐱</p>
        </footer>

        <script>
            const ctx = "${pageContext.request.contextPath}";
            const baseUrl = ctx + "/chat";

            let currentCustomerId = null;

            // 🔹 Load danh sách cuộc trò chuyện
            function loadChatSessions() {
                console.log("📡 Fetch sessions from:", baseUrl + "?action=getSessions");

                fetch(baseUrl + "?action=getSessions")
                        .then(res => res.json())
                        .then(data => {
                            console.log("✅ Sessions data:", data);
                            const list = document.getElementById("conversationsList");
                            list.innerHTML = "";

                            if (!data || data.length === 0) {
                                list.innerHTML = "<p style='padding:15px;color:#888;'>Chưa có cuộc trò chuyện nào</p>";
                                return;
                            }

                            for (const s of data) {
                                const item = document.createElement("div");
                                item.className = "conversation-item";
                                item.dataset.customerId = s.customerId;
                                // ✅ Lưu lowercase name để tìm kiếm
                                item.dataset.name = (s.customerName || ("Khách hàng #" + s.customerId)).toLowerCase();

                                const avatarText = (s.customerName ? s.customerName.substring(0, 2) : "??").toUpperCase();
                                const displayName = s.customerName || ("Khách hàng #" + s.customerId);
                                const startedText = s.startedAt || "";

                                item.innerHTML =
                                        "<div class='conversation-avatar'>" + avatarText + "</div>" +
                                        "<div class='conversation-info'>" +
                                        "<div class='conversation-name'>" + displayName + "</div>" +
                                        "<div class='conversation-preview'>Nhấn để xem tin nhắn...</div>" +
                                        "<div class='conversation-time'>" + startedText + "</div>" +
                                        "</div>";

                                item.addEventListener("click", function () {
                                    selectCustomer(s.customerId, s.customerName);
                                });

                                list.appendChild(item);
                            }

                            // ✅ Kích hoạt tìm kiếm sau khi render danh sách
                            initSearchConversations();
                        })
                        .catch(err => console.error("❌ Lỗi load danh sách:", err));
            }

            // ✅ Tìm kiếm khách hàng theo tên
            function initSearchConversations() {
                const searchInput = document.getElementById("searchConversations");
                if (!searchInput)
                    return;

                // Lọc khi gõ hoặc nhấn Enter
                const filterList = function () {
                    const keyword = searchInput.value.trim().toLowerCase();
                    const items = document.querySelectorAll(".conversation-item");
                    let visibleCount = 0;

                    items.forEach(item => {
                        const name = item.dataset.name || "";
                        if (name.includes(keyword)) {
                            item.style.display = "flex";
                            visibleCount++;
                        } else {
                            item.style.display = "none";
                        }
                    });

                    const noResult = document.getElementById("noResults");
                    if (visibleCount === 0) {
                        if (!noResult) {
                            const msg = document.createElement("p");
                            msg.id = "noResults";
                            msg.textContent = "Không tìm thấy kết quả";
                            msg.style.padding = "10px";
                            msg.style.color = "#aaa";
                            document.getElementById("conversationsList").appendChild(msg);
                        }
                    } else if (noResult) {
                        noResult.remove();
                    }
                };

                // Gõ từng ký tự
                searchInput.addEventListener("input", filterList);

                // Nhấn Enter
                searchInput.addEventListener("keypress", function (e) {
                    if (e.key === "Enter") {
                        e.preventDefault();
                        filterList();
                    }
                });
            }

            // ✅ Chọn khách hàng
            function selectCustomer(id, name) {
                currentCustomerId = id;

                document.querySelectorAll('.conversation-item').forEach(i => i.classList.remove('active'));
                const selectedItem = document.querySelector("[data-customer-id='" + id + "']");
                if (selectedItem)
                    selectedItem.classList.add('active');

                const avatarText = (name || "??").substring(0, 2).toUpperCase();
                document.getElementById('chatUserName').textContent = name || ("Khách hàng #" + id);
                document.getElementById('chatUserAvatar').textContent = avatarText;
                document.getElementById('chatUserStatus').textContent = "Đang trò chuyện";

                loadStaffChat();
            }

            // ✅ Load tin nhắn
            function loadStaffChat() {
                if (!currentCustomerId)
                    return;

                fetch(baseUrl + "?action=get&customerId=" + currentCustomerId)
                        .then(res => res.json())
                        .then(messages => {
                            const container = document.getElementById("messagesContainer");
                            container.innerHTML = "";

                            if (!messages || messages.length === 0) {
                                container.innerHTML = "<p style='color:#999;text-align:center;margin-top:50px;'>Chưa có tin nhắn nào</p>";
                                return;
                            }

                            for (const m of messages) {
                                const msgDiv = document.createElement("div");
                                msgDiv.style.display = "flex";
                                msgDiv.style.justifyContent = (m.senderType.toLowerCase() === "staff") ? "flex-end" : "flex-start";
                                msgDiv.style.marginBottom = "10px";

                                const bubble = document.createElement("div");
                                bubble.textContent = m.message;
                                bubble.style.padding = "10px 15px";
                                bubble.style.borderRadius = "18px";
                                bubble.style.maxWidth = "70%";
                                bubble.style.wordWrap = "break-word";

                                if (m.senderType.toLowerCase() === "staff") {
                                    bubble.style.background = "#1877f2";
                                    bubble.style.color = "white";
                                    bubble.style.borderRadius = "18px 18px 0 18px";
                                } else {
                                    bubble.style.background = "#e4e6ea";
                                    bubble.style.color = "#111";
                                    bubble.style.borderRadius = "18px 18px 18px 0";
                                }

                                msgDiv.appendChild(bubble);
                                container.appendChild(msgDiv);
                            }

                            container.scrollTop = container.scrollHeight;
                        })
                        .catch(err => console.error("❌ loadStaffChat error:", err));
            }

            // ✅ Gửi tin nhắn
            function sendStaffMessage() {
                const msgInput = document.getElementById("messageInput");
                const text = msgInput.value.trim();
                if (!text || !currentCustomerId)
                    return;

                fetch(baseUrl, {
                    method: "POST",
                    headers: {"Content-Type": "application/x-www-form-urlencoded"},
                    body: "action=send&customerId=" + currentCustomerId + "&senderType=staff&message=" + encodeURIComponent(text)
                })
                        .then(() => {
                            msgInput.value = "";
                            loadStaffChat();
                        })
                        .catch(err => console.error("❌ sendStaffMessage error:", err));
            }

            // ✅ Khởi chạy
            loadChatSessions();
            setInterval(loadStaffChat, 3000);
        </script>
    </body>
</html>
