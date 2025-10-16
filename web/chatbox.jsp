<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<div id="chat-icon" onclick="toggleChatBox()">💬</div>
<!-- đã sửa -->
<div id="chat-box">
    <div id="chat-header">
        🐾 Pet Toy Chat 🐾
        <span id="chat-minimize" onclick="minimizeChat()">−</span>
    </div>
    
    <!-- Tổng giá cố định -->
    <div id="cart-summary">
        <span id="cart-total">💰 Tổng: 0₫</span>
        <span id="cart-count">📦 0 sản phẩm</span>
        <details class="cart-details" id="cart-details-expand" style="margin-top:4px;">
            <summary>📦 Chi tiết giỏ hàng</summary>
            <div id="cart-details-list"></div>
        </details>
    </div>
    
    <div id="chat-messages"></div>

    <div class="suggestion-box">
        <button onclick="quickAsk('Đồ chơi rẻ nhất')">🪙 Rẻ nhất</button>
        <button onclick="quickAsk('Đồ chơi an toàn cho chó')">🤍 An toàn</button>
        <button onclick="clearCartFromChat()" class="chat-action-btn danger">🗑️ Xoá giỏ hàng</button>
    </div>

    <div class="input-area">
        <input type="text" id="chat-input" placeholder="🔍 Hỏi gì đó..." onkeydown="handleKey(event)">
        <button onclick="sendMessage()">Gửi</button>
    </div>
</div>

<!-- Modal hiển thị chi tiết sản phẩm -->
<div id="productDetailModal" style="display:none; position:fixed; top:10%; left:50%; transform:translateX(-50%); background:#fff; border:1px solid #ccc; padding:20px; z-index:2000; min-width:320px; max-width:90vw; box-shadow:0 4px 16px rgba(0,0,0,0.2); border-radius:18px;">
    <span id="closeProductModal" style="cursor:pointer; float:right; font-size:22px;">&times;</span>
    <div id="productDetailContent"></div>
</div>

<div id="chat-toast"></div>

<style>
/* Import fonts */
@import url('https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;500;600;700&family=Nunito:wght@300;400;500;600;700;800&family=Baloo+2:wght@400;500;600;700;800&display=swap');

/* CSS Variables */
:root {
    --main-bg: #FFFDF8;
    --card-bg: #FFFFFF;
    --card-bg-alt: #F6FCF7;
    --primary: #6FD5DD;
    --secondary: #FFD6C0;
    --accent: #FFC94D;
    --accent-pink: #FF8C94;
    --text: #34495E;
    --text-light: #A9A9A9;
    --border-radius: 22px;
    --border-radius-small: 18px;
    --shadow-light: 0 2px 16px 0 rgba(140, 170, 205, 0.12);
    --shadow-hover: 0 4px 32px 0 rgba(140, 170, 205, 0.18);
    --shadow-button: 0 2px 8px 0 rgba(140, 170, 205, 0.12);
    --shadow-button-hover: 0 4px 18px 0 rgba(255, 181, 163, 0.18);
    --transition: all 0.2s ease;
}

#chat-icon {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    padding: 16px;
    font-size: 20px;
    border-radius: 50%;
    cursor: pointer;
    z-index: 999;
    box-shadow: var(--shadow-hover);
    transition: var(--transition);
    font-family: 'Baloo 2', cursive;
    animation: bounce 2s infinite;
}

#chat-icon:hover {
    transform: scale(1.1);
    box-shadow: 0 8px 25px rgba(111, 213, 221, 0.4);
}

@keyframes bounce {
    0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
    40% { transform: translateY(-10px); }
    60% { transform: translateY(-5px); }
}

#chat-box {
    position: fixed;
    bottom: 90px;
    right: 20px;
    width: 360px;
    max-height: 80vh; /* Giới hạn chiều cao tối đa */
    overflow-y: auto; /* Cho phép scroll toàn bộ chatbox */
    background: var(--card-bg);
    border: 2px solid rgba(111, 213, 221, 0.3);
    border-radius: var(--border-radius);
    display: none;
    flex-direction: column;
    z-index: 999;
    box-shadow: var(--shadow-hover);
    font-family: 'Quicksand', sans-serif;
}

