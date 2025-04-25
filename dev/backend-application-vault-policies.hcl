path "transit/encrypt/user/wallet/recovery" {
  capabilities = ["update"]
}

path "transit/decrypt/user/wallet/recovery" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
