import os
import firebase_admin
from firebase_admin import credentials, firestore

# Optionnel : utiliser les émulateurs si dispo
# if os.getenv("USE_FIRESTORE_EMULATOR", "1") == "1":
os.environ["FIRESTORE_EMULATOR_HOST"] = "firebase-emulators:8080"  # adapter si besoin

# 🔐 Authentification : fichier JSON requis si pas d'émulateur
cred_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
if cred_path:
    print(f"[INFO] Using credentials from: {cred_path}")
    cred = credentials.Certificate(cred_path)
else:
    print("[INFO] Using Application Default Credentials")
    cred = credentials.ApplicationDefault()

# 🔧 Initialisation Firebase Admin
app = firebase_admin.initialize_app(cred, {
    "projectId": os.getenv("FIREBASE_PROJECT_ID", "demo-project-id"),  # adapter si tu n’utilises pas les émulateurs
})

# 🔥 Firestore client test
db = firestore.client()
print("[INFO] Firestore client initialized")

# Test d’écriture / lecture dans Firestore
doc_ref = db.collection("tests").document("connectivity-check")
doc_ref.set({"status": "ok"})

data = doc_ref.get().to_dict()
print("[SUCCESS] Firestore document read:", data)