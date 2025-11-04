<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🐾 Đăng ký - Petcity</title>
        <link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
        <script>
            function validateForm() {
                var phone = document.forms["registerForm"]["phone"].value;
                var email = document.forms["registerForm"]["email"].value;
                var name = document.forms["registerForm"]["name"].value;
                var password = document.forms["registerForm"]["password"].value;
                var address = document.forms["registerForm"]["address"].value;

                var phoneRegex = /^0(3|5|7|8|9)\d{8}$/;
                var emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
                var nameRegex = /^[A-Za-zÀ-ỹ\s]+$/;

                // Validate name
                if (name == "" || !nameRegex.test(name)) {
                    alert("Họ và tên không hợp lệ! Chỉ chứa chữ cái và khoảng trắng.");
                    return false;
                }

                // Validate phone
                if (!phoneRegex.test(phone)) {
                    alert("Số điện thoại không hợp lệ! Số điện thoại phải bắt đầu bằng 0 và có độ dài 10 chữ số.");
                    return false;
                }

                // Validate email
                if (!emailRegex.test(email)) {
                    alert("Email không hợp lệ!");
                    return false;
                }

                // Validate password
                if (password == "") {
                    alert("Mật khẩu không được để trống!");
                    return false;
                }

                // Validate address
                if (address == "") {
                    alert("Địa chỉ không được để trống!");
                    return false;
                }

                return true;
            }

            function checkNameInput() {
                var name = document.forms["registerForm"]["name"].value;
                var nameRegex = /^[A-Za-zÀ-ỹ\s]+$/;

                if (nameRegex.test(name)) {
                    document.getElementById("nameError").innerText = "";
                } else {
                    document.getElementById("nameError").innerText = "Họ và tên không hợp lệ! Chỉ chứa chữ cái và khoảng trắng.";
                }
            }

            async function suggestAddress(query) {
                const suggestDiv = document.getElementById("suggestion");
                const errDiv = document.getElementById("addressError");
                suggestDiv.textContent = "";
                errDiv.classList.add("hidden");

                if (query.trim().length < 5)
                    return; // chỉ gợi ý khi nhập >5 ký tự

                try {
                    const res = await fetch(
                            `https://nominatim.openstreetmap.org/search?format=json&q=\${encodeURIComponent(query)}`
                            );

                    const results = await res.json();
                    if (results && results.length > 0) {
                        suggestDiv.textContent = results[0].display_name; // gợi ý mờ
                    } else {
                        errDiv.textContent = "⚠️ Không tìm thấy địa chỉ.";
                        errDiv.classList.remove("hidden");
                    }
                } catch (e) {
                    errDiv.textContent = "⚠️ Lỗi khi tìm địa chỉ.";
                    errDiv.classList.remove("hidden");
                }
            }


        </script>


        <style>
            body {
                font-family: 'Baloo 2', cursive;
                background: linear-gradient(135deg, #fce4ec 0%, #f8bbd9 25%, #f3e5f5 50%, #e1bee7 75%, #fce4ec 100%);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                overflow-x: hidden;
            }

            /* Floating cute elements: paws, hearts, stars, bubbles */
            .floating-elements {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                pointer-events: none;
                overflow: hidden;
            }

            .element {
                position: absolute;
                font-size: 1.5rem;
                opacity: 0.15;
                animation: gentleFloat 12s infinite linear;
            }

            .element:nth-child(1) {
                top: 10%;
                left: 10%;
                animation-delay: 0s;
            }
            .element:nth-child(2) {
                top: 20%;
                left: 80%;
                animation-delay: 1s;
            }
            .element:nth-child(3) {
                top: 70%;
                left: 20%;
                animation-delay: 2s;
            }
            .element:nth-child(4) {
                top: 50%;
                left: 90%;
                animation-delay: 3s;
            }
            .element:nth-child(5) {
                top: 80%;
                left: 50%;
                animation-delay: 4s;
            }
            .element:nth-child(6) {
                top: 30%;
                left: 30%;
                animation-delay: 5s;
            }
            .element:nth-child(7) {
                top: 60%;
                left: 70%;
                animation-delay: 6s;
            }
            .element:nth-child(8) {
                top: 15%;
                left: 60%;
                animation-delay: 7s;
            }
            .element:nth-child(9) {
                top: 40%;
                left: 5%;
                animation-delay: 8s;
            }
            .element:nth-child(10) {
                top: 90%;
                left: 85%;
                animation-delay: 9s;
            }
            .element:nth-child(11) {
                top: 5%;
                left: 40%;
                animation-delay: 10s;
            }
            .element:nth-child(12) {
                top: 85%;
                left: 15%;
                animation-delay: 11s;
            }

            @keyframes gentleFloat {
                0% {
                    transform: translateY(100vh) rotate(0deg);
                }
                100% {
                    transform: translateY(-100px) rotate(360deg);
                }
            }

            .register-box {
                background: #fefefe;
                padding: 2rem 3rem;
                border-radius: 25px;
                border: 3px dotted #ffb3ba;
                box-shadow: 0 10px 25px rgba(255, 179, 186, 0.3);
                width: 100%;
                max-width: 480px;
                position: relative;
                z-index: 1;
                animation: slideIn 0.8s ease-out;
            }

            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateY(-50px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .register-title {
                font-size: 2.2rem;
                color: #ff8a80;
                text-align: center;
                margin-bottom: 1.5rem;
                font-weight: bold;
                animation: bounceIn 1s ease-out;
                text-shadow: 0 2px 4px rgba(255, 138, 128, 0.3);
            }

            @keyframes bounceIn {
                0% {
                    transform: scale(0.3);
                    opacity: 0;
                }
                50% {
                    transform: scale(1.05);
                }
                70% {
                    transform: scale(0.9);
                }
                100% {
                    transform: scale(1);
                    opacity: 1;
                }
            }

            .cute-btn {
                background: linear-gradient(90deg, #fce4ec 0%, #f8bbd9 50%, #f3e5f5 100%);
                color: #e91e63;
                font-weight: bold;
                border-radius: 25px;
                border: 2px solid #fce4ec;
                box-shadow: 0 5px 15px rgba(252, 228, 236, 0.4);
                padding: 12px 24px;
                width: 100%;
                font-size: 1rem;
                transition: all 0.4s ease;
                cursor: pointer;
                position: relative;
                overflow: hidden;
                animation: gentlePulse 2.5s infinite;
            }

            @keyframes gentlePulse {
                0%, 100% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.03);
                }
            }

            .cute-btn::before {
                content: '💖';
                position: absolute;
                top: 50%;
                left: 10px;
                transform: translateY(-50%);
                font-size: 1.2rem;
                opacity: 0;
                transition: opacity 0.3s ease;
            }

            .cute-btn:hover {
                background: linear-gradient(90deg, #ffccdd 0%, #ba68c8 50%, #e1bee7 100%);
                color: #c2185b;
                box-shadow: 0 8px 25px rgba(255, 204, 221, 0.6);
                transform: scale(1.05) rotate(-0.5deg);
                border-color: #ffccdd;
            }

            .cute-btn:hover::before {
                opacity: 1;
            }

            .cute-btn:active {
                transform: scale(0.98) rotate(0deg);
                box-shadow: 0 3px 10px rgba(255, 204, 221, 0.4);
            }

            .input-container {
                position: relative;
            }

            input {
                font-family: inherit;
                border-radius: 15px;
                border: 2px solid #fce4ec;
                padding: 12px 40px 12px 12px;
                width: 100%;
                background: #fffef9;
                margin-bottom: 1rem;
                transition: all 0.3s ease;
            }

            input:focus {
                border: 2px solid #ba68c8;
                background: #fefefe;
                outline: none;
                box-shadow: 0 0 15px rgba(186, 104, 200, 0.4);
                transform: translateY(-3px);
            }

            label {
                display: block;
                margin-bottom: 0.5rem;
                color: #ff8a80;
                font-weight: bold;
                transition: color 0.3s ease;
            }

            input:focus + label, input:focus ~ label {
                color: #ff6b6b;
            }

            .input-icon {
                position: absolute;
                right: 10px;
                top: 50%;
                transform: translateY(-50%);
                font-size: 1.2rem;
                color: #ffb3ba;
                pointer-events: none;
            }

            .error {
                color: #ff6b6b;
                font-size: 0.9rem;
                animation: gentleShake 0.5s ease-in-out;
            }

            @keyframes gentleShake {
                0%, 100% {
                    transform: translateX(0);
                }
                25% {
                    transform: translateX(-3px);
                }
                75% {
                    transform: translateX(3px);
                }
            }

            .error-message {
                color: #ff6b6b;
                font-size: 0.9rem;
                margin-top: -0.5rem;
                margin-bottom: 1rem;
                animation: fadeIn 0.5s ease-in;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(-10px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            #suggestion {
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                opacity: 0.6;
                transition: opacity 0.3s ease;
            }

            .success-message {
                animation: successPulse 1s ease-in-out infinite alternate;
            }

            @keyframes successPulse {
                from {
                    transform: scale(1);
                    box-shadow: 0 0 0 0 rgba(76, 175, 80, 0.7);
                }
                to {
                    transform: scale(1.05);
                    box-shadow: 0 0 0 10px rgba(76, 175, 80, 0);
                }
            }

            .confetti {
                position: absolute;
                width: 10px;
                height: 10px;
                background: #ff8a80;
                animation: confettiFall 3s linear forwards;
            }

            @keyframes confettiFall {
                0% {
                    transform: translateY(-100vh) rotate(0deg);
                    opacity: 1;
                }
                100% {
                    transform: translateY(100vh) rotate(720deg);
                    opacity: 0;
                }
            }

            @media (max-width: 768px) {
                .register-box {
                    padding: 1.5rem 2rem;
                    margin: 1rem;
                }
                .register-title {
                    font-size: 1.8rem;
                }
            }

            @media (max-width: 480px) {
                .register-box {
                    padding: 1rem 1.5rem;
                    margin: 0.5rem;
                }
                .register-title {
                    font-size: 1.5rem;
                }
            }
        </style>
    </head>


    <body>

        <div class="floating-elements">
            <div class="element">🐾</div>
            <div class="element">💖</div>
            <div class="element">⭐</div>
            <div class="element">🫧</div>
            <div class="element">🐶</div>
            <div class="element">💕</div>
            <div class="element">🌟</div>
            <div class="element">🦄</div>
            <div class="element">🐱</div>
            <div class="element">🌸</div>
            <div class="element">✨</div>
            <div class="element">🦋</div>
        </div>
        <div class="register-box">
            <h2 class="register-title">🐶 Đăng Ký Thành Viên</h2>
            <form name="registerForm" onsubmit="return validateForm()" action="register" method="post">
                <label>Họ và tên:</label>
                <input type="text" name="name" oninput="checkNameInput()" value="${nameValue}" required />
                <span id="nameError" class="error"></span>

                <label>Số điện thoại:</label>
                <input type="text" name="phone" value="${phoneValue}" required />
                <c:if test="${not empty phoneError}">
                    <p class="error-message">${phoneError}</p>
                </c:if>

                <label>Email:</label>
                <input type="email" name="email" value="${emailValue}" required />
                <c:if test="${not empty emailError}">
                    <p class="error-message">${emailError}</p>
                </c:if>

                <label>Mật khẩu:</label>
                <input type="password" name="password" required />

                <label>Địa chỉ:</label>
                <div class="relative">
                    <input type="text" id="address" name="address" value="${addressValue}" 
                           oninput="suggestAddress(this.value)" 
                           class="w-full" required />
                    <div id="suggestion" 
                         class="absolute left-3 top-3 text-gray-400 text-sm pointer-events-none select-none"></div>
                </div>
                <p id="addressError" class="text-red-500 text-sm mt-1 hidden"></p>

                <div class="flex items-center gap-2 mb-4">
                    <button type="button" onclick="openMapPopup()" 
                            class="bg-pink-400 hover:bg-pink-500 text-white px-3 py-1 rounded text-sm">
                        🗺️ Chọn vị trí
                    </button>
                    <span id="map-status" class="text-sm text-green-600 hidden">📍 Vị trí đã chọn</span>
                </div>

                <input type="hidden" name="latitude" id="latitude" />
                <input type="hidden" name="longitude" id="longitude" />



                <button type="submit" class="cute-btn">Đăng ký</button>
            </form>

            <c:if test="${not empty error}">
                <p class="text-center mt-3 text-red-500 font-semibold">${error}</p>
            </c:if>

            <c:if test="${not empty message_register}">
                <div class="alert alert-${messageType}" style="padding: 12px; border-radius: 8px; margin-bottom: 1rem; font-weight: 500; background-color: ${messageType == 'success' ? '#d4edda' : '#f8d7da'}; color: ${messageType == 'success' ? '#155724' : '#721c24'}; border: 1px solid ${messageType == 'success' ? '#c3e6cb' : '#f5c6cb'};">
                    ${message_register}
                </div>
            </c:if>

            <c:if test="${param.error == 'max_attempt'}">
                <div class="alert alert-error" style="padding: 12px; border-radius: 8px; margin-bottom: 1rem; font-weight: 500; background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;">
                    Bạn đã nhập sai OTP quá 3 lần. Vui lòng đăng ký lại.
                </div>
            </c:if>

            <p class="text-center mt-4">Đã có tài khoản? <a href="login.jsp" class="text-pink-500 font-bold hover:underline">Đăng nhập</a></p>
        </div>

        <!-- Popup chọn vị trí -->
        <div id="map-popup" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden z-50">
            <div class="bg-white rounded shadow-lg w-11/12 md:w-3/4 h-96 relative flex flex-col">
                <button onclick="closeMapPopup()" class="absolute top-2 right-2 text-red-500 text-lg">✖</button>
                <div id="map" class="w-full flex-1 rounded"></div>
                <div class="p-3 border-t text-right">
                    <button onclick="confirmLocation()" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded">
                        ✅ Xác nhận vị trí
                    </button>
                </div>
            </div>
        </div>
        <!-- Leaflet CSS & JS -->
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

        <script>
                                let map, marker, selectedLat, selectedLng;

                                function openMapPopup() {
                                    document.getElementById("map-popup").classList.remove("hidden");

                                    setTimeout(() => {
                                        if (!map) {
                                            map = L.map("map");
                                            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                                                attribution: "&copy; OpenStreetMap contributors"
                                            }).addTo(map);

                                            // Ưu tiên định vị vị trí hiện tại (nếu được)
                                            if (navigator.geolocation) {
                                                navigator.geolocation.getCurrentPosition(
                                                        pos => map.setView([pos.coords.latitude, pos.coords.longitude], 15),
                                                        () => map.setView([21.0285, 105.8542], 13)
                                                );
                                            } else {
                                                map.setView([21.0285, 105.8542], 13);
                                            }

                                            // Khi click chọn vị trí
                                            map.on("click", function (e) {
                                                selectedLat = e.latlng.lat;
                                                selectedLng = e.latlng.lng;

                                                if (marker)
                                                    map.removeLayer(marker);
                                                marker = L.marker([selectedLat, selectedLng]).addTo(map);

                                                // Gọi API reverse geocoding để fill địa chỉ
                                                fetch("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=" + selectedLat + "&lon=" + selectedLng)
                                                        .then(r => r.json())
                                                        .then(data => {
                                                            if (data && data.display_name) {
                                                                document.getElementById("address").value = data.display_name;
                                                                document.getElementById("map-status").classList.remove("hidden");
                                                            } else {
                                                                alert("Không tìm được địa chỉ tại vị trí đã chọn.");
                                                            }
                                                        })
                                                        .catch(() => alert("Không truy vấn được địa chỉ. Vui lòng thử lại."));
                                            });
                                        }

                                        // Nếu đã có địa chỉ trước đó → geocode lại để hiển thị marker
                                        const addr = document.getElementById("address").value;
                                        if (addr && addr.trim().length > 5) {
                                            geocodeAddress(addr, true);
                                        }

                                        setTimeout(() => map.invalidateSize(), 300);
                                    }, 300);
                                }

                                function confirmLocation() {
                                    if (selectedLat && selectedLng) {
                                        document.getElementById("latitude").value = selectedLat;
                                        document.getElementById("longitude").value = selectedLng;
                                        document.getElementById("map-status").classList.remove("hidden");
                                        closeMapPopup();
                                    } else {
                                        alert("📍 Vui lòng chọn vị trí trên bản đồ trước khi xác nhận.");
                                    }
                                }

                                function closeMapPopup() {
                                    document.getElementById("map-popup").classList.add("hidden");
                                }

        // Hàm geocode (tìm toạ độ từ địa chỉ đã nhập)
                                function geocodeAddress(address, centerOnly = false) {
                                    fetch("https://nominatim.openstreetmap.org/search?format=json&q=" + encodeURIComponent(address))
                                            .then(r => r.json())
                                            .then(results => {
                                                if (results && results.length > 0) {
                                                    const {lat, lon, display_name} = results[0];
                                                    selectedLat = parseFloat(lat);
                                                    selectedLng = parseFloat(lon);
                                                    if (map) {
                                                        map.setView([selectedLat, selectedLng], 16);
                                                        if (marker)
                                                            map.removeLayer(marker);
                                                        marker = L.marker([selectedLat, selectedLng]).addTo(map);
                                                    }
                                                    if (!centerOnly) {
                                                        document.getElementById("address").value = display_name;
                                                    }
                                                } else {
                                                    alert("Không tìm thấy vị trí cho địa chỉ đã nhập.");
                                                }
                                            })
                                            .catch(() => alert("Không truy vấn được vị trí."));
                                }
        </script>


    </body>
</html>
