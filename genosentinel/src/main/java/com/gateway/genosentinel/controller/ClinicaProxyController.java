package com.gateway.genosentinel.controller;

import com.gateway.genosentinel.service.GatewayProxyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador para hacer proxy de peticiones al microservicio de Clinica
 */
@RestController
@RequestMapping("/api/clinica")
@RequiredArgsConstructor
@Slf4j
public class ClinicaProxyController {

    private final GatewayProxyService gatewayProxyService;

    /**
     * Proxy GET a cualquier endpoint de Clinica
     */
    @GetMapping(value = "/**")
    public ResponseEntity<String> proxyGetToClinica() {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/clinica/?", "");
            log.debug("Proxying GET to Clinica: /api/{}", path);
            return gatewayProxyService.proxyToClinicaWithHeaders("/api/" + path);
        }

        return ResponseEntity.ok("{}");
    }

    /**
     * Proxy POST a cualquier endpoint de Clinica
     */
    @PostMapping(value = "/**")
    public ResponseEntity<String> proxyPostToClinica(@RequestBody String body) {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/clinica/?", "");
            log.debug("Proxying POST to Clinica: /api/{}", path);
            return ResponseEntity.ok(gatewayProxyService.proxyToClinicaPost("/api/" + path, body));
        }

        return ResponseEntity.ok("{}");
    }

    /**
     * Proxy PATCH a cualquier endpoint de Clinica
     */
    @PatchMapping(value = "/**")
    public ResponseEntity<String> proxyPatchToClinica(@RequestBody String body) {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/clinica/?", "");
            log.debug("Proxying PATCH to Clinica: /api/{}", path);
            return ResponseEntity.ok(gatewayProxyService.proxyToClinicaPatch("/api/" + path, body));
        }

        return ResponseEntity.ok("{}");
    }

    /**
     * Proxy DELETE a cualquier endpoint de Clinica
     */
    @DeleteMapping(value = "/**")
    public ResponseEntity<String> proxyDeleteToClinica() {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/clinica/?", "");
            log.debug("Proxying DELETE to Clinica: /api/{}", path);
            return ResponseEntity.ok(gatewayProxyService.proxyToClinicaDelete("/api/" + path));
        }

        return ResponseEntity.ok("{}");
    }
}
