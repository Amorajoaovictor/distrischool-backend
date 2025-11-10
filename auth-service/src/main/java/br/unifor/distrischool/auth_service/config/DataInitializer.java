package br.unifor.distrischool.auth_service.config;

import br.unifor.distrischool.auth_service.model.Role;
import br.unifor.distrischool.auth_service.model.User;
import br.unifor.distrischool.auth_service.repository.RoleRepository;
import br.unifor.distrischool.auth_service.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private RoleRepository roleRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        logger.info("🔧 Starting DataInitializer...");
        
        // Initialize roles
        if (roleRepository.count() == 0) {
            logger.info("📝 Creating default roles...");
            roleRepository.save(new Role(Role.RoleName.ROLE_STUDENT));
            roleRepository.save(new Role(Role.RoleName.ROLE_TEACHER));
            roleRepository.save(new Role(Role.RoleName.ROLE_ADMIN));
            roleRepository.save(new Role(Role.RoleName.ROLE_PARENT));
            logger.info("✅ Roles initialized: STUDENT, TEACHER, ADMIN, PARENT");
        } else {
            logger.info("ℹ️ Roles already exist, skipping initialization");
        }
        
        // Create default admin user
        if (!userRepository.existsByEmail("admin@distrischool.com")) {
            logger.info("👤 Creating default admin user...");
            User admin = new User();
            admin.setEmail("admin@distrischool.com");
            admin.setFullName("Admin Principal");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setEnabled(true);
            admin.setRole("ADMIN");
            
            Role adminRole = roleRepository.findByName(Role.RoleName.ROLE_ADMIN)
                    .orElseThrow(() -> new RuntimeException("ROLE_ADMIN not found"));
            
            Set<Role> roles = new HashSet<>();
            roles.add(adminRole);
            admin.setRoles(roles);
            
            userRepository.save(admin);
            logger.info("✅ Default admin created successfully!");
            logger.info("   Email: admin@distrischool.com");
            logger.info("   Password: admin123");
            logger.info("   Role: ADMIN");
        } else {
            logger.info("ℹ️ Admin user already exists, skipping creation");
        }
        
        logger.info("🎉 DataInitializer completed successfully!");
    }
}
