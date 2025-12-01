package com.gateway.genosentinel.controller;

import com.gateway.genosentinel.dto.HealthResponse;
import com.gateway.genosentinel.service.HealthCheckService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Controlador para endpoints de monitoreo
 */
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class HealthController {

    private final HealthCheckService healthCheckService;

    /**
     * Health check completo del sistema
     */
    @GetMapping("/health")
    public ResponseEntity<HealthResponse> health() {
        HealthResponse health = healthCheckService.checkHealth();
        return ResponseEntity.ok(health);
    }

    /**
     * Endpoint simple de status
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> status() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "GenoSentinel Gateway",
                "timestamp", LocalDateTime.now(),
                "message", "Gateway is running"));
    }

    /**
     * Endpoint de información del servicio
     */
    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> info() {
        return ResponseEntity.ok(Map.of(
                "service", "GenoSentinel Gateway",
                "version", "1.0.0",
                "description", "API Gateway con autenticación JWT",
                "features", new String[] {
                        "JWT Authentication",
                        "Request Routing",
                        "Health Monitoring"
                }));
    }
}
