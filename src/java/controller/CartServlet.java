package controller;

import com.google.gson.Gson;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.CartItem;
import model.Product;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/cartservlet")
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String productIdRaw = request.getParameter("id");
        String qtyRaw = request.getParameter("quantity");
        HttpSession session = request.getSession();

        // Xử lý yêu cầu đếm số lượng sản phẩm
        if ("count".equalsIgnoreCase(action)) {
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            int count = 0;
            if (cart != null) {
                for (CartItem item : cart.values()) {
                    if (item != null) {
                        count += item.getQuantity(); // Đếm tổng số lượng sản phẩm
                    }
                }
            }
            response.setContentType("text/plain");
            response.getWriter().print(count);
            return;
        }

        // Xử lý yêu cầu tính tổng tiền
        if ("total".equalsIgnoreCase(action)) {
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            double total = 0;
            if (cart != null) {
                for (CartItem item : cart.values()) {
                    if (item != null && item.getProduct() != null) {
                        total += item.getQuantity() * item.getProduct().getPrice();
                    }
                }
            }
            response.setContentType("text/plain");
            response.getWriter().print(String.format("%.2f", total));
            return;
        }

        // Xử lý yêu cầu lấy chi tiết giỏ hàng
        if ("details".equalsIgnoreCase(action)) {
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            StringBuilder html = new StringBuilder();
            
            if (cart != null && !cart.isEmpty()) {
                for (Map.Entry<Integer, CartItem> entry : cart.entrySet()) {
                    CartItem item = entry.getValue();
                    if (item != null && item.getProduct() != null) {
                        Product product = item.getProduct();
                        double itemTotal = item.getQuantity() * product.getPrice();
                        html.append("<div class='cart-item' style='display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid #e9ecef;'>");
                        html.append("<div style='flex:1;'>");
                        html.append("<strong style='color:#27ae60;'>").append(product.getName()).append("</strong><br/>");
                        html.append("<small>").append(String.format("%,.0f", product.getPrice())).append("₫/cái</small>");
                        html.append("</div>");
                        html.append("<div style='display:flex;align-items:center;gap:8px;margin:0 8px;'>");

                        html.append("<span class='cart-qty' style='min-width:30px;text-align:center;font-weight:bold;'>").append(item.getQuantity()).append("</span>");
                        html.append("</div>");
                        html.append("<div style='text-align:right;min-width:80px;'>");
                        html.append("<strong style='color:#e67e22;'>").append(String.format("%,.0f", itemTotal)).append("₫</strong><br/>");
                        html.append("</div>");
                        html.append("</div>");
                    }
                }
            } else {
                html.append("<div style='color:#888; text-align:center; padding:8px;'>Chưa có sản phẩm nào trong giỏ hàng.</div>");
            }
            
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().print(html.toString());
            return;
        }

        // Xử lý trả về danh sách ID sản phẩm trong giỏ hàng (cho chatbox)
        if ("ids".equalsIgnoreCase(action)) {
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            java.util.List<Integer> ids = new java.util.ArrayList<>();
            if (cart != null) {
                ids.addAll(cart.keySet());
            }
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write(new com.google.gson.Gson().toJson(ids));
            return;
        }

        // Xử lý xóa sản phẩm từ chatbox
        if ("remove_chat".equalsIgnoreCase(action)) {
            if (productIdRaw != null) {
                try {
                    int productId = Integer.parseInt(productIdRaw);
                    Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
                    if (cart != null) {
                        cart.remove(productId);
                        session.setAttribute("cart", cart);
                        response.setContentType("application/json; charset=UTF-8");
                        response.getWriter().write("{\"success\": true, \"message\": \"Đã xóa sản phẩm\"}");
                    } else {
                        response.setContentType("application/json; charset=UTF-8");
                        response.getWriter().write("{\"success\": false, \"message\": \"Không tìm thấy giỏ hàng\"}");
                    }
                } catch (NumberFormatException e) {
                    response.setContentType("application/json; charset=UTF-8");
                    response.getWriter().write("{\"success\": false, \"message\": \"Sai định dạng tham số\"}");
                }
            } else {
                response.setContentType("application/json; charset=UTF-8");
                response.getWriter().write("{\"success\": false, \"message\": \"Thiếu tham số\"}");
            }
            return;
        }
     

        // Kiểm tra tham số bắt buộc
        if (action == null || productIdRaw == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số.");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdRaw);
            int quantity = 1;
            if (qtyRaw != null) {
                quantity = Integer.parseInt(qtyRaw);
            }

            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getProductById(productId);

            if (product == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy sản phẩm.");
                return;
            }

            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
            if (cart == null) {
                cart = new HashMap<>();
            }

            int currentQty = cart.containsKey(productId) ? cart.get(productId).getQuantity() : 0;
            int newQty = currentQty + quantity;

            boolean available = productDAO.checkStockAvailability(productId, newQty);

            if (available) {
                if (cart.containsKey(productId)) {
                    cart.get(productId).setQuantity(newQty);
                } else {
                    cart.put(productId, new CartItem(product, quantity));
                }

                session.setAttribute("cart", cart);
                response.setContentType("text/plain");
                response.getWriter().write("success");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Không đủ hàng trong kho.");
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Sai định dạng tham số.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
        }

        String action = request.getParameter("action");

        // Xử lý thêm sản phẩm vào giỏ hàng
        if ("add".equalsIgnoreCase(action)) {
            String productIdRaw = request.getParameter("id");
            String qtyRaw = request.getParameter("quantity");
            if (productIdRaw == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số.");
                return;
            }
            try {
                int productId = Integer.parseInt(productIdRaw);
                int quantity = 1;
                if (qtyRaw != null) {
                    quantity = Integer.parseInt(qtyRaw);
                }
                ProductDAO productDAO = new ProductDAO();
                Product product = productDAO.getProductById(productId);
                if (product == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy sản phẩm.");
                    return;
                }
                int currentQty = cart.containsKey(productId) ? cart.get(productId).getQuantity() : 0;
                int newQty = currentQty + quantity;
                boolean available = productDAO.checkStockAvailability(productId, newQty);
                if (available) {
                    if (cart.containsKey(productId)) {
                        cart.get(productId).setQuantity(newQty);
                    } else {
                        cart.put(productId, new CartItem(product, quantity));
                    }
                    session.setAttribute("cart", cart);
                    response.setContentType("text/plain");
                    response.getWriter().write("success");
                } else {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Không đủ hàng trong kho.");
                }
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Sai định dạng tham số.");
            }
            return;
        }

        // Xử lý xóa sản phẩm
        if ("remove".equalsIgnoreCase(action)) {
            handleRemoveItem(request, response, session, cart);
            return;
        }

        // Xử lý cập nhật số lượng
        if ("update".equalsIgnoreCase(action)) {
            handleUpdateQuantity(request, response, session, cart);
            return;
        }

        // Xử lý xóa toàn bộ giỏ hàng từ chatbox
        if ("clear".equalsIgnoreCase(action)) {
            session.removeAttribute("cart");
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"success\": true, \"message\": 'Đã xoá toàn bộ giỏ hàng!' }");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/cart/cart.jsp");
    }

    private void handleRemoveItem(HttpServletRequest request, HttpServletResponse response, 
            HttpSession session, Map<Integer, CartItem> cart) throws IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int productId = Integer.parseInt(idStr);
                cart.remove(productId);
                session.setAttribute("cart", cart);
                session.setAttribute("total", calculateTotal(cart));
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Sai định dạng tham số.");
                return;
            }
        }
        response.sendRedirect(request.getContextPath() + "/cart/cart.jsp");
    }

    private void handleUpdateQuantity(HttpServletRequest request, HttpServletResponse response,
        HttpSession session, Map<Integer, CartItem> cart) throws ServletException, IOException {
    String[] productIds = request.getParameterValues("productId");
    String[] quantities = request.getParameterValues("quantity");

    if (productIds == null || quantities == null || productIds.length != quantities.length) {
        response.sendRedirect(request.getContextPath() + "/cart/cart.jsp");
        return;
    }

    ProductDAO dao = new ProductDAO();
    boolean hasError = false;
    String errorMessage = null;
    Map<String, String> responseData = new HashMap<>();

    for (int i = 0; i < productIds.length; i++) {
        try {
            int id = Integer.parseInt(productIds[i]);
            int qty = Integer.parseInt(quantities[i]);

            if (qty <= 0) {
                cart.remove(id);
                continue;
            }

            if (!dao.checkStockAvailability(id, qty)) {
                hasError = true;
                errorMessage = "Sản phẩm " + id + " không đủ hàng trong kho";
                responseData.put("error", errorMessage);
                continue;
            }

            if (cart.containsKey(id)) {
                cart.get(id).setQuantity(qty);
                // Tính toán lại giá trị cho sản phẩm vừa cập nhật
                CartItem item = cart.get(id);
                double itemTotal = item.getQuantity() * item.getProduct().getPrice();
                responseData.put("item_" + id, String.format("%.2f", itemTotal));
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Sai định dạng tham số.");
            return;
        }
    }

    session.setAttribute("cart", cart);
    double total = calculateTotal(cart);
    session.setAttribute("total", total);
    responseData.put("total", String.format("%.2f", total));

    // Trả về JSON nếu là AJAX request
    if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(responseData));
        return;
    }

    if (hasError) {
        request.setAttribute("errorMessage", errorMessage);
        request.getRequestDispatcher("/cart/cart.jsp").forward(request, response);
    } else {
        response.sendRedirect(request.getContextPath() + "/cart/cart.jsp");
    }
}

    private double calculateTotal(Map<Integer, CartItem> cart) {
        double total = 0;
        if (cart != null) {
            for (CartItem item : cart.values()) {
                if (item != null && item.getProduct() != null) {
                    total += item.getQuantity() * item.getProduct().getPrice();
                }
            }
        }
        return total;
    }
}