/* Tổng giá cố định */
#cart-summary {
    background: linear-gradient(135deg, var(--card-bg-alt), rgba(111, 213, 221, 0.1));
    border-bottom: 2px solid rgba(111, 213, 221, 0.2);
    padding: 12px;
    font-size: 14px;
    font-weight: 600;
    color: var(--primary);
    text-align: center;
    display: none;
    position: relative;
}

/* Expand sản phẩm */
.cart-details {
    background: var(--card-bg);
    border: 1px solid rgba(111, 213, 221, 0.3);
    border-radius: var(--border-radius-small);
    margin: 8px 0;
    font-size: 12px;
    max-height: 240px;
    overflow: hidden;
    display: block;
    position: relative;
}

.cart-details[open] > #cart-details-list {
    max-height: 180px;
    overflow-y: auto;
    padding: 12px;
}

#cart-details-list {
    padding: 0;
}

.cart-details summary {
    cursor: pointer;
    color: var(--primary);
    font-size: 13px;
    font-weight: 600;
    padding: 10px;
    background: var(--card-bg);
    border-radius: 18px 18px 0 0;
    position: sticky;
    top: 0;
    z-index: 2;
    transition: var(--transition);
    background: #fff;
    border-radius: 18px 18px 0 0;
    padding: 10px;
    font-weight: 600;
    font-size: 13px;
    color: var(--primary);
    box-shadow: 0 2px 8px 0 rgba(140, 170, 205, 0.04);
}

.cart-details summary:hover {
    background: var(--card-bg-alt);
    color: var(--accent);
}

.cart-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    border-bottom: 1px solid rgba(111, 213, 221, 0.2);
    font-size: 12px;
}

.cart-item:last-child {
    border-bottom: none;
}

.cart-item > div:last-child {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 4px;
}

#chat-header {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    padding: 12px;
    font-weight: 700;
    text-align: center;
    position: relative;
    font-family: 'Baloo 2', cursive;
    font-size: 16px;
}

#chat-minimize {
    position: absolute;
    top: 8px;
    right: 15px;
    cursor: pointer;
    font-weight: bold;
    font-size: 20px;
    transition: var(--transition);
    padding: 2px 6px;
    border-radius: 50%;
}

#chat-minimize:hover {
    background: rgba(255, 255, 255, 0.2);
    transform: scale(1.1);
}

#chat-messages {
    padding: 12px;
    height: 280px;
    overflow-y: auto;
    font-size: 14px;
    line-height: 1.5;
    background: var(--main-bg);
}

.input-area {
    display: flex;
    border-top: 2px solid rgba(111, 213, 221, 0.2);
    background: var(--card-bg);
}

.input-area input {
    flex: 1;
    border: none;
    padding: 12px;
    font-size: 14px;
    background: transparent;
    color: var(--text);
    font-family: 'Quicksand', sans-serif;
    outline: none;
}

.input-area input::placeholder {
    color: var(--text-light);
}

.input-area button {
    background: linear-gradient(135deg, var(--primary), var(--accent));
    color: white;
    border: none;
    padding: 12px 18px;
    cursor: pointer;
    font-weight: 600;
    font-family: 'Quicksand', sans-serif;
    transition: var(--transition);
}

.input-area button:hover {
    background: linear-gradient(135deg, var(--accent), var(--secondary));
    transform: scale(1.05);
}

.user-msg {
    text-align: right;
    color: var(--text);
    margin-bottom: 10px;
    word-wrap: break-word;
    background: linear-gradient(135deg, var(--card-bg-alt), rgba(111, 213, 221, 0.1));
    padding: 8px 12px;
    border-radius: var(--border-radius-small);
    display: inline-block;
    max-width: 80%;
    margin-left: auto;
    box-shadow: var(--shadow-light);
}

.bot-msg {
    text-align: left;
    color: var(--text);
    margin-bottom: 10px;
    word-wrap: break-word;
    background: var(--card-bg);
    padding: 8px 12px;
    border-radius: var(--border-radius-small);
    display: inline-block;
    max-width: 80%;
    box-shadow: var(--shadow-light);
    border-left: 3px solid var(--primary);
}

.suggestion-box {
    display: flex;
    justify-content: space-around;
    padding: 8px 12px;
    border-top: 1px solid rgba(111, 213, 221, 0.2);
    background: var(--card-bg-alt);
    gap: 5px;
}

