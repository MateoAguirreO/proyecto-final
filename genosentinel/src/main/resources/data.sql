-- Script de inicialización de datos de prueba

-- Crear usuario de prueba
-- Password: password123 (encriptado con BCrypt)
INSERT IGNORE INTO users (username, password, full_name, email, role, enabled, created_at, updated_at)
VALUES ('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Administrador', 'admin@genosentinel.com', 'USER', true, NOW(), NOW());

INSERT IGNORE INTO users (username, password, full_name, email, role, enabled, created_at, updated_at)
VALUES ('doctor', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Dr. Juan Pérez', 'doctor@genosentinel.com', 'USER', true, NOW(), NOW());
