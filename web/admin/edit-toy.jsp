<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Admin" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    Admin admin = (Admin) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Cập nhật sản phẩm</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 p-6">
    <div class="max-w-3xl mx-auto bg-white shadow-md rounded-lg p-6">
        <h2 class="text-2xl font-bold text-orange-600 mb-4">🛠️ Chỉnh sửa sản phẩm</h2>
        <p class="text-sm text-gray-500 mb-2">DEBUG PRODUCT ID: ${product.productId}</p>

        <form action="<%=request.getContextPath()%>/admin/toys" method="post" enctype="multipart/form-data" class="space-y-4">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="productId" value="${product.productId}">

            <div>
                <label class="block font-semibold mb-1">Tên sản phẩm</label>
                <input type="text" name="name" required class="w-full border border-gray-300 rounded px-3 py-2"
                       value="${product.name}">
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block font-semibold mb-1">Giá</label>
                    <input type="number" step="0.01" name="price" required class="w-full border px-3 py-2 rounded"
                           value="${product.price}">
                </div>
                <div>
                    <label class="block font-semibold mb-1">Số lượng kho</label>
                    <input type="number" name="stock" required class="w-full border px-3 py-2 rounded"
                           value="${product.stockQuantity}">
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block font-semibold mb-1">Danh mục</label>
                    <select name="categoryId" class="form-select w-full p-2 border rounded mb-4" required>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}" 
                                    <c:if test="${cat.categoryId == product.categoryId}">selected</c:if>>
                                ${cat.name}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div>
                    <label class="block font-semibold mb-1">Nhà cung cấp</label>
                    <select name="supplierId" class="form-select w-full p-2 border rounded" required>
                        <c:forEach var="sup" items="${suppliers}">
                            <option value="${sup.supplierId}" 
                                    <c:if test="${sup.supplierId == product.supplierId}">selected</c:if>>
                                ${sup.nameCompany}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div>
                <label class="block font-semibold mb-1">Mô tả</label>
                <textarea name="description" rows="3" class="w-full border px-3 py-2 rounded resize-none">${product.description}</textarea>
            </div>

            <div>
                <label class="block font-semibold mb-1">Cập nhật hình ảnh (chỉ file '.jpg')</label>
                <input type="file" name="image" accept="image/jpeg" class="w-full border px-3 py-2 rounded bg-white">
                <p class="text-sm text-gray-500 mt-1">Nếu không chọn, ảnh cũ sẽ được giữ lại.</p>
            </div>

            <div class="flex items-center justify-between mt-6">
                <a href="toys" class="text-gray-500 hover:underline">← Quay lại danh sách</a>
                <button type="submit" class="bg-orange-500 hover:bg-orange-600 text-white px-5 py-2 rounded">
                    Cập nhật sản phẩm
                </button>
            </div>
        </form>
    </div>
</body>
</html>
