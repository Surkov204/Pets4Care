<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Liên hệ - Petcity</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/homeStyle.css" />
</head>
<body class="bg-gray-50">

    <!-- Header -->
    <div class="top-bar bg-gradient-to-r from-pink-300 to-blue-200 text-gray-800 flex justify-between px-8 py-2 text-sm">
        <div>🐾 PETCITY - SIÊU THỊ THÚ CƯNG ONLINE 🐾</div>
        <div class="flex gap-4">
            <a href="#"><i class="fab fa-facebook-f"></i></a>
            <a href="#"><i class="fab fa-instagram"></i></a>
            <a href="#"><i class="fab fa-twitter"></i></a>
            <a href="#"><i class="fas fa-envelope"></i></a>
        </div>
    </div>

    <nav class="bg-gradient-to-r from-pink-200 to-blue-200 py-3">
        <ul class="flex justify-center gap-6 font-semibold text-gray-700">
            <li><a href="<%= request.getContextPath()%>/home.jsp">TRANG CHỦ</a></li>
            <li><a href="<%= request.getContextPath()%>/gioi-thieu.jsp">GIỚI THIỆU</a></li>
            <li><a href="<%= request.getContextPath()%>/lien-he.jsp" class="text-orange-600">LIÊN HỆ</a></li>
        </ul>
    </nav>

    <main class="max-w-6xl mx-auto mt-10 px-6 space-y-20">

        <!-- 👥 Nhóm thực hiện -->
        <section class="text-center">
            <h2 class="text-3xl font-bold text-orange-600 mb-10">👨‍💻 Nhóm Thực Hiện</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-10 justify-items-center">

                <!-- Thành viên 1 -->
                <div>
                    <img src="<%= request.getContextPath() %>/images/member1.jpg"
                         class="w-56 h-56 object-cover rounded-full shadow-lg border-4 border-orange-300"
                         alt="Nguyễn Minh Tuấn">
                    <h3 class="mt-4 text-xl font-semibold text-gray-800">Nguyễn Minh Tuấn</h3>
                    <p class="text-gray-600">Trưởng nhóm - Thiết kế hệ thống</p>
                </div>

                <!-- Thành viên 2 (load member_9.png) -->
                <div>
                    <img src="<%= request.getContextPath() %>/images/tuananh.jpg"
                         class="w-56 h-56 object-cover rounded-full shadow-lg border-4 border-orange-300"
                         alt="Lương Văn Tuấn Anh">
                    <h3 class="mt-4 text-xl font-semibold text-gray-800">Lương Văn Tuấn Anh</h3>
                    <p class="text-gray-600">Phát triển hệ thống & AI Chatbot</p>
                </div>

                <!-- Thành viên 3 -->
                <div>
                    <img src="<%= request.getContextPath() %>/images/member3.jpg"
                         class="w-56 h-56 object-cover rounded-full shadow-lg border-4 border-orange-300"
                         alt="Trần Hồng Sơn">
                    <h3 class="mt-4 text-xl font-semibold text-gray-800">Trần Hồng Sơn</h3>
                    <p class="text-gray-600">Giao diện & Frontend</p>
                </div>

            </div>
        </section>

        <!-- 📬 Liên hệ -->
        <section>
            <h2 class="text-3xl font-bold text-orange-600 mb-6 text-center">📬 Gửi tin nhắn liên hệ</h2>
            <div class="grid md:grid-cols-2 gap-10">
                <form action="mailto:petcity.support@gmail.com" method="post" enctype="text/plain" class="space-y-4">
                    <input type="text" name="name" placeholder="Họ và tên" required class="w-full p-3 border rounded">
                    <input type="email" name="email" placeholder="Email" required class="w-full p-3 border rounded">
                    <textarea name="message" rows="6" placeholder="Nội dung liên hệ..." required class="w-full p-3 border rounded"></textarea>
                    <button type="submit" class="bg-orange-500 hover:bg-orange-600 text-white px-5 py-2 rounded">
                        Gửi liên hệ
                    </button>
                </form>

                <div>
                    <h4 class="text-lg font-semibold text-gray-700 mb-2">📍 Địa chỉ nhóm</h4>
                    <p>Trường Đại học FPT Đà Nẵng</p>
                    <p>Email: <a href="mailto:vinhhtien110@gmail.com" class="text-blue-500 underline">vinhhtien110@gmail.com</a></p>
                    <p>Điện thoại: 091 613 4642</p>
                </div>
            </div>
        </section>
    </main>

    <footer class="bg-gray-800 text-gray-300 mt-16 py-6 text-center text-sm">
        <p>© 2025 Petcity | Thiết kế bởi Nhóm SWP - FPT University Đà Nẵng</p>
    </footer>

</body>
</html>
