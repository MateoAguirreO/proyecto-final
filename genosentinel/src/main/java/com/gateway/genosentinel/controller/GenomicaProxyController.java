package com.gateway.genosentinel.controller;

import com.gateway.genosentinel.service.GatewayProxyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador para hacer proxy de peticiones al microservicio de Genomica
 */
@RestController
@RequestMapping("/api/genomica")
@RequiredArgsConstructor
@Slf4j
public class GenomicaProxyController {

    private final GatewayProxyService gatewayProxyService;

    /**
     * Proxy GET a cualquier endpoint de Genomica
     */
    @GetMapping(value = "/**")
    public ResponseEntity<String> proxyGetToGenomica() {
        // Usar Spring para obtener el path original de la petición
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            // Remove /api/genomica/ prefix and keep the rest (e.g., v1/genes/)
            String path = requestUri.replaceFirst("^/api/genomica/?", "");
            log.debug("Proxying GET to Genomica: /api/{}", path);
            // Genomica expects /api/v1/... so we prepend /api/
            return gatewayProxyService.proxyToGenomicaWithHeaders("/api/" + path);
        }

        return ResponseEntity.ok("{}");
    }

    /**
     * Proxy POST a cualquier endpoint de Genomica
     */
    @PostMapping(value = "/**")
    public ResponseEntity<String> proxyPostToGenomica(@RequestBody String body) {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            // Remove /api/genomica/ prefix and keep the rest (e.g., v1/genes/)
            String path = requestUri.replaceFirst("^/api/genomica/?", "");
            log.debug("Proxying POST to Genomica: /api/{}", path);
            // Genomica expects /api/v1/... so we prepend /api/
            // For now return the old method, but should create
            // proxyToGenomicaPostWithHeaders
            return ResponseEntity.ok(gatewayProxyService.proxyToGenomicaPost("/api/" + path, body));
        }

        return ResponseEntity.ok("{}");
    }
}
