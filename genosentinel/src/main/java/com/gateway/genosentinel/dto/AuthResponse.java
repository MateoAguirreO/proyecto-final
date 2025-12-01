package com.gateway.genosentinel.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para respuesta de autenticación
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponse {

    private String token;
    @Builder.Default
    private String type = "Bearer";
    private String username;
    private String fullName;
    private String email;
    private String role;
    private Long expiresIn;

    public AuthResponse(String token, String username, String fullName, String email, String role, Long expiresIn) {
        this.token = token;
        this.username = username;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
        this.expiresIn = expiresIn;
    }
}
