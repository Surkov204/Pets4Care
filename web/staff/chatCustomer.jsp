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
        /* Messenger-like Chat Interface */
        .messenger-container {
            display: flex;
            height: calc(100vh - 120px);
            background: #f0f2f5;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        /* Left Sidebar - Conversations List */
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
            background: white;
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
            margin-bottom: 2px;
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

        .unread-badge {
            background: #1877f2;
            color: white;
            border-radius: 10px;
            padding: 2px 6px;
            font-size: 11px;
            font-weight: 600;
            margin-top: 4px;
        }

        /* Right Side - Chat Area */
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

        .chat-user-details p {
            margin: 0;
            color: #8a8d91;
            font-size: 12px;
        }

        .chat-actions {
            display: flex;
            gap: 10px;
        }

        .chat-action-btn {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            border: none;
            background: #f0f2f5;
            color: #8a8d91;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.2s;
        }

        .chat-action-btn:hover {
            background: #e4e6ea;
        }

        .messages-container {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #f0f2f5;
        }

        .message {
            display: flex;
            margin-bottom: 15px;
            animation: fadeIn 0.3s ease-in;
        }

        .message.sent {
            justify-content: flex-end;
        }

        .message.received {
            justify-content: flex-start;
        }

        .message-bubble {
            max-width: 70%;
            padding: 10px 15px;
            border-radius: 18px;
            font-size: 14px;
            line-height: 1.4;
            word-wrap: break-word;
        }

        .message.sent .message-bubble {
            background: #1877f2;
            color: white;
            border-bottom-right-radius: 4px;
        }

        .message.received .message-bubble {
            background: white;
            color: #1c1e21;
            border-bottom-left-radius: 4px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
        }

        .message-time {
            font-size: 11px;
            color: #8a8d91;
            margin-top: 4px;
            text-align: right;
        }

        .message.received .message-time {
            text-align: left;
        }

        .typing-indicator {
            display: flex;
            align-items: center;
            padding: 10px 15px;
            background: white;
            border-radius: 18px;
            border-bottom-left-radius: 4px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
            margin-bottom: 15px;
        }

        .typing-dots {
            display: flex;
            gap: 3px;
        }

        .typing-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: #8a8d91;
            animation: typing 1.4s infinite;
        }

        .typing-dot:nth-child(2) {
            animation-delay: 0.2s;
        }

        .typing-dot:nth-child(3) {
            animation-delay: 0.4s;
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

        .message-input::placeholder {
            color: #8a8d91;
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

        .send-button:disabled {
            background: #8a8d91;
            cursor: not-allowed;
        }

        .attachment-button {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            border: none;
            background: transparent;
            color: #8a8d91;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
            transition: background-color 0.2s;
        }

        .attachment-button:hover {
            background: #e4e6ea;
        }

        /* Empty State */
        .empty-chat {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #8a8d91;
            text-align: center;
        }

        .empty-chat i {
            font-size: 64px;
            margin-bottom: 20px;
            color: #e4e6ea;
        }

        .empty-chat h3 {
            margin: 0 0 10px 0;
            color: #1c1e21;
        }

        .empty-chat p {
            margin: 0;
            font-size: 14px;
        }

        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes typing {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-10px); }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .conversations-sidebar {
                width: 100%;
            }
            
            .chat-area {
                display: none;
            }
            
            .chat-area.active {
                display: flex;
            }
        }
        
        /* Dropdown Menu Styles */
        .avatar-dropdown {
            position: relative;
            display: inline-block;
        }
        
        .avatar {
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 8px;
            transition: background-color 0.3s;
        }
        
        .avatar:hover {
            background-color: rgba(255, 255, 255, 0.1);
        }
        
        .avatar i {
            font-size: 12px;
            transition: transform 0.3s;
        }
        
        .dropdown-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            min-width: 200px;
            z-index: 1000;
            display: none;
            overflow: hidden;
        }
        
        .dropdown-menu.show {
            display: block;
        }
        
        .dropdown-menu a {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 16px;
            color: #333;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        
        .dropdown-menu a:hover {
            background-color: #f8f9fa;
        }
        
        .dropdown-menu a i {
            color: #6c757d;
            width: 16px;
        }
    </style>
</head>
<body>

<header class="staff-header">
    <div class="user-section">
        <div class="avatar-dropdown">
            <div class="avatar" onclick="toggleDropdown()">
                <img src="${pageContext.request.contextPath}/images/staff-avatar.png" alt="Staff">
                <span>${sessionScope.staff.name}</span>
                <i class="fas fa-chevron-down"></i>
            </div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="${pageContext.request.contextPath}/home.jsp">
                    <i class="fas fa-home"></i> Trang chủ
                </a>
                <a href="${pageContext.request.contextPath}/staff/edit-profile">
                    <i class="fas fa-user-edit"></i> Chỉnh sửa thông tin
                </a>
                <a href="${pageContext.request.contextPath}/staff/logout">
                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </a>
            </div>
        </div>
    </div>
</header>

<div class="staff-wrapper">
    <!-- Sidebar -->
    <aside class="staff-sidebar">
        <ul>
            <li><a href="${pageContext.request.contextPath}/staff/viewOrder"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/work-schedule"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/customer-list"><i class="fas fa-user"></i> Customer Profile</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/services-booking"><i class="fas fa-list"></i> Services Booking</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/chatCustomer" class="active"><i class="fas fa-comments"></i> Chat with Customer</a></li>
            <li><a href="${pageContext.request.contextPath}/staff/products"><i class="fas fa-box"></i> View Product</a></li>
        </ul>
    </aside>

    <!-- Main Content -->
    <main class="staff-content">
        <section class="recent-section">
            <h2><i class="fas fa-comments"></i> Chat with Customers</h2>
            <p style="color: var(--text-light); margin-bottom: 1rem;">Giao tiếp với khách hàng một cách dễ dàng và nhanh chóng 💬</p>

            <!-- Messenger-like Chat Interface -->
            <div class="messenger-container">
                <!-- Left Sidebar - Conversations List -->
                <div class="conversations-sidebar">
                    <div class="conversations-header">
                        <h3>Cuộc trò chuyện</h3>
                        <div class="search-conversations">
                            <i class="fas fa-search"></i>
                            <input type="text" placeholder="Tìm kiếm cuộc trò chuyện..." id="searchConversations">
                        </div>
                    </div>
                    
                    <div class="conversations-list" id="conversationsList">
                        <!-- Sample conversations - will be populated by JavaScript -->
                        <div class="conversation-item active" data-customer-id="1">
                            <div class="conversation-avatar">NV</div>
                            <div class="conversation-info">
                                <div class="conversation-name">Nguyễn Văn A</div>
                                <div class="conversation-preview">Xin chào, tôi muốn hỏi về dịch vụ...</div>
                                <div class="conversation-time">2 phút trước</div>
                            </div>
                            <div class="unread-badge">2</div>
                        </div>
                        
                        <div class="conversation-item" data-customer-id="2">
                            <div class="conversation-avatar">LT</div>
                            <div class="conversation-info">
                                <div class="conversation-name">Lê Thị B</div>
                                <div class="conversation-preview">Cảm ơn bạn đã hỗ trợ!</div>
                                <div class="conversation-time">1 giờ trước</div>
                            </div>
                        </div>
                        
                        <div class="conversation-item" data-customer-id="3">
                            <div class="conversation-avatar">PT</div>
                            <div class="conversation-info">
                                <div class="conversation-name">Phạm Văn C</div>
                                <div class="conversation-preview">Khi nào có thể đặt lịch?</div>
                                <div class="conversation-time">3 giờ trước</div>
                            </div>
                            <div class="unread-badge">1</div>
                        </div>
                        
                        <div class="conversation-item" data-customer-id="4">
                            <div class="conversation-avatar">HT</div>
                            <div class="conversation-info">
                                <div class="conversation-name">Hoàng Thị D</div>
                                <div class="conversation-preview">Sản phẩm này còn hàng không?</div>
                                <div class="conversation-time">1 ngày trước</div>
                            </div>
                        </div>
                        
                        <div class="conversation-item" data-customer-id="5">
                            <div class="conversation-avatar">TM</div>
                            <div class="conversation-info">
                                <div class="conversation-name">Trần Minh E</div>
                                <div class="conversation-preview">Tôi muốn hủy đơn hàng</div>
                                <div class="conversation-time">2 ngày trước</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Side - Chat Area -->
                <div class="chat-area">
            <div class="chat-header">
                        <div class="chat-user-info">
                            <div class="chat-user-avatar">NV</div>
                            <div class="chat-user-details">
                                <h4>Nguyễn Văn A</h4>
                                <p>Đang hoạt động</p>
                            </div>
                        </div>
                        <div class="chat-actions">
                            <button class="chat-action-btn" title="Gọi video">
                                <i class="fas fa-video"></i>
                            </button>
                            <button class="chat-action-btn" title="Gọi thoại">
                                <i class="fas fa-phone"></i>
                            </button>
                            <button class="chat-action-btn" title="Thông tin">
                                <i class="fas fa-info-circle"></i>
                </button>
            </div>
                    </div>

                    <div class="messages-container" id="messagesContainer">
                        <!-- Sample messages -->
                        <div class="message received">
                            <div class="message-bubble">
                                Xin chào, tôi muốn hỏi về dịch vụ chăm sóc thú cưng của bạn
                            </div>
                            <div class="message-time">14:30</div>
                        </div>
                        
                        <div class="message sent">
                            <div class="message-bubble">
                                Xin chào! Tôi rất vui được hỗ trợ bạn. Bạn muốn hỏi về dịch vụ nào cụ thể?
                            </div>
                            <div class="message-time">14:31</div>
                        </div>
                        
                        <div class="message received">
                            <div class="message-bubble">
                                Tôi có một chú chó Golden Retriever 2 tuổi, muốn đặt lịch tắm và cắt tỉa lông
                            </div>
                            <div class="message-time">14:32</div>
                        </div>
                        
                        <div class="message sent">
                            <div class="message-bubble">
                                Tuyệt vời! Chúng tôi có dịch vụ spa cho chó với giá 150,000đ. Bạn có thể đặt lịch vào ngày nào?
                            </div>
                            <div class="message-time">14:33</div>
                        </div>
                        
                        <div class="message received">
                            <div class="message-bubble">
                                Ngày mai có được không? Khoảng 2h chiều
                            </div>
                            <div class="message-time">14:35</div>
                        </div>
                        
                        <div class="message sent">
                            <div class="message-bubble">
                                Được rồi! Tôi sẽ đặt lịch cho bạn vào ngày mai lúc 2h chiều. Bạn có thể đến địa chỉ: 123 Đường ABC, Quận 1
                            </div>
                            <div class="message-time">14:36</div>
                        </div>
                        
                        <div class="message received">
                            <div class="message-bubble">
                                Cảm ơn bạn rất nhiều! Tôi sẽ đến đúng giờ
                            </div>
                            <div class="message-time">14:37</div>
                        </div>
                        
                        <div class="message sent">
                            <div class="message-bubble">
                                Không có gì! Hẹn gặp bạn và chú chó vào ngày mai nhé! 🐕
                            </div>
                            <div class="message-time">14:38</div>
                        </div>
                    </div>

                    <div class="message-input-area">
                        <div class="message-input-container">
                            <button class="attachment-button" title="Đính kèm file">
                                <i class="fas fa-paperclip"></i>
                            </button>
                            <textarea class="message-input" placeholder="Nhập tin nhắn..." id="messageInput" rows="1"></textarea>
                            <button class="send-button" id="sendButton" title="Gửi tin nhắn">
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
// Chat functionality
document.addEventListener('DOMContentLoaded', function() {
    const conversationsList = document.getElementById('conversationsList');
    const messagesContainer = document.getElementById('messagesContainer');
    const messageInput = document.getElementById('messageInput');
    const sendButton = document.getElementById('sendButton');
    const searchInput = document.getElementById('searchConversations');

    // Sample conversations data
    const conversations = {
        1: {
            name: 'Nguyễn Văn A',
            avatar: 'NV',
            status: 'Đang hoạt động',
            messages: [
                { type: 'received', text: 'Xin chào, tôi muốn hỏi về dịch vụ chăm sóc thú cưng của bạn', time: '14:30' },
                { type: 'sent', text: 'Xin chào! Tôi rất vui được hỗ trợ bạn. Bạn muốn hỏi về dịch vụ nào cụ thể?', time: '14:31' },
                { type: 'received', text: 'Tôi có một chú chó Golden Retriever 2 tuổi, muốn đặt lịch tắm và cắt tỉa lông', time: '14:32' },
                { type: 'sent', text: 'Tuyệt vời! Chúng tôi có dịch vụ spa cho chó với giá 150,000đ. Bạn có thể đặt lịch vào ngày nào?', time: '14:33' },
                { type: 'received', text: 'Ngày mai có được không? Khoảng 2h chiều', time: '14:35' },
                { type: 'sent', text: 'Được rồi! Tôi sẽ đặt lịch cho bạn vào ngày mai lúc 2h chiều. Bạn có thể đến địa chỉ: 123 Đường ABC, Quận 1', time: '14:36' },
                { type: 'received', text: 'Cảm ơn bạn rất nhiều! Tôi sẽ đến đúng giờ', time: '14:37' },
                { type: 'sent', text: 'Không có gì! Hẹn gặp bạn và chú chó vào ngày mai nhé! 🐕', time: '14:38' }
            ]
        },
        2: {
            name: 'Lê Thị B',
            avatar: 'LT',
            status: 'Hoạt động 1 giờ trước',
            messages: [
                { type: 'received', text: 'Cảm ơn bạn đã hỗ trợ!', time: '13:45' },
                { type: 'sent', text: 'Không có gì! Rất vui được phục vụ bạn', time: '13:46' }
            ]
        },
        3: {
            name: 'Phạm Văn C',
            avatar: 'PT',
            status: 'Hoạt động 3 giờ trước',
            messages: [
                { type: 'received', text: 'Khi nào có thể đặt lịch?', time: '11:20' },
                { type: 'sent', text: 'Bạn có thể đặt lịch bất kỳ lúc nào trong giờ hành chính', time: '11:21' }
            ]
        },
        4: {
            name: 'Hoàng Thị D',
            avatar: 'HT',
            status: 'Hoạt động 1 ngày trước',
            messages: [
                { type: 'received', text: 'Sản phẩm này còn hàng không?', time: 'Hôm qua' },
                { type: 'sent', text: 'Có, sản phẩm vẫn còn hàng. Bạn có muốn đặt mua không?', time: 'Hôm qua' }
            ]
        },
        5: {
            name: 'Trần Minh E',
            avatar: 'TM',
            status: 'Hoạt động 2 ngày trước',
            messages: [
                { type: 'received', text: 'Tôi muốn hủy đơn hàng', time: '2 ngày trước' },
                { type: 'sent', text: 'Tôi sẽ hỗ trợ bạn hủy đơn hàng ngay', time: '2 ngày trước' }
            ]
        }
    };

    // Switch conversation
    function switchConversation(customerId) {
        // Update active conversation
        document.querySelectorAll('.conversation-item').forEach(item => {
            item.classList.remove('active');
        });
        document.querySelector(`[data-customer-id="${customerId}"]`).classList.add('active');

        // Update chat header
        const conversation = conversations[customerId];
        const chatHeader = document.querySelector('.chat-user-info');
        chatHeader.innerHTML = `
            <div class="chat-user-avatar">${conversation.avatar}</div>
            <div class="chat-user-details">
                <h4>${conversation.name}</h4>
                <p>${conversation.status}</p>
            </div>
        `;

        // Update messages
        messagesContainer.innerHTML = '';
        conversation.messages.forEach(message => {
            const messageElement = document.createElement('div');
            messageElement.className = `message ${message.type}`;
            messageElement.innerHTML = `
                <div class="message-bubble">${message.text}</div>
                <div class="message-time">${message.time}</div>
            `;
            messagesContainer.appendChild(messageElement);
        });

        // Scroll to bottom
        messagesContainer.scrollTop = messagesContainer.scrollHeight;

        // Clear unread badge
        const unreadBadge = document.querySelector(`[data-customer-id="${customerId}"] .unread-badge`);
        if (unreadBadge) {
            unreadBadge.remove();
        }
    }

    // Send message
    function sendMessage() {
        const messageText = messageInput.value.trim();
        if (messageText) {
            const activeConversation = document.querySelector('.conversation-item.active');
            const customerId = activeConversation.dataset.customerId;
            
            // Add message to UI
            const messageElement = document.createElement('div');
            messageElement.className = 'message sent';
            const currentTime = new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
            messageElement.innerHTML = `
                <div class="message-bubble">${messageText}</div>
                <div class="message-time">${currentTime}</div>
            `;
            messagesContainer.appendChild(messageElement);
            
            // Clear input
            messageInput.value = '';
            
            // Scroll to bottom
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
            
            // Here you would typically send the message to the server
            console.log(`Sending message to customer ${customerId}: ${messageText}`);
        }
    }

    // Event listeners
    conversationsList.addEventListener('click', function(e) {
        const conversationItem = e.target.closest('.conversation-item');
        if (conversationItem) {
            const customerId = conversationItem.dataset.customerId;
            switchConversation(customerId);
        }
    });

    sendButton.addEventListener('click', sendMessage);

    messageInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // Auto-resize textarea
    messageInput.addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = Math.min(this.scrollHeight, 100) + 'px';
    });

    // Search conversations
    searchInput.addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        document.querySelectorAll('.conversation-item').forEach(item => {
            const name = item.querySelector('.conversation-name').textContent.toLowerCase();
            const preview = item.querySelector('.conversation-preview').textContent.toLowerCase();
            
            if (name.includes(searchTerm) || preview.includes(searchTerm)) {
                item.style.display = 'flex';
            } else {
                item.style.display = 'none';
            }
        });
    });

    // Initialize with first conversation
    switchConversation(1);
    
    function toggleDropdown() {
        const dropdown = document.getElementById('dropdownMenu');
        dropdown.classList.toggle('show');
    }

    // Close dropdown when clicking outside
    document.addEventListener('click', function(event) {
        const dropdown = document.getElementById('dropdownMenu');
        const avatar = document.querySelector('.avatar');
        
        if (!avatar.contains(event.target)) {
            dropdown.classList.remove('show');
        }
    });
});
</script>

</body>
</html>