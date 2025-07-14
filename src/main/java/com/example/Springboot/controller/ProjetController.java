package com.example.Springboot.controller;

import com.example.Springboot.model.Projet;
import com.example.Springboot.service.ProjetService;
import com.example.Springboot.dto.ProjetDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/projets")
public class ProjetController {
    @Autowired
    private ProjetService projetService;

    // Accessible à tous les rôles (lecture)
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'EMPLOYE')")
    public List<ProjetDTO> getAllProjets() {
        System.out.println(">>> [ProjetController] Requête GET /api/projets reçue");
        List<ProjetDTO> projets = projetService.getAllProjets().stream().map(projetService::toDTO).collect(Collectors.toList());
        System.out.println(">>> [ProjetController] Nombre de projets retournés : " + projets.size());
        return projets;
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'EMPLOYE')")
    public ResponseEntity<ProjetDTO> getProjetById(@PathVariable Long id) {
        Optional<Projet> projet = projetService.getProjetById(id);
        return projet.map(p -> ResponseEntity.ok(projetService.toDTO(p))).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Création (ADMIN/SUPERVISEUR uniquement)
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ProjetDTO createProjet(@RequestBody ProjetDTO projetDTO) {
        Projet saved = projetService.saveProjet(projetService.toEntity(projetDTO));
        return projetService.toDTO(saved);
    }

    // Modification (ADMIN/SUPERVISEUR uniquement)
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<ProjetDTO> updateProjet(@PathVariable Long id, @RequestBody ProjetDTO projetDTO) {
        Optional<Projet> existing = projetService.getProjetById(id);
        if (existing.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        Projet toUpdate = projetService.toEntity(projetDTO);
        toUpdate.setId(id);
        Projet saved = projetService.saveProjet(toUpdate);
        return ResponseEntity.ok(projetService.toDTO(saved));
    }

    // Suppression (ADMIN/SUPERVISEUR uniquement)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> deleteProjet(@PathVariable Long id) {
        if (projetService.getProjetById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        projetService.deleteProjet(id);
        return ResponseEntity.noContent().build();
    }
} 