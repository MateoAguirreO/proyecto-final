package com.gateway.genosentinel.service;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

import java.util.Map;

/**
 * Servicio de Gateway para enrutar peticiones a los microservicios
 */
@Service
@RequiredArgsConstructor
public class GatewayService {

    private final WebClient.Builder webClientBuilder;

    /**
     * Proxy genérico para enrutar peticiones
     */
    public ResponseEntity<String> proxyRequest(
            String targetUrl,
            HttpMethod method,
            String authToken,
            Object body) {
        try {
            WebClient webClient = webClientBuilder.build();

            // Construir la petición
            WebClient.RequestBodySpec request = webClient
                    .method(method)
                    .uri(targetUrl)
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE);

            // Agregar token de autenticación si existe
            if (authToken != null && !authToken.isEmpty()) {
                request.header(HttpHeaders.AUTHORIZATION, authToken);
            }

            // Ejecutar petición con o sin body
            Mono<String> responseMono;
            if (body != null && (method == HttpMethod.POST || method == HttpMethod.PUT || method == HttpMethod.PATCH)) {
                responseMono = request
                        .bodyValue(body)
                        .retrieve()
                        .bodyToMono(String.class);
            } else {
                responseMono = request
                        .retrieve()
                        .bodyToMono(String.class);
            }

            // Obtener respuesta
            String responseBody = responseMono.block();
            return ResponseEntity.ok(responseBody);

        } catch (WebClientResponseException e) {
            // Reenviar el error del microservicio
            return ResponseEntity
                    .status(e.getStatusCode())
                    .body(e.getResponseBodyAsString());
        } catch (Exception e) {
            // Error general
            return ResponseEntity
                    .status(500)
                    .body("{\"error\": \"Error en Gateway\", \"message\": \"" + e.getMessage() + "\"}");
        }
    }

    /**
     * Proxy para peticiones GET
     */
    public ResponseEntity<String> get(String targetUrl, String authToken) {
        return proxyRequest(targetUrl, HttpMethod.GET, authToken, null);
    }

    /**
     * Proxy para peticiones POST
     */
    public ResponseEntity<String> post(String targetUrl, String authToken, Object body) {
        return proxyRequest(targetUrl, HttpMethod.POST, authToken, body);
    }

    /**
     * Proxy para peticiones PUT
     */
    public ResponseEntity<String> put(String targetUrl, String authToken, Object body) {
        return proxyRequest(targetUrl, HttpMethod.PUT, authToken, body);
    }

    /**
     * Proxy para peticiones PATCH
     */
    public ResponseEntity<String> patch(String targetUrl, String authToken, Object body) {
        return proxyRequest(targetUrl, HttpMethod.PATCH, authToken, body);
    }

    /**
     * Proxy para peticiones DELETE
     */
    public ResponseEntity<String> delete(String targetUrl, String authToken) {
        return proxyRequest(targetUrl, HttpMethod.DELETE, authToken, null);
    }
}
