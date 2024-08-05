import React from 'react';
import {useEffect, useState, lazy, Suspense} from 'react';
import { Drawer } from '@mui/material';
import { Marker, GoogleMap, LoadScript } from '@react-google-maps/api';
// import { SignInScreen } from './signIn'
const SignInScreen = lazy(() => import("./signIn"));  // Remplacer "./SignInScreen" par le chemin réel vers votre composant

const libraries = ["places"];  

export function MyMapComponent() {
  const mapContainerStyle = {
    width: '1500px',
    height: '1400px'
  };
  
  const [currentPosition, setCurrentPosition] = useState({});
  
  useEffect(() => {
    navigator.geolocation.getCurrentPosition(position => {
      setCurrentPosition({
        lat: position.coords.latitude,
        lng: position.coords.longitude,
      });
    },
    error => {
      console.error("Erreur lors de l'obtention de la position actuelle : ", error);
    });
  }, []);
  const [showLogin, setShowLogin] = useState(false);
  const handleMapClick = () => {
    console.log("click map")
    setShowLogin(true);
  };
  const handleLoginClose = () => {
    setShowLogin(false);
  };
  return (
    <LoadScript 
      googleMapsApiKey={process.env.REACT_APP_GOOGLE_MAPS_API_KEY}
      libraries={libraries}
    >
      <GoogleMap
        id="example-map"
        mapContainerStyle={mapContainerStyle}
        zoom={15}
        center={currentPosition}
        onClick={handleMapClick}
        >
      

      <Suspense fallback={<div>Loading...</div>}>
      {showLogin && <SignInScreen isShowing={showLogin} handleLoginClose={handleLoginClose} />}
    </Suspense>
      {/* {showLogin ? <SignInScreen isShowing={showLogin} handleLoginClose={handleLoginClose} /> : null} */}
    {/* Autre code... */}
      {currentPosition.lat && currentPosition.lng && 
      <Marker  visible="true" label="bonjour" position={currentPosition} />}
        {/* You can put your map markers or other components here */}
      </GoogleMap>
      </LoadScript>
  );
}

export function MyMap () {
  return (
    <>
      <Drawer variant="permanent">
      <MyMapComponent />
      </Drawer>
    </>
  );
}
