package com.gateway.genosentinel.controller;

import com.gateway.genosentinel.service.GatewayProxyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
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
    @GetMapping(value = "/**", produces = MediaType.APPLICATION_JSON_VALUE)
    public String proxyGetToClinica() {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/clinica/?", "");
            log.debug("Proxying GET to Clinica: /api/{}", path);
            return gatewayProxyService.proxyToClinica("/api/" + path);
        }

        return "{}";
    }

    /**
     * Proxy POST a cualquier endpoint de Clinica
     */
    @PostMapping(value = "/**", produces = MediaType.APPLICATION_JSON_VALUE)
    public String proxyPostToClinica(@RequestBody String body) {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/clinica/?", "");
            log.debug("Proxying POST to Clinica: /api/{}", path);
            return gatewayProxyService.proxyToClinicaPost("/api/" + path, body);
        }

        return "{}";
    }

    /**
     * Proxy PATCH a cualquier endpoint de Clinica
     */
    @PatchMapping(value = "/**", produces = MediaType.APPLICATION_JSON_VALUE)
    public String proxyPatchToClinica(@RequestBody String body) {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/clinica/?", "");
            log.debug("Proxying PATCH to Clinica: /api/{}", path);
            return gatewayProxyService.proxyToClinicaPatch("/api/" + path, body);
        }

        return "{}";
    }

    /**
     * Proxy DELETE a cualquier endpoint de Clinica
     */
    @DeleteMapping(value = "/**", produces = MediaType.APPLICATION_JSON_VALUE)
    public String proxyDeleteToClinica() {
        org.springframework.web.context.request.ServletRequestAttributes attrs = (org.springframework.web.context.request.ServletRequestAttributes) org.springframework.web.context.request.RequestContextHolder
                .getRequestAttributes();

        if (attrs != null) {
            String requestUri = attrs.getRequest().getRequestURI();
            String path = requestUri.replaceFirst("^/api/clinica/?", "");
            log.debug("Proxying DELETE to Clinica: /api/{}", path);
            return gatewayProxyService.proxyToClinicaDelete("/api/" + path);
        }

        return "{}";
    }
}
