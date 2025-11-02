# 🚀 PayOS SDK Migration Guide

## 📋 CHECKLIST - Follow in Order

### ✅ Step 1: Download & Install SDK (5-10 phút)

1. **Chạy PowerShell script:**
   ```powershell
   cd d:\SWP391\Pets4Care_tranhongson\Pets4Care
   .\download-payos-sdk.ps1
   ```

2. **Add JARs to NetBeans:**
   - Right-click project "Pets4Care" → Properties
   - Select "Libraries" → "Compile" tab
   - Click "Add JAR/Folder"
   - Navigate to `lib/` folder
   - Select ALL 4 JAR files:
     - `payos-2.1.0.jar`
     - `jackson-databind-2.15.0.jar`
     - `jackson-core-2.15.0.jar`
     - `jackson-annotations-2.15.0.jar`
   - Click "Open" → "OK"

3. **Verify installation:**
   - Click "Clean and Build"
   - ✅ If no errors → SDK installed successfully!
   - ❌ If errors → Check if JARs are in Libraries list

---

### ✅ Step 2: Update PayOSController (5 phút)

**Replace existing `PayOSController.java`** to use new service:

```java
// In handleCreatePayment method:

// OLD CODE (comment out or delete):
// String paymentUrl = payOSService.createPaymentLink(...);

// NEW CODE:
PayOSServiceV2 payOSServiceV2 = new PayOSServiceV2();
String paymentUrl = payOSServiceV2.createPaymentLink(
    orderId,
    amount,
    description,
    returnUrl,
    cancelUrl
);
```

**Full update:**

1. Open `src/java/controller/PayOSController.java`
2. Add import: `import service.PayOSServiceV2;`
3. Replace the payment creation code with the above

---

### ✅ Step 3: Test Payment Flow (10 phút)

1. **Start server:**
   - Run project in NetBeans (F6)
   - Wait for server to start on port 9998

2. **Test payment creation:**
   - Go to: http://localhost:9998/Pets4Care
   - Add items to cart
   - Proceed to checkout
   - Click "Thanh toán PayOS"

3. **Expected results:**
   - ✅ No console errors
   - ✅ Redirects to PayOS checkout page
   - ✅ QR code appears for payment

4. **If errors occur:**
   - Check console logs for PayOS SDK errors
   - Verify payos.properties configuration
   - Run connectivity test: http://localhost:9998/Pets4Care/payos/test-payos-connectivity.jsp

---

### ✅ Step 4: Setup Webhook (15 phút)

**For LOCAL DEVELOPMENT:**

1. **Download ngrok:**
   - Go to: https://ngrok.com/download
   - Download for Windows
   - Extract to any folder

2. **Run ngrok:**
   ```powershell
   cd path\to\ngrok
   .\ngrok.exe http 9998
   ```

3. **Copy ngrok URL:**
   - You'll see: `Forwarding https://abc123.ngrok.io -> http://localhost:9998`
   - Copy the HTTPS URL: `https://abc123.ngrok.io`

4. **Register webhook in PayOS:**
   - Go to: https://my.payos.vn
   - Navigate to Settings → Webhook
   - Webhook URL: `https://abc123.ngrok.io/Pets4Care/payos/webhook`
   - Click "Save"

5. **Test webhook:**
   - Make a test payment
   - Check console logs for "PAYOS WEBHOOK RECEIVED"
   - Order status should auto-update to "PAID"

**For PRODUCTION:**

1. Use your production domain
2. Webhook URL: `https://yourdomain.com/Pets4Care/payos/webhook`
3. Register in PayOS dashboard

---

### ✅ Step 5: Verify Everything Works (5 phút)

Run through complete flow:

1. ☑️ Create order → Redirects to PayOS
2. ☑️ Make payment (use test account)
3. ☑️ Webhook received → Order status updates
4. ☑️ User redirected back → Success page shows

---

## 🔧 Troubleshooting

### ❌ Problem: "PayOS cannot be resolved"

**Solution:**
- JARs not added to project
- Re-check Libraries in NetBeans
- Clean and Build again

### ❌ Problem: "Payment URL is NULL"

**Solution:**
- Run connectivity test: `/payos/test-payos-connectivity.jsp`
- Check internet connection
- Verify PayOS credentials in `payos.properties`

### ❌ Problem: "Webhook not received"

**Solution:**
- Check if ngrok is running
- Verify webhook URL in PayOS dashboard
- Test webhook endpoint: `http://localhost:9998/Pets4Care/payos/webhook` (should show setup page)

### ❌ Problem: "Signature verification failed"

**Solution:**
- PayOS SDK handles this automatically
- If still failing, check if checksum key is correct in `payos.properties`

---

## 📁 New Files Created

You now have these new files:

```
src/java/
├── utils/
│   └── PayOSManager.java          ← SDK wrapper (Singleton)
├── service/
│   └── PayOSServiceV2.java        ← New service using SDK
└── controller/
    └── PayOSWebhookController.java ← Webhook handler

web/payos/
├── index.jsp                       ← PayOS tools dashboard
├── debug-payos.jsp
├── test-payos-connectivity.jsp
├── test-payos.jsp
├── test-webhook.jsp
└── refund.jsp

lib/
├── payos-2.1.0.jar
├── jackson-databind-2.15.0.jar
├── jackson-core-2.15.0.jar
└── jackson-annotations-2.15.0.jar
```

---

## 🎯 What Changed?

### Before (Manual Implementation):
```java
// You manually:
// - Created HTTP requests
// - Generated signatures
// - Parsed JSON responses
// - Verified webhooks
```

### After (SDK Implementation):
```java
// SDK automatically:
// - Handles HTTP requests
// - Generates signatures ✅
// - Parses responses ✅
// - Verifies webhooks ✅
PayOS payOS = new PayOS(clientId, apiKey, checksumKey);
CreatePaymentLinkResponse response = payOS.paymentRequests().create(request);
```

---

## 📚 Resources

- **PayOS Docs:** https://payos.vn/docs
- **PayOS Dashboard:** https://my.payos.vn
- **PayOS GitHub:** https://github.com/payOSHQ/payos-demo-java-spring
- **ngrok Download:** https://ngrok.com/download

---

## ✅ SUCCESS CRITERIA

You're done when:
- [ ] No compile errors
- [ ] Payment creation works
- [ ] Redirects to PayOS checkout
- [ ] Webhook receives notifications
- [ ] Order status updates automatically
- [ ] User sees success page

---

## 🆘 Need Help?

If you encounter issues:

1. Check console logs (most errors are logged)
2. Run diagnostic tools in `/payos/` folder
3. Verify all credentials in `payos.properties`
4. Test connectivity using test pages

Good luck! 🚀
