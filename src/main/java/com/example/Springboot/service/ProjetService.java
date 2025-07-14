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
        Projet saved = projetRepository.save(projet);
        if (messagingTemplate != null) {
            messagingTemplate.convertAndSend("/topic/projets", toDTO(saved));
        }
        return saved;
    }

    public void deleteProjet(Long id) {
        projetRepository.deleteById(id);
        if (messagingTemplate != null) {
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
        dto.setStatutFacturation(projet.getStatutFacturation());
        dto.setRemarques(projet.getRemarques());
        // Pièces jointes individuelles
        if (dto.getPiecesJointes() == null) dto.setPiecesJointes(new ProjetDTO.PiecesJointes());
        if (projet.getPvReceptionProvisoire() != null && pieceJointeExiste(projet.getPvReceptionProvisoire())) {
            ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
            pj.nomFichier = projet.getPvReceptionProvisoire();
            dto.getPiecesJointes().pvReceptionProvisoire = pj;
        }
        if (projet.getPvReceptionDefinitif() != null && pieceJointeExiste(projet.getPvReceptionDefinitif())) {
            ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
            pj.nomFichier = projet.getPvReceptionDefinitif();
            dto.getPiecesJointes().pvReceptionDefinitive = pj;
        }
        if (projet.getAttestationReference() != null && pieceJointeExiste(projet.getAttestationReference())) {
            ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
            pj.nomFichier = projet.getAttestationReference();
            dto.getPiecesJointes().attestationReference = pj;
        }
        if (projet.getContratPieceJointe() != null && pieceJointeExiste(projet.getContratPieceJointe())) {
            ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
            pj.nomFichier = projet.getContratPieceJointe();
            dto.getPiecesJointes().contrat = pj;
        }
        if (projet.getSuiviExecutionDetaillePieceJointe() != null && pieceJointeExiste(projet.getSuiviExecutionDetaillePieceJointe())) {
            ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
            pj.nomFichier = projet.getSuiviExecutionDetaillePieceJointe();
            dto.getPiecesJointes().suiviExecutionDetaille = pj;
        }
        if (projet.getSuiviReglementDetaillePieceJointe() != null && pieceJointeExiste(projet.getSuiviReglementDetaillePieceJointe())) {
            ProjetDTO.PieceJointe pj = new ProjetDTO.PieceJointe();
            pj.nomFichier = projet.getSuiviReglementDetaillePieceJointe();
            dto.getPiecesJointes().suiviReglementDetaille = pj;
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
        
        DateTimeFormatter jsonFormatter = DateTimeFormatter.ofPattern("M/d/yyyy");
        if (dto.getDateDebut() != null && !dto.getDateDebut().isEmpty()) {
            try {
                projet.setDateDebut(java.time.LocalDate.parse(dto.getDateDebut(), jsonFormatter));
            } catch (Exception e) {
                // format non conforme, on ignore
            }
        }
        if (dto.getDateFinEffective() != null && !dto.getDateFinEffective().isEmpty()) {
            try {
                projet.setDateFinEffective(java.time.LocalDate.parse(dto.getDateFinEffective(), jsonFormatter));
            } catch (Exception e) {
                // format non conforme, on ignore
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
        if (dto.getStatutFacturation() != null && !dto.getStatutFacturation().trim().isEmpty()) {
            projet.setStatutFacturation(dto.getStatutFacturation().trim());
        }
        if (dto.getRemarques() != null && !dto.getRemarques().trim().isEmpty()) {
            projet.setRemarques(dto.getRemarques().trim());
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
                    System.out.println("DEBUG - Service: Contrat mis à jour avec filename=" + filename);
                    break;
                case "pvReceptionProvisoire":
                    projet.setPvReceptionProvisoire(filename);
                    System.out.println("DEBUG - Service: PV Provisoire mis à jour avec filename=" + filename);
                    break;
                case "pvReceptionDefinitif":
                    projet.setPvReceptionDefinitif(filename);
                    System.out.println("DEBUG - Service: PV Definitif mis à jour avec filename=" + filename);
                    break;
                case "attestationReference":
                    projet.setAttestationReference(filename);
                    System.out.println("DEBUG - Service: Attestation mise à jour avec filename=" + filename);
                    break;
                case "suivi_execution_detaille":
                    projet.setSuiviExecutionDetaillePieceJointe(filename);
                    System.out.println("DEBUG - Service: Suivi execution mis à jour avec filename=" + filename);
                    break;
                case "suivi_reglement_detaille":
                    projet.setSuiviReglementDetaillePieceJointe(filename);
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