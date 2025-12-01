package com.gateway.genosentinel.controller;

import com.gateway.genosentinel.service.GatewayService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Controlador del Gateway para enrutar peticiones a microservicios
 */
@RestController
@RequestMapping("/api/gateway")
@RequiredArgsConstructor
public class GatewayController {

    private final GatewayService gatewayService;

    @Value("${microservices.clinica.url}")
    private String clinicaUrl;

    @Value("${microservices.genomica.url}")
    private String genomicaUrl;

    /**
     * Proxy genérico para Microservicio de Clínica
     */
    @RequestMapping(value = "/clinica/**", method = { RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT,
            RequestMethod.PATCH, RequestMethod.DELETE })
    public ResponseEntity<String> proxyClinica(
            HttpServletRequest request,
            @RequestHeader(value = "Authorization", required = false) String authToken,
            @RequestBody(required = false) Map<String, Object> body) {
        String path = request.getRequestURI().replace("/api/gateway/clinica", "");
        String queryString = request.getQueryString();
        String targetUrl = clinicaUrl + path + (queryString != null ? "?" + queryString : "");

        HttpMethod method = HttpMethod.valueOf(request.getMethod());
        return gatewayService.proxyRequest(targetUrl, method, authToken, body);
    }

    /**
     * Proxy genérico para Microservicio de Genómica
     */
    @RequestMapping(value = "/genomica/**", method = { RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT,
            RequestMethod.PATCH, RequestMethod.DELETE })
    public ResponseEntity<String> proxyGenomica(
            HttpServletRequest request,
            @RequestHeader(value = "Authorization", required = false) String authToken,
            @RequestBody(required = false) Map<String, Object> body) {
        String path = request.getRequestURI().replace("/api/gateway/genomica", "");
        String queryString = request.getQueryString();
        String targetUrl = genomicaUrl + path + (queryString != null ? "?" + queryString : "");

        HttpMethod method = HttpMethod.valueOf(request.getMethod());
        return gatewayService.proxyRequest(targetUrl, method, authToken, body);
    }
}
