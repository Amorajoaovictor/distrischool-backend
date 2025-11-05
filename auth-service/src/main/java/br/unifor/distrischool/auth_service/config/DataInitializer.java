package br.unifor.distrischool.auth_service.config;

import br.unifor.distrischool.auth_service.model.Role;
import br.unifor.distrischool.auth_service.repository.RoleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private RoleRepository roleRepository;

    @Override
    public void run(String... args) throws Exception {
        if (roleRepository.count() == 0) {
            roleRepository.save(new Role(Role.RoleName.ROLE_STUDENT));
            roleRepository.save(new Role(Role.RoleName.ROLE_TEACHER));
            roleRepository.save(new Role(Role.RoleName.ROLE_ADMIN));
            roleRepository.save(new Role(Role.RoleName.ROLE_PARENT));
            System.out.println("✅ Roles initialized: STUDENT, TEACHER, ADMIN, PARENT");
        }
    }
}
