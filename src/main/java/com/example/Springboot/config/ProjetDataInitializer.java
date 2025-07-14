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
        // Vider la table avant import
        projetService.deleteAllProjets();
        List<ProjetDTO> projets = projetService.loadProjetsFromJson();
        int imported = 0;
        for (ProjetDTO dto : projets) {
            if (dto.getNumeroProjet() != null && projetService.getProjetByNumero(dto.getNumeroProjet()).isEmpty()) {
                Projet saved = projetService.saveProjet(projetService.toEntity(dto));
                System.out.println("[INIT] Projet importé: " + saved.getNumeroProjet() + " (ID: " + saved.getId() + ")");
                imported++;
            }
        }
        System.out.println("[INIT] Projets importés depuis le JSON : " + imported);
    }
} 