package com.gateway.genosentinel.repository;

import com.gateway.genosentinel.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio para la entidad User
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Buscar usuario por username
     * 
     * @param username nombre de usuario
     * @return Optional con el usuario si existe
     */
    Optional<User> findByUsername(String username);

    /**
     * Buscar usuario por email
     * 
     * @param email correo electrónico
     * @return Optional con el usuario si existe
     */
    Optional<User> findByEmail(String email);

    /**
     * Verificar si existe un username
     * 
     * @param username nombre de usuario
     * @return true si existe
     */
    boolean existsByUsername(String username);

    /**
     * Verificar si existe un email
     * 
     * @param email correo electrónico
     * @return true si existe
     */
    boolean existsByEmail(String email);
}
