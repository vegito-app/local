package api

import (
	nethttp "net/http"

	"github.com/7d4b9/utrade/backend/internal/http"
)

type User struct {
	ID          string           `json:"id,omitempty"`
	Name        string           `json:"name"`
	Description string           `json:"description"`
	SaleType    string           `json:"saleType"`
	WeightGrams int              `json:"weightGrams"`
	PriceCents  int              `json:"priceCents"`
	Images      []VegetableImage `json:"images"`
	CreatedAt   int64            `json:"createdAt"`
}

type UserStorage interface {
	// StoreUser(ctx context.Context, userID string, o User) error
	// GetUser(ctx context.Context, userID, id string) (*User, error)
	// ListUsers(ctx context.Context, userID string) ([]*User, error)
	// DeleteUser(ctx context.Context, userID, id string) error
}

// UserService defines all routes handled by UserService
type UserService struct {
	*UserRecoveryKeyService
	storage UserStorage
}

func NewUserService(mux *nethttp.ServeMux, storage UserStorage, userRecoveryKeyVault UserRecoveryKeyVault) (*UserService, error) {

	u := &UserService{
		storage: storage,
		UserRecoveryKeyService: &UserRecoveryKeyService{
			vault: userRecoveryKeyVault,
		},
	}

	mux.Handle("GET /api/user/store-recoverykey", http.ApplyMiddleware(
		nethttp.HandlerFunc(u.retrieveUserRecoveryKey),
		FirebaseAuthMiddleware))

	mux.Handle("POST /api/user/store-recoverykey", http.ApplyMiddleware(
		nethttp.HandlerFunc(u.storeUserRecoveryKey),
		FirebaseAuthMiddleware))

	mux.Handle("POST /api/user/get-recoverykey-version", http.ApplyMiddleware(
		nethttp.HandlerFunc(u.getUserRecoveryKeyVersion),
		FirebaseAuthMiddleware))

	return u, nil
}
