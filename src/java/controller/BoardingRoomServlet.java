package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.BoardingRoomDAO;
import dao.BoardingBookingDAO;
import dao.PetDAO;
import dao.ReviewDAO;
import model.BoardingRoom;
import model.BoardingBooking;
import model.Customer;
import model.Pet;
import model.PetServiceModel;
import model.Review;
import service.ReviewService;
import java.util.Arrays;

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
    private ReviewService reviewService;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.boardingRoomDAO = new BoardingRoomDAO();
        this.reviewService = new ReviewService();
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
            } else if (action != null && action.equals("submit-room-review")) {
                // Gửi đánh giá cho phòng
                submitRoomReview(request, response, customer);
            } else if (action != null && action.equals("edit-room-review")) {
                // Sửa đánh giá phòng
                editRoomReview(request, response, customer);
            } else if (action != null && action.equals("delete-room-review")) {
                // Xóa đánh giá phòng
                deleteRoomReview(request, response, customer);
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
            logger.info("=== showRoomDetail called ===");
            logger.info("roomIdParam: " + roomIdParam);
            
            if (roomIdParam == null || roomIdParam.trim().isEmpty()) {
                logger.warning("roomIdParam is null or empty, redirecting to home");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            int roomId = Integer.parseInt(roomIdParam);
            logger.info("Parsed roomId: " + roomId);
            
            BoardingRoom room = boardingRoomDAO.getRoomById(roomId);
            logger.info("Room found: " + (room != null ? room.getRoomName() : "null"));
            
            if (room == null) {
                logger.severe("=== ROOM NOT FOUND ===");
                logger.severe("Room ID requested: " + roomId);
                logger.severe("Request URL: " + request.getRequestURL().toString());
                logger.severe("Query string: " + request.getQueryString());
                
                // Try to get all rooms to see what IDs exist
                try {
                    List<BoardingRoom> allRooms = boardingRoomDAO.getAllRooms();
                    logger.severe("Available rooms in database: " + allRooms.size());
                    for (BoardingRoom r : allRooms) {
                        logger.severe("  - Room ID: " + r.getRoomId() + ", Name: " + r.getRoomName() + ", Type: " + r.getRoomType());
                    }
                } catch (Exception e) {
                    logger.warning("Could not list all rooms: " + e.getMessage());
                }
                
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Không tìm thấy phòng với ID: " + roomId + ". Vui lòng kiểm tra lại.");
                response.sendRedirect(request.getContextPath() + "/spa-service.jsp");
                return;
            }
            
            logger.info("Room loaded successfully: " + room.getRoomName() + " (ID: " + room.getRoomId() + ")");
            request.setAttribute("room", room);
            
            // Lấy các phòng cùng loại
            List<BoardingRoom> similarRooms = boardingRoomDAO.getRoomsByType(room.getRoomType());
            similarRooms.removeIf(r -> r.getRoomId() == roomId);
            request.setAttribute("similarRooms", similarRooms);
            
            // Lấy đánh giá cho phòng (serviceId = 1000 + roomId)
            int serviceId = 1000 + roomId;
            List<Review> reviews = reviewService.listByService(serviceId, 50);
            request.setAttribute("reviews", reviews);
            
            // Tính điểm trung bình
            double avgRating = 0;
            if (reviews != null && !reviews.isEmpty()) {
                int totalRating = 0;
                int count = 0;
                for (Review review : reviews) {
                    if (review != null && review.getRating() > 0) {
                        totalRating += review.getRating();
                        count++;
                    }
                }
                if (count > 0) {
                    avgRating = (double) totalRating / count;
                }
            }
            request.setAttribute("avgRating", avgRating);
            
            // Kiểm tra xem customer có thể đánh giá không (đã đặt và hoàn thành booking)
            Customer customer = (Customer) request.getSession().getAttribute("currentUser");
            boolean hasPurchasedRoom = false;
            List<Pet> customerPets = new java.util.ArrayList<>();
            
            if (customer != null) {
                try {
                    ReviewDAO reviewDAO = new ReviewDAO();
                    hasPurchasedRoom = reviewDAO.hasPurchasedService(customer.getCustomerId(), serviceId);
                    
                    // Lấy danh sách thú cưng của customer
                    PetDAO petDAO = new PetDAO();
                    customerPets = petDAO.getPetsByCustomerId(customer.getCustomerId());
                    if (customerPets == null) {
                        customerPets = new java.util.ArrayList<>();
                    }
                    logger.info("Loaded " + customerPets.size() + " pets for customer " + customer.getCustomerId());
                } catch (Exception e) {
                    logger.warning("Error loading customer pets: " + e.getMessage());
                    e.printStackTrace();
                    // Continue without pets - customer can still view room detail
                }
            }
            
            request.setAttribute("customerPets", customerPets);
            request.setAttribute("hasPurchasedRoom", hasPurchasedRoom);
            
            logger.info("Forwarding to boarding-room-detail.jsp");
            request.getRequestDispatcher("/boarding-room-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            logger.warning("Invalid roomId format: " + request.getParameter("roomId"));
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "ID phòng không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/spa-service.jsp");
        } catch (Exception e) {
            logger.severe("Error showing room detail: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi tải chi tiết phòng: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/spa-service.jsp");
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
            String[] selectedPets = request.getParameterValues("selectedPets"); // Array of pet IDs
            String shareRoomParam = request.getParameter("shareRoom"); // "on" if checked, null otherwise
            String specialNotesParam = request.getParameter("specialNotes");
            String emergencyPhone1Param = request.getParameter("emergencyPhone1");
            String emergencyPhone2Param = request.getParameter("emergencyPhone2");
            String checkInTimeParam = request.getParameter("checkInTime");
            String checkOutTimeParam = request.getParameter("checkOutTime");
            
            // Validate input
            if (roomIdParam == null || checkInDate == null || checkOutDate == null) {
                session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            // Validate selected pets
            if (selectedPets == null || selectedPets.length == 0) {
                session.setAttribute("errorMessage", "Vui lòng chọn ít nhất 1 thú cưng");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            // Validate emergency phones (both required)
            if (emergencyPhone1Param == null || emergencyPhone1Param.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập số điện thoại khẩn cấp 1");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            if (emergencyPhone2Param == null || emergencyPhone2Param.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập số điện thoại khẩn cấp 2");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            // Get pet names from IDs
            PetDAO petDAO = new PetDAO();
            StringBuilder petInfoBuilder = new StringBuilder();
            for (int i = 0; i < selectedPets.length; i++) {
                try {
                    int petId = Integer.parseInt(selectedPets[i]);
                    Pet pet = petDAO.getPetById(petId);
                    if (pet != null && pet.getCustomerId() == customer.getCustomerId()) {
                        // Verify pet belongs to customer
                        if (i > 0) petInfoBuilder.append(", ");
                        petInfoBuilder.append(pet.getPetName() != null ? pet.getPetName() : "Thú cưng #" + petId);
                    } else {
                        logger.warning("Pet ID " + petId + " does not belong to customer " + customer.getCustomerId());
                        if (i > 0) petInfoBuilder.append(", ");
                        petInfoBuilder.append("Pet ID: ").append(petId);
                    }
                } catch (NumberFormatException e) {
                    logger.warning("Invalid pet ID: " + selectedPets[i]);
                }
            }
            String petInfoParam = petInfoBuilder.toString();
            
            // Determine if sharing room
            boolean shareRoom = "on".equals(shareRoomParam);
            int numberOfPets = selectedPets.length;
            int numberOfRooms = shareRoom ? 1 : numberOfPets;
            
            int roomId = Integer.parseInt(roomIdParam);
            BoardingRoom room = boardingRoomDAO.getRoomById(roomId);
            
            if (room == null) {
                session.setAttribute("errorMessage", "Phòng không tồn tại");
                response.sendRedirect(request.getContextPath() + "/home.jsp");
                return;
            }
            
            // Validate time parameters
            if (checkInTimeParam == null || checkInTimeParam.trim().isEmpty()) {
                checkInTimeParam = "08:00";
            }
            if (checkOutTimeParam == null || checkOutTimeParam.trim().isEmpty()) {
                checkOutTimeParam = "17:00";
            }
            
            // Parse dates and times
            SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Timestamp checkInTimestamp;
            Timestamp checkOutTimestamp;
            
            try {
                checkInTimestamp = new Timestamp(dateTimeFormat.parse(checkInDate + " " + checkInTimeParam).getTime());
                checkOutTimestamp = new Timestamp(dateTimeFormat.parse(checkOutDate + " " + checkOutTimeParam).getTime());
            } catch (ParseException e) {
                // Fallback to date only if time parsing fails
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                checkInTimestamp = new Timestamp(dateFormat.parse(checkInDate).getTime());
                checkOutTimestamp = new Timestamp(dateFormat.parse(checkOutDate).getTime());
                logger.warning("Failed to parse time, using default times: " + e.getMessage());
            }
            
            // Validate dates and times
            Timestamp now = new Timestamp(System.currentTimeMillis());
            if (checkInTimestamp.before(now)) {
                session.setAttribute("errorMessage", "Thời gian nhận không được là quá khứ");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomId);
                return;
            }
            
            if (checkOutTimestamp.before(checkInTimestamp) || checkOutTimestamp.equals(checkInTimestamp)) {
                session.setAttribute("errorMessage", "Thời gian trả phải sau thời gian nhận");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomId);
                return;
            }
            
            // Check room availability (simplified check)
            if (!boardingRoomDAO.isRoomAvailable(roomId, checkInTimestamp, checkOutTimestamp)) {
                session.setAttribute("errorMessage", "Phòng không có sẵn trong khoảng thời gian này");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomId);
                return;
            }
            
            // Calculate flexible boarding days based on time
            double boardingDays = calculateFlexibleBoardingDays(checkInDate, checkInTimeParam, checkOutDate, checkOutTimeParam);
            double pricePerDay = room.getPricePerDay();
            double totalPrice = boardingDays * pricePerDay * numberOfRooms;
            
            // Lưu booking vào database
            // Logic: Nếu chung phòng -> 1 đơn booking với tất cả thú cưng
            //        Nếu khác phòng -> mỗi thú cưng 1 đơn booking riêng (như spa service)
            try {
                BoardingBookingDAO bookingDAO = new BoardingBookingDAO();
                
                if (shareRoom) {
                    // CHUNG PHÒNG: Tạo 1 booking duy nhất với tất cả thú cưng
                    BoardingBooking boardingBooking = new BoardingBooking();
                    boardingBooking.setCustomerId(customer.getCustomerId());
                    boardingBooking.setRoomType(room.getRoomType());
                    boardingBooking.setPricePerDay(BigDecimal.valueOf(pricePerDay));
                    boardingBooking.setBoardingDays((int) Math.round(boardingDays));
                    boardingBooking.setCheckInDate(checkInTimestamp);
                    boardingBooking.setCheckOutDate(checkOutTimestamp);
                    boardingBooking.setCheckInTime(checkInTimeParam != null ? checkInTimeParam : "08:00");
                    boardingBooking.setCheckOutTime(checkOutTimeParam != null ? checkOutTimeParam : "17:00");
                    boardingBooking.setPetInfo(petInfoParam); // Tất cả thú cưng trong 1 booking
                    boardingBooking.setSpecialNotes(specialNotesParam != null ? specialNotesParam : "");
                    boardingBooking.setEmergencyPhone1(emergencyPhone1Param);
                    boardingBooking.setEmergencyPhone2(emergencyPhone2Param != null ? emergencyPhone2Param : "");
                    boardingBooking.setStatus("Chờ xác nhận");
                    boardingBooking.setTotalPrice(BigDecimal.valueOf(totalPrice)); // Tổng giá cho 1 phòng
                    boardingBooking.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                    boardingBooking.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
                    
                    boolean saved = bookingDAO.addBoardingBooking(boardingBooking);
                    if (saved) {
                        logger.info("✅ Boarding booking (shared room) saved to database with ID: " + boardingBooking.getBookingId());
                    } else {
                        logger.warning("⚠️ Failed to save boarding booking (shared room) to database, but continuing...");
                    }
                } else {
                    // KHÁC PHÒNG: Tạo nhiều bookings riêng, mỗi thú cưng 1 booking (1 phòng)
                    int successCount = 0;
                    for (int i = 0; i < selectedPets.length; i++) {
                        try {
                            int petId = Integer.parseInt(selectedPets[i]);
                            Pet pet = petDAO.getPetById(petId);
                            
                            if (pet != null && pet.getCustomerId() == customer.getCustomerId()) {
                                // Tạo booking riêng cho mỗi thú cưng
                                BoardingBooking boardingBooking = new BoardingBooking();
                                boardingBooking.setCustomerId(customer.getCustomerId());
                                boardingBooking.setRoomType(room.getRoomType());
                                boardingBooking.setPricePerDay(BigDecimal.valueOf(pricePerDay));
                                boardingBooking.setBoardingDays((int) Math.round(boardingDays));
                                boardingBooking.setCheckInDate(checkInTimestamp);
                                boardingBooking.setCheckOutDate(checkOutTimestamp);
                                boardingBooking.setCheckInTime(checkInTimeParam != null ? checkInTimeParam : "08:00");
                                boardingBooking.setCheckOutTime(checkOutTimeParam != null ? checkOutTimeParam : "17:00");
                                
                                // Mỗi booking chỉ có 1 thú cưng
                                String singlePetInfo = pet.getPetName() != null ? pet.getPetName() : "Thú cưng #" + petId;
                                boardingBooking.setPetInfo(singlePetInfo);
                                
                                boardingBooking.setSpecialNotes(specialNotesParam != null ? specialNotesParam : "");
                                boardingBooking.setEmergencyPhone1(emergencyPhone1Param);
                                boardingBooking.setEmergencyPhone2(emergencyPhone2Param != null ? emergencyPhone2Param : "");
                                boardingBooking.setStatus("Chờ xác nhận");
                                boardingBooking.setTotalPrice(BigDecimal.valueOf(boardingDays * pricePerDay)); // Giá cho 1 phòng
                                boardingBooking.setCreatedAt(new Timestamp(System.currentTimeMillis()));
                                boardingBooking.setUpdatedAt(new Timestamp(System.currentTimeMillis()));
                                
                                boolean saved = bookingDAO.addBoardingBooking(boardingBooking);
                                if (saved) {
                                    successCount++;
                                    logger.info("✅ Boarding booking (separate room) saved to database with ID: " + boardingBooking.getBookingId() + " for pet: " + singlePetInfo);
                                } else {
                                    logger.warning("⚠️ Failed to save boarding booking for pet ID: " + petId);
                                }
                            }
                        } catch (NumberFormatException e) {
                            logger.warning("Invalid pet ID: " + selectedPets[i]);
                        } catch (Exception e) {
                            logger.severe("Error creating booking for pet ID " + selectedPets[i] + ": " + e.getMessage());
                        }
                    }
                    
                    if (successCount == selectedPets.length) {
                        logger.info("✅ All " + successCount + " boarding bookings (separate rooms) saved successfully");
                    } else {
                        logger.warning("⚠️ Only " + successCount + " out of " + selectedPets.length + " bookings saved successfully");
                    }
                }
            } catch (Exception e) {
                logger.severe("❌ Error saving boarding booking(s) to database: " + e.getMessage());
                e.printStackTrace();
                // Continue anyway - booking is still in session
            }
            
            // Chuyển thông tin đặt phòng đến giỏ spa
            Map<String, Object> boardingDetails = new HashMap<>();
            boardingDetails.put("roomType", room.getRoomType());
            boardingDetails.put("pricePerDay", pricePerDay);
            boardingDetails.put("boardingDays", (int) Math.ceil(boardingDays)); // Store as int for compatibility
            boardingDetails.put("boardingDaysDecimal", boardingDays); // Store decimal value for accurate pricing
            boardingDetails.put("numberOfPets", numberOfPets);
            boardingDetails.put("numberOfRooms", numberOfRooms);
            boardingDetails.put("shareRoom", shareRoom);
            boardingDetails.put("checkInDate", checkInDate);
            boardingDetails.put("checkOutDate", checkOutDate);
            boardingDetails.put("checkInTime", checkInTimeParam != null ? checkInTimeParam : "08:00");
            boardingDetails.put("checkOutTime", checkOutTimeParam != null ? checkOutTimeParam : "17:00");
            boardingDetails.put("petInfo", petInfoParam);
            boardingDetails.put("selectedPetIds", String.join(",", selectedPets)); // Store pet IDs
            boardingDetails.put("specialNotes", specialNotesParam != null ? specialNotesParam : "");
            boardingDetails.put("emergencyPhone1", emergencyPhone1Param);
            boardingDetails.put("emergencyPhone2", emergencyPhone2Param);
            
            // Tạo boarding service object
            PetServiceModel boardingService = new PetServiceModel();
            boardingService.setServiceId(1000 + room.getRoomId()); // Unique ID for boarding services
            boardingService.setName("🏠 Lưu trú " + room.getRoomName() + (numberOfPets > 1 ? " (" + numberOfPets + " thú cưng)" : ""));
            boardingService.setDescription("Dịch vụ lưu trú thú cưng - " + boardingDays + " ngày - " + 
                numberOfPets + " thú cưng" + (shareRoom ? " (Chung phòng)" : ""));
            boardingService.setPrice(BigDecimal.valueOf(totalPrice));
            boardingService.setDuration((int) Math.round(boardingDays * 24 * 60)); // Duration in minutes
            
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
            
            // Thông báo thành công tùy theo loại booking
            if (shareRoom) {
                session.setAttribute("successMessage", "Đã đặt phòng lưu trú chung cho " + numberOfPets + " thú cưng thành công!");
            } else {
                session.setAttribute("successMessage", "Đã đặt " + numberOfPets + " phòng lưu trú riêng thành công (mỗi thú cưng 1 phòng)!");
            }
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
     * Gửi đánh giá cho phòng
     */
    private void submitRoomReview(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String roomIdParam = request.getParameter("roomId");
            String ratingParam = request.getParameter("rating");
            String comment = request.getParameter("comment");
            
            if (roomIdParam == null || ratingParam == null) {
                session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            int roomId = Integer.parseInt(roomIdParam);
            int rating = Integer.parseInt(ratingParam);
            int serviceId = 1000 + roomId;
            
            if (rating < 1 || rating > 5) {
                session.setAttribute("errorMessage", "Đánh giá phải từ 1 đến 5 sao");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomId);
                return;
            }
            
            // Kiểm tra xem customer đã đặt phòng chưa
            ReviewDAO reviewDAO = new ReviewDAO();
            if (!reviewDAO.hasPurchasedService(customer.getCustomerId(), serviceId)) {
                session.setAttribute("errorMessage", "Bạn cần đặt và sử dụng phòng này trước khi đánh giá");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomId);
                return;
            }
            
            // Lấy bookingId nếu có
            Integer bookingId = reviewDAO.getBookingIdForService(customer.getCustomerId(), serviceId);
            
            // Tạo review
            Review review = new Review();
            review.setCustomerId(customer.getCustomerId());
            review.setServiceId(serviceId);
            if (bookingId != null) {
                review.setBookingId(bookingId);
            }
            review.setRating(rating);
            review.setComment(comment != null ? comment : "");
            
            reviewService.add(review);
            
            session.setAttribute("successMessage", "✅ Gửi đánh giá thành công!");
            response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomId);
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        } catch (Exception e) {
            logger.severe("Error submitting room review: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi gửi đánh giá: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }
    
    /**
     * Sửa đánh giá phòng
     */
    private void editRoomReview(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String reviewIdParam = request.getParameter("reviewId");
            String roomIdParam = request.getParameter("roomId");
            String ratingParam = request.getParameter("rating");
            String comment = request.getParameter("comment");
            
            if (reviewIdParam == null || roomIdParam == null || ratingParam == null) {
                session.setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            int reviewId = Integer.parseInt(reviewIdParam);
            int rating = Integer.parseInt(ratingParam);
            
            if (rating < 1 || rating > 5) {
                session.setAttribute("errorMessage", "Đánh giá phải từ 1 đến 5 sao");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            Review review = reviewService.getReviewById(reviewId);
            if (review == null || review.getCustomerId() != customer.getCustomerId()) {
                session.setAttribute("errorMessage", "Không tìm thấy đánh giá hoặc bạn không có quyền sửa");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            review.setRating(rating);
            review.setComment(comment != null ? comment : "");
            
            boolean success = reviewService.update(review);
            if (success) {
                session.setAttribute("successMessage", "✅ Sửa đánh giá thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể sửa đánh giá");
            }
            
            response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        } catch (Exception e) {
            logger.severe("Error editing room review: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi sửa đánh giá: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }
    
    /**
     * Xóa đánh giá phòng
     */
    private void deleteRoomReview(HttpServletRequest request, HttpServletResponse response, Customer customer)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            String reviewIdParam = request.getParameter("reviewId");
            String roomIdParam = request.getParameter("roomId");
            
            if (reviewIdParam == null || roomIdParam == null) {
                session.setAttribute("errorMessage", "Không tìm thấy đánh giá");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            int reviewId = Integer.parseInt(reviewIdParam);
            
            Review review = reviewService.getReviewById(reviewId);
            if (review == null || review.getCustomerId() != customer.getCustomerId()) {
                session.setAttribute("errorMessage", "Không tìm thấy đánh giá hoặc bạn không có quyền xóa");
                response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
                return;
            }
            
            boolean success = reviewService.delete(reviewId);
            if (success) {
                session.setAttribute("successMessage", "✅ Xóa đánh giá thành công!");
            } else {
                session.setAttribute("errorMessage", "Không thể xóa đánh giá");
            }
            
            response.sendRedirect(request.getContextPath() + "/boarding-room?action=detail&roomId=" + roomIdParam);
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Thông tin không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        } catch (Exception e) {
            logger.severe("Error deleting room review: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra khi xóa đánh giá: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/home.jsp");
        }
    }
    
    /**
     * Tính số ngày giữa 2 mốc thời gian, làm tròn lên tối thiểu 1 ngày
     */
    /**
     * Tính số ngày lưu trú linh hoạt dựa trên thời gian check-in và check-out
     * Rule: Check-in trước 12:00 = full day, sau 12:00 = half day
     *       Check-out trước 12:00 = half day, sau 12:00 = full day
     */
    private double calculateFlexibleBoardingDays(String checkInDate, String checkInTime, 
                                                  String checkOutDate, String checkOutTime) {
        try {
            SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            java.util.Date checkIn = dateTimeFormat.parse(checkInDate + " " + checkInTime);
            java.util.Date checkOut = dateTimeFormat.parse(checkOutDate + " " + checkOutTime);
            
            // Calculate time difference in milliseconds
            long diffMillis = checkOut.getTime() - checkIn.getTime();
            
            // Parse hours
            int checkInHour = Integer.parseInt(checkInTime.split(":")[0]);
            int checkOutHour = Integer.parseInt(checkOutTime.split(":")[0]);
            
            double totalDays = 0;
            
            // If same day, calculate based on hours
            if (checkInDate.equals(checkOutDate)) {
                double hours = diffMillis / (1000.0 * 60 * 60);
                if (hours <= 6) {
                    totalDays = 0.5; // Less than 6 hours = half day
                } else if (hours <= 12) {
                    totalDays = 0.75; // 6-12 hours = 0.75 days
                } else {
                    totalDays = 1.0; // More than 12 hours = full day
                }
            } else {
                // Different days: calculate days between dates (not including check-in and check-out dates)
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                java.util.Date dateIn = dateFormat.parse(checkInDate);
                java.util.Date dateOut = dateFormat.parse(checkOutDate);
                long daysDiff = (dateOut.getTime() - dateIn.getTime()) / (24L * 60L * 60L * 1000L);
                
                // Days between = daysDiff - 1 (not including check-in and check-out dates)
                // Example: 08/11 to 10/11 = 2 days diff, but only 1 day between (09/11)
                int daysBetween = (int) Math.max(0, daysDiff - 1);
                
                // Start with full days between (intermediate days - full days)
                totalDays = daysBetween;
                
                // Check-in date: add based on check-in time
                if (checkInHour < 12) {
                    // Check-in before 12:00 = full day for check-in date
                    totalDays += 1.0;
                } else {
                    // Check-in after 12:00 = half day for check-in date
                    totalDays += 0.5;
                }
                
                // Check-out date: add based on check-out time
                if (checkOutHour < 12) {
                    // Check-out before 12:00 = half day for check-out date
                    totalDays += 0.5;
                } else {
                    // Check-out after 12:00 = full day for check-out date
                    totalDays += 1.0;
                }
            }
            
            // Ensure minimum 0.5 days
            return Math.max(totalDays, 0.5);
            
        } catch (Exception e) {
            logger.warning("Error calculating flexible boarding days: " + e.getMessage());
            // Fallback to simple day calculation
            try {
                SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                java.util.Date checkIn = dateFormat.parse(checkInDate);
                java.util.Date checkOut = dateFormat.parse(checkOutDate);
                long diffMillis = checkOut.getTime() - checkIn.getTime();
                long millisPerDay = 24L * 60L * 60L * 1000L;
                return Math.max(Math.ceil(diffMillis / (double) millisPerDay), 1.0);
            } catch (ParseException pe) {
                logger.severe("Failed to parse dates in fallback: " + pe.getMessage());
                return 1.0; // Default to 1 day
            }
        }
    }
    
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
