package br.unifor.distrischool.auth_service.service;

import br.unifor.distrischool.auth_service.dto.AuthResponse;
import br.unifor.distrischool.auth_service.dto.LoginRequest;
import br.unifor.distrischool.auth_service.model.User;
import br.unifor.distrischool.auth_service.repository.UserRepository;
import br.unifor.distrischool.auth_service.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private KafkaService kafkaService;
    
    @Autowired
    private br.unifor.distrischool.auth_service.repository.RoleRepository roleRepository;

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        if (!user.isEnabled()) {
            throw new RuntimeException("Account not enabled");
        }

        List<String> roles = user.getRoles().stream()
                .map(r -> r.getName().name())
                .collect(Collectors.toList());

        String token = jwtUtil.generateToken(user.getEmail(), roles);

        kafkaService.sendUserLoggedEvent(user.getEmail());

        return new AuthResponse(token, user.getEmail(), roles);
    }

    public boolean validateToken(String token) {
        return jwtUtil.validateToken(token);
    }

    public String getEmailFromToken(String token) {
        return jwtUtil.getEmailFromToken(token);
    }

    public List<String> getRolesFromToken(String token) {
        return jwtUtil.getRolesFromToken(token);
    }

    public void resetAdminUser() {
        // Delete existing admin if exists
        userRepository.findByEmail("admin@distrischool.com").ifPresent(user -> {
            userRepository.delete(user);
        });

        // Get or create ADMIN role
        br.unifor.distrischool.auth_service.model.Role adminRole = roleRepository
                .findByName(br.unifor.distrischool.auth_service.model.Role.RoleName.ROLE_ADMIN)
                .orElseGet(() -> {
                    return roleRepository.save(new br.unifor.distrischool.auth_service.model.Role(
                            br.unifor.distrischool.auth_service.model.Role.RoleName.ROLE_ADMIN));
                });

        // Create new admin user
        User admin = new User();
        admin.setEmail("admin@distrischool.com");
        admin.setFullName("Admin Principal");
        admin.setPassword(passwordEncoder.encode("admin123"));
        admin.setEnabled(true);
        admin.setRole("ADMIN");
        admin.setRoles(java.util.Set.of(adminRole));

        userRepository.save(admin);
    }
}
