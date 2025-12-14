# ⚡ QUICK ML DEPLOYMENT

## 5-Minute Setup Guide

---

## 📝 **Prerequisites**

✅ Python installed  
✅ Flutter installed  
✅ Phone & PC on same Wi-Fi  

---

## 🚀 **STEP-BY-STEP**

### **1️⃣ Export Models (2 minutes)**

```bash
# Open notebook
jupyter notebook GCP_VM_Pricing_Project1.ipynb

# Run ALL cells (important!)
# Scroll to Section 10
# Run Section 10 cells

# Verify files created:
# ✅ regression_model.pkl
# ✅ classification_model.pkl
# ✅ clustering_model.pkl
# ✅ + 5 more .pkl files
# ✅ model_metadata.json
```

---

### **2️⃣ Install & Run Server (1 minute)**

```bash
# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn main:app --host 0.0.0.0 --port 8000

# Should see:
# ✅ All models loaded successfully!
# ✅ Uvicorn running on http://0.0.0.0:8000
```

**Test:** Open http://127.0.0.1:8000/docs

---

### **3️⃣ Get IP Address (30 seconds)**

```bash
# Windows
ipconfig

# Look for IPv4 Address
# Example: 192.168.1.15
```

**Copy this IP!**

---

### **4️⃣ Update Flutter App (30 seconds)**

Open: `lib/screens/ml_prediction_screen.dart`

Line 21:
```dart
String apiUrl = "http://192.168.1.15:8000"; // ← PUT YOUR IP HERE
```

---

### **5️⃣ Run App (1 minute)**

```bash
flutter run -d android
```

---

## ✅ **TEST IT**

1. Sign in to your account
2. Tap **"GCP VM Price Prediction"**
3. Enter:
   - vCPUs: `2`
   - Memory: `8`
   - Storage: `100`
4. Tap **"Predict Cost"**
5. See results! 🎉

---

## ❌ **Not Working?**

### **Connection Error**

✅ Server running? (check terminal)  
✅ Same Wi-Fi? (phone & PC)  
✅ Correct IP? (check again with `ipconfig`)  

**Test on phone browser:** `http://YOUR_IP:8000/health`

### **Model Not Found**

✅ Run notebook Section 10  
✅ Check `.pkl` files exist  
✅ Files in same folder as `main.py`  

---

## 📱 **Features**

- 💰 **Monthly Cost** prediction
- 🏷️ **Price Category** (Low/Medium/High)
- 👥 **VM Cluster** grouping
- 📊 **Confidence** percentages
- ⚡ **Real-time** predictions

---

## 🎯 **That's It!**

**Total Time:** ~5 minutes  
**Result:** Full ML-powered mobile app!  

See `ML_DEPLOYMENT_GUIDE.md` for detailed docs.

---

**Happy Coding! 🚀**

