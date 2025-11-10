package br.unifor.distrischool.auth_service.listener;

import br.unifor.distrischool.auth_service.dto.UserCreatedEvent;
import br.unifor.distrischool.auth_service.model.Role;
import br.unifor.distrischool.auth_service.model.User;
import br.unifor.distrischool.auth_service.repository.RoleRepository;
import br.unifor.distrischool.auth_service.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Component
public class UserEventListener {

    private static final Logger logger = LoggerFactory.getLogger(UserEventListener.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private br.unifor.distrischool.auth_service.service.CredentialsFileService credentialsFileService;

    @KafkaListener(topics = "student-events", groupId = "auth-service")
    public void handleStudentCreated(String message) {
        try {
            logger.info("📥 Received student-events event: {}", message);
            UserCreatedEvent event = objectMapper.readValue(message, UserCreatedEvent.class);
            createUserFromEvent(event, Role.RoleName.ROLE_STUDENT);
        } catch (Exception e) {
            logger.error("❌ Error processing student-events event", e);
        }
    }

    @KafkaListener(topics = "teacher-events", groupId = "auth-service")
    public void handleTeacherCreated(String message) {
        try {
            logger.info("📥 Received teacher-events event: {}", message);
            UserCreatedEvent event = objectMapper.readValue(message, UserCreatedEvent.class);
            createUserFromEvent(event, Role.RoleName.ROLE_TEACHER);
        } catch (Exception e) {
            logger.error("❌ Error processing teacher-events event", e);
        }
    }

    @KafkaListener(topics = "admin-events", groupId = "auth-service")
    public void handleAdminCreated(String message) {
        try {
            logger.info("📥 Received admin-events event: {}", message);
            UserCreatedEvent event = objectMapper.readValue(message, UserCreatedEvent.class);
            createUserFromEvent(event, Role.RoleName.ROLE_ADMIN);
        } catch (Exception e) {
            logger.error("❌ Error processing admin-events event", e);
        }
    }

    private void createUserFromEvent(UserCreatedEvent event, Role.RoleName roleName) {
        // Check if user already exists
        if (userRepository.existsByEmail(event.getEmail())) {
            logger.warn("⚠️ User already exists: {}", event.getEmail());
            return;
        }

        // Use password from event if provided, otherwise generate temporary password
        String password = (event.getPassword() != null && !event.getPassword().isEmpty()) 
            ? event.getPassword() 
            : UUID.randomUUID().toString().substring(0, 8);
        
        boolean passwordGenerated = (event.getPassword() == null || event.getPassword().isEmpty());
        
        User user = new User();
        user.setFullName(event.getFullName());
        user.setEmail(event.getEmail());
        user.setPassword(passwordEncoder.encode(password));
        user.setEnabled(true);
        user.setRole(roleName.name()); // Define o campo role (String)

        // Set role
        Role role = roleRepository.findByName(roleName)
                .orElseThrow(() -> new RuntimeException("Role not found: " + roleName));
        
        Set<Role> roles = new HashSet<>();
        roles.add(role);
        user.setRoles(roles);

        userRepository.save(user);

        // Salva credenciais no arquivo credentials.txt
        credentialsFileService.saveCredentials(event.getEmail(), password, roleName.name(), passwordGenerated);

        if (event.getPassword() != null && !event.getPassword().isEmpty()) {
            logger.info("✅ User created successfully: {} with role {} and provided password", 
                    event.getEmail(), roleName);
        } else {
            logger.info("✅ User created successfully: {} with role {} and temp password: {}", 
                    event.getEmail(), roleName, password);
        }
        
        // TODO: Send email with temporary password
        // emailService.sendTemporaryPassword(event.getEmail(), tempPassword);
    }
}
