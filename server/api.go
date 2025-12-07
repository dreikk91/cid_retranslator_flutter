package server

import (
	"cid_retranslator_walk/cidparser"
	"cid_retranslator_walk/client"
	"cid_retranslator_walk/config"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
)

// DataProvider interface для отримання даних від retranslator
// Це дозволяє уникнути циклічної залежності core ← → server
type DataProvider interface {
	GetInitialDevices() []Device
	GetInitialEvents() []GlobalEvent
	GetDeviceEvents(deviceID int) []Event
	GetClient() *client.Client
}

// APIServer представляє HTTP API сервер
type APIServer struct {
	router       *mux.Router
	dataProvider DataProvider
	eventMap     cidparser.EventMap // Map, not pointer
	config       *config.Config
	wsClients    map[*websocket.Conn]bool
	wsUpgrader   websocket.Upgrader
}

// NewAPIServer створює новий API сервер
func NewAPIServer(dataProvider DataProvider, eventMap cidparser.EventMap, cfg *config.Config) *APIServer {
	s := &APIServer{
		router:       mux.NewRouter(),
		dataProvider: dataProvider,
		eventMap:     eventMap,
		config:       cfg,
		wsClients:    make(map[*websocket.Conn]bool),
		wsUpgrader: websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool {
				return true // Дозволяємо всі origins для development
			},
		},
	}

	s.setupRoutes()
	return s
}

// setupRoutes налаштовує маршрути API
func (s *APIServer) setupRoutes() {
	// Додаємо CORS middleware
	s.router.Use(corsMiddleware)

	// API routes
	api := s.router.PathPrefix("/api").Subrouter()
	api.HandleFunc("/ppk", s.handleGetPPKList).Methods("GET", "OPTIONS")
	api.HandleFunc("/ppk/{id}/events", s.handleGetPPKEvents).Methods("GET", "OPTIONS")
	api.HandleFunc("/events", s.handleGetEvents).Methods("GET", "OPTIONS")
	api.HandleFunc("/stats", s.handleGetStats).Methods("GET", "OPTIONS")
	api.HandleFunc("/config", s.handleGetConfig).Methods("GET", "OPTIONS")
	api.HandleFunc("/config", s.handleUpdateConfig).Methods("PUT", "OPTIONS")

	// WebSocket endpoint
	s.router.HandleFunc("/ws", s.handleWebSocket)
}

