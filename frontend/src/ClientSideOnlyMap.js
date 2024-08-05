import React, { useState, useEffect } from 'react';
import { MyMap } from './Map'
export function ClientSideOnlyMap() {
  const [isClient, setIsClient] = useState(false);
  useEffect(() => {
    setIsClient(true);
    console.log("useEffect a été exécuté");
  }, []);
  console.log('Le JavaScript côt client est bien chargé');

  if (!isClient) {
    return null
  }
  return <MyMap />;
}