.suggestion-box button {
    font-size: 12px;
    padding: 6px 10px;
    border-radius: var(--border-radius-small);
    border: 1px solid rgba(111, 213, 221, 0.3);
    background: var(--card-bg);
    cursor: pointer;
    transition: var(--transition);
    font-family: 'Quicksand', sans-serif;
    font-weight: 500;
    color: var(--text);
}

.suggestion-box button:hover {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    transform: translateY(-2px);
    box-shadow: var(--shadow-button-hover);
}

.chat-add-cart-btn {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: var(--border-radius-small);
    font-size: 12px;
    cursor: pointer;
    margin-right: 5px;
    transition: var(--transition);
    font-family: 'Quicksand', sans-serif;
    font-weight: 600;
    box-shadow: var(--shadow-button);
}

.chat-add-cart-btn:hover {
    background: linear-gradient(135deg, var(--accent), var(--accent-pink));
    transform: scale(1.05);
    box-shadow: var(--shadow-button-hover);
}

.chat-view-btn {
    background: linear-gradient(135deg, var(--accent), var(--secondary));
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: var(--border-radius-small);
    font-size: 12px;
    cursor: pointer;
    transition: var(--transition);
    font-family: 'Quicksand', sans-serif;
    font-weight: 600;
    box-shadow: var(--shadow-button);
}

.chat-view-btn:hover {
    background: linear-gradient(135deg, var(--accent-pink), var(--primary));
    transform: scale(1.05);
    box-shadow: var(--shadow-button-hover);
}

.chat-buy-btn {
    background: linear-gradient(135deg, var(--accent-pink), var(--accent));
    color: white;
    border: none;
    padding: 6px 12px;
    border-radius: var(--border-radius-small);
    font-size: 12px;
    cursor: pointer;
    margin-left: 5px;
    transition: var(--transition);
    font-family: 'Quicksand', sans-serif;
    font-weight: 600;
    box-shadow: var(--shadow-button);
}

.chat-buy-btn:hover {
    background: linear-gradient(135deg, var(--accent), var(--primary));
    transform: scale(1.05);
    box-shadow: var(--shadow-button-hover);
}

/* Modal xác nhận */
#order-modal {
    display: none;
    position: fixed;
    z-index: 2000;
    left: 0; top: 0; width: 100vw; height: 100vh;
    background: rgba(0,0,0,0.3);
    align-items: center;
    justify-content: center;
}

#order-modal .modal-content {
    background: var(--card-bg);
    padding: 24px 20px;
    border-radius: var(--border-radius);
    min-width: 300px;
    max-width: 90vw;
    box-shadow: var(--shadow-hover);
    text-align: center;
    font-family: 'Quicksand', sans-serif;
}

#order-modal .modal-actions button {
    margin: 0 8px;
    padding: 8px 20px;
    border-radius: var(--border-radius-small);
    border: none;
    font-size: 15px;
    cursor: pointer;
    font-family: 'Quicksand', sans-serif;
    font-weight: 600;
    transition: var(--transition);
}

#order-modal .modal-actions .confirm {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    box-shadow: var(--shadow-button);
}

#order-modal .modal-actions .confirm:hover {
    transform: scale(1.05);
    box-shadow: var(--shadow-button-hover);
}

#order-modal .modal-actions .cancel {
    background: var(--card-bg-alt);
    color: var(--text);
    border: 1px solid rgba(111, 213, 221, 0.3);
}

#order-modal .modal-actions .cancel:hover {
    background: rgba(111, 213, 221, 0.1);
}

#chat-toast {
    display: none;
    position: fixed;
    bottom: 120px;
    right: 40px;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    padding: 12px 20px;
    border-radius: var(--border-radius-small);
    font-size: 14px;
    font-weight: 600;
    z-index: 3000;
    box-shadow: var(--shadow-hover);
    opacity: 0;
    transition: opacity 1s ease-in-out;
    font-family: 'Quicksand', sans-serif;
}

#chat-toast.show {
    display: block;
    opacity: 1;
}

/* CSS cho các nút bấm trong chatbot */
.chat-action-buttons {
    display: flex;
    gap: 8px;
    margin-top: 12px;
    flex-wrap: wrap;
}

.chat-action-btn {
    padding: 8px 16px;
    border: none;
    border-radius: var(--border-radius-small);
    font-size: 13px;
    cursor: pointer;
    transition: var(--transition);
    text-decoration: none;
    display: inline-block;
    font-family: 'Quicksand', sans-serif;
    font-weight: 600;
    box-shadow: var(--shadow-button);
}

