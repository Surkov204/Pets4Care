package service;

import dao.BookingDAO;
import dao.BookingServiceDAO;
import dao.PetServiceDAO;
import dao.DoctorDAO;
import model.Booking;
import model.BookingServiceItem;
import model.Customer;
import model.Pet;
import model.Doctor;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Service xử lý logic nghiệp vụ cho Health Check Booking
 * Tích hợp với trang đặt lịch khám hiện có
 * @author ASUS
 */
public class HealthCheckBookingService {
    
    private static final Logger logger = Logger.getLogger(HealthCheckBookingService.class.getName());
    
    private BookingDAO bookingDAO;
    private BookingServiceDAO bookingServiceDAO;
    private PetServiceDAO petServiceDAO;
    private PetService petService;
    private dao.PetDAO petDAO;
    private DoctorDAO doctorDAO;

    public HealthCheckBookingService() {
        this.bookingDAO = new BookingDAO();
        this.bookingServiceDAO = new BookingServiceDAO();
        this.petServiceDAO = new PetServiceDAO();
        this.petService = new PetService();
        this.petDAO = new dao.PetDAO();
        this.doctorDAO = new DoctorDAO();
    }
    
    /**
     * Lấy tất cả dịch vụ khám sức khỏe đang hoạt động
     */
    public List<model.PetServiceModel> getActiveHealthCheckServices() {
        return petServiceDAO.getActiveServicesByType("health_check");
    }
    
    /**
     * Lấy dịch vụ khám sức khỏe theo ID
     */
    public model.PetServiceModel getHealthCheckServiceById(int serviceId) {
        model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
        if (service != null && service.isHealthCheckService()) {
            return service;
        }
        return null;
    }
    
    /**
     * Validate dịch vụ khám sức khỏe có thể đặt lịch
     */
    public boolean validateHealthCheckService(int serviceId) {
        model.PetServiceModel service = getHealthCheckServiceById(serviceId);
        return service != null && service.isActive();
    }
    
