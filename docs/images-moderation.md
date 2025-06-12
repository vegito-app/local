---

## Images Path, URL Construction & Moderation Logic

### Storage Model

- Only the **relative path** of images is stored in the database (e.g. `vegetables/{userId}/{filename}.jpg`).
- No full URL or CDN prefix is ever stored.
- This applies to both pending and validated images.

### Backend Behavior

- When serving data via the API (`ListVegetables` or `GetVegetable`), the backend returns:
  - `imagePath`: the relative storage path.
  - `status`: `"pending"` or `"uploaded"`.
  - `servedByCdn`: `true` if the image has been processed and moved to the CDN bucket; otherwise `false`.

- The backend decides `servedByCdn` based on:
  - Image status (`uploaded`).
  - Current environment (production vs local/dev).
  - In dev/local environments, even validated images may not be served by CDN because no worker migrates them.

### Frontend URL Reconstruction Logic

The frontend receives:

```json
{
  "imagePath": "vegetables/3tCqwqnPfH2otNJb4fA2japR3FUO/1749662010807_poivron.jpg",
  "status": "pending" | "uploaded",
  "servedByCdn": true | false
}
```

It reconstructs the public URL based on `servedByCdn`:

```dart
String getPublicImageUrl(String imagePath, bool servedByCdn) {
  if (servedByCdn) {
    return '$CDN_PUBLIC_PREFIX/$imagePath';
  } else {
    final encodedPath = Uri.encodeFull(imagePath);
    return '$FIREBASE_STORAGE_PUBLIC_PREFIX/$encodedPath?alt=media';
  }
}
```

- `CDN_PUBLIC_PREFIX` and `FIREBASE_STORAGE_PUBLIC_PREFIX` are injected via frontend configuration.

### Security Logic (Ownership Filtering)

- If `status == "pending"` and `image.ownerId != currentUserId`:
  - The frontend must hide the image from the UI.
  - This prevents users from seeing images pending moderation that belong to others.

---
