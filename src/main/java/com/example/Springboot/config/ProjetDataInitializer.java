package com.example.Springboot.config;

import com.example.Springboot.service.ProjetService;
import com.example.Springboot.dto.ProjetDTO;
import com.example.Springboot.model.Projet;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ProjetDataInitializer {
    @Autowired
    private ProjetService projetService;

    @PostConstruct
    public void importJsonToH2() {
        // Vérifier si la base de données est vide
        List<Projet> projetsExistants = projetService.getAllProjets();
        
        if (!projetsExistants.isEmpty()) {
            System.out.println("[INIT] Base de données non vide (" + projetsExistants.size() + " projets). Aucun import depuis JSON.");
            return;
        }
        
        System.out.println("[INIT] Base de données vide. Import initial depuis JSON...");
        
        List<ProjetDTO> projets = projetService.loadProjetsFromJson();
        System.out.println("[INIT] Nombre de projets dans le JSON: " + projets.size());
        
        int imported = 0;
        for (ProjetDTO dto : projets) {
            if (dto.getNumeroProjet() != null) {
                Projet saved = projetService.saveProjet(projetService.toEntity(dto));
                System.out.println("[INIT] Projet importé: " + saved.getNumeroProjet() + " (ID: " + saved.getId() + ")");
                imported++;
            }
        }
        System.out.println("[INIT] Projets importés depuis le JSON : " + imported);
    }
} 