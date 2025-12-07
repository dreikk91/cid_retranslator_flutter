package main

import (
	"cid_retranslator_walk/cidparser"
	"cid_retranslator_walk/config"
	"cid_retranslator_walk/core"
	"cid_retranslator_walk/metrics"
	"cid_retranslator_walk/server"
	"context"
	"fmt"
	"log"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	const eventFilePath = "events.json"
	jsonData, err := os.ReadFile(eventFilePath)
	if err != nil {
		log.Fatalf("Failed to load %s: %v", eventFilePath, err)
	}

	eventMap, err := cidparser.LoadEvents(jsonData)
	if err != nil {
		log.Fatal(err)
	}

	// Завантажуємо конфігурацію
	cfg := config.New()

	// Ініціалізація Core (TCP сервер/клієнт)
	stats := metrics.New()
	retranslator := core.NewApp(stats)

	// Запускаємо TCP сервер/клієнт в окремій горутині
	go func() {
		slog.Info("Starting TCP retranslator...")
		retranslator.Startup()
	}()

	// Створюємо контекст для graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Запускаємо HTTP API сервер (якщо увімкнено)
	var apiServer *server.APIServer
	if cfg.HTTP.Enabled {
		apiServer = server.NewAPIServer(retranslator, eventMap, cfg)
		go func() {
			addr := fmt.Sprintf("%s:%s", cfg.HTTP.Host, cfg.HTTP.Port)
			slog.Info("Starting HTTP API server", "address", addr)
			if err := apiServer.Start(addr); err != nil {
				slog.Error("HTTP API server failed", "error", err)
			}
		}()

		// Горутина для broadcasting updates через WebSocket
		go func() {
			deviceChan := retranslator.GetDeviceUpdates()
			eventChan := retranslator.GetEventUpdates()

			for {
				select {
				case <-ctx.Done():
					return
				case device := <-deviceChan:
					// Broadcast device update to all WebSocket clients
					apiServer.BroadcastPPKUpdate(map[string]interface{}{
						"number": device.ID,
						"name":   fmt.Sprintf("%d", device.ID),
						"event":  device.LastEvent,
						"date":   device.LastEventTime,
					})
				case event := <-eventChan:
					// Broadcast event update to all WebSocket clients
					if len(event.Data) >= 20 {
						code := event.Data[11:15]
						eventType, desc, found := eventMap.GetEventDescriptions(code)
						if found {
							group := event.Data[15:17]
							zone := event.Data[17:20]

							apiServer.BroadcastEventUpdate(map[string]interface{}{
								"time":     event.Time,
								"device":   event.Data[7:11],
								"code":     code,
								"type":     eventType,
								"desc":     desc,
								"zone":     fmt.Sprintf("Зона %s|Група %s", zone, group),
								"priority": determineEventPriority(code),
							})
						}
					}
				}
			}
		}()
	}

	// Горутина для оновлення статистики (якщо потрібно)
	go func() {
		ticker := time.NewTicker(1 * time.Second)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				// Тут можна додати логіку оновлення статистики якщо потрібно
			}
		}
	}()

	// Очікуємо сигнал завершення
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	slog.Info("Server is running. Press Ctrl+C to stop.")
	<-sigChan

	// Graceful shutdown
	slog.Info("Shutting down...")
	retranslator.Shutdown(retranslator.Ctx())

	slog.Info("Server stopped")
}

// determineEventPriority визначає пріоритет події
func determineEventPriority(code string) int {
	if len(code) < 2 {
		return 0
	}
	switch code[:2] {
	case "E4":
		return 1 // Guard
	case "E3":
		return 2 // Disguard
	case "E1", "R1":
		return 3 // OK
	case "E6":
		return 4 // Alarm
	default:
		return 5 // Other
	}
}