// corsMiddleware додає CORS заголовки
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// handleGetPPKList повертає список всіх ППК
func (s *APIServer) handleGetPPKList(w http.ResponseWriter, r *http.Request) {
	devices := s.dataProvider.GetInitialDevices()

	type PPKResponse struct {
		Number int       `json:"number"`
		Name   string    `json:"name"`
		Event  string    `json:"event"`
		Date   time.Time `json:"date"`
		Status string    `json:"status"`
	}

	response := make([]PPKResponse, 0, len(devices))
	for _, dev := range devices {
		response = append(response, PPKResponse{
			Number: dev.ID,
			Name:   fmt.Sprintf("%d", dev.ID), // Device ID as name
			Event:  dev.LastEvent,
			Date:   dev.LastEventTime,
			Status: "Активний", // Можна додати логіку для визначення статусу
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// handleGetPPKEvents повертає події для конкретного ППК
func (s *APIServer) handleGetPPKEvents(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	deviceID, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid device ID", http.StatusBadRequest)
		return
	}

	events := s.dataProvider.GetDeviceEvents(deviceID)

	type EventResponse struct {
		Time     time.Time `json:"time"`
		Device   string    `json:"device"`
		Code     string    `json:"code"`
		Type     string    `json:"type"`
		Desc     string    `json:"desc"`
		Zone     string    `json:"zone"`
		Priority int       `json:"priority"`
	}

	response := make([]EventResponse, 0, len(events))
	for _, ev := range events {
		if len(ev.Data) < 20 {
			continue
		}

		devID := ev.Data[7:11]
		code := ev.Data[11:15]
		group := ev.Data[15:17]
		zone := ev.Data[17:20]

		eventType, desc, found := s.eventMap.GetEventDescriptions(code)
		if !found {
			continue
		}

		priority := determineEventPriority(code)

		response = append(response, EventResponse{
			Time:     ev.Time,
			Device:   devID,
			Code:     code,
			Type:     eventType,
			Desc:     desc,
			Zone:     fmt.Sprintf("Зона %s|Група %s", zone, group),
			Priority: priority,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// handleGetEvents повертає останні події
func (s *APIServer) handleGetEvents(w http.ResponseWriter, r *http.Request) {
	events := s.dataProvider.GetInitialEvents()

	type EventResponse struct {
		ID       int64     `json:"id"`
		Time     time.Time `json:"time"`
		Device   string    `json:"device"`
		Code     string    `json:"code"`
		Type     string    `json:"type"`
		Desc     string    `json:"desc"`
		Zone     string    `json:"zone"`
		Priority int       `json:"priority"`
	}

	response := make([]EventResponse, 0, len(events))
	for i, ev := range events {
		if len(ev.Data) < 20 {
			continue
		}

		devID := ev.Data[7:11]
		code := ev.Data[11:15]
		group := ev.Data[15:17]
		zone := ev.Data[17:20]

		eventType, desc, found := s.eventMap.GetEventDescriptions(code)
		if !found {
			continue
		}

		priority := determineEventPriority(code)

		response = append(response, EventResponse{
			ID:       int64(i),
			Time:     ev.Time,
			Device:   devID,
			Code:     code,
			Type:     eventType,
			Desc:     desc,
			Zone:     fmt.Sprintf("Зона %s|Група %s", zone, group),
			Priority: priority,
		})
	}

	// Обмежуємо до 500 останніх подій
	if len(response) > 500 {
		response = response[len(response)-500:]
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// handleGetStats повертає поточну статистику
func (s *APIServer) handleGetStats(w http.ResponseWriter, r *http.Request) {
	statsChan := s.dataProvider.GetClient().GetQueueStats()

	select {
	case stats := <-statsChan:
		type StatsResponse struct {
			Connected  bool   `json:"connected"`
			Accepted   int64  `json:"accepted"`
			Rejected   int64  `json:"rejected"`
			Reconnects int64  `json:"reconnects"`
			Uptime     string `json:"uptime"`
		}

		response := StatsResponse{
			Connected:  stats.Connected,
			Accepted:   stats.Accepted,
			Rejected:   stats.Rejected,
			Reconnects: stats.Reconnects,
			Uptime:     stats.UptimeString(),
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)

	case <-time.After(500 * time.Millisecond):
		http.Error(w, "Stats timeout", http.StatusRequestTimeout)
	}
}

// handleGetConfig повертає поточну конфігурацію
func (s *APIServer) handleGetConfig(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(s.config)
}

// handleUpdateConfig оновлює конфігурацію
func (s *APIServer) handleUpdateConfig(w http.ResponseWriter, r *http.Request) {
	var newConfig config.Config
	if err := json.NewDecoder(r.Body).Decode(&newConfig); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Зберігаємо конфігурацію
	if err := newConfig.Save("config.yaml"); err != nil {
		http.Error(w, fmt.Sprintf("Failed to save config: %v", err), http.StatusInternalServerError)
		return
	}

	// Оновлюємо поточну конфігурацію
	*s.config = newConfig

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Configuration updated successfully",
	})
}

// handleWebSocket обробляє WebSocket підключення
func (s *APIServer) handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := s.wsUpgrader.Upgrade(w, r, nil)
	if err != nil {
		slog.Error("WebSocket upgrade failed", "error", err)
		return
	}

	s.wsClients[conn] = true
	slog.Info("WebSocket client connected", "remoteAddr", conn.RemoteAddr())

	go s.handleWSClient(conn)
}

// handleWSClient обробляє WebSocket клієнта
func (s *APIServer) handleWSClient(conn *websocket.Conn) {
	defer func() {
		delete(s.wsClients, conn)
		conn.Close()
		slog.Info("WebSocket client disconnected")
	}()

	// Просто чекаємо на закриття підключення
	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			break
		}
	}
}

// Start запускає HTTP сервер
func (s *APIServer) Start(addr string) error {
	slog.Info("Starting HTTP API server", "address", addr)
	return http.ListenAndServe(addr, s.router)
}

// BroadcastPPKUpdate надсилає оновлення ППК всім WebSocket клієнтам
func (s *APIServer) BroadcastPPKUpdate(data interface{}) {
	message := map[string]interface{}{
		"type": "ppk_update",
		"data": data,
	}

	s.broadcastToClients(message)
}

// BroadcastEventUpdate надсилає оновлення події всім WebSocket клієнтам
func (s *APIServer) BroadcastEventUpdate(data interface{}) {
	message := map[string]interface{}{
		"type": "event_update",
		"data": data,
	}

	s.broadcastToClients(message)
}

// BroadcastStatsUpdate надсилає оновлення статистики всім WebSocket клієнтам
func (s *APIServer) BroadcastStatsUpdate(data interface{}) {
	message := map[string]interface{}{
		"type": "stats_update",
		"data": data,
	}

	s.broadcastToClients(message)
}

// broadcastToClients надсилає повідомлення всім підключеним WebSocket клієнтам
func (s *APIServer) broadcastToClients(message interface{}) {
	for client := range s.wsClients {
		err := client.WriteJSON(message)
		if err != nil {
			slog.Error("Failed to send WebSocket message", "error", err)
			client.Close()
			delete(s.wsClients, client)
		}
	}
}

// determineEventPriority визначає пріоритет події на основі коду
func determineEventPriority(code string) int {
	if len(code) < 2 {
		return 0 // Unknown
	}
	switch code[:2] {
	case "E4": return 1  // Guard
	case "E3": return 2  // Disguard
	case "E1", "R1": return 3  // OK
	case "E6": return 4  // Alarm
	default: return 5  // Other
	}
}