.chat-action-btn.primary {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
}

.chat-action-btn.primary:hover {
    background: linear-gradient(135deg, var(--accent), var(--accent-pink));
    transform: scale(1.05);
    box-shadow: var(--shadow-button-hover);
}

.chat-action-btn.secondary {
    background: var(--card-bg-alt);
    color: var(--text);
    border: 1px solid rgba(111, 213, 221, 0.3);
}

.chat-action-btn.secondary:hover {
    background: rgba(111, 213, 221, 0.1);
    transform: translateY(-2px);
}

.chat-action-btn.danger {
    background: linear-gradient(135deg, var(--accent-pink), #e74c3c);
    color: white;
}

.chat-action-btn.danger:hover {
    background: linear-gradient(135deg, #e74c3c, #c0392b);
    transform: scale(1.05);
    box-shadow: var(--shadow-button-hover);
}

.chat-action-btn.warning {
    background: linear-gradient(135deg, var(--accent), var(--secondary));
    color: white;
}

.chat-action-btn.warning:hover {
    background: linear-gradient(135deg, var(--secondary), var(--accent-pink));
    transform: scale(1.05);
    box-shadow: var(--shadow-button-hover);
}

/* CSS cho nút thanh toán */
.payment-method-btn {
    padding: 12px 20px;
    margin: 8px;
    border: 2px solid rgba(111, 213, 221, 0.3);
    border-radius: var(--border-radius-small);
    background: var(--card-bg);
    color: var(--text);
    cursor: pointer;
    transition: var(--transition);
    font-size: 14px;
    font-weight: 600;
    font-family: 'Quicksand', sans-serif;
    box-shadow: var(--shadow-light);
}

.payment-method-btn:hover {
    border-color: var(--primary);
    background: var(--card-bg-alt);
    transform: translateY(-2px);
    box-shadow: var(--shadow-hover);
}

.payment-method-btn.selected {
    border-color: var(--primary);
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: white;
    box-shadow: var(--shadow-button-hover);
}

/* Responsive */
@media (max-width: 700px) {
    #chat-box {
        width: 320px;
        right: 10px;
        bottom: 80px;
    }
    
    .cart-details-popup {
        left: 0;
        right: 0;
        width: 100vw;
    }
    
    .chat-action-buttons {
        flex-direction: column;
    }
    
    .chat-action-btn {
        width: 100%;
        text-align: center;
    }
    
    #chat-toast {
        right: 20px;
        bottom: 100px;
    }
}

/* Scrollbar styling */
#chat-messages::-webkit-scrollbar {
    width: 6px;
}

#chat-messages::-webkit-scrollbar-track {
    background: var(--card-bg-alt);
    border-radius: 3px;
}

#chat-messages::-webkit-scrollbar-thumb {
    background: var(--primary);
    border-radius: 3px;
}

#chat-messages::-webkit-scrollbar-thumb:hover {
    background: var(--accent);
}
</style>

<script>
let hasLoadedGreeting = false;

function toggleChatBox() {
    const box = document.getElementById("chat-box");
    const isHidden = box.style.display === "none" || box.style.display === "";

    if (isHidden) {
        box.style.display = "flex";
        loadHistory();
        initializeCartSummary(); // Khởi tạo tổng giá thực tế

        if (!hasLoadedGreeting) {
            hasLoadedGreeting = true;
            fetch("chatcontroller", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "question=" // Gửi request trống để tạo session với lời chào
            }).then(() => loadHistory());
        }
    } else {
        box.style.display = "none";
    }
}

function minimizeChat() {
    document.getElementById("chat-box").style.display = "none";
}

function handleKey(e) {
    if (e.key === "Enter") sendMessage();
}

function quickAsk(text) {
    document.getElementById("chat-input").value = text;
    sendMessage();
}

