<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>🐾 Chat with Customer | Pet4Care</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/staff.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="${pageContext.request.contextPath}/js/chat.js" defer></script>
    <style>
        /* --- Chat Box Style --- */
        .chat-wrapper {
            display: flex;
            flex-direction: column;
            align-items: center;
            background: #fff;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            height: 85vh;
            width: 90%;
            max-width: 800px;
            margin: 20px auto;
        }

        .chat-header {
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: linear-gradient(90deg, #a7d8d8, #d5edea);
            padding: 14px 18px;
            border-radius: 12px;
            color: #0b646b;
            font-weight: 600;
            margin-bottom: 16px;
        }

        .chat-header h2 {
            margin: 0;
            font-size: 18px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .chat-header button {
            background: transparent;
            border: none;
            color: #0b646b;
            font-size: 18px;
            cursor: pointer;
            transition: 0.2s;
        }

        .chat-header button:hover {
            transform: scale(1.1);
            color: #084f56;
        }

        .chat-body {
            flex: 1;
            width: 100%;
            background: #f7fafb;
            border-radius: 12px;
            padding: 16px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .message {
            max-width: 75%;
            padding: 10px 14px;
            border-radius: 16px;
            line-height: 1.4;
            font-size: 14px;
            animation: fadeIn 0.25s ease-in-out;
        }

        .message.user {
            background: #0b646b;
            color: white;
            align-self: flex-end;
            border-bottom-right-radius: 4px;
        }

        .message.customer {
            background: #e9ecef;
            color: #333;
            align-self: flex-start;
            border-bottom-left-radius: 4px;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .chat-input {
            width: 100%;
            display: flex;
            align-items: center;
            padding-top: 10px;
        }

        .chat-input input {
            flex: 1;
            border: none;
            background: #f1f3f5;
            padding: 12px 16px;
            border-radius: 25px;
            outline: none;
            font-size: 14px;
        }

        .chat-input button {
            margin-left: 8px;
            background: #0b646b;
            color: white;
            border: none;
            border-radius: 50%;
            width: 42px;
            height: 42px;
            cursor: pointer;
            font-size: 16px;
            transition: 0.2s;
        }

        .chat-input button:hover {
            background: #084f56;
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
    <!-- Sidebar -->
    <aside class="staff-sidebar">
        <ul>
            <li><a href="dashboard.jsp"><i class="fas fa-home"></i> Dashboard</a></li>
            <li><a href="viewOrder.jsp"><i class="fas fa-receipt"></i> View Orders</a></li>
            <li><a href="booking-list.jsp"><i class="fas fa-edit"></i> Update Booking</a></li>
            <li><a href="booking-stats.jsp"><i class="fas fa-list"></i> Services Booking</a></li>
            <li><a href="chatCustomer.jsp" class="active"><i class="fas fa-comments"></i> Chat with Customer</a></li>
            <li><a href="customer-list.jsp"><i class="fas fa-user"></i> Customer Profile</a></li>
            <li><a href="index.jsp"><i class="fas fa-calendar-alt"></i> Work Schedule</a></li>
            <li><a href="staff-profile.jsp"><i class="fas fa-id-card"></i> Staff Profile</a></li>
        </ul>
    </aside>

    <!-- Main content -->
    <main class="staff-content">
        <section class="welcome-card">
            <h2><i class="fas fa-comments"></i> Chat with Customer</h2>
            <p>Kết nối và hỗ trợ khách hàng nhanh chóng 💬</p>
        </section>

        <section class="chat-wrapper">
            <div class="chat-header">
                <h2><i class="fas fa-comment-dots"></i> Hộp thoại trực tiếp</h2>
                <button onclick="window.history.back()" title="Quay lại">
                    <i class="fas fa-arrow-left"></i>
                </button>
            </div>

            <div id="chat-body" class="chat-body">
                <div class="message customer">Xin chào! Mình cần hỗ trợ về lịch đặt grooming.</div>
                <div class="message user">Chào bạn! Mình sẽ kiểm tra lịch cho bạn ngay nhé 🐾</div>
            </div>

            <form id="chat-form" class="chat-input">
                <input type="text" id="message" placeholder="Nhập tin nhắn..." autocomplete="off">
                <button type="submit"><i class="fas fa-paper-plane"></i></button>
            </form>
        </section>
    </main>
</div>

<footer class="staff-footer">
    <p>© 2025 Pet4Care — Where Pets Feel Loved 🐶🐱</p>
</footer>
