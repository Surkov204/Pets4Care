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
                background: linear-gradient(120deg, #f0e68c 50%, #daa520 100%);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                overflow-x: hidden;
            }

            /* Floating paw prints animation */
            .floating-paws {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                pointer-events: none;
                overflow: hidden;
            }

            .paw {
                position: absolute;
                font-size: 2rem;
                opacity: 0.1;
                animation: float 10s infinite linear;
            }

            .paw:nth-child(1) {
                top: 10%;
                left: 10%;
                animation-delay: 0s;
            }
            .paw:nth-child(2) {
                top: 20%;
                left: 80%;
                animation-delay: 2s;
            }
            .paw:nth-child(3) {
                top: 70%;
                left: 20%;
                animation-delay: 4s;
            }
            .paw:nth-child(4) {
                top: 50%;
                left: 90%;
                animation-delay: 6s;
            }
            .paw:nth-child(5) {
                top: 80%;
                left: 50%;
                animation-delay: 8s;
            }

            @keyframes float {
                0% {
                    transform: translateY(100vh) rotate(0deg);
                }
                100% {
                    transform: translateY(-100px) rotate(360deg);
                }
            }

            .register-box {
                background: #fff3f7;
                padding: 2rem 3rem;
                border-radius: 20px;
                box-shadow: 0 8px 20px rgba(255, 180, 190, 0.4);
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
                font-size: 2rem;
                color: #ff7090;
                text-align: center;
                margin-bottom: 1.5rem;
                font-weight: bold;
                animation: bounceIn 1s ease-out;
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
                background: linear-gradient(90deg, #ffb3d9 45%, #c7e9ff 100%);
                color: #ff4d94;
                font-weight: bold;
                border-radius: 20px;
                border: 2px solid #ffb3d9;
                box-shadow: 0 4px 12px rgba(255, 179, 217, 0.4);
                padding: 12px 24px;
                width: 100%;
                font-size: 1rem;
                transition: all 0.4s ease;
                cursor: pointer;
                position: relative;
                overflow: hidden;
                animation: pulse 2s infinite;
            }

            @keyframes pulse {
                0%, 100% {
                    transform: scale(1);
                }
                50% {
                    transform: scale(1.02);
                }
            }

            .cute-btn::before {
                content: '🐾';
                position: absolute;
                top: 50%;
                left: 10px;
                transform: translateY(-50%);
                font-size: 1.2rem;
                opacity: 0;
                transition: opacity 0.3s ease;
            }

            .cute-btn:hover {
                background: linear-gradient(90deg, #ff99cc 40%, #a8e6ff 95%);
                color: #e60073;
                box-shadow: 0 6px 20px rgba(255, 153, 204, 0.6);
                transform: scale(1.08) rotate(-1deg);
                border-color: #ff99cc;
            }

            .cute-btn:hover::before {
                opacity: 1;
            }

            .cute-btn:active {
                transform: scale(0.98) rotate(0deg);
                box-shadow: 0 2px 8px rgba(255, 153, 204, 0.4);
            }

            input {
                font-family: inherit;
                border-radius: 12px;
                border: 1px solid #ffd6e2;
                padding: 10px;
                width: 100%;
                background: #fff8fb;
                margin-bottom: 1rem;
                transition: all 0.3s ease;
                position: relative;
            }

            input:focus {
                border: 1.5px solid #ff94b8;
                background: #fff7fc;
                outline: none;
                box-shadow: 0 0 10px rgba(255, 148, 184, 0.3);
                transform: translateY(-2px);
            }

            label {
                display: block;
                margin-bottom: 0.5rem;
                color: #ff7090;
                font-weight: bold;
                transition: color 0.3s ease;
            }

            input:focus + label {
                color: #ff94b8;
            }

            .error {
                color: red;
                font-size: 0.9rem;
                animation: shake 0.5s ease-in-out;
            }

            @keyframes shake {
                0%, 100% {
                    transform: translateX(0);
                }
                25% {
                    transform: translateX(-5px);
                }
                75% {
                    transform: translateX(5px);
                }
            }

            .error-message {
                color: red;
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
                opacity: 0.5;
                transition: opacity 0.3s ease;
            }

            .success-message {
                animation: successPulse 1s ease-in-out infinite alternate;
            }

            @keyframes successPulse {
                from {
                    transform: scale(1);
                    box-shadow: 0 0 0 0 rgba(40, 167, 69, 0.7);
                }
                to {
                    transform: scale(1.05);
                    box-shadow: 0 0 0 10px rgba(40, 167, 69, 0);
                }
            }

            .confetti {
                position: absolute;
                width: 10px;
                height: 10px;
                background: #ff7090;
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
                    font-size: 1.5rem;
                }
            }

            @media (max-width: 480px) {
                .register-box {
                    padding: 1rem 1.5rem;
                    margin: 0.5rem;
                }
                .register-title {
                    font-size: 1.25rem;
                }
            }
        </style>
    </head>


    <body>

        <div class="floating-paws">
            <div class="paw">🐾</div>
            <div class="paw">🐾</div>
            <div class="paw">🐾</div>
            <div class="paw">🐾</div>
            <div class="paw">🐾</div>
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
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
let map, marker, lat = null, lng = null;

function openMapPopup() {
  const popup = document.getElementById("map-popup");
  popup.classList.remove("hidden");

  setTimeout(() => {
    if (!map) {
      map = L.map("map");
      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: "&copy; OpenStreetMap contributors"
      }).addTo(map);

      // Khi click chọn vị trí
      map.on("click", async function (e) {
        lat = e.latlng.lat;
        lng = e.latlng.lng;

        if (marker) map.removeLayer(marker);
        marker = L.marker([lat, lng]).addTo(map);

        try {
          const res = await fetch(
            `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}`,
            { headers: { "User-Agent": "PetcityApp/1.0 (contact@localhost)" } }
          );
          const data = await res.json();

          if (data && data.display_name) {
            document.getElementById("address").value = data.display_name;
            document.getElementById("map-status").classList.remove("hidden");
          } else if (data && data.address) {
            const addr = `${data.address.road || ""}, ${data.address.suburb || ""}, ${data.address.city || data.address.town || ""}`;
            document.getElementById("address").value = addr.trim() || "Không rõ địa chỉ";
            document.getElementById("map-status").classList.remove("hidden");
          } else {
            document.getElementById("address").value = "Không xác định được địa chỉ.";
          }
        } catch (err) {
          console.error("Reverse geocode error:", err);
        }
      });
    }

    // Xoá marker cũ nếu có
    if (marker) {
      map.removeLayer(marker);
      marker = null;
    }

    // Focus map theo ô address (nếu có)
    const addr = document.getElementById("address").value;
    if (addr && addr.trim().length > 5) {
      fetch("https://nominatim.openstreetmap.org/search?format=json&q=" + encodeURIComponent(addr))
        .then(r => r.json())
        .then(results => {
          if (results && results.length > 0) {
            const { lat: a, lon: o } = results[0];
            lat = parseFloat(a);
            lng = parseFloat(o);
            map.setView([lat, lng], 15);
            marker = L.marker([lat, lng]).addTo(map);
          } else {
            map.setView([21.0285, 105.8542], 13); // Hà Nội mặc định
          }
        });
    } else {
      map.setView([21.0285, 105.8542], 13);
    }

    setTimeout(() => map.invalidateSize(), 300);
  }, 300);
}

