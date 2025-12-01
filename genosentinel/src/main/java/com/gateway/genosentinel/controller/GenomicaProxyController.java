package com.gateway.genosentinel.controller;

import com.gateway.genosentinel.service.GatewayProxyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
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
    @GetMapping(value = "/**", produces = MediaType.APPLICATION_JSON_VALUE)
    public String proxyGetToGenomica() {
        // Usar Spring para obtener el path original de la petición
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/genomica/?", "");
            log.debug("Proxying GET to Genomica: /api/v1/{}", path);
            return gatewayProxyService.proxyToGenomica("/api/v1/" + path);
        }

        return "{}";
    }

    /**
     * Proxy POST a cualquier endpoint de Genomica
     */
    @PostMapping(value = "/**", produces = MediaType.APPLICATION_JSON_VALUE)
    public String proxyPostToGenomica(@RequestBody String body) {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/genomica/?", "");
            log.debug("Proxying POST to Genomica: /api/v1/{}", path);
            return gatewayProxyService.proxyToGenomicaPost("/api/v1/" + path, body);
        }

        return "{}";
    }
}
