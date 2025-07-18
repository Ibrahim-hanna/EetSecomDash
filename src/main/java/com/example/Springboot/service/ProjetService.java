package com.example.Springboot.service;

import com.example.Springboot.model.Projet;
import com.example.Springboot.repository.ProjetRepository;
import com.example.Springboot.dto.ProjetDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.io.ClassPathResource;
import java.time.format.DateTimeFormatter;

import java.util.List;
import java.util.Optional;

@Service
public class ProjetService {
    @Autowired
    private ProjetRepository projetRepository;

    @Autowired(required = false)
    private SimpMessagingTemplate messagingTemplate;
    
    @Autowired(required = false)
    private WebSocketNotificationService webSocketNotificationService;

    public List<Projet> getAllProjets() {
        List<Projet> projets = projetRepository.findAll();
        System.out.println(">>> [ProjetService] Nombre de projets trouvés en base : " + projets.size());
        if (!projets.isEmpty()) {
            System.out.println(">>> [ProjetService] Premier projet : " + projets.get(0).getNumeroProjet());
        }
        return projets;
    }

    public Optional<Projet> getProjetById(Long id) {
        return projetRepository.findById(id);
    }

    public Optional<Projet> getProjetByNumero(String numeroProjet) {
        return projetRepository.findByNumeroProjet(numeroProjet);
    }

