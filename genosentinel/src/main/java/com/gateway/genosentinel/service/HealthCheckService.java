package com.gateway.genosentinel.service;

import com.gateway.genosentinel.dto.HealthResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.LocalDateTime;

/**
 * Servicio para monitoreo de salud del sistema
 */
@Service
@RequiredArgsConstructor
public class HealthCheckService {

    private final DataSource dataSource;
    private final WebClient.Builder webClientBuilder;

    @Value("${microservices.clinica.url}")
    private String clinicaUrl;

    @Value("${microservices.genomica.url}")
    private String genomicaUrl;

    @Value("${spring.application.name}")
    private String serviceName;

    /**
     * Verificar salud completa del sistema
     */
    public HealthResponse checkHealth() {
        return HealthResponse.builder()
                .status("UP")
                .timestamp(LocalDateTime.now())
                .service(serviceName)
                .version("1.0.0")
                .database(checkDatabase())
                .microservices(checkMicroservices())
                .build();
    }

    /**
     * Verificar conexión a base de datos
     */
    private HealthResponse.DatabaseStatus checkDatabase() {
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(1)) {
                return HealthResponse.DatabaseStatus.builder()
                        .status("UP")
                        .message("Database connection is healthy")
                        .build();
            }
        } catch (Exception e) {
            return HealthResponse.DatabaseStatus.builder()
                    .status("DOWN")
                    .message("Database connection failed: " + e.getMessage())
                    .build();
        }

        return HealthResponse.DatabaseStatus.builder()
                .status("DOWN")
                .message("Database connection is not valid")
                .build();
    }

    /**
     * Verificar estado de microservicios
     */
    private HealthResponse.MicroservicesStatus checkMicroservices() {
        return HealthResponse.MicroservicesStatus.builder()
                .clinica(checkService(clinicaUrl + "/health"))
                .genomica(checkService(genomicaUrl + "/api/v1/"))
                .build();
    }

    /**
     * Verificar estado de un microservicio específico
     */
    private HealthResponse.ServiceStatus checkService(String url) {
        try {
            long startTime = System.currentTimeMillis();

            WebClient webClient = webClientBuilder.build();
            String response = webClient.get()
                    .uri(url)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            long responseTime = System.currentTimeMillis() - startTime;

            return HealthResponse.ServiceStatus.builder()
                    .status("UP")
                    .url(url)
                    .responseTime(responseTime)
                    .build();
        } catch (Exception e) {
            return HealthResponse.ServiceStatus.builder()
                    .status("DOWN")
                    .url(url)
                    .responseTime(null)
                    .build();
        }
    }
}
