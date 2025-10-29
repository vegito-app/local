path "transit/encrypt/user_wallet_recovery," {
  capabilities = ["update"]
}

path "transit/decrypt/user_wallet_recovery," {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
