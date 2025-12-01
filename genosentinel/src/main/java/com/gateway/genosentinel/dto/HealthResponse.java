package com.gateway.genosentinel.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO para el health check del sistema
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class HealthResponse {

    private String status;
    private LocalDateTime timestamp;
    private String service;
    private String version;
    private DatabaseStatus database;
    private MicroservicesStatus microservices;

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class DatabaseStatus {
        private String status;
        private String message;
    }

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class MicroservicesStatus {
        private ServiceStatus clinica;
        private ServiceStatus genomica;
    }

    @Data
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class ServiceStatus {
        private String status;
        private String url;
        private Long responseTime;
    }
}
