<%@ page import="utils.PayOSUtils" %>
<%@ page import="utils.PayOSConfig" %>
<!DOCTYPE html>
<html>
<head>
    <title>PayOS Connectivity Test</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 1000px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .section {
            margin: 20px 0;
            padding: 15px;
            background: #f8f9fa;
            border-left: 4px solid #3498db;
            border-radius: 5px;
        }
        .success {
            color: #27ae60;
            font-weight: bold;
        }
        .error {
            color: #e74c3c;
            font-weight: bold;
        }
        .info {
            color: #3498db;
        }
        pre {
            background: #2c3e50;
            color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-size: 12px;
            line-height: 1.5;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 10px 5px;
        }
        .btn:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 PayOS Connectivity Diagnostic</h1>
        
        <div class="section">
            <h2>Configuration Status</h2>
            <p><strong>Client ID:</strong> <%= PayOSConfig.getClientId() %></p>
            <p><strong>API Key:</strong> <%= PayOSConfig.getApiKey() != null ? "[SET - " + PayOSConfig.getApiKey().substring(0, Math.min(10, PayOSConfig.getApiKey().length())) + "...]" : "[NULL]" %></p>
            <p><strong>Checksum Key:</strong> <%= PayOSConfig.getChecksumKey() != null ? "[SET]" : "[NULL]" %></p>
            <p><strong>Base URL:</strong> <%= PayOSConfig.getBaseUrl() %></p>
            <p><strong>Webhook URL:</strong> <%= PayOSConfig.getWebhookUrl() %></p>
        </div>
        
        <div class="section">
            <h2>Network Diagnostic Results</h2>
            <p class="info">Running comprehensive connectivity tests...</p>
            <pre><%
                // Capture System.out and System.err to display diagnostics
                java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
                java.io.PrintStream ps = new java.io.PrintStream(baos);
                java.io.PrintStream oldOut = System.out;
                java.io.PrintStream oldErr = System.err;
                
                try {
                    System.setOut(ps);
                    System.setErr(ps);
                    
                    // Run the diagnostic
                    PayOSUtils.diagnosePayOSConnectivity();
                    
                } catch (Exception e) {
                    out.println("Error running diagnostic: " + e.getMessage());
                    e.printStackTrace(ps);
                } finally {
                    System.out.flush();
                    System.err.flush();
                    System.setOut(oldOut);
                    System.setErr(oldErr);
                    
                    // Output the captured logs
                    out.print(baos.toString("UTF-8"));
                }
            %></pre>
        </div>
        
        <div class="section">
            <h2>Troubleshooting Tips</h2>
            <ul>
                <li><strong>DNS Resolution Failed:</strong> Check your internet connection and DNS settings</li>
                <li><strong>TCP Connection Failed:</strong> Check firewall settings or VPN configuration</li>
                <li><strong>SSL/TLS Error:</strong> Update Java, check system time, or verify SSL certificates</li>
                <li><strong>Authentication Failed:</strong> Verify your Client ID and API Key in payos.properties</li>
            </ul>
        </div>
        
        <div style="text-align: center; margin-top: 30px;">
            <a href="test-payos-connectivity.jsp" class="btn">🔄 Refresh Test</a>
            <a href="debug-payos.jsp" class="btn">🔙 Back to Debug</a>
            <a href="../home.jsp" class="btn">🏠 Home</a>
        </div>
    </div>
</body>
</html>
