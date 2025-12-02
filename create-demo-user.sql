-- Crear usuario de prueba con password plano "demo123"
-- Hash BCrypt generado: $2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN96DPa4XHW3k3/cYw5Oy (password: demo123)
INSERT INTO users (username, password, full_name, email, role, enabled, created_at, updated_at)
VALUES ('demo', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN96DPa4XHW3k3/cYw5Oy', 'Usuario Demo', 'demo@test.com', 'USER', 1, NOW(), NOW());

SELECT username, email, role, enabled FROM users WHERE username = 'demo';
