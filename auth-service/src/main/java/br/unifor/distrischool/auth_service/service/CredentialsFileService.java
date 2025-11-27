package br.unifor.distrischool.auth_service.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class CredentialsFileService {

    private static final Logger logger = LoggerFactory.getLogger(CredentialsFileService.class);
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Value("${credentials.file.path:credentials.txt}")
    private String credentialsFilePath;

    /**
     * Salva credenciais geradas no arquivo credentials.txt
     * 
     * @param email Email do usuário
     * @param password Senha em texto plano (antes da criptografia)
     * @param role Role do usuário
     * @param generated Se a senha foi gerada automaticamente ou fornecida
     */
    public void saveCredentials(String email, String password, String role, boolean generated) {
        try {
            // Determina o caminho do arquivo (relativo à raiz do projeto)
            Path projectRoot = Paths.get("").toAbsolutePath();
            while (!Files.exists(projectRoot.resolve("pom.xml")) && projectRoot.getParent() != null) {
                projectRoot = projectRoot.getParent();
            }
            
            // Se não encontrou pom.xml, usa o diretório atual
            Path credentialsPath = projectRoot.resolve(credentialsFilePath);
            
            // Cria o arquivo se não existir
            if (!Files.exists(credentialsPath)) {
                Files.createFile(credentialsPath);
                writeHeader(credentialsPath);
                logger.info("📝 Arquivo credentials.txt criado em: {}", credentialsPath.toAbsolutePath());
            }

            // Monta a linha de credenciais
            String timestamp = LocalDateTime.now().format(DATE_FORMATTER);
            String passwordType = generated ? "[GENERATED]" : "[PROVIDED]";
            String line = String.format("%s | %s | %-30s | %-25s | %s%n",
                    timestamp, passwordType, email, password, role);

            // Append ao arquivo
            Files.writeString(credentialsPath, line, 
                    StandardOpenOption.APPEND);

            logger.info("💾 Credenciais salvas em credentials.txt: {} ({})", email, passwordType);

        } catch (IOException e) {
            logger.error("❌ Erro ao salvar credenciais no arquivo: {}", e.getMessage());
            // Não lança exceção para não interromper a criação do usuário
        }
    }

    private void writeHeader(Path path) throws IOException {
        String header = String.format(
                "=================================================================================%n" +
                "DISTRISCHOOL - CREDENCIAIS GERADAS AUTOMATICAMENTE%n" +
                "=================================================================================%n" +
                "ATENÇÃO: Este arquivo contém senhas em texto plano.%n" +
                "         Mantenha-o seguro e NÃO commite no Git!%n" +
                "         Adicione 'credentials.txt' ao .gitignore%n" +
                "=================================================================================%n%n" +
                "%-19s | %-11s | %-30s | %-25s | %s%n" +
                "---------------------------------------------------------------------------------%n",
                "TIMESTAMP", "TYPE", "EMAIL", "PASSWORD", "ROLE"
        );
        Files.writeString(path, header);
    }

    /**
     * Limpa o arquivo de credenciais
     */
    public void clearCredentialsFile() {
        try {
            Path projectRoot = Paths.get("").toAbsolutePath();
            while (!Files.exists(projectRoot.resolve("pom.xml")) && projectRoot.getParent() != null) {
                projectRoot = projectRoot.getParent();
            }
            
            Path credentialsPath = projectRoot.resolve(credentialsFilePath);
            
            if (Files.exists(credentialsPath)) {
                Files.delete(credentialsPath);
                logger.info("🗑️  Arquivo credentials.txt limpo");
            }
        } catch (IOException e) {
            logger.error("❌ Erro ao limpar arquivo de credenciais: {}", e.getMessage());
        }
    }
}
