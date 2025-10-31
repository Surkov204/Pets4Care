package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.BoardingRoomDAO;
import model.BoardingRoom;
import model.Customer;
import model.PetServiceModel;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.logging.Logger;

/**
 * Controller cho Boarding Room Rental
 * Xử lý thuê phòng lưu trú thú cưng
 * @author ASUS
 */
public class BoardingRoomServlet extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(BoardingRoomServlet.class.getName());
    
    private BoardingRoomDAO boardingRoomDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.boardingRoomDAO = new BoardingRoomDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("currentUser");
        
        try {
            String action = request.getParameter("action");
            
            if (action == null || action.equals("list")) {
                // Redirect về trang chủ vì không còn hỗ trợ danh sách phòng
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            } else if (action.equals("detail")) {
                // Hiển thị chi tiết phòng
                showRoomDetail(request, response);
            } else if (action.equals("my-bookings")) {
                // Hiển thị lịch sử đặt phòng của khách hàng
                showMyBookings(request, response, customer);
            } else if (action != null && action.equals("initiate-boarding-payment")) {
                // Khởi tạo thanh toán PayOS cho booking lưu trú (GET request)
                initiateBoardingPayment(request, response, customer);
            }
            
        } catch (Exception e) {
            logger.severe("Error in BoardingRoomServlet doGet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/boarding-room-list.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Customer customer = (Customer) session.getAttribute("currentUser");
        
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        try {
            String action = request.getParameter("action");
            
            if (action != null && action.equals("book-room")) {
                // Đặt phòng lưu trú
                bookRoom(request, response, customer);
            } else if (action != null && action.equals("initiate-boarding-payment")) {
                // Khởi tạo thanh toán PayOS cho booking lưu trú
                initiateBoardingPayment(request, response, customer);
            } else if (action != null && action.equals("cancel-booking")) {
                // Hủy đặt phòng
                cancelBooking(request, response, customer);
            } else if (action != null && action.equals("check-availability")) {
                // Kiểm tra phòng có sẵn
                checkAvailability(request, response);
            }
            
        } catch (Exception e) {
            logger.severe("Error in BoardingRoomServlet doPost: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }

    /**
     * Khởi tạo thanh toán PayOS cho booking lưu trú
     * Tái sử dụng PayOSController để tạo link thanh toán
     */
    private void initiateBoardingPayment(HttpServletRequest request, HttpServletResponse response, model.Customer customer)
            throws ServletException, IOException {
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing bookingId");
                return;
            }
            int bookingId = Integer.parseInt(bookingIdParam);

            // Lấy thông tin booking
            dao.BoardingBookingDAO bookingDAO = new dao.BoardingBookingDAO();
            model.BoardingBooking booking = bookingDAO.getBoardingBookingById(bookingId);
            if (booking == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                return;
            }

            // Lưu bookingId vào session để PayOSController có thể lấy thông tin
            HttpSession session = request.getSession();
            session.setAttribute("currentBoardingPayment", bookingId);
            
            // Điều hướng đến PayOSController để xử lý
            // PayOSController sẽ tự động lấy bookingId và tạo link thanh toán
            String redirectUrl = request.getContextPath() + "/payos/create-payment?orderId=" + bookingId + "&type=boarding";
            response.sendRedirect(redirectUrl);

        } catch (NumberFormatException ex) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid bookingId");
        } catch (Exception ex) {
            logger.severe("Error initiating boarding payment: " + ex.getMessage());
            ex.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Internal error");
        }
    }
    
    /**
     * Hiển thị chi tiết phòng
     */
    private void showRoomDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String roomIdParam = request.getParameter("roomId");
            if (roomIdParam == null || roomIdParam.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            int roomId = Integer.parseInt(roomIdParam);
            BoardingRoom room = boardingRoomDAO.getRoomById(roomId);
            
            if (room == null) {
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            request.setAttribute("room", room);
            
            // Lấy các phòng cùng loại
            List<BoardingRoom> similarRooms = boardingRoomDAO.getRoomsByType(room.getRoomType());
            similarRooms.removeIf(r -> r.getRoomId() == roomId);
            request.setAttribute("similarRooms", similarRooms);
            
            request.getRequestDispatcher("/boarding-room-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        } catch (Exception e) {
            logger.severe("Error showing room detail: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }
    
    /**
     * Đặt phòng lưu trú
     */
    private void bookRoom(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Debug: Log request parameters
        logger.info("=== BOOKING ROOM DEBUG ===");
        logger.info("Customer: " + (customer != null ? customer.getCustomerId() : "null"));
        logger.info("RoomId: " + request.getParameter("roomId"));
        logger.info("RoomType: " + request.getParameter("roomType"));
        logger.info("PricePerDay: " + request.getParameter("pricePerDay"));
        logger.info("BoardingDays: " + request.getParameter("boardingDays"));
        logger.info("CheckInDate: " + request.getParameter("checkInDate"));
        logger.info("CheckOutDate: " + request.getParameter("checkOutDate"));
        logger.info("PetInfo: " + request.getParameter("petInfo"));
        
        try {
            // Lấy thông tin đặt phòng
            String roomIdParam = request.getParameter("roomId");
            String checkInDate = request.getParameter("checkInDate");
            String checkOutDate = request.getParameter("checkOutDate");
            String petInfoParam = request.getParameter("petInfo");
            String specialNotesParam = request.getParameter("specialNotes");
            String emergencyPhone1Param = request.getParameter("emergencyPhone1");
            String emergencyPhone2Param = request.getParameter("emergencyPhone2");
            String checkInTimeParam = request.getParameter("checkInTime");
            String checkOutTimeParam = request.getParameter("checkOutTime");
            
            // Validate input
            if (roomIdParam == null || checkInDate == null || checkOutDate == null || 
                petInfoParam == null || emergencyPhone1Param == null) {
                session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            int roomId = Integer.parseInt(roomIdParam);
            BoardingRoom room = boardingRoomDAO.getRoomById(roomId);
            
            if (room == null) {
                session.setAttribute("errorMessage", "Phòng không tồn tại");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            // Parse dates
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            Timestamp checkInTimestamp = new Timestamp(dateFormat.parse(checkInDate).getTime());
            Timestamp checkOutTimestamp = new Timestamp(dateFormat.parse(checkOutDate).getTime());
            
            // Validate dates
            Timestamp now = new Timestamp(System.currentTimeMillis());
            if (checkInTimestamp.before(now)) {
                session.setAttribute("errorMessage", "Ngày nhận không được là ngày quá khứ");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            if (checkOutTimestamp.before(checkInTimestamp)) {
                session.setAttribute("errorMessage", "Ngày trả phải sau hoặc bằng ngày nhận");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            // Check room availability
            if (!boardingRoomDAO.isRoomAvailable(roomId, checkInTimestamp, checkOutTimestamp)) {
                session.setAttribute("errorMessage", "Phòng không có sẵn trong khoảng thời gian này");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            // Chuyển thông tin đặt phòng đến giỏ spa
            Map<String, Object> boardingDetails = new HashMap<>();
            boardingDetails.put("roomType", room.getRoomType());
            boardingDetails.put("pricePerDay", room.getPricePerDay());
            boardingDetails.put("boardingDays", calculateDays(checkInTimestamp, checkOutTimestamp));
            boardingDetails.put("checkInDate", checkInDate);
            boardingDetails.put("checkOutDate", checkOutDate);
            boardingDetails.put("checkInTime", checkInTimeParam != null ? checkInTimeParam : "08:00");
            boardingDetails.put("checkOutTime", checkOutTimeParam != null ? checkOutTimeParam : "17:00");
            boardingDetails.put("petInfo", petInfoParam);
            boardingDetails.put("specialNotes", specialNotesParam != null ? specialNotesParam : "");
            boardingDetails.put("emergencyPhone1", emergencyPhone1Param);
            boardingDetails.put("emergencyPhone2", emergencyPhone2Param != null ? emergencyPhone2Param : "");
            
            // Tạo boarding service object
            PetServiceModel boardingService = new PetServiceModel();
            boardingService.setServiceId(1000 + room.getRoomId()); // Unique ID for boarding services
            boardingService.setName("🏠 Lưu trú " + room.getRoomName());
            boardingService.setDescription("Dịch vụ lưu trú thú cưng - " + calculateDays(checkInTimestamp, checkOutTimestamp) + " ngày");
            boardingService.setPrice(BigDecimal.valueOf(room.getPricePerDay() * calculateDays(checkInTimestamp, checkOutTimestamp)));
            boardingService.setDuration(calculateDays(checkInTimestamp, checkOutTimestamp) * 24 * 60); // Duration in minutes
            
            // Lấy giỏ hàng Spa từ session
            @SuppressWarnings("unchecked")
            Map<Integer, Integer> spaCart = (Map<Integer, Integer>) session.getAttribute("spaCart");
            if (spaCart == null) {
                spaCart = new HashMap<>();
            }
            
            // Thêm vào giỏ hàng
            spaCart.put(boardingService.getServiceId(), 1);
            session.setAttribute("spaCart", spaCart);
            
            // Lưu chi tiết boarding vào session
            @SuppressWarnings("unchecked")
            Map<Integer, Map<String, Object>> boardingDetailsMap = 
                (Map<Integer, Map<String, Object>>) session.getAttribute("boardingDetails");
            if (boardingDetailsMap == null) {
                boardingDetailsMap = new HashMap<>();
            }
            boardingDetailsMap.put(boardingService.getServiceId(), boardingDetails);
            session.setAttribute("boardingDetails", boardingDetailsMap);
            
            session.setAttribute("successMessage", "Đã thêm dịch vụ lưu trú vào giỏ Spa thành công!");
            logger.info("=== REDIRECTING TO HISTORY ===");
            logger.info("Redirect URL: " + request.getContextPath() + "/spa-booking?action=history");
            
            // Đảm bảo response được flush trước khi redirect
            response.setStatus(HttpServletResponse.SC_MOVED_TEMPORARILY);
            response.setHeader("Location", request.getContextPath() + "/spa-booking?action=history");
            response.flushBuffer();
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        } catch (ParseException e) {
            session.setAttribute("errorMessage", "Ngày tháng không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        } catch (Exception e) {
            logger.severe("Error booking room: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi đặt phòng: " + e.getMessage());
            // Debug: Log chi tiết lỗi
            logger.severe("Exception details: " + e.getClass().getSimpleName());
            logger.severe("Stack trace: ");
            for (StackTraceElement element : e.getStackTrace()) {
                logger.severe("  at " + element.toString());
            }
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }
    
    /**
     * Kiểm tra phòng có sẵn
     */
    private void checkAvailability(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String roomIdParam = request.getParameter("roomId");
            String checkInDate = request.getParameter("checkInDate");
            String checkOutDate = request.getParameter("checkOutDate");
            
            if (roomIdParam == null || checkInDate == null || checkOutDate == null) {
                response.getWriter().write("{\"available\": false, \"message\": \"Thông tin không đầy đủ\"}");
                return;
            }
            
            int roomId = Integer.parseInt(roomIdParam);
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            Timestamp checkInTimestamp = new Timestamp(dateFormat.parse(checkInDate).getTime());
            Timestamp checkOutTimestamp = new Timestamp(dateFormat.parse(checkOutDate).getTime());
            
            boolean available = boardingRoomDAO.isRoomAvailable(roomId, checkInTimestamp, checkOutTimestamp);
            
            String message = available ? "Phòng có sẵn" : "Phòng không có sẵn trong khoảng thời gian này";
            
            response.setContentType("application/json");
            response.getWriter().write("{\"available\": " + available + ", \"message\": \"" + message + "\"}");
            
        } catch (Exception e) {
            logger.severe("Error checking availability: " + e.getMessage());
            response.getWriter().write("{\"available\": false, \"message\": \"Có lỗi xảy ra\"}");
        }
    }
    
    /**
     * Hiển thị lịch sử đặt phòng của khách hàng
     */
    private void showMyBookings(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        try {
            // TODO: Lấy danh sách booking từ database
            // Đây sẽ tích hợp với BoardingBookingDAO
            
            request.setAttribute("bookings", new java.util.ArrayList<>());
            request.getRequestDispatcher("/spa-booking?action=history").forward(request, response);
            
        } catch (Exception e) {
            logger.severe("Error showing my bookings: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải lịch sử đặt phòng: " + e.getMessage());
            request.getRequestDispatcher("/spa-booking?action=history").forward(request, response);
        }
    }
    
    /**
     * Hủy đặt phòng
     */
    private void cancelBooking(HttpServletRequest request, HttpServletResponse response, Customer customer) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Không tìm thấy booking");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=my-bookings");
                return;
            }
            
            int bookingId = Integer.parseInt(bookingIdParam);
            
            // TODO: Hủy booking trong database
            // Đây sẽ tích hợp với BoardingBookingDAO
            
            session.setAttribute("successMessage", "Đã hủy đặt phòng thành công");
            response.sendRedirect(request.getContextPath() + "/boarding-room?action=my-bookings");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "ID booking không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/boarding-room?action=my-bookings");
        } catch (Exception e) {
            logger.severe("Error canceling booking: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi hủy đặt phòng: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/boarding-room?action=my-bookings");
        }
    }

    /**
     * Tính số ngày giữa 2 mốc thời gian, làm tròn lên tối thiểu 1 ngày
     */
    private int calculateDays(Timestamp start, Timestamp end) {
        if (start == null || end == null) {
            return 0;
        }
        long diffMillis = end.getTime() - start.getTime();
        if (diffMillis <= 0) {
            return 0;
        }
        long millisPerDay = 24L * 60L * 60L * 1000L;
        return (int) Math.ceil(diffMillis / (double) millisPerDay);
    }
}