function closeMapPopup() {
  document.getElementById("map-popup").classList.add("hidden");
}

async function confirmLocation() {
  if (!lat || !lng) {
    alert("📍 Vui lòng click chọn vị trí trên bản đồ trước khi xác nhận.");
    return;
  }

  document.getElementById("latitude").value = lat;
  document.getElementById("longitude").value = lng;

  try {
    const res = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}`,
      { headers: { "User-Agent": "PetcityApp/1.0 (contact@localhost)" } }
    );
    const data = await res.json();

    let addr = "";
    if (data && data.display_name) {
      addr = data.display_name;
    } else if (data && data.address) {
      const a = data.address;
      addr = `${a.road || ""}, ${a.suburb || a.village || ""}, ${a.city || a.town || a.county || ""}, ${a.state || ""}`;
    } else {
      // Nếu API không có gì, hiển thị toạ độ
      addr = `Vị trí: ${lat.toFixed(5)}, ${lng.toFixed(5)}`;
    }

    document.getElementById("address").value = addr.trim();
    document.getElementById("map-status").classList.remove("hidden");
  } catch (err) {
    console.error("Reverse geocode error:", err);
    document.getElementById("address").value = `Vị trí: ${lat.toFixed(5)}, ${lng.toFixed(5)}`;
    document.getElementById("map-status").classList.remove("hidden");
  }

  closeMapPopup();
}

</script>

    </body>
</html>
