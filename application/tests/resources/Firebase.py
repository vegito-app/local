# REMARQUE : La méthode `clear_storage` nécessite que le package `google-cloud-storage`
# soit installé, et que l’émulateur Firebase Storage soit configuré dans `firebase.json`.
# firebase.py
import firebase_admin
from firebase_admin import firestore
from firebase_admin._utils import EmulatorAdminCredentials
import os

class Firebase:
    def __init__(self):
        cred = EmulatorAdminCredentials()
        if not firebase_admin._apps:
            firebase_admin.initialize_app(
                cred,
                options={"projectId": os.getenv("FIREBASE_PROJECT_ID", "demo-project-id")}
            )
        self.db = firestore.client()

    def purge_vegetables_collection(self):
        veggies = self.db.collection("vegetables").stream()
        batch = self.db.batch()
        count = 0
        for doc in veggies:
            batch.delete(doc.reference)
            count += 1
            if count % 500 == 0:
                batch.commit()
                batch = self.db.batch()
        batch.commit()
        return f"Deleted {count} vegetable documents"

    # Robot Framework keyword wrapper
    def purge_test_vegetables(self):
        return self.purge_vegetables_collection()
    
    def purge_users_collection(self):
        users = self.db.collection("users").stream()
        batch = self.db.batch()
        count = 0
        for doc in users:
            batch.delete(doc.reference)
            count += 1
            if count % 500 == 0:
                batch.commit()
                batch = self.db.batch()
        batch.commit()
        return f"Deleted {count} user documents"

    # Robot Framework keyword wrapper
    def purge_test_users(self):
        return self.purge_users_collection()

    # --- Nouveaux mots-clés utiles pour les tests Robot Framework ---
    def reset_firestore(self):
        collections = list(self.db.collections())
        for collection in collections:
            self._recursive_delete(collection)
        return "All Firestore collections and subcollections reset"

    def _recursive_delete(self, collection_ref, batch_size=500):
        docs = collection_ref.limit(batch_size).stream()
        for doc in docs:
            # Supprimer récursivement les sous-collections
            subcollections = doc.reference.collections()
            for subcollection in subcollections:
                self._recursive_delete(subcollection, batch_size)

            # Supprimer le document lui-même
            doc.reference.delete()
        
    def create_test_user(self, email="test@example.com", password="test1234"):
        from firebase_admin import auth
        user = auth.create_user(email=email, password=password)
        return f"Created user {user.uid}"

    def delete_test_user(self, email="test@example.com"):
        from firebase_admin import auth
        try:
            user = auth.get_user_by_email(email)
            auth.delete_user(user.uid)
            return f"Deleted user {user.uid}"
        except auth.UserNotFoundError:
            return "User not found"
        
    def insert_test_data(self, collection, document, data):
        import json
        if isinstance(data, str):
            data = json.loads(data)
        ref = self.db.collection(collection).document(document)
        ref.set(data)
        return f"Inserted test data into {collection}/{document}"

    def delete_all_auth_users(self):
        from firebase_admin import auth
        page = auth.list_users()
        deleted = 0
        while page:
            for user in page.users:
                auth.delete_user(user.uid)
                deleted += 1
            page = page.get_next_page()
        return f"Deleted {deleted} user(s)"

    def clear_storage(self, bucket_name=None):
        # Nécessite google-cloud-storage installé et l'émulateur Storage configuré dans firebase.json
        from google.cloud import storage
        if not bucket_name:
            bucket_name = f"{os.getenv('FIREBASE_PROJECT_ID', 'demo-project-id')}.firebasestorage.app"
        client = storage.Client(project=os.getenv("FIREBASE_PROJECT_ID", "demo-project-id"))
        bucket = client.bucket(bucket_name)
        blobs = list(bucket.list_blobs())
        for blob in blobs:
            blob.delete()       
        return f"Deleted {len(blobs)} file(s) from storage"

    def snapshot_firestore(self):
        import json
        snapshot = {}
        for collection in self.db.collections():
            collection_name = collection.id
            snapshot[collection_name] = {}
            for doc in collection.stream():
                snapshot[collection_name][doc.id] = doc.to_dict()
        return json.dumps(snapshot, indent=2)

    def restore_firestore_snapshot(self, snapshot_json):
        import json
        if isinstance(snapshot_json, str):
            snapshot = json.loads(snapshot_json)
        else:
            snapshot = snapshot_json  # déjà dict
        for collection, documents in snapshot.items():
            for doc_id, doc_data in documents.items():
                self.db.collection(collection).document(doc_id).set(doc_data)
        return "Snapshot restored to Firestore"

    def get_vegetable_document(self, doc_id):
        doc = self.db.collection("vegetables").document(doc_id).get()
        return doc.to_dict() if doc.exists else None

    def create_test_vegetable(self, name="Carotte", doc_id="carotte-id", lat=48.8, lng=2.3, radius=5):
        data = {
            "name": name,
            "description": f"{name} test",
            "location": {"lat": lat, "lng": lng},
            "deliveryRadiusKm": radius,
            "imageUrl": "https://fake.url/carotte.jpg",
            "quantity": 10,
            "price": 3.5,
        }
        return self.insert_test_data("vegetables", doc_id, data)

    def reset_data_before_test(self):
        # Ne touche pas aux comptes utilisateurs Firebase Auth
        self.reset_firestore_and_storage_before_test()

    def reset_firestore_and_storage_before_test(self):
        """Réinitialise complètement Firestore et Storage."""
        self.clear_storage()
        self.reset_firestore()

def get_robot_library():
    return Firebase()

def create_test_cart(self, user_id, items):
    cart_ref = self.db.collection("carts").document(user_id)
    cart_ref.set({"items": items})
    return f"Inserted cart for user {user_id}"