function sendMessage(extraParam = '') {
    const input = document.getElementById("chat-input");
    const text = input.value.trim();
    if (!text) return;

    appendMessage("👤 " + text.replace(/\n/g, "<br/>"), true);
    input.value = "";

    const typing = document.createElement("div");
    typing.className = "bot-msg";
    typing.innerHTML = "🤖 Đang gõ...";
    document.getElementById("chat-messages").appendChild(typing);
    scrollToBottom();

    // Lưu từ khóa tìm kiếm hiện tại
    sessionStorage.setItem('currentSearchQuery', text.toLowerCase());

    // Gửi agenticOrderPrompt=1 nếu user bấm 'có' ở prompt đặt hàng
    let agentic = '';
    if (sessionStorage.getItem('agenticOrderPrompt')) {
        if (text.toLowerCase() === 'có') {
            agentic = '&agenticOrderPrompt=1';
            sessionStorage.removeItem('agenticOrderPrompt');
        }
    }
    
    // Thêm selectedItems nếu có - CHỈ gửi khi thực sự có
    let selectedItemsParam = '';
    const selectedItems = sessionStorage.getItem('selectedItems');
    if (selectedItems) {
        selectedItemsParam = '&selectedItems=' + encodeURIComponent(selectedItems);
        sessionStorage.removeItem('selectedItems'); // Xóa sau khi gửi
    }

    // Gộp tất cả param
    const requestBody = "question=" + encodeURIComponent(text) + agentic + selectedItemsParam + (extraParam || '');
    console.log('DEBUG: Full request body:', requestBody);

    fetch("<%= request.getContextPath() %>/chatcontroller", {
        method: "POST",
        headers: { 
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: requestBody
    })
    .then(res => res.text())
    .then(res => {
        typing.remove();
        appendMessage("🤖 " + res.replace(/\n/g, "<br/>"), false);
        // Nếu là kết thúc flow agentic, xóa các nút action cũ
        if (res.includes('Không sao! Bạn có thể tiếp tục mua sắm') || res.includes('Đã hủy đặt hàng')) {
            setTimeout(() => {
                document.querySelectorAll('.chat-action-buttons').forEach(btns => btns.remove());
                scrollToBottom();
            }, 100);
        }
    });
}

function appendMessage(msg, isUser) {
    const div = document.createElement("div");
    div.className = isUser ? "user-msg" : "bot-msg";
    div.innerHTML = msg;
    document.getElementById("chat-messages").appendChild(div);
    // Nếu là bot trả lời, thêm UI feedback
    if (!isUser) {
        const feedbackDiv = document.createElement('div');
        feedbackDiv.className = 'chat-feedback';
        feedbackDiv.innerHTML = `<button class="feedback-btn" data-feedback="like">👍 Hữu ích</button> <button class="feedback-btn" data-feedback="dislike">👎 Không hữu ích</button>`;
        div.appendChild(feedbackDiv);
    }
    scrollToBottom();
}

function scrollToBottom() {
    const chat = document.getElementById("chat-messages");
    chat.scrollTop = chat.scrollHeight;
}

function loadHistory() {
    fetch("<%= request.getContextPath() %>/chathistory")
        .then(res => res.text())
        .then(html => {
            document.getElementById("chat-messages").innerHTML = html;
            scrollToBottom();
        });
}

function showToast(message) {
    const toast = document.getElementById("chat-toast");
    toast.textContent = message;

    // Hiển thị toast và áp dụng transition
    toast.style.display = "block";
    toast.classList.add("show");

    // Sau 1.5 giây, ẩn đi
    setTimeout(() => {
        toast.classList.remove("show");
        setTimeout(() => { toast.style.display = "none"; }, 1000);  // ẩn toast sau khi mờ
    }, 1500);
}

function addToCartFromChat(productId, price) {
    fetch('<%= request.getContextPath() %>/cartservlet?action=add&id=' + productId)
        .then(res => {
            if (res.ok) {
                showToast('🛒 Đã thêm vào giỏ hàng!');
                updateCartSummary();
                refreshHeaderCart();
                // Chỉ hỏi agentic prompt nếu vừa tìm kiếm mới
                const lastSearchQuery = sessionStorage.getItem('lastSearchQuery');
                const currentQuery = sessionStorage.getItem('currentSearchQuery');
                if (!lastSearchQuery || lastSearchQuery !== currentQuery) {
                    setTimeout(function() {
                        const orderPromptHtml = `
                            <div style='margin: 10px 0;'>
                                <strong>🤖 Bạn vừa thêm sản phẩm vào giỏ. Bạn có muốn đặt hàng luôn không?</strong>
                                <div class='chat-action-buttons'>
                                    <button class='chat-action-btn primary' data-action='confirm'>✅ Có, đặt hàng</button>
                                    <button class='chat-action-btn secondary' data-action='cancel'>❌ Không, để sau</button>
                                </div>
                            </div>
                        `;
                        appendMessage(orderPromptHtml, false);
                        sessionStorage.setItem('agenticOrderPrompt', '1'); // Đảm bảo luôn set lại mỗi khi render prompt
                        sessionStorage.setItem('lastSearchQuery', currentQuery);
                    }, 500);
                }
            }
        });
}

// Cập nhật tổng giá hiển thị
function updateCartSummary() {
    fetch('<%= request.getContextPath() %>/cartservlet?action=total')
        .then(res => res.text())
        .then(amount => {
            document.getElementById('cart-total').innerText = '💰 Tổng: ' + formatCurrency(amount) + '₫';
        });
    fetch('<%= request.getContextPath() %>/cartservlet?action=count')
        .then(res => res.text())
        .then(count => {
            document.getElementById('cart-count').innerText = '📦 ' + count + ' sản phẩm';
            if (parseInt(count) > 0) {
                document.getElementById('cart-summary').style.display = 'block';
            } else {
                document.getElementById('cart-summary').style.display = 'none';
            }
        });
    // Cập nhật chi tiết giỏ hàng vào cart-details-list
    fetch('<%= request.getContextPath() %>/cartservlet?action=details')
        .then(res => res.text())
        .then(html => {
            document.getElementById('cart-details-list').innerHTML = html;
        });
}

function formatCurrency(amount) {
    amount = parseFloat(amount);
    if (isNaN(amount)) return '0';
    return amount.toLocaleString('vi-VN', { maximumFractionDigits: 0 });
}

// Khởi tạo tổng giá khi mở chat
function initializeCartSummary() {
    updateCartSummary();
}

function viewProductDetail(productId) {
    // Mở modal chi tiết sản phẩm
    document.getElementById('productDetailModal').style.display = 'block';

    // Gửi request tới server để lấy chi tiết sản phẩm (hoặc dùng dữ liệu đã có)
    fetch('<%= request.getContextPath() %>/toy/toy-detail.jsp?productId=' + productId)
        .then(response => response.text())
        .then(data => {
            document.getElementById('productDetailContent').innerHTML = data;
        });
}

document.addEventListener('click', function(e) {
    if (e.target.classList.contains('chat-view-btn')) {
        e.preventDefault();
        var productId = e.target.getAttribute('data-product-id');
        window.location.href = '<%= request.getContextPath() %>/toy/toy-detail.jsp?productId=' + productId;
        return;
    }
    if (e.target.id === 'closeProductModal') {
        document.getElementById('productDetailModal').style.display = 'none';
    }
});

// Xử lý các nút bấm trong chatbot
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('chat-action-btn')) {
        e.preventDefault();
        const action = e.target.getAttribute('data-action');
        const value = e.target.getAttribute('data-value');
        // Xác định có đang ở bước chọn sản phẩm không
        const isSelectItemsStep = !!document.querySelector('input[id^="select_item_"]');
        if ((action === 'confirm' || action === 'continue') && isSelectItemsStep) {
            const selectedItems = getSelectedSelectItems();
            sessionStorage.setItem('selectedItems', JSON.stringify(selectedItems));
            if (selectedItems.length === 0) {
                alert('❗ Vui lòng chọn ít nhất 1 sản phẩm để đặt hàng.');
                return;
            }
            // XÓA checkbox khỏi DOM để không bị nhận nhầm bước ở lần click tiếp theo
            document.querySelectorAll('input[id^="select_item_"]').forEach(cb => cb.remove());
        } else {
            // Ở các bước khác, luôn xóa selectedItems để không gửi nhầm
            sessionStorage.removeItem('selectedItems');
        }
        // Disable nút xác nhận để tránh double click
        e.target.disabled = true;
        setTimeout(() => { e.target.disabled = false; }, 1500);
        // Gửi message tương ứng với action
        let message = '';
        let extraParam = '';
        switch(action) {
            case 'confirm':
                message = 'có';
                break;
            case 'cancel':
                message = 'không';
                break;
            case 'payment':
                message = value;
                break;
            case 'continue':
                message = 'có';
                break;
            case 'select_all':
                message = 'select_all';
                break;
            default:
                message = value || action;
        }
        document.getElementById('chat-input').value = message;
        sendMessage(extraParam);
    }
    
    if (e.target.classList.contains('payment-method-btn')) {
        e.preventDefault();
        const method = e.target.getAttribute('data-method');
        
        // Gửi phương thức thanh toán
        document.getElementById('chat-input').value = method;
        sendMessage();
    }
});

