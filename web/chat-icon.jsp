<%@ page contentType="text/html;charset=UTF-8" %>
<div id="chat-icon"
     onclick="window.open('<%=request.getContextPath()%>/customer-chat.jsp',
                          '_blank',
                          'width=420,height=600,left=1000,top=100,resizable=no,scrollbars=no,status=no')"
     style="position:fixed;
            bottom:25px;
            right:25px;
            width:60px;
            height:60px;
            background:#38bdf8;
            color:#fff;
            border-radius:50%;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:28px;
            box-shadow:0 6px 18px rgba(0,0,0,0.25);
            cursor:pointer;
            z-index:9999;">
    💬
</div>