    /**
     * Tạo booking khám sức khỏe
     */
    public boolean createHealthCheckBooking(Customer customer, int petId, int serviceId,
                                          Timestamp appointmentStart, String note, int doctorId) {
        logger.info("=== BẮT ĐẦU TẠO BOOKING ===");
        logger.info("Customer ID: " + customer.getCustomerId());
        logger.info("Pet ID: " + petId);
        logger.info("Service ID: " + serviceId);
        logger.info("Doctor ID: " + doctorId);
        logger.info("Appointment Start: " + appointmentStart);

        try {
            // 1. Validate customer và pet
            logger.info("Bước 1: Kiểm tra thông tin pet...");
            Pet pet = petDAO.getPetById(petId);
            if (pet == null) {
                logger.severe("❌ FAILED: Pet ID " + petId + " không tồn tại");
                return false;
            }
            // Verify pet belongs to customer
            if (pet.getCustomerId() != customer.getCustomerId()) {
                logger.severe("❌ FAILED: Pet ID " + petId + " không thuộc về customer " + customer.getCustomerId());
                return false;
            }
            logger.info("✓ Pet found: ID=" + pet.getId() + ", Name=" + pet.getPetName());

            // 2. Kiểm tra trùng lịch với bác sĩ
            logger.info("Bước 2: Kiểm tra trùng lịch bác sĩ...");
            if (hasConflictingAppointment(doctorId, appointmentStart)) {
                logger.severe("❌ FAILED: Bác sĩ " + doctorId + " đã có lịch hẹn vào thời gian này");
                return false;
            }
            logger.info("✓ No conflicting appointments found");
            
            // 3. Validate dịch vụ khám sức khỏe
            logger.info("Bước 3: Kiểm tra dịch vụ...");
            if (!validateHealthCheckService(serviceId)) {
                logger.severe("❌ FAILED: Dịch vụ khám sức khỏe ID " + serviceId + " không hợp lệ");
                return false;
            }
            logger.info("✓ Service validated");

            // 4. Lấy thông tin dịch vụ
            logger.info("Bước 4: Lấy thông tin dịch vụ...");
            model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
            if (service == null) {
                logger.severe("❌ FAILED: Không tìm thấy dịch vụ ID: " + serviceId);
                return false;
            }
            logger.info("✓ Service: " + service.getName() + ", Price: " + service.getPrice() + ", Duration: " + service.getDuration());

            // 5. Tính thời gian kết thúc
            logger.info("Bước 5: Tính thời gian kết thúc...");
            int duration = service.getDuration();
            Timestamp appointmentEnd = new Timestamp(appointmentStart.getTime() + (duration * 60 * 1000L));
            logger.info("✓ Appointment End: " + appointmentEnd);

            // 6. Tạo booking
            logger.info("Bước 6: Tạo booking object...");
            Booking booking = new Booking();
            booking.setCustomerId(customer.getCustomerId());
            booking.setPetId(pet.getId());
            booking.setAppointmentStart(appointmentStart);
            booking.setAppointmentEnd(appointmentEnd);
            booking.setStatus("Hoàn thành"); // Status là "Hoàn thành" sau khi thanh toán thành công
            booking.setNote(note != null ? note.trim() : "");
            booking.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            booking.setDoctorId(doctorId);
            logger.info("✓ Booking object created with status: Hoàn thành");

            // 7. Lưu booking và chi tiết
            logger.info("Bước 7: Lưu booking vào database...");
            boolean success = createBookingWithService(booking, serviceId);
            
            if (success) {
                logger.info("✅ SUCCESS: Tạo booking khám sức khỏe thành công! Booking ID: " + booking.getBookingId());
            } else {
                logger.severe("❌ FAILED: Không thể lưu booking vào database");
            }
            
            return success;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "❌ EXCEPTION: Lỗi khi tạo booking khám sức khỏe", e);
            return false;
        }
    }
    
    /**
     * Tạo booking với dịch vụ khám sức khỏe
     */
    private boolean createBookingWithService(Booking booking, int serviceId) {
        logger.info("  → Bước 6.1: Lưu booking chính vào bảng Booking...");
        try {
            // 1. Tạo booking chính
            boolean bookingCreated = bookingDAO.addBooking(booking);
            if (!bookingCreated) {
                logger.severe("  ❌ Không thể tạo booking chính trong database");
                return false;
            }
            logger.info("  ✓ Booking created with ID: " + booking.getBookingId());
            
            // 2. Tạo chi tiết booking service
            logger.info("  → Bước 6.2: Lấy thông tin dịch vụ để tạo Booking_Service...");
            model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
            if (service == null) {
                logger.severe("  ❌ Không tìm thấy dịch vụ ID: " + serviceId);
                return false;
            }
            logger.info("  ✓ Service found: " + service.getName());
            
            logger.info("  → Bước 6.3: Tạo booking service item...");
            BookingServiceItem bookingService = new BookingServiceItem();
            bookingService.setBookingId(booking.getBookingId());
            bookingService.setServiceId(serviceId);
            bookingService.setQuantity(1);
            bookingService.setPrice(service.getPrice());
            bookingService.setNote("");
            logger.info("  ✓ BookingService object created: booking_id=" + booking.getBookingId() + ", service_id=" + serviceId);
            
            logger.info("  → Bước 6.4: Lưu booking service vào bảng Booking_Service...");
            boolean detailCreated = bookingServiceDAO.addBookingService(bookingService);
            if (!detailCreated) {
                logger.severe("  ❌ Không thể tạo chi tiết booking service ID: " + serviceId);
                return false;
            }
            logger.info("  ✓ Booking service detail created successfully");
            
            logger.info("  ✓ HOÀN THÀNH: Đã lưu booking và booking service vào database");
            return true;
            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "  ❌ EXCEPTION: Lỗi khi tạo booking với service", e);
            return false;
        }
    }
    
    /**
     * Lấy booking khám sức khỏe của customer
     */
    public List<Booking> getHealthCheckBookingsByCustomerId(int customerId) {
        List<Booking> allBookings = bookingDAO.getBookingsByCustomerId(customerId);
        List<Booking> healthCheckBookings = new ArrayList<>();
        
        for (Booking booking : allBookings) {
            List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
            boolean hasHealthCheckService = false;
            
            for (BookingServiceItem bs : bookingServices) {
                if (bs.isHealthCheckService()) {
                    hasHealthCheckService = true;
                    break;
                }
            }
            
            if (hasHealthCheckService) {
                healthCheckBookings.add(booking);
            }
        }
        
        return healthCheckBookings;
    }
    
    /**
     * Kiểm tra xem có thể hủy booking khám sức khỏe không
     */
    public boolean canCancelHealthCheckBooking(int bookingId) {
        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            return false;
        }
        
        String status = booking.getStatus();
        return "pending".equals(status) || "confirmed".equals(status);
    }
    
    /**
     * Hủy booking khám sức khỏe
     */
    public boolean cancelHealthCheckBooking(int bookingId) {
        if (!canCancelHealthCheckBooking(bookingId)) {
            logger.warning("Không thể hủy booking ID: " + bookingId);
            return false;
        }
        
        return bookingDAO.updateBookingStatus(bookingId, "cancelled");
    }
    
    /**
     * Lấy chi tiết booking khám sức khỏe
     */
    public List<BookingServiceItem> getHealthCheckBookingDetails(int bookingId) {
        List<BookingServiceItem> allDetails = bookingServiceDAO.getBookingServicesByBookingId(bookingId);
        List<BookingServiceItem> healthCheckDetails = new ArrayList<>();
        
        for (BookingServiceItem detail : allDetails) {
            if (detail.isHealthCheckService()) {
                healthCheckDetails.add(detail);
            }
        }
        
        return healthCheckDetails;
    }
    
    /**
     * Lấy lịch sử khám sức khỏe của pet
     */
    public List<Booking> getHealthCheckHistoryByPetId(int petId) {
        List<Booking> allBookings = bookingDAO.getBookingsByPetId(petId);
        List<Booking> healthCheckHistory = new ArrayList<>();
        
        for (Booking booking : allBookings) {
            List<BookingServiceItem> bookingServices = bookingServiceDAO.getBookingServicesByBookingId(booking.getBookingId());
            boolean hasHealthCheckService = false;
            
            for (BookingServiceItem bs : bookingServices) {
                if (bs.isHealthCheckService()) {
                    hasHealthCheckService = true;
                    break;
                }
            }
            
            if (hasHealthCheckService) {
                healthCheckHistory.add(booking);
            }
        }
        
        return healthCheckHistory;
    }
    
    /**
     * Kiểm tra thời gian hẹn có hợp lệ không
     */
    public boolean validateAppointmentTime(Timestamp appointmentStart) {
        // Kiểm tra thời gian hẹn không được trong quá khứ
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (appointmentStart.before(now)) {
            return false;
        }
        
        // Kiểm tra thời gian hẹn không được quá xa trong tương lai (tối đa 3 tháng)
        long threeMonthsInMillis = 3L * 30L * 24L * 60L * 60L * 1000L;
        Timestamp maxAppointment = new Timestamp(now.getTime() + threeMonthsInMillis);
        if (appointmentStart.after(maxAppointment)) {
            return false;
        }
        
        // Kiểm tra giờ làm việc (8:00 - 17:00)
        LocalDateTime appointmentDateTime = appointmentStart.toLocalDateTime();
        int hour = appointmentDateTime.getHour();
        if (hour < 8 || hour >= 17) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Lấy các khung giờ có sẵn trong ngày
     */
    public List<String> getAvailableTimeSlots(String date) {
        List<String> availableSlots = new ArrayList<>();
        
        // Tạo danh sách khung giờ mặc định
        String[] timeSlots = {
            "08:00", "09:00", "10:00", "11:00", 
            "14:00", "15:00", "16:00", "17:00"
        };
        
        for (String timeSlot : timeSlots) {
            // TODO: Kiểm tra xem khung giờ này có bị trùng với booking khác không
            // Hiện tại trả về tất cả khung giờ
            availableSlots.add(timeSlot);
        }
        
        return availableSlots;
    }

    /**
     * Kiểm tra xem bác sĩ có lịch hẹn trùng vào thời gian này không
     */
    public boolean hasConflictingAppointment(int doctorId, Timestamp appointmentStart) {
        try {
            // Lấy danh sách booking của bác sĩ trong ngày
            java.sql.Date appointmentDate = new java.sql.Date(appointmentStart.getTime());
            List<Booking> doctorBookings = bookingDAO.getBookingsByDoctorAndDate(doctorId, appointmentDate.toLocalDate());

            // Kiểm tra trùng thời gian
            for (Booking booking : doctorBookings) {
                // Chỉ kiểm tra các booking chưa bị hủy
                if (!"cancelled".equals(booking.getStatus())) {
                    // Kiểm tra thời gian bắt đầu có trùng không
                    if (booking.getAppointmentStart().equals(appointmentStart)) {
                        logger.warning("Conflicting appointment found: Doctor " + doctorId +
                                     " already has booking at " + appointmentStart);
                        return true;
                    }

                    // Kiểm tra khoảng thời gian có chồng lấn không
                    if (booking.getAppointmentStart().before(appointmentStart) &&
                        booking.getAppointmentEnd().after(appointmentStart)) {
                        logger.warning("Time overlap detected: Doctor " + doctorId +
                                     " has overlapping booking from " + booking.getAppointmentStart() +
                                     " to " + booking.getAppointmentEnd());
                        return true;
                    }
                }
            }

            return false;

        } catch (Exception e) {
            logger.severe("Error checking for conflicting appointments: " + e.getMessage());
            e.printStackTrace();
            // Trong trường hợp lỗi, cho phép tạo booking để tránh block user
            return false;
        }
    }

    /**
     * Tự động chọn bác sĩ phù hợp với dịch vụ khám dựa trên chuyên khoa
     */
    public Doctor getSuitableDoctorForService(int serviceId, Timestamp appointmentStart) {
        try {
            // Lấy thông tin dịch vụ
            model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
            if (service == null) {
                logger.warning("Service not found: " + serviceId);
                return getDefaultAvailableDoctor(appointmentStart);
            }

            // Lấy danh sách chuyên khoa ưu tiên cho dịch vụ này
            List<String> prioritySpecializations = getPrioritySpecializationsForService(serviceId);
            logger.info("Service ID: " + serviceId + " -> Priority specializations: " + prioritySpecializations);

            // Duyệt qua từng chuyên khoa theo thứ tự ưu tiên
            for (int priority = 0; priority < prioritySpecializations.size(); priority++) {
                String targetSpecialization = prioritySpecializations.get(priority);
                logger.info("Trying specialization (Priority " + (priority + 1) + "): " + targetSpecialization);
                
                // Tìm bác sĩ có chuyên khoa này
                List<Doctor> suitableDoctors = doctorDAO.getDoctorsBySpecialization(targetSpecialization);
                
                if (suitableDoctors != null && !suitableDoctors.isEmpty()) {
                    // Tìm bác sĩ có chuyên khoa phù hợp và không bận vào thời gian đặt
                    for (Doctor doctor : suitableDoctors) {
                        if (!hasConflictingAppointment(doctor.getDoctorId(), appointmentStart)) {
                            logger.info("✅ Found suitable doctor (Priority " + (priority + 1) + "): " + doctor.getName() + 
                                       " (ID: " + doctor.getDoctorId() + ", Specialization: " + doctor.getSpecialization() + ")");
                            return doctor;
                        }
                    }
                    logger.info("⚠️ All doctors with specialization '" + targetSpecialization + "' (Priority " + (priority + 1) + ") are busy");
                } else {
                    logger.info("ℹ️ No doctors found with specialization: " + targetSpecialization + " (Priority " + (priority + 1) + ")");
                }
            }
            
            // Nếu không tìm thấy bác sĩ nào từ các chuyên khoa ưu tiên, tìm bác sĩ khác đang rảnh
            logger.warning("⚠️ All doctors from priority specializations are busy or not found, finding any available doctor");
            Doctor availableDoctor = getDefaultAvailableDoctor(appointmentStart);
            if (availableDoctor != null) {
                logger.info("✅ Found alternative available doctor: " + availableDoctor.getName() + 
                           " (ID: " + availableDoctor.getDoctorId() + ", Specialization: " + availableDoctor.getSpecialization() + ")");
                return availableDoctor;
            }

            // Nếu không tìm thấy bác sĩ nào, trả về null để caller xử lý
            logger.severe("❌ No available doctor found after trying all priority specializations");
            return null;

        } catch (Exception e) {
            logger.severe("Error getting suitable doctor for service: " + e.getMessage());
            e.printStackTrace();
            return getDefaultAvailableDoctor(appointmentStart);
        }
    }

    /**
     * Lấy danh sách chuyên khoa ưu tiên cho dịch vụ (theo thứ tự ưu tiên 1, 2, 3...)
     * @param serviceId ID của dịch vụ
     * @return Danh sách chuyên khoa theo thứ tự ưu tiên
     */
    private List<String> getPrioritySpecializationsForService(int serviceId) {
        List<String> specializations = new ArrayList<>();
        
        // Mapping dịch vụ cụ thể với chuyên khoa ưu tiên
        switch (serviceId) {
            case 1: // Khám sức khỏe tổng quát
                specializations.add("Tim mạch & hô hấp"); // Ưu tiên 1: Kiểm tra tim mạch, hô hấp
                specializations.add("Tiêu hóa & dinh dưỡng"); // Ưu tiên 2: Kiểm tra tiêu hóa
                specializations.add("Da liễu & chăm sóc da"); // Ưu tiên 3: Kiểm tra da
                break;
                
            case 2: // Khám chuyên sâu (xét nghiệm máu, nước tiểu, X-quang)
                specializations.add("Thần kinh & hành vi"); // Ưu tiên 1: Chuyên sâu, cần chẩn đoán phức tạp
                specializations.add("Tim mạch & hô hấp"); // Ưu tiên 2: Xét nghiệm tim mạch
                specializations.add("Tiêu hóa & dinh dưỡng"); // Ưu tiên 3: Xét nghiệm tiêu hóa
                break;
                
            case 3: // Khám định kỳ
                specializations.add("Tiêu hóa & dinh dưỡng"); // Ưu tiên 1: Theo dõi sức khỏe định kỳ
                specializations.add("Tim mạch & hô hấp"); // Ưu tiên 2: Kiểm tra tim mạch
                specializations.add("Da liễu & chăm sóc da"); // Ưu tiên 3: Kiểm tra da
                break;
                
            case 4: // Tiêm phòng cơ bản
                specializations.add("Thần kinh & hành vi"); // Ưu tiên 1: Chuyên về tiêm phòng, vaccine
                specializations.add("Tim mạch & hô hấp"); // Ưu tiên 2: Phòng bệnh hô hấp
                specializations.add("Tiêu hóa & dinh dưỡng"); // Ưu tiên 3: Phòng bệnh tiêu hóa
                break;
                
            case 5: // Tư vấn dinh dưỡng
                specializations.add("Tiêu hóa & dinh dưỡng"); // Ưu tiên 1: Chuyên về dinh dưỡng
                specializations.add("Tim mạch & hô hấp"); // Ưu tiên 2: Dinh dưỡng cho tim mạch
                break;
                
            default:
                // Fallback: Dựa vào tên và mô tả dịch vụ
                model.PetServiceModel service = petServiceDAO.getServiceById(serviceId);
                if (service != null) {
                    String serviceName = service.getName().toLowerCase();
                    String serviceDescription = service.getDescription() != null ? service.getDescription().toLowerCase() : "";
                    String combinedText = serviceName + " " + serviceDescription;
                    
                    if (combinedText.contains("dinh dưỡng") || combinedText.contains("tiêu hóa") || combinedText.contains("ăn uống")) {
                        specializations.add("Tiêu hóa & dinh dưỡng");
                        specializations.add("Tim mạch & hô hấp");
                    } else if (combinedText.contains("da liễu") || combinedText.contains("da") || combinedText.contains("lông")) {
                        specializations.add("Da liễu & chăm sóc da");
                        specializations.add("Tiêu hóa & dinh dưỡng");
                    } else if (combinedText.contains("phẫu thuật") || combinedText.contains("chỉnh hình")) {
                        specializations.add("Phẫu thuật & chỉnh hình");
                        specializations.add("Tim mạch & hô hấp");
                    } else if (combinedText.contains("tim mạch") || combinedText.contains("hô hấp") || combinedText.contains("tim") || combinedText.contains("phổi")) {
                        specializations.add("Tim mạch & hô hấp");
                        specializations.add("Tiêu hóa & dinh dưỡng");
                    } else if (combinedText.contains("sản khoa") || combinedText.contains("sinh sản") || combinedText.contains("thai")) {
                        specializations.add("Sản khoa & sinh sản");
                        specializations.add("Tiêu hóa & dinh dưỡng");
                    } else if (combinedText.contains("thần kinh") || combinedText.contains("hành vi") || combinedText.contains("tâm lý")) {
                        specializations.add("Thần kinh & hành vi");
                        specializations.add("Tim mạch & hô hấp");
                    } else {
                        // Default cho các dịch vụ khác
                        specializations.add("Tiêu hóa & dinh dưỡng");
                        specializations.add("Tim mạch & hô hấp");
                    }
                } else {
                    // Fallback cuối cùng
                    specializations.add("Tiêu hóa & dinh dưỡng");
                }
                break;
        }
        
        return specializations;
    }
    
    /**
     * Xác định chuyên khoa dựa trên tên và mô tả dịch vụ (deprecated - sử dụng getPrioritySpecializationsForService)
     * @deprecated Sử dụng getPrioritySpecializationsForService để có danh sách ưu tiên
     */
    @Deprecated
    private String determineSpecializationFromService(String serviceText) {
        // Giữ lại method này để tương thích với code cũ
        if (serviceText.contains("dinh dưỡng") || serviceText.contains("tiêu hóa") || serviceText.contains("ăn uống")) {
            return "Tiêu hóa & dinh dưỡng";
        } else if (serviceText.contains("da liễu") || serviceText.contains("da") || serviceText.contains("lông")) {
            return "Da liễu & chăm sóc da";
        } else if (serviceText.contains("phẫu thuật") || serviceText.contains("chỉnh hình")) {
            return "Phẫu thuật & chỉnh hình";
        } else if (serviceText.contains("tim mạch") || serviceText.contains("hô hấp") || serviceText.contains("tim")) {
            return "Tim mạch & hô hấp";
        } else if (serviceText.contains("sản khoa") || serviceText.contains("sinh sản")) {
            return "Sản khoa & sinh sản";
        } else if (serviceText.contains("thần kinh") || serviceText.contains("hành vi")) {
            return "Thần kinh & hành vi";
        }
        return "Tiêu hóa & dinh dưỡng";
    }

    /**
     * Lấy bác sĩ có sẵn mặc định (không bận vào thời gian đặt)
     */
    private Doctor getDefaultAvailableDoctor(Timestamp appointmentStart) {
        try {
            List<Doctor> allDoctors = doctorDAO.getAllActiveDoctors();
            
            // Tìm bác sĩ có sẵn đầu tiên
            for (Doctor doctor : allDoctors) {
                if (!hasConflictingAppointment(doctor.getDoctorId(), appointmentStart)) {
                    logger.info("✅ Found available doctor: " + doctor.getName() + " (ID: " + doctor.getDoctorId() + ")");
                    return doctor;
                }
            }
            
            // Nếu tất cả đều bận, trả về bác sĩ đầu tiên
            if (!allDoctors.isEmpty()) {
                logger.warning("⚠️ All doctors are busy, selecting first doctor: " + allDoctors.get(0).getName());
                return allDoctors.get(0);
            }
            
            // Fallback: lấy bất kỳ bác sĩ nào
            int doctorId = doctorDAO.getAnyActiveDoctorId();
            if (doctorId > 0) {
                Doctor doctor = doctorDAO.findById(doctorId);
                if (doctor != null) {
                    logger.warning("⚠️ Using fallback doctor: " + doctor.getName());
                    return doctor;
                }
            }
            
        } catch (Exception e) {
            logger.severe("Error getting default available doctor: " + e.getMessage());
            e.printStackTrace();
        }
        
        logger.severe("❌ No doctor available!");
        return null;
    }
}
