package br.unifor.distrischool.student_service.security;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);

        Map<String, Object> validationResult = validateTokenWithAuthService(token);

        if (validationResult == null || !Boolean.TRUE.equals(validationResult.get("valid"))) {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
            response.getWriter().write("Invalid token");
            return;
        }

        // Extrai email e roles do resultado da validação
        String email = (String) validationResult.get("email");
        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) validationResult.get("roles");
        
        // Converte roles para GrantedAuthority
        List<SimpleGrantedAuthority> authorities = roles.stream()
            .map(SimpleGrantedAuthority::new)
            .toList();
        
        // Cria Authentication e seta no SecurityContext
        UsernamePasswordAuthenticationToken authentication = 
            new UsernamePasswordAuthenticationToken(email, null, authorities);
        SecurityContextHolder.getContext().setAuthentication(authentication);

        filterChain.doFilter(request, response);
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getRequestURI();
        if ("/actuator/prometheus".equals(path)) {
            return true;
        }
        return false;
    }

    private Map<String, Object> validateTokenWithAuthService(String token) {
        try {
            String authServiceUrl = "http://auth-service:8080/api/auth/validate";
            
            // Cria headers com o token
            HttpHeaders headers = new HttpHeaders();
            headers.set(HttpHeaders.AUTHORIZATION, "Bearer " + token);
            
            // Cria entity com headers
            HttpEntity<Void> requestEntity = new HttpEntity<>(headers);
            
            // Chama auth-service
            var response = restTemplate.postForEntity(authServiceUrl, requestEntity, Map.class);
            
            if (response.getStatusCode().is2xxSuccessful()) {
                return response.getBody();
            }
        } catch (Exception e) {
            // Log the error
            System.err.println("Error validating token: " + e.getMessage());
        }
        return null;
    }
}
