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
        <title>Thêm sản phẩm mới</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-100 p-6">
        <div class="max-w-3xl mx-auto bg-white shadow-md rounded-lg p-6">
            <h2 class="text-2xl font-bold text-orange-600 mb-4">🧸 Thêm sản phẩm mới</h2>

            <form action="<%=request.getContextPath()%>/admin/toys" method="post" enctype="multipart/form-data" class="space-y-4">
                <input type="hidden" name="action" value="create">

                <div>
                    <label class="block font-semibold mb-1">Tên sản phẩm</label>
                    <input type="text" name="name" required class="w-full border border-gray-300 rounded px-3 py-2">
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block font-semibold mb-1">Giá</label>
                        <input type="number" step="0.01" name="price" required class="w-full border px-3 py-2 rounded">
                    </div>
                    <div>
                        <label class="block font-semibold mb-1">Số lượng kho</label>
                        <input type="number" name="stock" required class="w-full border px-3 py-2 rounded">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block mb-2 font-medium">Danh mục</label>
                        <select name="categoryId" class="form-select w-full p-2 border rounded mb-4" required>
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}">${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div>
                        <label class="block font-semibold mb-1">Nhà cung cấp</label>
                        <select name="supplierId" class="form-select w-full p-2 border rounded" required>
                            <option value="">-- Chọn nhà cung cấp --</option>
                            <c:forEach var="sup" items="${suppliers}">
                                <option value="${sup.supplierId}">${sup.nameCompany}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block font-semibold mb-1">Mô tả</label>
                    <textarea name="description" rows="3" class="w-full border px-3 py-2 rounded resize-none"></textarea>
                </div>

                <div>
                    <label class="block font-semibold mb-1">Hình ảnh</label>
                    <input type="file" name="image" accept=".jpg,image/jpeg" required class="w-full border px-3 py-2 rounded bg-white" onchange="validateImage(this)">
                </div>

                <div class="flex items-center justify-between mt-6">
                    <a href="toys" class="text-gray-500 hover:underline">← Quay lại danh sách</a>
                    <button type="submit" class="bg-orange-500 hover:bg-orange-600 text-white px-5 py-2 rounded">
                        Thêm sản phẩm
                    </button>
                </div>
            </form>
        </div>
        <script>
            function validateImage(input) {
                const file = input.files[0];
                if (file) {
                    const fileName = file.name.toLowerCase();
                    const allowedExtension = /\.jpg$/;

                    if (!allowedExtension.test(fileName)) {
                        alert("❌ Chỉ chấp nhận ảnh định dạng .jpg");
                        input.value = ""; // Clear file input
                    }
                }
            }
        </script>

    </body>
</html>
