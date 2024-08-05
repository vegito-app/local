import React from 'react'
// Import FirebaseAuth and firebase.
import {useState,useEffect} from 'react';
import StyledFirebaseAuth from 'react-firebaseui/StyledFirebaseAuth';
import { Modal } from '@mui/material'
import { initializeApp } from 'firebase/app'
import { getAuth,EmailAuthProvider,onAuthStateChanged, GoogleAuthProvider } from 'firebase/auth'

const firebaseConfig = {
  apiKey: process.env.REACT_APP_UTRADE_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_UTRADE_FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.REACT_APP_UTRADE_FIREBASE_DATABASE_URL,
  projectId: process.env.REACT_APP_UTRADE_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_UTRADE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_UTRADE_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_UTRADE_FIREBASE_APP_ID,
}

const  app = initializeApp(firebaseConfig)
const auth = getAuth(app)

let uiConfig = {
  signInFlow: 'popup',
  popupMode: false,
  signInOptions: [
    {
      provider: EmailAuthProvider.PROVIDER_ID,
      signInMethod: EmailAuthProvider.EMAIL_LINK_SIGN_IN_METHOD,
    },
    {
      provider: GoogleAuthProvider.PROVIDER_ID,
      // signInMethod: GoogleAuthProvider.EMAIL_LINK_SIGN_IN_METHOD,
    }
  ],
  callbacks: {
    signInSuccessWithAuthResult: function(authResult, redirectUrl) {
      // Les informations utilisateur peuvent être consultées avec authResult.user ou authResult.credential.
      console.log(authResult.user);
      // Retourner true pour continuer la redirection vers signInSuccessUrl (si configuré)
      return true;
    },
  },
};

export const SignInScreen =({isShowing,handleLoginClose})=> {
  const [isLoaded, setLoaded] = useState(false);
  
  const [isSignedIn, setIsSignedIn] = useState(false); // Local signed-in state.

  useEffect(() => {
    // Ce code sera exécuté une fois que le composant est monté
    setLoaded(true);
  }, []);

  // Listen to the Firebase Auth state and set the local state.
  useEffect(() => {
    const unregisterAuthObserver = auth.onAuthStateChanged(user => {
      if (user) {
        user.getIdToken().then((id)=>{
          console.log("id :", id )
          
        }).catch((reason)=>{
          
        })
        // User is signed in, see docs for a list of available properties
        // https://firebase.google.com/docs/reference/js/auth.user
        const uid = user.uid;
        console.log('User is logged in', user);
        handleLoginClose(true);  // <-- close the modal after login
      } else {
        console.log('User is not logged in');
      }
      setIsSignedIn(!!user);
      // setIsSignedIn(!!user);
      // handleLoginClose(false);
    });
    return () => unregisterAuthObserver(); // Make sure we un-register Firebase observers when the component unmounts.
  });

  onAuthStateChanged(auth, (user) => {
    if (user) {
      user.getIdToken().then((id)=>{
        console.log("id :", id )
        
      }).catch((reason)=>{
        
      })
      // User is signed in, see docs for a list of available properties
      // https://firebase.google.com/docs/reference/js/auth.user
      const uid = user.uid;
      // ...
    } else {
      // User is signed out
      // ...
    }
  });
  return (

    <div>
      <h1>Welcome to My Awesome App</h1>
      <p>Please sign-in:</p>
      <StyledFirebaseAuth uiCallback={ui => ui.disableAutoSignIn()} uiConfig={uiConfig} firebaseAuth={auth} />
    </div>
  );
}
    //   <Modal
    //   open={isShowing}
    //   // onClose={handleLoginClose}
    //   aria-labelledby="modal-modal-title"
    //   aria-describedby="modal-modal-description"
    //   >

    // </Modal>
export const SignInScreen1=({isShowing,handleLoginClose}) =>{

  onAuthStateChanged(auth, (user) => {
    if (user) {
      user.getIdToken().then((id)=>{
        console.log("id :", id )
        
      }).catch((reason)=>{
        
      })
      // User is signed in, see docs for a list of available properties
      // https://firebase.google.com/docs/reference/js/auth.user
      const uid = user.uid;
      // ...
    } else {
      // User is signed out
      // ...
    }
  });
  const [isSignedIn, setIsSignedIn] = useState(false); // Local signed-in state.

  // Listen to the Firebase Auth state and set the local state.
  useEffect(() => {
    const unregisterAuthObserver = auth.onAuthStateChanged(user => {
      if (user) {
        console.log('User is logged in', user);
        handleLoginClose(true);  // <-- close the modal after login
      } else {
        console.log('User is not logged in');
      }
      setIsSignedIn(!!user);
      // setIsSignedIn(!!user);
      // handleLoginClose(false);
    });
    return () => unregisterAuthObserver(); // Make sure we un-register Firebase observers when the component unmounts.
  });

  if (!isSignedIn) {
    return (
          <Modal
              open={isShowing}
              // onClose={handleLoginClose}
              aria-labelledby="modal-modal-title"
              aria-describedby="modal-modal-description"
            >
        <div>
          <h1>Car2Go</h1>
          <p>Version {process.env.REACT_APP_UTRADE_VERSION}</p>
          <p>Please sign-in:</p>
          <StyledFirebaseAuth uiCallback={ui => ui.disableAutoSignIn()} uiConfig={uiConfig} firebaseAuth={auth} />
        </div>
      </Modal>
    );
  }
  return (
    <div>
      <h1>My App</h1>
      <p>Welcome {auth.currentUser.displayName}! You are now signed-in!</p>
      <button onClick={() => auth.signOut()}>Sign-out</button>
    </div>
  );
}
export default SignInScreen;
