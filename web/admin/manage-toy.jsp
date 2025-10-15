<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý sản phẩm</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-100 min-h-screen font-sans flex">
        <!-- Sidebar -->
        <div class="w-1/5 bg-white shadow h-screen p-6 fixed top-0 left-0 border-r border-orange-100">
            <h2 class="text-xl font-bold text-orange-600 mb-6 font-baloo">📋 Danh mục quản lý</h2>
            <ul class="space-y-3">
                <li>
                    <a href="toys?action=list"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                        🧸 Sản phẩm
                    </a>
                </li>
                <li>
                    <a href="SupplierServlet?action=list"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                        🏢 Nhà cung cấp
                    </a>
                </li>
                <li>
                    <a href="manage-customer"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-semibold">
                        👤 Khách hàng
                    </a>
                </li>
                <li>
                    <a href="manage-order"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                        📦 Đơn hàng
                    </a>
                </li>
                <li>
                    <a href="statistics?type=day"
                       class="block px-3 py-2 rounded-md text-blue-600 hover:bg-orange-50 hover:text-orange-700 transition font-medium">
                        📈 Thống kê
                    </a>
                </li>
            </ul>

            <div class="mt-10 space-y-2">
                <a href="dashboard.jsp"
                   class="block text-center bg-gray-100 hover:bg-gray-200 text-sm text-gray-700 font-medium py-2 px-3 rounded-md transition">
                    🔙 Quay về Dashboard
                </a>
                <a href="../home"
                   class="block text-center bg-orange-100 hover:bg-orange-200 text-sm text-orange-800 font-medium py-2 px-3 rounded-md transition">
                    🏠 Về trang chủ
                </a>
            </div>
        </div>


        <!-- Main Content -->
        <div class="ml-[20%] w-[80%] p-8">
            <!-- Header -->
            <div class="mb-6 border-b pb-4 flex justify-between items-center">
                <h1 class="text-2xl font-bold text-orange-600">📦 Quản lý sản phẩm</h1>
                <a href="toys?action=create" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded">+ Thêm sản phẩm</a>
            </div>

            <!-- Form tìm kiếm và lọc -->
            <form method="get" action="toys" class="flex gap-4 items-center mb-4">
                <input type="text" name="keyword" placeholder="Tìm theo tên hoặc ID" value="${param.keyword}"
                       class="border px-3 py-2 rounded w-1/3">
                <select name="category" class="border px-3 py-2 rounded">
                    <option value="">-- Tất cả danh mục --</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}" ${cat.categoryId == selectedCategory ? 'selected' : ''}>
                            ${cat.name}
                        </option>
                    </c:forEach>
                </select>
                <button type="submit" class="bg-orange-500 text-white px-4 py-2 rounded hover:bg-orange-600">
                    🔍 Tìm kiếm
                </button>
            </form>

            <!-- Bảng sản phẩm -->
            <div class="overflow-x-auto">
                <table class="w-full table-auto border border-collapse bg-white shadow text-sm text-center">
                    <thead class="bg-gray-100 text-gray-700 font-semibold">
                        <tr>
                            <th class="border px-4 py-2">ID</th>
                            <th class="border px-4 py-2">Tên</th>
                            <th class="border px-4 py-2">Giá</th>
                            <th class="border px-4 py-2">Danh mục</th>
                            <th class="border px-4 py-2">Kho</th>
                            <th class="border px-4 py-2">Nhà cung cấp</th>
                            <th class="border px-4 py-2">Mô tả</th>
                            <th class="border px-4 py-2">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="toy" items="${toys}">
                            <tr class="hover:bg-gray-50">
                                <td class="border px-2 py-1">${toy.toyId}</td>
                                <td class="border px-2 py-1">${toy.name}</td>
                                <td class="border px-2 py-1">${toy.price}</td>
                                <td class="border px-2 py-1">
                                    <c:forEach var="cat" items="${categories}">
                                        <c:if test="${cat.categoryId == toy.categoryId}">
                                            ${cat.name}
                                        </c:if>
                                    </c:forEach>
                                </td>
                                <td class="border px-2 py-1">${toy.stockQuantity}</td>
                                <td class="border px-2 py-1">${supplierMap[toy.supplierId]}</td>
                                <td class="border px-2 py-1">${toy.description}</td>
                                <td class="border px-2 py-1 space-x-2">
                                    <a href="toys?action=edit&id=${toy.toyId}" class="text-blue-600 hover:underline">Sửa</a>
                                    |
                                    <a href="toys?action=delete&id=${toy.toyId}" class="text-red-600 hover:underline"
                                       onclick="return confirm('Bạn có chắc muốn xoá sản phẩm này?')">Xoá</a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty toys}">
                            <tr>
                                <td colspan="8" class="text-center text-gray-500 py-4">Không tìm thấy sản phẩm nào.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>
