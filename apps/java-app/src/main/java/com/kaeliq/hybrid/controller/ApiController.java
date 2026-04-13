package com.kaeliq.hybrid.controller;

import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ApiController {

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP", "service", "java-app");
    }

    @GetMapping("/info")
    public Map<String, String> info() {
        return Map.of(
            "app", "hybrid-java-app",
            "version", "1.0.0",
            "environment", System.getenv().getOrDefault("APP_ENV", "local")
        );
    }

    @GetMapping("/data")
    public Map<String, Object> getData() {
        return Map.of(
            "message", "Hello from Java Microservice",
            "timestamp", System.currentTimeMillis(),
            "items", java.util.List.of("item1", "item2", "item3")
        );
    }
}
