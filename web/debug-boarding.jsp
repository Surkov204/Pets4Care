<%@page import="model.Customer"%>
<%@page import="model.BoardingBooking"%>
<%@page import="dao.BoardingBookingDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.util.Calendar"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Debug Boarding Booking</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .container { max-width: 800px; margin: auto; background: #f9f9f9; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .message { padding: 10px; margin-bottom: 10px; border-radius: 5px; }
        .success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .button-group button { padding: 10px 15px; margin-right: 10px; border: none; border-radius: 5px; cursor: pointer; }
        .button-group .insert { background-color: #28a745; color: white; }
        .button-group .list { background-color: #007bff; color: white; }
        .button-group .test { background-color: #6c757d; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <%
            BoardingBookingDAO boardingBookingDAO = new BoardingBookingDAO();
            
            // Lấy customer từ session hoặc tạo test customer
            Customer testCustomer = (Customer) session.getAttribute("currentUser");
            if (testCustomer == null) {
                // Tạo test customer nếu không có session
                testCustomer = new Customer();
                testCustomer.setCustomerId(1); // Giả sử customer_id = 1 tồn tại
                testCustomer.setName("Test Customer");
                testCustomer.setEmail("test@example.com");
                testCustomer.setPhone("0901234567");
            }
        %>
        
        <h1>Debug Boarding Booking System</h1>
        
        <div style="background-color: #e7f3ff; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
            <h3>Customer Info:</h3>
            <p><strong>Customer ID:</strong> <%= testCustomer.getCustomerId() %></p>
            <p><strong>Full Name:</strong> <%= testCustomer.getName() %></p>
            <p><strong>Email:</strong> <%= testCustomer.getEmail() %></p>
            <p><strong>Phone:</strong> <%= testCustomer.getPhone() %></p>
            <p><strong>Session User:</strong> <%= session.getAttribute("currentUser") != null ? "Yes" : "No" %></p>
        </div>

        <%

            String action = request.getParameter("action");
            String message = "";
            String messageType = "";

            if (action != null) {
                if (action.equals("test-insert")) {
                    try {
                        // Test database connection
                        boolean dbInit = boardingBookingDAO.initializeDatabase();
                        if (!dbInit) {
                            message = "Lỗi khởi tạo database";
                            messageType = "error";
                        } else {
                            // Tạo dữ liệu test
                            String roomType = "Phòng Test Debug";
                            BigDecimal pricePerDay = new BigDecimal("300000");
                            int boardingDays = 2;

                            Calendar calIn = Calendar.getInstance();
                            calIn.add(Calendar.DAY_OF_MONTH, 2); // Check-in 2 ngày tới
                            calIn.set(Calendar.HOUR_OF_DAY, 9);
                            calIn.set(Calendar.MINUTE, 0);
                            calIn.set(Calendar.SECOND, 0);
                            calIn.set(Calendar.MILLISECOND, 0);
                            Timestamp checkInTimestamp = new Timestamp(calIn.getTimeInMillis());

                            Calendar calOut = Calendar.getInstance();
                            calOut.setTimeInMillis(checkInTimestamp.getTime());
                            calOut.add(Calendar.DAY_OF_MONTH, boardingDays); // Check-out sau boardingDays
                            calOut.set(Calendar.HOUR_OF_DAY, 10);
                            Timestamp checkOutTimestamp = new Timestamp(calOut.getTimeInMillis());

                            String petInfo = "Chó Test Debug, 1 tuổi, nặng 5kg";
                            String specialNotes = "Test từ debug page";
                            String emergencyPhone1 = "0912345678";
                            String emergencyPhone2 = "0987654321";

                            BoardingBooking booking = new BoardingBooking(
                                testCustomer.getCustomerId(),
                                roomType,
                                pricePerDay,
                                boardingDays,
                                checkInTimestamp,
                                checkOutTimestamp,
                                "09:00",
                                "10:00",
                                petInfo,
                                specialNotes,
                                emergencyPhone1,
                                emergencyPhone2
                            );

                            boolean success = boardingBookingDAO.addBoardingBooking(booking);
                            if (success) {
                                message = "✅ Test insert thành công! ID: " + booking.getBookingId();
                                messageType = "success";
                            } else {
                                message = "❌ Test insert thất bại";
                                messageType = "error";
                            }
                        }
                    } catch (Exception e) {
                        message = "❌ Lỗi test insert: " + e.getMessage();
                        messageType = "error";
                        e.printStackTrace();
                    }
                } else if (action.equals("test-list")) {
                    try {
                        List<BoardingBooking> bookings = boardingBookingDAO.getBoardingBookingsByCustomerId(testCustomer.getCustomerId());
                        if (bookings != null && !bookings.isEmpty()) {
                            message = "✅ Test list thành công! Tìm thấy " + bookings.size() + " booking(s)";
                            messageType = "success";
                        } else {
                            message = "⚠️ Test list thành công nhưng không có dữ liệu";
                            messageType = "error";
                        }
                    } catch (Exception e) {
                        message = "❌ Lỗi test list: " + e.getMessage();
                        messageType = "error";
                        e.printStackTrace();
                    }
                } else if (action.equals("test-db-init")) {
                    try {
                        boolean success = boardingBookingDAO.initializeDatabase();
                        if (success) {
                            message = "✅ Database initialization thành công!";
                            messageType = "success";
                        } else {
                            message = "❌ Database initialization thất bại";
                            messageType = "error";
                        }
                    } catch (Exception e) {
                        message = "❌ Lỗi database initialization: " + e.getMessage();
                        messageType = "error";
                        e.printStackTrace();
                    }
                } else if (action.equals("test-customer")) {
                    try {
                        // Kiểm tra customer có tồn tại không
                        String checkCustomerSQL = "SELECT COUNT(*) FROM dbo.Customer WHERE customer_id = ?";
                        try (java.sql.Connection conn = utils.DBConnection.getConnection();
                             java.sql.PreparedStatement pstmt = conn.prepareStatement(checkCustomerSQL)) {
                            
                            pstmt.setInt(1, testCustomer.getCustomerId());
                            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                                if (rs.next()) {
                                    int count = rs.getInt(1);
                                    if (count > 0) {
                                        message = "✅ Customer ID " + testCustomer.getCustomerId() + " tồn tại trong database!";
                                        messageType = "success";
                                    } else {
                                        message = "❌ Customer ID " + testCustomer.getCustomerId() + " KHÔNG tồn tại trong database!";
                                        messageType = "error";
                                    }
                                }
                            }
                        }
                    } catch (Exception e) {
                        message = "❌ Lỗi kiểm tra customer: " + e.getMessage();
                        messageType = "error";
                        e.printStackTrace();
                    }
                }
            }
        %>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <div class="button-group">
            <form action="debug-boarding.jsp" method="post" style="display:inline;">
                <button type="submit" name="action" value="test-db-init" class="test">Test DB Init</button>
            </form>
            <form action="debug-boarding.jsp" method="post" style="display:inline;">
                <button type="submit" name="action" value="test-customer" class="test">Test Customer</button>
            </form>
            <form action="debug-boarding.jsp" method="post" style="display:inline;">
                <button type="submit" name="action" value="test-insert" class="insert">Test Insert</button>
            </form>
            <form action="debug-boarding.jsp" method="get" style="display:inline;">
                <button type="submit" name="action" value="test-list" class="list">Test List</button>
            </form>
            <a href="<%= request.getContextPath() %>/spa-booking?action=history" class="button-group test">Xem Lịch Sử</a>
        </div>

        <% if (action != null && action.equals("test-list")) { %>
            <h2>Danh sách Boarding Bookings (Customer ID: <%= testCustomer.getCustomerId() %>)</h2>
            <%
                List<BoardingBooking> bookings = boardingBookingDAO.getBoardingBookingsByCustomerId(testCustomer.getCustomerId());
                if (bookings != null && !bookings.isEmpty()) {
            %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Room Type</th>
                            <th>Price/Day</th>
                            <th>Days</th>
                            <th>Total Price</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Pet Info</th>
                            <th>Status</th>
                            <th>Created At</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (BoardingBooking booking : bookings) { %>
                            <tr>
                                <td><%= booking.getBookingId() %></td>
                                <td><%= booking.getRoomType() %></td>
                                <td><%= String.format("%,.0f₫", booking.getPricePerDay()) %></td>
                                <td><%= booking.getBoardingDays() %></td>
                                <td><%= String.format("%,.0f₫", booking.getTotalPrice()) %></td>
                                <td><%= booking.getCheckInDate() %></td>
                                <td><%= booking.getCheckOutDate() %></td>
                                <td><%= booking.getPetInfo() %></td>
                                <td><%= booking.getStatus() %></td>
                                <td><%= booking.getCreatedAt() %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <p>Không tìm thấy booking nào cho khách hàng này.</p>
            <% } %>
        <% } %>

        <div style="margin-top: 30px; padding: 20px; background-color: #e9ecef; border-radius: 5px;">
            <h3>Hướng dẫn Debug:</h3>
            <ol>
                <li><strong>Test DB Init:</strong> Kiểm tra kết nối database và tạo bảng</li>
                <li><strong>Test Customer:</strong> Kiểm tra customer có tồn tại trong database không</li>
                <li><strong>Test Insert:</strong> Thử insert một booking test</li>
                <li><strong>Test List:</strong> Kiểm tra việc lấy danh sách bookings</li>
                <li><strong>Xem Lịch Sử:</strong> Kiểm tra trang lịch sử chính</li>
            </ol>
            
            <h3>Troubleshooting:</h3>
            <ul>
                <li><strong>Nếu Test Customer thất bại:</strong> Customer ID không tồn tại, cần đăng nhập hoặc tạo customer</li>
                <li><strong>Nếu Test Insert thất bại:</strong> Kiểm tra foreign key constraint và customer ID</li>
                <li><strong>Nếu Test List không có dữ liệu:</strong> Chưa có booking nào được tạo</li>
            </ul>
            
            <h3>URLs để test:</h3>
            <ul>
                <li><a href="<%= request.getContextPath() %>/boarding-booking-form.jsp">Form đặt phòng</a></li>
                <li><a href="<%= request.getContextPath() %>/spa-booking?action=history">Lịch sử đặt phòng</a></li>
                <li><a href="<%= request.getContextPath() %>/debug-boarding.jsp">Trang debug này</a></li>
            </ul>
        </div>
    </div>
</body>
</html>
