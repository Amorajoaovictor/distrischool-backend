package br.unifor.distrischool.admin_staff_service.config;

import br.unifor.distrischool.admin_staff_service.event.AdminEvent;
import br.unifor.distrischool.admin_staff_service.kafka.AdminEventProducer;
import br.unifor.distrischool.admin_staff_service.model.Admin;
import br.unifor.distrischool.admin_staff_service.repository.AdminRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class DefaultAdminInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DefaultAdminInitializer.class);

    private final AdminRepository adminRepository;
    private final AdminEventProducer adminEventProducer;

    @Value("${DEFAULT_ADMIN_EMAIL:admin@distrischool.com}")
    private String defaultAdminEmail;

    @Value("${DEFAULT_ADMIN_PASSWORD:admin123}")
    private String defaultAdminPassword;

    @Value("${DEFAULT_ADMIN_NAME:Admin Principal}")
    private String defaultAdminName;

    public DefaultAdminInitializer(AdminRepository adminRepository, AdminEventProducer adminEventProducer) {
        this.adminRepository = adminRepository;
        this.adminEventProducer = adminEventProducer;
    }

    @Override
    public void run(String... args) throws Exception {
        logger.info("🔍 Verificando se admin padrão existe...");

        Optional<Admin> existingAdmin = adminRepository.findByEmail(defaultAdminEmail);

        if (existingAdmin.isEmpty()) {
            logger.info("📝 Criando admin padrão: {}", defaultAdminEmail);

            // Cria o admin no banco local
            Admin admin = new Admin();
            admin.setName(defaultAdminName);
            admin.setEmail(defaultAdminEmail);
            admin.setRole("ADMIN");
            admin.setPassword(defaultAdminPassword); // Será criptografado no auth-service

            Admin savedAdmin = adminRepository.save(admin);
            logger.info("✅ Admin criado com sucesso: ID={}", savedAdmin.getId());

            // Publica evento Kafka para criar credenciais no auth-service
            publishAdminEvent(savedAdmin);
        } else {
            logger.info("ℹ️  Admin padrão já existe: {}", defaultAdminEmail);
            // Publica evento novamente para garantir que auth-service tenha as credenciais
            logger.info("📤 Republicando evento para garantir sincronização com auth-service");
            publishAdminEvent(existingAdmin.get());
        }
    }

    private void publishAdminEvent(Admin admin) {
        try {
            AdminEvent event = new AdminEvent(
                admin.getId(),
                admin.getName(),
                admin.getEmail(),
                defaultAdminPassword, // Envia senha para auth-service criptografar
                "CREATED"
            );
            adminEventProducer.publishAdminEvent(event);
            logger.info("📤 Evento de criação publicado para admin: {} ({})", admin.getName(), admin.getEmail());
        } catch (Exception e) {
            logger.error("❌ Erro ao publicar evento Kafka para admin {}", admin.getId(), e);
            // Não remove o admin se o evento falhar
        }
    }
}