// Hàm lấy danh sách sản phẩm được chọn trong bước chọn sản phẩm
function getSelectedSelectItems() {
    const checkboxes = document.querySelectorAll('input[id^="select_item_"]:checked');
    const selectedItems = [];
    checkboxes.forEach(checkbox => {
        const itemId = checkbox.id.replace('select_item_', '');
        selectedItems.push(parseInt(itemId));
    });
    return selectedItems;
}

// Hàm xử lý khi người dùng nhập địa chỉ mới
function submitNewAddress() {
    const addressInput = document.getElementById('new_address');
    if (addressInput && addressInput.value.trim()) {
        // Gửi địa chỉ mới
        document.getElementById('chat-input').value = addressInput.value.trim();
        sendMessage();
    } else {
        alert('Vui lòng nhập địa chỉ giao hàng!');
    }
}

// Bắt sự kiện Enter trên input địa chỉ mới
document.addEventListener('keydown', function(e) {
    if (e.target && e.target.id === 'new_address' && e.key === 'Enter') {
        submitNewAddress();
    }
});

function refreshHeaderCart() {
    fetch('<%= request.getContextPath() %>/cartservlet?action=total')
        .then(res => res.text())
        .then(amount => {
            document.querySelectorAll('.cart-amount').forEach(el => el.innerText = parseFloat(amount).toFixed(2));
        });
    fetch('<%= request.getContextPath() %>/cartservlet?action=count')
        .then(res => res.text())
        .then(count => {
            document.querySelectorAll('.cart-count').forEach(el => el.innerText = count);
        });
}

