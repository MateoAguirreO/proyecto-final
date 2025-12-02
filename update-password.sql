-- Actualizar password del usuario admin
-- Password: "admin123" hasheado con BCrypt
UPDATE users SET password = '$2a$10$DowJonesE8P4g4fKBKvAzIufHnFKXthUs3yRiZxaXBIY2yN7jEJZ6G' WHERE username = 'admin';
SELECT username, 'Password actualizado' as status FROM users WHERE username = 'admin';
