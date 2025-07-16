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
import java.util.Map;

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

    // Synthèse globale pour tous les projets (ADMIN/SUPERVISEUR)
    @GetMapping("/synthese")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public Map<String, Object> getSyntheseGlobale() {
        List<ProjetDTO> projets = projetService.getAllProjets().stream().map(projetService::toDTO).collect(Collectors.toList());
        
        int projetsEnCours = (int) projets.stream().filter(p -> {
            String statut = p.getStatutExecution();
            return statut != null && (statut.toLowerCase().contains("en cours") || statut.toLowerCase().contains("cours"));
        }).count();
        double avancementMoyen = projets.stream()
            .filter(p -> p.getAvancement() != null && !p.getAvancement().isEmpty())
            .mapToDouble(p -> {
                try { return Double.parseDouble(p.getAvancement().replace("%", "").replace(",", ".").trim()); }
                catch (Exception e) { return 0; }
            }).average().orElse(0);
        double totalContrats = projets.stream()
            .filter(p -> p.getMontantContratTTC() != null && !p.getMontantContratTTC().isEmpty())
            .mapToDouble(p -> parseMontant(p.getMontantContratTTC()))
            .sum();
        double totalEncaisse = projets.stream()
            .filter(p -> p.getMontantEncaisse() != null && !p.getMontantEncaisse().isEmpty())
            .mapToDouble(p -> parseMontant(p.getMontantEncaisse()))
            .sum();
        double soldeRestant = projets.stream()
            .filter(p -> p.getSoldeRestant() != null && !p.getSoldeRestant().isEmpty())
            .mapToDouble(p -> parseMontant(p.getSoldeRestant()))
            .sum();
        
        // Compter les projets qui ont des PV de réception dans leurs pièces jointes
        int pvReceptionDisponible = (int) projets.stream()
            .filter(p -> p.getPiecesJointes() != null && 
                        ((p.getPiecesJointes().pvReceptionProvisoire != null && 
                          p.getPiecesJointes().pvReceptionProvisoire.nomFichier != null) ||
                         (p.getPiecesJointes().pvReceptionDefinitive != null && 
                          p.getPiecesJointes().pvReceptionDefinitive.nomFichier != null)))
            .count();

        Map<String, Object> synthese = new java.util.HashMap<>();
        synthese.put("projetsEnCours", projetsEnCours);
        synthese.put("avancementMoyen", Math.round(avancementMoyen));
        synthese.put("totalContrats", totalContrats);
        synthese.put("totalEncaisse", totalEncaisse);
        synthese.put("soldeRestant", soldeRestant);
        synthese.put("pvReceptionDisponible", pvReceptionDisponible);
        return synthese;
    }
    
    // Méthode utilitaire pour parser les montants
    private double parseMontant(String montantString) {
        if (montantString == null || montantString.trim().isEmpty() || "N/A".equals(montantString.trim())) {
            return 0.0;
        }
        
        try {
            // Nettoyer la chaîne
            String cleaned = montantString.trim();
            
            // Si c'est déjà un nombre, le retourner directement
            if (cleaned.matches("^\\d+(\\.\\d+)?$")) {
                return Double.parseDouble(cleaned);
            }
            
            // Enlever tous les caractères non numériques sauf les virgules et points
            cleaned = cleaned.replaceAll("[^\\d.,]", "");
            
            // Si la chaîne contient une virgule, c'est probablement un séparateur de milliers
            if (cleaned.contains(",")) {
                // Si c'est le format français (1,234.56), remplacer la virgule par rien
                if (cleaned.matches("^\\d{1,3}(,\\d{3})*(\\.\\d+)?$")) {
                    cleaned = cleaned.replace(",", "");
                } else {
                    // Sinon, remplacer la virgule par un point (format européen)
                    cleaned = cleaned.replace(",", ".");
                }
            }
            
            return Double.parseDouble(cleaned);
        } catch (Exception e) {
            System.err.println("Erreur parsing montant: " + montantString + " - " + e.getMessage());
            return 0.0;
        }
    }

    // Création (ADMIN/SUPERVISEUR uniquement)
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ProjetDTO createProjet(@RequestBody ProjetDTO projetDTO) {
        System.out.println(">>> [ProjetController] [POST] /api/projets appelé");
        System.out.println(">>> [ProjetController] Données reçues : " + projetDTO);
        try {
            Projet saved = projetService.saveProjet(projetService.toEntity(projetDTO));
            System.out.println(">>> [ProjetController] Projet créé avec succès, ID: " + saved.getId());
            return projetService.toDTO(saved);
        } catch (Exception e) {
            System.err.println(">>> [ProjetController] Erreur lors de la création du projet: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    // Modification (ADMIN/SUPERVISEUR uniquement)
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<ProjetDTO> updateProjet(@PathVariable Long id, @RequestBody ProjetDTO projetDTO) {
        System.out.println(">>> [ProjetController] [PUT] /api/projets/" + id + " appelé");
        System.out.println(">>> [ProjetController] Données reçues : " + projetDTO);
        try {
            Optional<Projet> existing = projetService.getProjetById(id);
            if (existing.isEmpty()) {
                System.out.println(">>> [ProjetController] Projet non trouvé avec ID: " + id);
                return ResponseEntity.notFound().build();
            }
            Projet toUpdate = projetService.toEntity(projetDTO);
            toUpdate.setId(id);
            Projet saved = projetService.saveProjet(toUpdate);
            ProjetDTO retour = projetService.toDTO(saved);
            System.out.println(">>> [ProjetController] DTO retourné : " + retour);
            return ResponseEntity.ok(retour);
        } catch (Exception e) {
            System.err.println(">>> [ProjetController] Erreur lors de la modification du projet: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    // Suppression (ADMIN/SUPERVISEUR uniquement)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR')")
    public ResponseEntity<Void> deleteProjet(@PathVariable Long id) {
        System.out.println(">>> [ProjetController] [DELETE] /api/projets/" + id + " appelé");
        try {
            if (projetService.getProjetById(id).isEmpty()) {
                System.out.println(">>> [ProjetController] Projet non trouvé avec ID: " + id);
                return ResponseEntity.notFound().build();
            }
            projetService.deleteProjet(id);
            System.out.println(">>> [ProjetController] Projet supprimé avec succès, ID: " + id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            System.err.println(">>> [ProjetController] Erreur lors de la suppression du projet: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
} 