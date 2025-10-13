<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ y tế - Pet4Care</title>
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
                <p class="text-white/90 text-sm">Hồ sơ y tế thú cưng</p>
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
        <h2 class="text-3xl font-[Baloo 2] text-gray-800 mb-2">🩺 Hồ Sơ Y Tế Thú Cưng</h2>
        <p class="text-gray-500">Theo dõi chẩn đoán, điều trị và lịch sử thăm khám</p>
    </section>

    <!-- Medical Record Table -->
    <section class="max-w-6xl mx-auto bg-white shadow-md rounded-2xl p-6 mb-12">
        <table class="w-full text-center border-collapse">
            <thead>
                <tr class="bg-orange-100 text-gray-800 font-semibold">
                    <th class="py-3 px-4 border-b">Tên Thú Cưng</th>
                    <th class="py-3 px-4 border-b">Chủ Sở Hữu</th>
                    <th class="py-3 px-4 border-b">Chẩn Đoán</th>
                    <th class="py-3 px-4 border-b">Điều Trị</th>
                    <th class="py-3 px-4 border-b">Ngày Khám</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="record" items="${medicalRecords}">
                    <tr class="hover:bg-orange-50 transition">
                        <td class="py-3 border-b">${record.petName}</td>
                        <td class="py-3 border-b">${record.ownerName}</td>
                        <td class="py-3 border-b">${record.diagnosis}</td>
                        <td class="py-3 border-b">${record.treatment}</td>
                        <td class="py-3 border-b">${record.date}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </section>

    <!-- Footer -->
    <footer class="bg-gradient-to-r from-teal-300 to-orange-200 text-center py-3 text-white text-sm">
        © 2025 Pet4Care. Chăm sóc tận tâm, yêu thương từng nhịp thở 🐶🐱
    </footer>
</body>
</html>
