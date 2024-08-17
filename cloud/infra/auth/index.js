const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { getAuth } = require("firebase-admin/auth");

admin.initializeApp();
const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true });

// [START v1ValidateNewUser]
// [START v1beforeCreateFunctionTrigger]
// Block account creation with any non-acme email address.
exports.beforeCreate = functions.auth.user().beforeCreate((user, context) => {
  // [END v1beforeCreateFunctionTrigger]
  // [START v1readEmailData]
  // Email passed from the User object.
  const name = user.name || "";
  const displayName = user.displayName || "";
  const email = user.email || "";
  const uid = user.uid || "";
  const auth = getAuth();
  // [END v1readEmailData]

  // [START v1domainHttpsError]
  // Only users of a specific domain can sign up.
  auth
    .createUser({
      displayName: displayName,
      email: email,
      uid: uid,
    })
    .then(() => {
      console.log(`success created new auth user: ${uid}`);
    })
    .catch((error) => {
      console.error("error '", error, "' create auth user: ", displayName);
      // throw new functions.https.HttpsError("User not created into auth", error);
    });

  const document = db.doc("users/" + uid);
  // Enter new data into the document.
  document
    .set({
      title: "Welcome to Firestore",
      body: "Hello World",
    })
    .then(() => {
      console.log("Entered new data into the document");
    })
    .then(
      document.update({
        displayName: displayName,
        name: name,
        email: email,
      })
    )
    .then(() => {
      console.log("Updated new data into the document");
    })
    .catch((error) => {
      console.error("Error writing document: ", error);
      throw new functions.https.HttpsError(
        "User not recorded into database",
        error
      );
    });
  //   // [END v1domainHttpsError]
});
// [END v1ValidateNewUser]

// [START v1CheckForBan]
// [START v1beforeSignInFunctionTrigger]
// Block account sign in with any banned account.
exports.checkForBan = functions.auth
  .user()
  .beforeSignIn(async (user, context) => {
    // [END v1beforeSignInFunctionTrigger]
    // [START v1readEmailData]
    // Email passed from the User object.
    const email = user.email || "";
    // [END v1readEmailData]

    // [START v1documentGet]
    // Obtain a document in Firestore of the banned email address.
    const doc = await db.collection("banned").doc(email).get();
    // [END v1documentGet]

    // [START v1bannedHttpsError]
    // Checking that the document exists for the email address.
    if (doc.exists) {
      // Throwing an HttpsError so that Auth rejects the account sign in.
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Unauthorized email"
      );
    }
    // [END v1bannedHttpsError]
  });
// [START v1CheckForBan]
