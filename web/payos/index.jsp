<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PayOS Testing & Debugging Tools</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 900px;
            width: 100%;
            padding: 40px;
        }
        
        h1 {
            color: #2c3e50;
            text-align: center;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        
        .subtitle {
            text-align: center;
            color: #7f8c8d;
            margin-bottom: 40px;
            font-size: 1.1em;
        }
        
        .tools-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .tool-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: white;
            display: block;
        }
        
        .tool-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }
        
        .tool-card.secondary {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        .tool-card.success {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        
        .tool-icon {
            font-size: 3em;
            margin-bottom: 15px;
        }
        
        .tool-title {
            font-size: 1.3em;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .tool-description {
            font-size: 0.9em;
            opacity: 0.9;
        }
        
        .back-button {
            display: inline-block;
            padding: 15px 30px;
            background: #34495e;
            color: white;
            text-decoration: none;
            border-radius: 10px;
            margin-top: 20px;
            transition: background 0.3s;
        }
        
        .back-button:hover {
            background: #2c3e50;
        }
        
        .info-section {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .info-section h3 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .info-section ul {
            margin-left: 20px;
            color: #555;
        }
        
        .info-section li {
            margin: 5px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 PayOS Testing Tools</h1>
        <p class="subtitle">Comprehensive debugging and testing suite for PayOS integration</p>
        
        <div class="info-section">
            <h3>📋 Available Tools</h3>
            <ul>
                <li><strong>Debug PayOS:</strong> Test PayOS configuration and create sample payment links</li>
                <li><strong>Connectivity Test:</strong> Diagnose network issues with PayOS API</li>
                <li><strong>Webhook Test:</strong> Test PayOS webhook integration</li>
                <li><strong>Refund Test:</strong> Test refund functionality</li>
                <li><strong>Payment Test:</strong> Simple payment link creation test</li>
            </ul>
        </div>
        
        <div class="tools-grid">
            <a href="debug-payos.jsp" class="tool-card">
                <div class="tool-icon">🐛</div>
                <div class="tool-title">Debug PayOS</div>
                <div class="tool-description">
                    Test configuration and create payment links
                </div>
            </a>
            
            <a href="test-payos-connectivity.jsp" class="tool-card secondary">
                <div class="tool-icon">🔌</div>
                <div class="tool-title">Connectivity Test</div>
                <div class="tool-description">
                    Diagnose DNS, SSL, and network issues
                </div>
            </a>
            
            <a href="test-webhook.jsp" class="tool-card success">
                <div class="tool-icon">📡</div>
                <div class="tool-title">Webhook Test</div>
                <div class="tool-description">
                    Test webhook endpoints and callbacks
                </div>
            </a>
            
            <a href="refund.jsp" class="tool-card">
                <div class="tool-icon">💰</div>
                <div class="tool-title">Refund Test</div>
                <div class="tool-description">
                    Test refund processing
                </div>
            </a>
            
            <a href="test-payos.jsp" class="tool-card secondary">
                <div class="tool-icon">💳</div>
                <div class="tool-title">Payment Test</div>
                <div class="tool-description">
                    Simple payment link test
                </div>
            </a>
        </div>
        
        <div style="text-align: center;">
            <a href="../home.jsp" class="back-button">← Back to Home</a>
        </div>
    </div>
</body>
</html>
