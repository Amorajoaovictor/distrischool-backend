package br.unifor.distrischool.user_service.security;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            response.getWriter().write("Missing or invalid Authorization header");
            return;
        }

        String token = authHeader.substring(7);

        boolean isValid = validateTokenWithAuthService(token);

        if (!isValid) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            response.getWriter().write("Invalid token");
            return;
        }

        filterChain.doFilter(request, response);
    }

    private boolean validateTokenWithAuthService(String token) {
        try {
            String authServiceUrl = "http://auth-service:8080/api/auth/validate";
            Map<String, String> headers = Map.of(HttpHeaders.AUTHORIZATION, "Bearer " + token);
            
            // Use RestTemplate to call auth-service
            var response = restTemplate.postForEntity(authServiceUrl, null, Map.class, headers);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                Map<String, Object> body = response.getBody();
                return body != null && Boolean.TRUE.equals(body.get("valid"));
            }
        } catch (Exception e) {
            // Log the error
            System.err.println("Error validating token: " + e.getMessage());
        }
        return false;
    }
}