    public Projet saveProjet(Projet projet) {
        System.out.println(">>> [ProjetService] Sauvegarde du projet: " + projet.getNumeroProjet());
        try {
            Projet saved = projetRepository.save(projet);
            System.out.println(">>> [ProjetService] Projet sauvegardé avec succès, ID: " + saved.getId());
            
            // Notifier via WebSocket
            if (webSocketNotificationService != null) {
                if (projet.getId() == null) {
                    webSocketNotificationService.notifyProjetCreated(saved.getId());
                } else {
                    webSocketNotificationService.notifyProjetModified(saved.getId());
                }
                webSocketNotificationService.notifyProjetsListUpdate();
            } else if (messagingTemplate != null) {
                messagingTemplate.convertAndSend("/topic/projets", toDTO(saved));
            }
            
            return saved;
        } catch (Exception e) {
            System.err.println(">>> [ProjetService] Erreur lors de la sauvegarde du projet: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    public void deleteProjet(Long id) {
        projetRepository.deleteById(id);
        
        // Notifier via WebSocket
        if (webSocketNotificationService != null) {
            webSocketNotificationService.notifyProjetDeleted(id);
            webSocketNotificationService.notifyProjetsListUpdate();
        } else if (messagingTemplate != null) {
            messagingTemplate.convertAndSend("/topic/projets", "deleted:" + id);
        }
    }

    public void deleteAllProjets() {
        projetRepository.deleteAll();
    }

    // Vérifie si une pièce jointe existe physiquement dans le dossier uploads
    private boolean pieceJointeExiste(String nomFichier) {
        if (nomFichier == null || nomFichier.trim().isEmpty()) return false;
        java.nio.file.Path path = java.nio.file.Paths.get("uploads", nomFichier);
        return java.nio.file.Files.exists(path);
    }

    public ProjetDTO toDTO(Projet projet) {
        if (projet == null) return null;
        ProjetDTO dto = new ProjetDTO();
        dto.setId(projet.getId());
        dto.setNumeroProjet(projet.getNumeroProjet());
        dto.setClient(projet.getClient());
        dto.setDesignation(projet.getDesignation());
        dto.setTypeProjet(projet.getTypeProjet());
        dto.setResponsableInterne(projet.getResponsableInterne());
        dto.setResponsableExterne(projet.getResponsableExterne());
        dto.setDureeContractuelle(projet.getDureeContractuelle());
        if (projet.getDateDebut() != null) {
            dto.setDateDebut(projet.getDateDebut().toString());
        }
        if (projet.getDateFinEffective() != null) {
            dto.setDateFinEffective(projet.getDateFinEffective().toString());
        }
        dto.setAvancement(projet.getAvancement());
        dto.setStatutExecution(projet.getStatutExecution());
        dto.setMontantContratTTC(projet.getMontantContratTTC());
        dto.setMontantAvenant(projet.getMontantAvenant());
        dto.setMontantCumul(projet.getMontantCumul());
        dto.setMontantEncaisse(projet.getMontantEncaisse());
        dto.setSoldeRestant(projet.getSoldeRestant());
        dto.setSolde(projet.getSolde());
        dto.setStatutFacturation(projet.getStatutFacturation());
        dto.setRemarques(projet.getRemarques());
        
        // Nouveaux champs pour le suivi d'exécution détaillé
        dto.setPhase(projet.getPhase());
        dto.setZone(projet.getZone());
        dto.setQuantiteInstallee(projet.getQuantiteInstallee());
        dto.setRemarquesExecution(projet.getRemarquesExecution());
        
        // Nouveaux champs pour le suivi règlement détaillé
        dto.setNAttachment(projet.getNAttachment());
        dto.setDateAttachement(projet.getDateAttachement());
        dto.setDateFacture(projet.getDateFacture());
        dto.setDatePaiement(projet.getDatePaiement());
        dto.setModeReglement(projet.getModeReglement());
        dto.setRemarqueReglement(projet.getRemarqueReglement());
        
        // Pièces jointes individuelles
        if (dto.getPiecesJointes() == null) dto.setPiecesJointes(new ProjetDTO.PiecesJointes());
        
        // Log de débogage pour les pièces jointes
        System.out.println("DEBUG - toDTO pour projet " + projet.getNumeroProjet() + " (ID: " + projet.getId() + ")");
        
        // Contrat
        if (projet.getContratPieceJointe() != null) {
            System.out.println("DEBUG - Contrat en base: " + projet.getContratPieceJointe());
            if (pieceJointeExiste(projet.getContratPieceJointe())) {
                ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
                pj.nomFichier = projet.getContratPieceJointe();
                pj.description = projet.getContratPieceJointeDescription(); // <-- à adapter selon le nom réel du getter
                dto.getPiecesJointes().contrat = pj;
                System.out.println("DEBUG - Contrat ajouté au DTO");
            } else {
                System.out.println("DEBUG - Contrat non trouvé physiquement: " + projet.getContratPieceJointe());
            }
        }
        
        // PV Réception Provisoire
        if (projet.getPvReceptionProvisoire() != null) {
            System.out.println("DEBUG - PV Provisoire en base: " + projet.getPvReceptionProvisoire());
            if (pieceJointeExiste(projet.getPvReceptionProvisoire())) {
                ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
                pj.nomFichier = projet.getPvReceptionProvisoire();
                pj.description = projet.getPvReceptionProvisoireDescription(); // <-- à adapter selon le nom réel du getter
                dto.getPiecesJointes().pvReceptionProvisoire = pj;
                System.out.println("DEBUG - PV Provisoire ajouté au DTO");
            } else {
                System.out.println("DEBUG - PV Provisoire non trouvé physiquement: " + projet.getPvReceptionProvisoire());
            }
        }
        
        // PV Réception Définitive
        if (projet.getPvReceptionDefinitif() != null) {
            System.out.println("DEBUG - PV Definitif en base: " + projet.getPvReceptionDefinitif());
            if (pieceJointeExiste(projet.getPvReceptionDefinitif())) {
                ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
                pj.nomFichier = projet.getPvReceptionDefinitif();
                pj.description = projet.getPvReceptionDefinitifDescription(); // <-- à adapter selon le nom réel du getter
                dto.getPiecesJointes().pvReceptionDefinitive = pj;
                System.out.println("DEBUG - PV Definitif ajouté au DTO");
            } else {
                System.out.println("DEBUG - PV Definitif non trouvé physiquement: " + projet.getPvReceptionDefinitif());
            }
        }
        
        // Attestation de référence
        if (projet.getAttestationReference() != null) {
            System.out.println("DEBUG - Attestation en base: " + projet.getAttestationReference());
            if (pieceJointeExiste(projet.getAttestationReference())) {
                ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
                pj.nomFichier = projet.getAttestationReference();
                pj.description = projet.getAttestationReferenceDescription(); // <-- à adapter selon le nom réel du getter
                dto.getPiecesJointes().attestationReference = pj;
                System.out.println("DEBUG - Attestation ajoutée au DTO");
            } else {
                System.out.println("DEBUG - Attestation non trouvée physiquement: " + projet.getAttestationReference());
            }
        }
        
        // Suivi exécution détaillé
        if (projet.getSuiviExecutionDetaillePieceJointe() != null) {
            System.out.println("DEBUG - Suivi execution en base: " + projet.getSuiviExecutionDetaillePieceJointe());
            if (pieceJointeExiste(projet.getSuiviExecutionDetaillePieceJointe())) {
                ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
                pj.nomFichier = projet.getSuiviExecutionDetaillePieceJointe();
                pj.description = projet.getSuiviExecutionDetaillePieceJointeDescription(); // <-- à adapter selon le nom réel du getter
                dto.getPiecesJointes().suiviExecutionDetaille = pj;
                System.out.println("DEBUG - Suivi execution ajouté au DTO");
            } else {
                System.out.println("DEBUG - Suivi execution non trouvé physiquement: " + projet.getSuiviExecutionDetaillePieceJointe());
            }
        }
        
        // Suivi règlement détaillé
        if (projet.getSuiviReglementDetaillePieceJointe() != null) {
            System.out.println("DEBUG - Suivi reglement en base: " + projet.getSuiviReglementDetaillePieceJointe());
            if (pieceJointeExiste(projet.getSuiviReglementDetaillePieceJointe())) {
                ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
                pj.nomFichier = projet.getSuiviReglementDetaillePieceJointe();
                pj.description = projet.getSuiviReglementDetaillePieceJointeDescription(); // <-- à adapter selon le nom réel du getter
                dto.getPiecesJointes().suiviReglementDetaille = pj;
                System.out.println("DEBUG - Suivi reglement ajouté au DTO");
            } else {
                System.out.println("DEBUG - Suivi reglement non trouvé physiquement: " + projet.getSuiviReglementDetaillePieceJointe());
            }
        }
        
        return dto;
    }

    public Projet toEntity(ProjetDTO dto) {
        if (dto == null) return null;
        Projet projet = new Projet();
        // Ne pas setter l'ID pour les nouveaux projets (sera généré automatiquement)
        if (dto.getId() != null) {
            projet.setId(dto.getId());
        }
        
        // Gestion des champs optionnels - on ne set que si la valeur n'est pas null ou vide
        if (dto.getNumeroProjet() != null && !dto.getNumeroProjet().trim().isEmpty()) {
            projet.setNumeroProjet(dto.getNumeroProjet().trim());
        }
        if (dto.getClient() != null && !dto.getClient().trim().isEmpty()) {
            projet.setClient(dto.getClient().trim());
        }
        if (dto.getDesignation() != null && !dto.getDesignation().trim().isEmpty()) {
            projet.setDesignation(dto.getDesignation().trim());
        }
        if (dto.getTypeProjet() != null && !dto.getTypeProjet().trim().isEmpty()) {
            projet.setTypeProjet(dto.getTypeProjet().trim());
        }
        if (dto.getResponsableInterne() != null && !dto.getResponsableInterne().trim().isEmpty()) {
            projet.setResponsableInterne(dto.getResponsableInterne().trim());
        }
        if (dto.getResponsableExterne() != null && !dto.getResponsableExterne().trim().isEmpty()) {
            projet.setResponsableExterne(dto.getResponsableExterne().trim());
        }
        if (dto.getDureeContractuelle() != null && !dto.getDureeContractuelle().trim().isEmpty()) {
            projet.setDureeContractuelle(dto.getDureeContractuelle().trim());
        }
        
        // Support pour les formats de date HTML (yyyy-MM-dd) et JSON (M/d/yyyy)
        if (dto.getDateDebut() != null && !dto.getDateDebut().isEmpty()) {
            try {
                // Essayer d'abord le format HTML
                projet.setDateDebut(java.time.LocalDate.parse(dto.getDateDebut()));
            } catch (Exception e1) {
                try {
                    // Essayer le format JSON
                    DateTimeFormatter jsonFormatter = DateTimeFormatter.ofPattern("M/d/yyyy");
                    projet.setDateDebut(java.time.LocalDate.parse(dto.getDateDebut(), jsonFormatter));
                } catch (Exception e2) {
                    // format non conforme, on ignore
                    System.out.println("DEBUG - Format de date non reconnu pour dateDebut: " + dto.getDateDebut());
                }
            }
        }
        if (dto.getDateFinEffective() != null && !dto.getDateFinEffective().isEmpty()) {
            try {
                // Essayer d'abord le format HTML
                projet.setDateFinEffective(java.time.LocalDate.parse(dto.getDateFinEffective()));
            } catch (Exception e1) {
                try {
                    // Essayer le format JSON
                    DateTimeFormatter jsonFormatter = DateTimeFormatter.ofPattern("M/d/yyyy");
                    projet.setDateFinEffective(java.time.LocalDate.parse(dto.getDateFinEffective(), jsonFormatter));
                } catch (Exception e2) {
                    // format non conforme, on ignore
                    System.out.println("DEBUG - Format de date non reconnu pour dateFinEffective: " + dto.getDateFinEffective());
                }
            }
        }
        
        if (dto.getAvancement() != null && !dto.getAvancement().trim().isEmpty()) {
            projet.setAvancement(dto.getAvancement().trim());
        }
        if (dto.getStatutExecution() != null && !dto.getStatutExecution().trim().isEmpty()) {
            projet.setStatutExecution(dto.getStatutExecution().trim());
        }
        if (dto.getMontantContratTTC() != null && !dto.getMontantContratTTC().trim().isEmpty()) {
            projet.setMontantContratTTC(dto.getMontantContratTTC().trim());
        }
        if (dto.getMontantAvenant() != null && !dto.getMontantAvenant().trim().isEmpty()) {
            projet.setMontantAvenant(dto.getMontantAvenant().trim());
        }
        if (dto.getMontantCumul() != null && !dto.getMontantCumul().trim().isEmpty()) {
            projet.setMontantCumul(dto.getMontantCumul().trim());
        }
        if (dto.getMontantEncaisse() != null && !dto.getMontantEncaisse().trim().isEmpty()) {
            projet.setMontantEncaisse(dto.getMontantEncaisse().trim());
        }
        if (dto.getSoldeRestant() != null && !dto.getSoldeRestant().trim().isEmpty()) {
            projet.setSoldeRestant(dto.getSoldeRestant().trim());
        }
        if (dto.getSolde() != null && !dto.getSolde().trim().isEmpty()) {
            projet.setSolde(dto.getSolde().trim());
        }
        if (dto.getStatutFacturation() != null && !dto.getStatutFacturation().trim().isEmpty()) {
            projet.setStatutFacturation(dto.getStatutFacturation().trim());
        }
        if (dto.getRemarques() != null && !dto.getRemarques().trim().isEmpty()) {
            projet.setRemarques(dto.getRemarques().trim());
        }
        
        // Nouveaux champs pour le suivi d'exécution détaillé
        if (dto.getPhase() != null && !dto.getPhase().trim().isEmpty()) {
            System.out.println("[DEBUG] Mise à jour phase: " + dto.getPhase());
            projet.setPhase(dto.getPhase().trim());
        }
        if (dto.getZone() != null && !dto.getZone().trim().isEmpty()) {
            System.out.println("[DEBUG] Mise à jour zone: " + dto.getZone());
            projet.setZone(dto.getZone().trim());
        }
        if (dto.getQuantiteInstallee() != null && !dto.getQuantiteInstallee().trim().isEmpty()) {
            System.out.println("[DEBUG] Mise à jour quantité installée: " + dto.getQuantiteInstallee());
            projet.setQuantiteInstallee(dto.getQuantiteInstallee().trim());
        }
        if (dto.getRemarquesExecution() != null && !dto.getRemarquesExecution().trim().isEmpty()) {
            System.out.println("[DEBUG] Mise à jour remarques exécution: " + dto.getRemarquesExecution());
            projet.setRemarquesExecution(dto.getRemarquesExecution().trim());
        }
        
        // Nouveaux champs pour le suivi règlement détaillé
        if (dto.getNAttachment() != null && !dto.getNAttachment().trim().isEmpty()) {
            projet.setNAttachment(dto.getNAttachment().trim());
        }
        if (dto.getDateAttachement() != null && !dto.getDateAttachement().trim().isEmpty()) {
            projet.setDateAttachement(dto.getDateAttachement().trim());
        }
        if (dto.getDateFacture() != null && !dto.getDateFacture().trim().isEmpty()) {
            projet.setDateFacture(dto.getDateFacture().trim());
        }
        if (dto.getDatePaiement() != null && !dto.getDatePaiement().trim().isEmpty()) {
            projet.setDatePaiement(dto.getDatePaiement().trim());
        }
        if (dto.getModeReglement() != null && !dto.getModeReglement().trim().isEmpty()) {
            projet.setModeReglement(dto.getModeReglement().trim());
        }
        if (dto.getRemarqueReglement() != null && !dto.getRemarqueReglement().trim().isEmpty()) {
            projet.setRemarqueReglement(dto.getRemarqueReglement().trim());
        }
        
        // Mapping des pièces jointes depuis le DTO
        if (dto.getPiecesJointes() != null) {
            if (dto.getPiecesJointes().contrat != null && dto.getPiecesJointes().contrat.nomFichier != null && !dto.getPiecesJointes().contrat.nomFichier.trim().isEmpty()) {
                projet.setContratPieceJointe(dto.getPiecesJointes().contrat.nomFichier.trim());
            }
            if (dto.getPiecesJointes().pvReceptionProvisoire != null && dto.getPiecesJointes().pvReceptionProvisoire.nomFichier != null && !dto.getPiecesJointes().pvReceptionProvisoire.nomFichier.trim().isEmpty()) {
                projet.setPvReceptionProvisoire(dto.getPiecesJointes().pvReceptionProvisoire.nomFichier.trim());
            }
            if (dto.getPiecesJointes().pvReceptionDefinitive != null && dto.getPiecesJointes().pvReceptionDefinitive.nomFichier != null && !dto.getPiecesJointes().pvReceptionDefinitive.nomFichier.trim().isEmpty()) {
                projet.setPvReceptionDefinitif(dto.getPiecesJointes().pvReceptionDefinitive.nomFichier.trim());
            }
            if (dto.getPiecesJointes().attestationReference != null && dto.getPiecesJointes().attestationReference.nomFichier != null && !dto.getPiecesJointes().attestationReference.nomFichier.trim().isEmpty()) {
                projet.setAttestationReference(dto.getPiecesJointes().attestationReference.nomFichier.trim());
            }
            if (dto.getPiecesJointes().suiviExecutionDetaille != null && dto.getPiecesJointes().suiviExecutionDetaille.nomFichier != null && !dto.getPiecesJointes().suiviExecutionDetaille.nomFichier.trim().isEmpty()) {
                projet.setSuiviExecutionDetaillePieceJointe(dto.getPiecesJointes().suiviExecutionDetaille.nomFichier.trim());
            }
            if (dto.getPiecesJointes().suiviReglementDetaille != null && dto.getPiecesJointes().suiviReglementDetaille.nomFichier != null && !dto.getPiecesJointes().suiviReglementDetaille.nomFichier.trim().isEmpty()) {
                projet.setSuiviReglementDetaillePieceJointe(dto.getPiecesJointes().suiviReglementDetaille.nomFichier.trim());
            }
        }
        
        return projet;
    }

    public List<ProjetDTO> loadProjetsFromJson() {
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(new ClassPathResource("projets_tous_complets.json").getInputStream(), new TypeReference<List<ProjetDTO>>(){});
        } catch (Exception e) {
            e.printStackTrace();
            return List.of();
        }
    }

    public boolean ajouterPieceJointe(Long projetId, String type, String filename, String description) {
        try {
            System.out.println("DEBUG - Service: ajouterPieceJointe appelé avec projetId=" + projetId + ", type=" + type + ", filename=" + filename);
            Optional<Projet> projetOpt = projetRepository.findById(projetId);
            if (projetOpt.isEmpty()) {
                System.out.println("DEBUG - Service: Projet non trouvé avec ID=" + projetId);
                return false;
            }

            Projet projet = projetOpt.get();
            System.out.println("DEBUG - Service: Projet trouvé: " + projet.getNumeroProjet());
            
            // Mettre à jour le champ approprié selon le type
            switch (type) {
                case "contrat":
                    projet.setContratPieceJointe(filename);
                    projet.setContratPieceJointeDescription(description);
                    System.out.println("DEBUG - Service: Contrat mis à jour avec filename=" + filename);
                    break;
                case "pvReceptionProvisoire":
                    projet.setPvReceptionProvisoire(filename);
                    projet.setPvReceptionProvisoireDescription(description);
                    System.out.println("DEBUG - Service: PV Provisoire mis à jour avec filename=" + filename);
                    break;
                case "pvReceptionDefinitif":
                case "pvReceptionDefinitive":
                    projet.setPvReceptionDefinitif(filename);
                    projet.setPvReceptionDefinitifDescription(description);
                    System.out.println("DEBUG - Service: PV Definitif mis à jour avec filename=" + filename);
                    break;
                case "attestationReference":
                    projet.setAttestationReference(filename);
                    projet.setAttestationReferenceDescription(description);
                    System.out.println("DEBUG - Service: Attestation mise à jour avec filename=" + filename);
                    break;
                case "suivi_execution_detaille":
                    projet.setSuiviExecutionDetaillePieceJointe(filename);
                    projet.setSuiviExecutionDetaillePieceJointeDescription(description);
                    System.out.println("DEBUG - Service: Suivi execution mis à jour avec filename=" + filename);
                    break;
                case "suivi_reglement_detaille":
                    projet.setSuiviReglementDetaillePieceJointe(filename);
                    projet.setSuiviReglementDetaillePieceJointeDescription(description);
                    System.out.println("DEBUG - Service: Suivi reglement mis à jour avec filename=" + filename);
                    break;
                default:
                    System.out.println("DEBUG - Service: Type inconnu: " + type);
                    return false;
            }

            projetRepository.save(projet);
            System.out.println("DEBUG - Service: Projet sauvegardé en base");
            
            // Notifier via WebSocket
            if (messagingTemplate != null) {
                messagingTemplate.convertAndSend("/topic/projets", toDTO(projet));
                System.out.println("DEBUG - Service: Notification WebSocket envoyée");
            }
            
            return true;
        } catch (Exception e) {
            System.out.println("DEBUG - Service: Exception lors de l'ajout de la pièce jointe: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean supprimerPieceJointe(Long projetId, String type) {
        try {
            Optional<Projet> projetOpt = projetRepository.findById(projetId);
            if (projetOpt.isEmpty()) return false;
            Projet projet = projetOpt.get();
            String nomFichier = null;
            switch (type) {
                case "contrat":
                    nomFichier = projet.getContratPieceJointe();
                    projet.setContratPieceJointe(null);
                    break;
                case "pvReceptionProvisoire":
                    nomFichier = projet.getPvReceptionProvisoire();
                    projet.setPvReceptionProvisoire(null);
                    break;
                case "pvReceptionDefinitif":
                case "pvReceptionDefinitive":
                    nomFichier = projet.getPvReceptionDefinitif();
                    projet.setPvReceptionDefinitif(null);
                    break;
                case "attestationReference":
                    nomFichier = projet.getAttestationReference();
                    projet.setAttestationReference(null);
                    break;
                case "suivi_execution_detaille":
                    nomFichier = projet.getSuiviExecutionDetaillePieceJointe();
                    projet.setSuiviExecutionDetaillePieceJointe(null);
                    break;
                case "suivi_reglement_detaille":
                    nomFichier = projet.getSuiviReglementDetaillePieceJointe();
                    projet.setSuiviReglementDetaillePieceJointe(null);
                    break;
                default:
                    return false;
            }
            // Supprimer le fichier physique si présent
            if (nomFichier != null && !nomFichier.trim().isEmpty()) {
                java.nio.file.Path path = java.nio.file.Paths.get("uploads", nomFichier);
                try { java.nio.file.Files.deleteIfExists(path); } catch (Exception e) { /* ignore */ }
            }
            projetRepository.save(projet);
            if (messagingTemplate != null) {
                messagingTemplate.convertAndSend("/topic/projets", toDTO(projet));
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }
} 