# 🚀 ML Model Deployment Guide
## GCP VM Pricing Prediction - Complete Setup

---

## ✅ **What's Been Set Up**

### 📊 Notebook Updates
- ✅ Added Section 10: Model Export
- ✅ Exports 3 models (Regression, Classification, Clustering)
- ✅ Exports 3 scalers (for each model)
- ✅ Exports label encoders
- ✅ Exports metadata JSON with feature names

### 🔧 FastAPI Server
- ✅ Created `main.py` - Complete API server
- ✅ 4 prediction endpoints
- ✅ CORS enabled for mobile access
- ✅ Error handling included

### 📱 Flutter App
- ✅ Created ML Prediction screen
- ✅ Beautiful modern UI
- ✅ HTTP package added
- ✅ Navigation from home screen
- ✅ Real-time predictions

---

## 🎯 **DEPLOYMENT STEPS**

### **STEP 1: Export Models from Notebook**

1. Open the notebook in Jupyter/Cursor:
   ```bash
   jupyter notebook GCP_VM_Pricing_Project1.ipynb
   ```

2. Run ALL cells from the beginning (important!)

3. Run the NEW Section 10 cells (at the end)

4. You should see these files created:
   ```
   ✅ regression_model.pkl
   ✅ classification_model.pkl
   ✅ clustering_model.pkl
   ✅ scaler_regression.pkl
   ✅ scaler_classification.pkl
   ✅ scaler_clustering.pkl
   ✅ label_encoders.pkl
   ✅ model_metadata.json
   ```

---

### **STEP 2: Install FastAPI Dependencies**

1. Open terminal in your project folder:
   ```bash
   cd C:\Users\talel\StudioProjects\untitled
   ```

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

   This installs:
   - FastAPI (API framework)
   - Uvicorn (Server)
   - Joblib (Model loading)
   - NumPy (Arrays)
   - Scikit-learn (ML library)
   - XGBoost (ML library)

---

### **STEP 3: Run the FastAPI Server**

1. Make sure all `.pkl` files are in the same directory as `main.py`

2. Start the server:
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

3. You should see:
   ```
   Loading models...
   ✅ All models loaded successfully!
   Uvicorn running on http://0.0.0.0:8000
   ```

4. Test it in browser:
   ```
   http://127.0.0.1:8000/docs
   ```

   You should see the FastAPI interactive documentation!

---

### **STEP 4: Get Your PC's IP Address**

**Windows:**
```bash
ipconfig
```

Look for:
```
IPv4 Address: 192.168.1.15
```

**macOS/Linux:**
```bash
ifconfig
```

**Copy your IP address** - you'll need it!

---

### **STEP 5: Update Flutter App with Your IP**

1. Open `lib/screens/ml_prediction_screen.dart`

2. Find line ~21:
   ```dart
   String apiUrl = "http://192.168.1.15:8000";
   ```

3. **Replace** `192.168.1.15` with YOUR IP address

4. Save the file

---

### **STEP 6: Connect Phone & PC to Same Wi-Fi**

⚠️ **CRITICAL**: Both must be on the **SAME Wi-Fi network**

- PC Wi-Fi: Check your current network
- Phone Wi-Fi: Connect to the SAME network

---

### **STEP 7: Run the Flutter App**

```bash
flutter run -d android
```

Or from Android Studio/VS Code, click Run.

---

## 🎯 **TESTING THE APP**

### **Test Workflow:**

1. **Sign in** to your account

2. On home screen, tap **"GCP VM Price Prediction"** button

3. Enter test values:
   - vCPUs: `2`
   - Memory (GB): `8`
   - Storage (GB): `100`

4. Tap **"Predict Cost"**

5. You should see:
   - ✅ Monthly Cost: `$XXX.XX`
   - ✅ Price Category: Low/Medium/High
   - ✅ VM Cluster: Group X
   - ✅ Confidence percentages

---

## 📡 **API Endpoints Available**

Your server provides these endpoints:

### 1. **Regression** - Predict monthly cost
```
POST /predict/regression
Body: {"features": [2, 8, 100, ...]}
```

### 2. **Classification** - Categorize as Low/Medium/High
```
POST /predict/classification
Body: {"features": [2, 8, 100, ...]}
```

### 3. **Clustering** - Find VM group
```
POST /predict/clustering
Body: {"features": [2, 8, 100, ...]}
```

### 4. **All Models** - Get all predictions
```
POST /predict/all
Body: {
  "features_regression": [2, 8, 100, ...],
  "features_classification": [2, 8, 100, ...],
  "features_clustering": [2, 8, 100, ...]
}
```

