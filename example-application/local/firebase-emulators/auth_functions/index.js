const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

db.settings({ ignoreUndefinedProperties: true });

exports.beforeCreate = functions.auth.user().beforeCreate(async (user) => {
  console.log("User DATA: ", user); // log the user data

  const name = user.name || "";
  const displayName = user.displayName || "";
  const email = user.email || "";
  const uid = user.uid || "";

  const document = db.doc("users/" + uid);
  try {
    await setInitialData(document);
  } catch (error) {
    console.error("Failed to enter new data into the document", error);
    throw new functions.https.HttpsError(
      "Internal",
      "Failed to enter new data into the document"
    );
  }

  try {
    await updateData(document, { displayName, name, email });
  } catch (error) {
    console.error("Failed to update the document", error);
    throw new functions.https.HttpsError(
      "Internal",
      "Failed to update the document"
    );
  }

  return { localId: uid };
});

async function setInitialData(document) {
  try {
    await document.set({
      title: "Welcome to Firestore",
      body: "Hello World",
    });
  } catch (error) {
    console.error("Failed to update the document", error, document);
    throw new functions.https.HttpsError(
      "Internal",
      "Failed to setInitialData user the document"
    );
  }
  console.log("Entered new data into the document");
}

async function updateData(document, { displayName, name, email }) {
  try {
    await document.update({ displayName, name, email });
  } catch (error) {
    console.error("Failed to update the document", error);
    throw new functions.https.HttpsError(
      "Internal",
      "Failed to update user the document"
    );
  }
  console.log("Updated new data into the document");
}

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
