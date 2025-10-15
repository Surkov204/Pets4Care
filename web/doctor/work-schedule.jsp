<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch làm việc - Pet4Care</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600&family=Quicksand:wght@500;600&display=swap" rel="stylesheet">
</head>
<body class="bg-orange-50 text-gray-700 font-[Quicksand]">
    <!-- Header -->
    <header class="bg-gradient-to-r from-teal-300 to-orange-200 py-4 px-8 flex justify-between items-center shadow">
        <div class="flex items-center gap-4">
            <img src="${pageContext.request.contextPath}/images/logo.png" class="w-12 h-12 rounded-full border-2 border-white" alt="Pet4Care Logo">
            <div>
                <h1 class="text-2xl font-bold text-white">Pet4Care</h1>
                <p class="text-white/90 text-sm">Bảng lịch làm việc</p>
            </div>
        </div>
        <div class="flex items-center gap-4">
            <i class="fas fa-bell text-white text-lg"></i>
            <i class="fas fa-comments text-white text-lg"></i>
            <a href="logout" class="bg-orange-400 text-white px-3 py-1 rounded-md hover:bg-orange-500 transition"><i class="fas fa-sign-out-alt"></i></a>
        </div>
    </header>

    <!-- Page Title -->
    <section class="text-center py-10">
        <h2 class="text-3xl font-[Baloo 2] text-gray-800 mb-2">📅 Lịch Làm Việc Của Bạn</h2>
        <p class="text-gray-500">Theo dõi ca trực và nhiệm vụ trong tuần</p>
    </section>

    <!-- Schedule Table -->
    <section class="max-w-5xl mx-auto bg-white shadow-md rounded-2xl p-6 mb-12">
        <table class="w-full text-center border-collapse">
            <thead>
                <tr class="bg-orange-100 text-gray-800 font-semibold">
                    <th class="py-3 px-4 border-b">Ngày</th>
                    <th class="py-3 px-4 border-b">Ca trực</th>
                    <th class="py-3 px-4 border-b">Phòng</th>
                    <th class="py-3 px-4 border-b">Ghi chú</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="shift" items="${workShifts}">
                    <tr class="hover:bg-orange-50 transition">
                        <td class="py-3 border-b">${shift.date}</td>
                        <td class="py-3 border-b">${shift.shiftName}</td>
                        <td class="py-3 border-b">${shift.room}</td>
                        <td class="py-3 border-b text-gray-600">${shift.note}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </section>

    <!-- Footer -->
    <footer class="bg-gradient-to-r from-teal-300 to-orange-200 text-center py-3 text-white text-sm">
        © 2025 Pet4Care. Bác sĩ luôn bên thú cưng 🐾
    </footer>
</body>
</html>
