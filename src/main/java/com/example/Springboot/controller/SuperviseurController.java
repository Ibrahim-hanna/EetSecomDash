package com.example.Springboot.controller;

import com.example.Springboot.dto.SuiviExecutionDTO;
import com.example.Springboot.dto.SyntheseDTO;
import com.example.Springboot.model.Projet;
import com.example.Springboot.repository.UserRepository;
import com.example.Springboot.service.ProjetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/superviseur")
@CrossOrigin(origins = "*")
public class SuperviseurController {
    @Autowired
    private ProjetService projetService;
    @Autowired
    private UserRepository userRepository;

    @GetMapping("/dashboard")
    public ResponseEntity<SuiviExecutionDTO> getSuperviseurDashboard() {
        List<Projet> projets = projetService.getAllProjets();
        int total = projets.size();
        int enCours = (int) projets.stream().filter(p -> "EN COURS".equalsIgnoreCase(p.getStatutExecution())).count();
        int termines = (int) projets.stream().filter(p -> "TERMINE".equalsIgnoreCase(p.getStatutExecution())).count();
        int enAttente = (int) projets.stream().filter(p -> "EN ATTENTE".equalsIgnoreCase(p.getStatutExecution())).count();
        SuiviExecutionDTO dto = new SuiviExecutionDTO(total, enCours, termines, enAttente);
        return ResponseEntity.ok(dto);
    }

    @GetMapping("/reports")
    public ResponseEntity<SyntheseDTO> getReports() {
        int totalProjets = projetService.getAllProjets().size();
        int totalPiecesJointes = projetService.getAllProjets().stream()
            .mapToInt(p -> {
                int count = 0;
                if (p.getPvReceptionProvisoire() != null) count++;
                if (p.getPvReceptionDefinitif() != null) count++;
                if (p.getAttestationReference() != null) count++;
                if (p.getContratPieceJointe() != null) count++;
                if (p.getSuiviExecutionDetaillePieceJointe() != null) count++;
                if (p.getSuiviReglementDetaillePieceJointe() != null) count++;
                return count;
            }).sum();
        int totalUtilisateurs = (int) userRepository.count();
        SyntheseDTO dto = new SyntheseDTO(totalProjets, totalPiecesJointes, totalUtilisateurs);
        return ResponseEntity.ok(dto);
    }
} 