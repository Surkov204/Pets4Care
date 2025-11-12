<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="model.Customer" %>
<%
    // Kiểm tra đăng nhập
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🏥 Hồ sơ y tế - ${pet.petName} | Pet4Care</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
        .timeline-item {
            position: relative;
            padding-left: 40px;
            padding-bottom: 30px;
            border-left: 2px solid #e5e7eb;
        }
        
        .timeline-item:last-child {
            border-left: none;
        }
        
        .timeline-dot {
            position: absolute;
            left: -9px;
            top: 0;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            background: #3b82f6;
            border: 3px solid white;
            box-shadow: 0 0 0 2px #3b82f6;
        }
        
        .record-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .record-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-completed {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-confirmed {
            background: #dbeafe;
            color: #1e40af;
        }
        
        .status-in_progress {
            background: #fef3c7;
            color: #92400e;
        }
        
        .info-row {
            display: flex;
            margin-bottom: 12px;
        }
        
        .info-label {
            font-weight: 600;
            color: #6b7280;
            min-width: 140px;
        }
        
        .info-value {
            color: #111827;
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header -->
    <header class="bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg">
        <div class="container mx-auto px-4 py-6">
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <a href="${pageContext.request.contextPath}/petinfoservlet" class="text-white hover:text-gray-200">
                        <i class="fas fa-arrow-left text-2xl"></i>
                    </a>
                    <div>
                        <h1 class="text-3xl font-bold">🏥 Hồ sơ y tế</h1>
                        <p class="text-blue-100">Lịch sử khám bệnh của ${pet.petName}</p>
                    </div>
                </div>
                <div class="text-right">
                    <p class="text-sm text-blue-100">Chào, ${sessionScope.customer.name}</p>
                </div>
            </div>
        </div>
    </header>

    <div class="container mx-auto px-4 py-8">
        <!-- Pet Info Card -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
            <div class="flex items-center space-x-6">
                <c:choose>
                    <c:when test="${not empty pet.imagePath}">
                        <img src="${pageContext.request.contextPath}/${pet.imagePath}" 
                             alt="${pet.petName}" 
                             class="w-24 h-24 rounded-full object-cover border-4 border-blue-500">
                    </c:when>
                    <c:otherwise>
                        <div class="w-24 h-24 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white text-4xl border-4 border-blue-500">
                            ${pet.speciesEmoji}
                        </div>
                    </c:otherwise>
                </c:choose>
                
                <div class="flex-1">
                    <h2 class="text-2xl font-bold text-gray-800">${pet.petName}</h2>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-3">
                        <div>
                            <p class="text-sm text-gray-500">Loài</p>
                            <p class="font-semibold">${pet.species}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Giống</p>
                            <p class="font-semibold">${pet.breed}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Tuổi</p>
                            <p class="font-semibold">${pet.ageText}</p>
                        </div>
                        <div>
                            <p class="text-sm text-gray-500">Tình trạng</p>
                            <p class="font-semibold text-green-600">${pet.healthStatus}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Medical Records Timeline -->
            <div class="lg:col-span-2">
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h3 class="text-xl font-bold text-gray-800 mb-6">
                        <i class="fas fa-notes-medical text-blue-600"></i> Lịch sử khám bệnh
                    </h3>
                    
                    <c:choose>
                        <c:when test="${not empty medicalRecords}">
                            <div class="timeline">
                                <c:forEach var="record" items="${medicalRecords}">
                                    <div class="timeline-item">
                                        <div class="timeline-dot"></div>
                                        <div class="record-card">
                                            <div class="flex justify-between items-start mb-3">
                                                <div>
                                                    <p class="text-sm text-gray-500">
                                                        <i class="fas fa-calendar"></i>
                                                        <fmt:formatDate value="${record.examinationDate}" pattern="dd/MM/yyyy HH:mm" />
                                                    </p>
                                                    <p class="text-lg font-bold text-gray-800 mt-1">
                                                        <i class="fas fa-user-md text-blue-600"></i> ${record.doctorName}
                                                    </p>
                                                </div>
                                            </div>
                                            
                                            <c:if test="${not empty record.symptoms}">
                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-thermometer text-red-500"></i> Triệu chứng:
                                                    </span>
                                                    <span class="info-value">${record.symptoms}</span>
                                                </div>
                                            </c:if>
                                            
                                            <c:if test="${not empty record.diagnosis}">
                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-stethoscope text-blue-500"></i> Chẩn đoán:
                                                    </span>
                                                    <span class="info-value">${record.diagnosis}</span>
                                                </div>
                                            </c:if>
                                            
                                            <c:if test="${not empty record.treatment}">
                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-procedures text-green-500"></i> Điều trị:
                                                    </span>
                                                    <span class="info-value">${record.treatment}</span>
                                                </div>
                                            </c:if>
                                            
                                            <c:if test="${not empty record.prescription}">
                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-pills text-purple-500"></i> Đơn thuốc:
                                                    </span>
                                                    <span class="info-value">${record.prescription}</span>
                                                </div>
                                            </c:if>
                                            
                                            <!-- Health Metrics -->
                                            <c:if test="${not empty record.weight || not empty record.temperature || not empty record.heartRate}">
                                                <div class="mt-4 pt-4 border-t border-gray-200">
                                                    <p class="font-semibold text-gray-700 mb-2">
                                                        <i class="fas fa-heartbeat text-red-500"></i> Chỉ số sức khỏe:
                                                    </p>
                                                    <div class="grid grid-cols-3 gap-4">
                                                        <c:if test="${not empty record.weight}">
                                                            <div class="text-center bg-blue-50 rounded p-2">
                                                                <p class="text-xs text-gray-600">Cân nặng</p>
                                                                <p class="font-bold text-blue-600">${record.weight} kg</p>
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${not empty record.temperature}">
                                                            <div class="text-center bg-red-50 rounded p-2">
                                                                <p class="text-xs text-gray-600">Nhiệt độ</p>
                                                                <p class="font-bold text-red-600">${record.temperature}°C</p>
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${not empty record.heartRate}">
                                                            <div class="text-center bg-green-50 rounded p-2">
                                                                <p class="text-xs text-gray-600">Nhịp tim</p>
                                                                <p class="font-bold text-green-600">${record.heartRate} bpm</p>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </c:if>
                                            
                                            <c:if test="${not empty record.followUpDate}">
                                                <div class="mt-4 bg-yellow-50 border-l-4 border-yellow-400 p-3 rounded">
                                                    <p class="text-sm font-semibold text-yellow-800">
                                                        <i class="fas fa-calendar-check"></i> Tái khám: 
                                                        <fmt:formatDate value="${record.followUpDate}" pattern="dd/MM/yyyy" />
                                                    </p>
                                                    <c:if test="${not empty record.followUpNotes}">
                                                        <p class="text-sm text-yellow-700 mt-1">${record.followUpNotes}</p>
                                                    </c:if>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-12">
                                <i class="fas fa-notes-medical text-gray-300 text-6xl mb-4"></i>
                                <p class="text-gray-500 text-lg">Chưa có hồ sơ y tế</p>
                                <p class="text-gray-400 text-sm mt-2">Hồ sơ khám bệnh sẽ được cập nhật sau mỗi lần khám</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Upcoming Appointments Sidebar -->
            <div class="lg:col-span-1">
                <div class="bg-white rounded-lg shadow-md p-6 sticky top-4">
                    <h3 class="text-xl font-bold text-gray-800 mb-4">
                        <i class="fas fa-calendar-alt text-green-600"></i> Lịch hẹn sắp tới
                    </h3>
                    
                    <c:choose>
                        <c:when test="${not empty upcomingAppointments}">
                            <c:forEach var="appointment" items="${upcomingAppointments}">
                                <div class="mb-4 p-4 bg-gradient-to-r from-blue-50 to-purple-50 rounded-lg border border-blue-200">
                                    <p class="text-sm text-gray-600 mb-1">
                                        <i class="fas fa-clock"></i>
                                        <fmt:formatDate value="${appointment.appointmentStart}" pattern="dd/MM/yyyy HH:mm" />
                                    </p>
                                    <p class="font-semibold text-gray-800">
                                        <i class="fas fa-user-md"></i> ${appointment.doctorName}
                                    </p>
                                    <p class="text-sm text-gray-600 mt-1">
                                        <i class="fas fa-concierge-bell"></i> ${appointment.serviceNames}
                                    </p>
                                    <span class="status-badge status-${appointment.status} mt-2 inline-block">
                                        ${appointment.status}
                                    </span>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-8">
                                <i class="fas fa-calendar-times text-gray-300 text-4xl mb-3"></i>
                                <p class="text-gray-500">Không có lịch hẹn</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    
                    <a href="${pageContext.request.contextPath}/booking.jsp" 
                       class="block w-full mt-4 bg-gradient-to-r from-blue-600 to-purple-600 text-white text-center py-3 rounded-lg font-semibold hover:from-blue-700 hover:to-purple-700 transition">
                        <i class="fas fa-plus-circle"></i> Đặt lịch khám mới
                    </a>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-gray-800 text-white text-center py-6 mt-12">
        <p>© 2025 Pet4Care — Chăm sóc sức khỏe thú cưng của bạn 🐶🐱</p>
    </footer>
</body>
</html>

