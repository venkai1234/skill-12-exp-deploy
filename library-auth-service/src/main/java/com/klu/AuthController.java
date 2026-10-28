package com.klu;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final SecretKey key;

    public AuthController(@Value("${jwt.secret}") String secret) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody LoginRequest request) {
        // Demo-only credentials. Replace with a database-backed user store and password hashing.
        if (!"admin".equals(request.username()) || !"admin123".equals(request.password())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid username or password");
        }
        long now = System.currentTimeMillis();
        long expiryMs = 60 * 60 * 1000L;
        String token = Jwts.builder()
                .subject(request.username())
                .issuedAt(new Date(now))
                .expiration(new Date(now + expiryMs))
                .signWith(key)
                .compact();
        return Map.of("token", token, "tokenType", "Bearer",
                "username", request.username(), "expiresInSeconds", 3600);
    }

    public record LoginRequest(String username, String password) {}
}
