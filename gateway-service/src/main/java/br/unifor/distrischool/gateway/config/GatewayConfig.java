package br.unifor.distrischool.gateway.config;

import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                // Auth Service Routes - /api/auth (Public)
                .route("auth-service", r -> r
                        .path("/api/auth/**")
                        .filters(f -> f
                                .stripPrefix(0)
                                .addRequestHeader("X-Gateway", "Distrischool-Gateway")
                                .circuitBreaker(config -> config
                                        .setName("authServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/auth")))
                        .uri("http://auth-service:8080"))

                // User Service Routes - /api/v1/users
                .route("user-service", r -> r
                        .path("/api/v1/users/**")
                        .filters(f -> f
                                .stripPrefix(0)
                                .addRequestHeader("X-Gateway", "Distrischool-Gateway")
                                .circuitBreaker(config -> config
                                        .setName("userServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/users")))
                        .uri("http://user-service:8080"))

                // User Management from Auth Service - /api/users (Protected)
                .route("auth-user-management", r -> r
                        .path("/api/users/**")
                        .filters(f -> f
                                .stripPrefix(0)
                                .addRequestHeader("X-Gateway", "Distrischool-Gateway")
                                .circuitBreaker(config -> config
                                        .setName("authServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/auth")))
                        .uri("http://auth-service:8080"))

                // Student Service Routes - /api/alunos
                .route("student-service", r -> r
                        .path("/api/alunos/**")
                        .filters(f -> f
                                .stripPrefix(0)
                                .addRequestHeader("X-Gateway", "Distrischool-Gateway")
                                .circuitBreaker(config -> config
                                        .setName("studentServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/students")))
                        .uri("http://student-service:8080"))

                // Teacher Service Routes - /api/teachers
                .route("teacher-service", r -> r
                        .path("/api/teachers/**")
                        .filters(f -> f
                                .stripPrefix(0)
                                .addRequestHeader("X-Gateway", "Distrischool-Gateway")
                                .circuitBreaker(config -> config
                                        .setName("teacherServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/teachers")))
                        .uri("http://teacher-service:8080"))

                // Admin Staff Service Routes - /api/v1/admins
                .route("admin-staff-service", r -> r
                        .path("/api/v1/admins/**")
                        .filters(f -> f
                                .stripPrefix(0)
                                .addRequestHeader("X-Gateway", "Distrischool-Gateway")
                                .circuitBreaker(config -> config
                                        .setName("adminServiceCircuitBreaker")
                                        .setFallbackUri("forward:/fallback/admin")))
                        .uri("http://admin-staff-service:8080"))

                // Actuator Routes for all services
                .route("user-actuator", r -> r
                        .path("/services/user/actuator/**")
                        .filters(f -> f.stripPrefix(2))
                        .uri("http://user-service:8080"))

                .route("student-actuator", r -> r
                        .path("/services/student/actuator/**")
                        .filters(f -> f.stripPrefix(2))
                        .uri("http://student-service:8080"))

                .route("teacher-actuator", r -> r
                        .path("/services/teacher/actuator/**")
                        .filters(f -> f.stripPrefix(2))
                        .uri("http://teacher-service:8080"))

                .route("admin-actuator", r -> r
                        .path("/services/admin/actuator/**")
                        .filters(f -> f.stripPrefix(2))
                        .uri("http://admin-staff-service:8080"))

                .route("auth-actuator", r -> r
                        .path("/services/auth/actuator/**")
                        .filters(f -> f.stripPrefix(2))
                        .uri("http://auth-service:8080"))

                .build();
    }

}
