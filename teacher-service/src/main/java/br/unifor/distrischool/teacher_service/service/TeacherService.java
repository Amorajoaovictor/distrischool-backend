package br.unifor.distrischool.teacher_service.service;

import br.unifor.distrischool.teacher_service.event.TeacherEvent;
import br.unifor.distrischool.teacher_service.exception.ResourceNotFoundException;
import br.unifor.distrischool.teacher_service.kafka.TeacherEventProducer;
import br.unifor.distrischool.teacher_service.model.Teacher;
import br.unifor.distrischool.teacher_service.repository.TeacherRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.List;

@Service
public class TeacherService {

    private static final Logger logger = LoggerFactory.getLogger(TeacherService.class);
    
    private final TeacherRepository repository;
    private final TeacherEventProducer eventProducer;

    public TeacherService(TeacherRepository repository, TeacherEventProducer eventProducer) {
        this.repository = repository;
        this.eventProducer = eventProducer;
    }

    public Teacher create(Teacher t) {
        Teacher saved = repository.save(t);
        
        // Gera email institucional
        String email = gerarEmailInstitucional(saved.getNome(), saved.getId());
        
        // Publish event com campos de autenticação
        try {
            TeacherEvent event = new TeacherEvent(
                saved.getId(), 
                saved.getNome(), 
                saved.getQualificacao(), 
                saved.getContato(),
                email,
                "CREATED"
            );
            eventProducer.publishTeacherEvent(event);
            logger.info("📤 Evento de criação publicado para professor: {} ({})", saved.getNome(), email);
        } catch (Exception e) {
            logger.error("❌ Erro ao publicar evento Kafka para professor {}", saved.getId(), e);
            // Não falha a criação do professor se o evento falhar
        }
        
        return saved;
    }
    
    private String gerarEmailInstitucional(String nomeCompleto, Long id) {
        // Remove acentos e caracteres especiais
        String nome = Normalizer.normalize(nomeCompleto, Normalizer.Form.NFD)
                .replaceAll("[^\\p{ASCII}]", "")
                .toLowerCase()
                .trim();
        
        // Pega primeiro nome e último sobrenome
        String[] partes = nome.split("\\s+");
        String primeiroNome = partes[0];
        String ultimoSobrenome = partes.length > 1 ? partes[partes.length - 1] : "";
        
        // Formato: primeiro.ultimo.prof.id@unifor.br
        // Exemplo: joao.silva.prof.123@unifor.br
        if (!ultimoSobrenome.isEmpty()) {
            return String.format("%s.%s.prof.%d@unifor.br", primeiroNome, ultimoSobrenome, id);
        } else {
            return String.format("%s.prof.%d@unifor.br", primeiroNome, id);
        }
    }

    public Teacher update(Long id, Teacher t) {
        Teacher exist = repository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Teacher not found"));
        exist.setNome(t.getNome());
        exist.setQualificacao(t.getQualificacao());
        exist.setContato(t.getContato());
        Teacher updated = repository.save(exist);
        // Publish event
        TeacherEvent event = new TeacherEvent(
            updated.getId(), 
            updated.getNome(), 
            updated.getQualificacao(), 
            updated.getContato(), 
            "UPDATED"
        );
        eventProducer.publishTeacherEvent(event);
        return updated;
    }

    public Teacher getById(Long id) {
        return repository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Teacher not found"));
    }

    public List<Teacher> listAll() {
        return repository.findAll();
    }

    public void delete(Long id) {
        Teacher teacher = repository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Teacher not found"));
        repository.deleteById(id);
        // Publish event
        TeacherEvent event = new TeacherEvent(
            teacher.getId(), 
            teacher.getNome(), 
            teacher.getQualificacao(), 
            teacher.getContato(), 
            "DELETED"
        );
        eventProducer.publishTeacherEvent(event);
    }
}
