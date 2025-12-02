package com.gateway.genosentinel.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

/**
 * Servicio para hacer proxy de peticiones a los microservicios
 */
@Service
@Slf4j
public class GatewayProxyService {

    private final RestTemplate restTemplate;
    private final String genomicaUrl;
    private final String clinicaUrl;

    public GatewayProxyService(
            @Value("${microservices.genomica.url}") String genomicaUrl,
            @Value("${microservices.clinica.url}") String clinicaUrl,
            RestTemplate restTemplate) {

        this.restTemplate = restTemplate;
        this.genomicaUrl = genomicaUrl;
        this.clinicaUrl = clinicaUrl;

        log.info("GatewayProxyService initialized with Genomica URL: {}", genomicaUrl);
        log.info("GatewayProxyService initialized with Clinica URL: {}", clinicaUrl);
    }

    /**
     * Hace proxy de una petición GET al microservicio de Genomica
     */
    public String proxyToGenomica(String path) {
        String fullUrl = genomicaUrl + path;
        log.info("Proxying GET request to Genomica: {} -> Full URL: {}", path, fullUrl);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    fullUrl,
                    HttpMethod.GET,
                    null,
                    String.class);
            log.info("Successfully proxied to Genomica. Status: {}", response.getStatusCode());
            return response.getBody();
        } catch (Exception e) {
            log.error("Error proxying to Genomica: {}", e.getMessage(), e);
            throw new RuntimeException("Error connecting to Genomica service: " + e.getMessage(), e);
        }
    }

    /**
     * Hace proxy de una petición GET al microservicio de Genomica retornando
     * ResponseEntity completo con headers preservados
     */
    public ResponseEntity<String> proxyToGenomicaWithHeaders(String path) {
        String fullUrl = genomicaUrl + path;
        log.info("Proxying GET request to Genomica: {} -> Full URL: {}", path, fullUrl);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    fullUrl,
                    HttpMethod.GET,
                    null,
                    String.class);

            log.info("Successfully proxied to Genomica. Status: {}, Content-Type: {}",
                    response.getStatusCode(),
                    response.getHeaders().getContentType());

            // Copiar explícitamente todos los headers de la respuesta
            HttpHeaders headers = new HttpHeaders();
            headers.putAll(response.getHeaders());

            // Crear nueva ResponseEntity con los headers copiados
            return ResponseEntity
                    .status(response.getStatusCode())
                    .headers(headers)
                    .body(response.getBody());
        } catch (Exception e) {
            log.error("Error proxying to Genomica: {}", e.getMessage(), e);
            throw new RuntimeException("Error connecting to Genomica service: " + e.getMessage(), e);
        }
    }

    /**
     * Hace proxy de una petición POST al microservicio de Genomica
     */
    public String proxyToGenomicaPost(String path, String body) {
        String fullUrl = genomicaUrl + path;
        log.info("Proxying POST request to Genomica: {} -> Full URL: {}", path, fullUrl);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set(HttpHeaders.CONTENT_TYPE, "application/json");
            HttpEntity<String> entity = new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.exchange(
                    fullUrl,
                    HttpMethod.POST,
                    entity,
                    String.class);
            log.info("Successfully proxied POST to Genomica. Status: {}", response.getStatusCode());
            return response.getBody();
        } catch (Exception e) {
            log.error("Error proxying POST to Genomica: {}", e.getMessage(), e);
            throw new RuntimeException("Error connecting to Genomica service: " + e.getMessage(), e);
        }
    }

    /**
     * Hace proxy de una petición GET al microservicio de Clínica
     */
    public String proxyToClinica(String path) {
        String fullUrl = clinicaUrl + path;
        log.info("Proxying GET request to Clinica: {} -> Full URL: {}", path, fullUrl);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    fullUrl,
                    HttpMethod.GET,
                    null,
                    String.class);
            log.info("Successfully proxied to Clinica. Status: {}", response.getStatusCode());
            return response.getBody();
        } catch (Exception e) {
            log.error("Error proxying to Clinica: {}", e.getMessage(), e);
            throw new RuntimeException("Error connecting to Clinica service: " + e.getMessage(), e);
        }
    }

    /**
     * Hace proxy de una petición POST al microservicio de Clínica
     */
    public String proxyToClinicaPost(String path, String body) {
        String fullUrl = clinicaUrl + path;
        log.info("Proxying POST request to Clinica: {} -> Full URL: {}", path, fullUrl);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set(HttpHeaders.CONTENT_TYPE, "application/json");
            HttpEntity<String> entity = new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.exchange(
                    fullUrl,
                    HttpMethod.POST,
                    entity,
                    String.class);
            log.info("Successfully proxied POST to Clinica. Status: {}", response.getStatusCode());
            return response.getBody();
        } catch (Exception e) {
            log.error("Error proxying POST to Clinica: {}", e.getMessage(), e);
            throw new RuntimeException("Error connecting to Clinica service: " + e.getMessage(), e);
        }
    }

    /**
     * Hace proxy de una petición PATCH al microservicio de Clínica
     */
    public String proxyToClinicaPatch(String path, String body) {
        String fullUrl = clinicaUrl + path;
        log.info("Proxying PATCH request to Clinica: {} -> Full URL: {}", path, fullUrl);

        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set(HttpHeaders.CONTENT_TYPE, "application/json");
            HttpEntity<String> entity = new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.exchange(
                    fullUrl,
                    HttpMethod.PATCH,
                    entity,
                    String.class);
            log.info("Successfully proxied PATCH to Clinica. Status: {}", response.getStatusCode());
            return response.getBody();
        } catch (Exception e) {
            log.error("Error proxying PATCH to Clinica: {}", e.getMessage(), e);
            throw new RuntimeException("Error connecting to Clinica service: " + e.getMessage(), e);
        }
    }

    /**
     * Hace proxy de una petición DELETE al microservicio de Clínica
     */
    public String proxyToClinicaDelete(String path) {
        String fullUrl = clinicaUrl + path;
        log.info("Proxying DELETE request to Clinica: {} -> Full URL: {}", path, fullUrl);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    fullUrl,
                    HttpMethod.DELETE,
                    null,
                    String.class);
            log.info("Successfully proxied DELETE to Clinica. Status: {}", response.getStatusCode());
            return response.getBody();
        } catch (Exception e) {
            log.error("Error proxying DELETE to Clinica: {}", e.getMessage(), e);
            throw new RuntimeException("Error connecting to Clinica service: " + e.getMessage(), e);
        }
    }
}