### 5. **Model Info** - Get model metadata
```
GET /models/info
```

### 6. **Health Check**
```
GET /health
```

---

## 🔧 **Troubleshooting**

### **Problem: "Connection error"**

**Solutions:**
1. ✅ Check server is running (`uvicorn main:app...`)
2. ✅ Phone & PC on same Wi-Fi
3. ✅ IP address is correct in Flutter code
4. ✅ No firewall blocking port 8000

**Test connection:**
On phone browser, open: `http://YOUR_IP:8000/health`

Should show: `{"status": "healthy"}`

---

### **Problem: "Model not found"**

**Solution:**
- Run notebook Section 10 to export models
- Make sure `.pkl` files are in same folder as `main.py`

---

### **Problem: "Prediction failed"**

**Solution:**
- Check server terminal for errors
- Verify feature count matches model requirements
- Open `http://127.0.0.1:8000/docs` to test manually

---

### **Problem: Port 8000 already in use**

**Solution:**
```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID_NUMBER> /F

# Then restart server
```

---

## 📊 **Model Performance**

Your deployed models have these metrics:

### Regression Model (XGBoost)
- R² Score: **0.8685**
- RMSE: **$930.22**
- MAE: **$551.38**

### Classification Model (Gradient Boosting)
- Accuracy: **80.35%**
- Categories: Low, Medium, High

### Clustering Model (K-Means)
- Silhouette Score: **0.9855**
- Clusters: **3**

---

## 🎨 **Features in Flutter App**

- ✨ Modern gradient UI
- 🔮 Real-time ML predictions
- 📊 Visual confidence bars
- 🎯 Category color coding
- ⚡ Fast HTTP requests
- 🔄 Loading states
- ❌ Error handling

---

## 📁 **File Structure**

```
untitled/
├── GCP_VM_Pricing_Project1.ipynb  # Notebook with export cells
├── main.py                         # FastAPI server
├── requirements.txt                # Python dependencies
├── regression_model.pkl            # ML model (exported)
├── classification_model.pkl        # ML model (exported)
├── clustering_model.pkl            # ML model (exported)
├── scaler_regression.pkl           # Scaler (exported)
├── scaler_classification.pkl       # Scaler (exported)
├── scaler_clustering.pkl           # Scaler (exported)
├── label_encoders.pkl              # Encoders (exported)
├── model_metadata.json             # Metadata (exported)
└── lib/
    └── screens/
        └── ml_prediction_screen.dart  # Flutter ML screen
```

---

## 🚀 **Production Deployment (Optional)**

For production deployment beyond local testing:

### **Option 1: Deploy to Cloud**
- Google Cloud Run
- AWS Lambda
- Heroku
- Render

### **Option 2: Use ngrok (Quick Testing)**
```bash
# Install ngrok
# Then run:
ngrok http 8000

# Use the ngrok URL in Flutter app
```

---

## ✅ **Deployment Checklist**

Before testing:

- [ ] Notebook Section 10 executed
- [ ] All 8 `.pkl` and `.json` files created
- [ ] `requirements.txt` dependencies installed
- [ ] FastAPI server running on port 8000
- [ ] Server shows "All models loaded successfully"
- [ ] PC IP address found (e.g., 192.168.1.15)
- [ ] IP updated in `ml_prediction_screen.dart`
- [ ] Phone & PC on same Wi-Fi network
- [ ] Flutter app running on phone
- [ ] Firestore enabled (for auth to work)

---

## 💡 **Quick Commands Reference**

```bash
# Export models
jupyter notebook GCP_VM_Pricing_Project1.ipynb
# Run all cells + Section 10

# Install dependencies
pip install -r requirements.txt

# Start server
uvicorn main:app --host 0.0.0.0 --port 8000

# Get IP address
ipconfig  # Windows
ifconfig  # macOS/Linux

# Run Flutter app
flutter run -d android

# Test API
http://127.0.0.1:8000/docs
```

---

## 🎉 **Success!**

When everything works, you should see:

1. ✅ Server running with "All models loaded"
2. ✅ Flutter app connected
3. ✅ Predictions appearing in real-time
4. ✅ Beautiful results with cost, category, and cluster

**You've successfully deployed a full-stack ML application!** 🚀

---

## 📞 **Need Help?**

Check these files:
- `TROUBLESHOOTING.md` - Flutter app issues
- `FIRESTORE_SETUP.md` - Database setup
- `FIXES_AND_IMPROVEMENTS.md` - Recent updates

**Server logs**: Check terminal where uvicorn is running
**App logs**: Check Android Studio/VS Code debug console

---

**Happy Predicting! 🎯📊**

