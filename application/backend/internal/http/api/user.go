package api

import (
	"context"
	"encoding/json"
	"errors"
	nethttp "net/http"

	"github.com/7d4b9/utrade/backend/internal/http"
)

var ErrUserNotFound = errors.New("user not found")

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

// UserStorage defines the interface for user persistence layer.
//
// Implementations must return ErrUserNotFound when a requested user does not exist,
// so that HTTP handlers can translate this into a 404 Not Found response.
type UserStorage interface {
	// StoreUser saves or updates a user with the given ID.
	StoreUser(ctx context.Context, userID string, u User) error

	// GetUser retrieves a user by ID.
	// Returns ErrUserNotFound if the user does not exist.
	GetUser(ctx context.Context, userID, id string) (*User, error)

	// ListUsers returns a list of all users owned by the given userID.
	ListUsers(ctx context.Context, userID string) ([]*User, error)

	// DeleteUser removes a user by ID.
	// Returns ErrUserNotFound if the user does not exist.
	DeleteUser(ctx context.Context, userID, id string) error
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

	mux.Handle("GET /api/user/{id}", http.ApplyMiddleware(
		nethttp.HandlerFunc(u.GetUser),
		FirebaseAuthMiddleware))

	mux.Handle("PUT /api/users", http.ApplyMiddleware(
		nethttp.HandlerFunc(u.StoreUser),
		FirebaseAuthMiddleware))

	mux.Handle("GET /api/users", http.ApplyMiddleware(
		nethttp.HandlerFunc(u.ListUsers),
		FirebaseAuthMiddleware))

	mux.Handle("DELETE /api/users", http.ApplyMiddleware(
		nethttp.HandlerFunc(u.DeleteUser),
		FirebaseAuthMiddleware))

	return u, nil
}

func (u *UserService) GetUser(w nethttp.ResponseWriter, r *nethttp.Request) {
	userID := requestUserID(r)
	id := r.URL.Query().Get("id")
	if id == "" {
		nethttp.Error(w, `{"error":"missing id query parameter"}`, nethttp.StatusBadRequest)
		return
	}

	user, err := u.storage.GetUser(r.Context(), userID, id)
	if err != nil {
		nethttp.Error(w, `{"error":"`+err.Error()+`"}`, nethttp.StatusInternalServerError)
		return
	}

	if user == nil {
		nethttp.Error(w, `{"error":"user not found"}`, nethttp.StatusNotFound)
		return
	}
	if err := json.NewEncoder(w).Encode(user); err != nil {
		nethttp.Error(w, `{"error":"`+err.Error()+`"}`, nethttp.StatusInternalServerError)
		return
	}
}

func (u *UserService) StoreUser(w nethttp.ResponseWriter, r *nethttp.Request) {
	userID := requestUserID(r)

	var input User
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		nethttp.Error(w, `{"error":"invalid json"}`, nethttp.StatusBadRequest)
		return
	}
	if input.ID == "" {
		nethttp.Error(w, `{"error":"missing user id"}`, nethttp.StatusBadRequest)
		return
	}

	if err := u.storage.StoreUser(r.Context(), userID, input); err != nil {
		nethttp.Error(w, `{"error":"`+err.Error()+`"}`, nethttp.StatusInternalServerError)
		return
	}
	w.WriteHeader(nethttp.StatusNoContent)
}

func (u *UserService) ListUsers(w nethttp.ResponseWriter, r *nethttp.Request) {
	userID := requestUserID(r)

	users, err := u.storage.ListUsers(r.Context(), userID)
	if err != nil {
		nethttp.Error(w, `{"error":"`+err.Error()+`"}`, nethttp.StatusInternalServerError)
		return
	}
	if users == nil {
		users = []*User{}
	}
	if err := json.NewEncoder(w).Encode(users); err != nil {
		nethttp.Error(w, `{"error":"`+err.Error()+`"}`, nethttp.StatusInternalServerError)
	}
}

func (u *UserService) DeleteUser(w nethttp.ResponseWriter, r *nethttp.Request) {
	userID := requestUserID(r)
	id := r.URL.Query().Get("id")
	if id == "" {
		nethttp.Error(w, `{"error":"missing id query parameter"}`, nethttp.StatusBadRequest)
		return
	}

	err := u.storage.DeleteUser(r.Context(), userID, id)
	if errors.Is(err, ErrUserNotFound) {
		nethttp.Error(w, `{"error":"user not found"}`, nethttp.StatusNotFound)
		return
	} else if err != nil {
		nethttp.Error(w, `{"error":"`+err.Error()+`"}`, nethttp.StatusInternalServerError)
		return
	}
	w.WriteHeader(nethttp.StatusNoContent)
}