// Xóa sản phẩm khỏi giỏ hàng từ chatbox
function removeFromCart(productId) {
    if (confirm('🗑️ Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?')) {
        fetch('<%= request.getContextPath() %>/cartservlet?action=remove_chat&id=' + productId, { method: 'POST' })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                showToast('✅ ' + data.message);
                updateCartSummary();
            } else {
                showToast('❌ ' + data.message);
            }
        });
    }
}

// Thay đổi số lượng sản phẩm từ chatbox
function updateCartQuantity(productId, change, btn) {
    // Lấy số lượng hiện tại từ DOM
    const cartItem = btn.closest('.cart-item');
    const quantitySpan = cartItem.querySelector('.cart-qty');
    const currentQuantity = parseInt(quantitySpan.textContent);
    const newQuantity = currentQuantity + change;
    if (newQuantity <= 0) {
        removeFromCart(productId);
        return;
    }
    fetch('<%= request.getContextPath() %>/cartservlet?action=update_chat&id=' + productId + '&quantity=' + newQuantity, { method: 'POST' })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            showToast('✅ ' + data.message);
            updateCartSummary();
        } else {
            showToast('❌ ' + data.message);
        }
    });
}

function clearCartFromChat() {
    if (confirm('Bạn có chắc muốn xoá toàn bộ giỏ hàng?')) {
        fetch('<%= request.getContextPath() %>/cartservlet?action=clear', { method: 'POST' })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                showToast('🗑️ Đã xoá toàn bộ giỏ hàng!');
                updateCartSummary();
               location.reload(); 
            } else {
                showToast('❌ ' + data.message);
            }
        });
    }
}

document.addEventListener('click', function(e) {
    if (e.target.classList.contains('feedback-btn')) {
        const feedback = e.target.getAttribute('data-feedback');
        // Lấy câu trả lời bot gần nhất
        const lastBotMsg = e.target.closest('.bot-msg');
        const answer = lastBotMsg ? lastBotMsg.innerText : '';
        // Lấy câu hỏi user gần nhất
        const userMsgs = document.querySelectorAll('.user-msg');
        const question = userMsgs.length ? userMsgs[userMsgs.length-1].innerText : '';
        fetch('/chatfeedback', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: 'question=' + encodeURIComponent(question) + '&answer=' + encodeURIComponent(answer) + '&feedback=' + feedback
        }).then(() => {
            e.target.parentElement.innerHTML = '<span>Cảm ơn bạn đã phản hồi!</span>';
        });
    }
});
</script>