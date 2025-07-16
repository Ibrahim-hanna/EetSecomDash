package com.example.Springboot.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class ProjetDTO {
    private Long id;
    @JsonProperty("client")
    private String client;
    @JsonProperty("numeroProjet")
    private String numeroProjet;
    @JsonProperty("designation")
    private String designation;
    @JsonProperty("typeProjet")
    private String typeProjet;
    @JsonProperty("responsableInterne")
    private String responsableInterne;
    @JsonProperty("responsableExterne")
    private String responsableExterne;
    @JsonProperty("dureeContractuelle")
    private String dureeContractuelle;
    @JsonProperty("dateDebut")
    private String dateDebut;
    @JsonProperty("dateFinEffective")
    private String dateFinEffective;
    @JsonProperty("avancement")
    private String avancement;
    @JsonProperty("statutExecution")
    private String statutExecution;
    @JsonProperty("montantContratTTC")
    private String montantContratTTC;
    @JsonProperty("montantAvenant")
    private String montantAvenant;
    @JsonProperty("montantCumul")
    private String montantCumul;
    @JsonProperty("montantEncaisse")
    private String montantEncaisse;
    @JsonProperty("soldeRestant")
    private String soldeRestant;
    @JsonProperty("solde")
    private String solde;
    @JsonProperty("statutFacturation")
    private String statutFacturation;
    @JsonProperty("remarques")
    private String remarques;
    
    // Nouveaux champs pour le suivi d'exécution détaillé
    @JsonProperty("phase")
    private String phase;
    @JsonProperty("zone")
    private String zone;
    @JsonProperty("quantiteInstallee")
    private String quantiteInstallee;
    @JsonProperty("remarquesExecution")
    private String remarquesExecution;
    
    // Nouveaux champs pour le suivi règlement détaillé
    @JsonProperty("nAttachment")
    private String nAttachment;
    @JsonProperty("dateAttachement")
    private String dateAttachement;
    @JsonProperty("dateFacture")
    private String dateFacture;
    @JsonProperty("datePaiement")
    private String datePaiement;
    @JsonProperty("modeReglement")
    private String modeReglement;
    @JsonProperty("remarqueReglement")
    private String remarqueReglement;
    
    @JsonProperty("piecesJointes")
    private PiecesJointes piecesJointes;

    public static class PiecesJointes {
        @JsonProperty("contrat")
        public PieceJointe contrat;
        @JsonProperty("pvReceptionProvisoire")
        public PieceJointe pvReceptionProvisoire;
        @JsonProperty("pvReceptionDefinitive")
        public PieceJointe pvReceptionDefinitive;
        @JsonProperty("attestationReference")
        public PieceJointe attestationReference;
        @JsonProperty("suiviExecutionDetaille")
        public PieceJointe suiviExecutionDetaille;
        @JsonProperty("suiviReglementDetaille")
        public PieceJointe suiviReglementDetaille;
    }
    public static class PieceJointe {
        @JsonProperty("nomFichier")
        public String nomFichier;
        @JsonProperty("format")
        public String format;
        @JsonProperty("statut")
        public String statut;
        @JsonProperty("description")
        public String description;
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getClient() { return client; }
    public void setClient(String client) { this.client = client; }
    public String getNumeroProjet() { return numeroProjet; }
    public void setNumeroProjet(String numeroProjet) { this.numeroProjet = numeroProjet; }
    public String getDesignation() { return designation; }
    public void setDesignation(String designation) { this.designation = designation; }
    public String getTypeProjet() { return typeProjet; }
    public void setTypeProjet(String typeProjet) { this.typeProjet = typeProjet; }
    public String getResponsableInterne() { return responsableInterne; }
    public void setResponsableInterne(String responsableInterne) { this.responsableInterne = responsableInterne; }
    public String getResponsableExterne() { return responsableExterne; }
    public void setResponsableExterne(String responsableExterne) { this.responsableExterne = responsableExterne; }
    public String getDureeContractuelle() { return dureeContractuelle; }
    public void setDureeContractuelle(String dureeContractuelle) { this.dureeContractuelle = dureeContractuelle; }
    public String getDateDebut() { return dateDebut; }
    public void setDateDebut(String dateDebut) { this.dateDebut = dateDebut; }
    public String getDateFinEffective() { return dateFinEffective; }
    public void setDateFinEffective(String dateFinEffective) { this.dateFinEffective = dateFinEffective; }
    public String getAvancement() { return avancement; }
    public void setAvancement(String avancement) { this.avancement = avancement; }
    public String getStatutExecution() { return statutExecution; }
    public void setStatutExecution(String statutExecution) { this.statutExecution = statutExecution; }
    public String getMontantContratTTC() { return montantContratTTC; }
    public void setMontantContratTTC(String montantContratTTC) { this.montantContratTTC = montantContratTTC; }
    public String getMontantAvenant() { return montantAvenant; }
    public void setMontantAvenant(String montantAvenant) { this.montantAvenant = montantAvenant; }
    public String getMontantCumul() { return montantCumul; }
    public void setMontantCumul(String montantCumul) { this.montantCumul = montantCumul; }
    public String getMontantEncaisse() { return montantEncaisse; }
    public void setMontantEncaisse(String montantEncaisse) { this.montantEncaisse = montantEncaisse; }
    public String getSoldeRestant() { return soldeRestant; }
    public void setSoldeRestant(String soldeRestant) { this.soldeRestant = soldeRestant; }
    public String getSolde() { return solde; }
    public void setSolde(String solde) { this.solde = solde; }
    public String getStatutFacturation() { return statutFacturation; }
    public void setStatutFacturation(String statutFacturation) { this.statutFacturation = statutFacturation; }
    public String getRemarques() { return remarques; }
    public void setRemarques(String remarques) { this.remarques = remarques; }
    
    // Getters et Setters pour les nouveaux champs
    public String getPhase() { return phase; }
    public void setPhase(String phase) { this.phase = phase; }
    public String getZone() { return zone; }
    public void setZone(String zone) { this.zone = zone; }
    public String getQuantiteInstallee() { return quantiteInstallee; }
    public void setQuantiteInstallee(String quantiteInstallee) { this.quantiteInstallee = quantiteInstallee; }
    public String getRemarquesExecution() { return remarquesExecution; }
    public void setRemarquesExecution(String remarquesExecution) { this.remarquesExecution = remarquesExecution; }
    
    // Getters et Setters pour les nouveaux champs de suivi règlement détaillé
    public String getNAttachment() { return nAttachment; }
    public void setNAttachment(String nAttachment) { this.nAttachment = nAttachment; }
    public String getDateAttachement() { return dateAttachement; }
    public void setDateAttachement(String dateAttachement) { this.dateAttachement = dateAttachement; }
    public String getDateFacture() { return dateFacture; }
    public void setDateFacture(String dateFacture) { this.dateFacture = dateFacture; }
    public String getDatePaiement() { return datePaiement; }
    public void setDatePaiement(String datePaiement) { this.datePaiement = datePaiement; }
    public String getModeReglement() { return modeReglement; }
    public void setModeReglement(String modeReglement) { this.modeReglement = modeReglement; }
    public String getRemarqueReglement() { return remarqueReglement; }
    public void setRemarqueReglement(String remarqueReglement) { this.remarqueReglement = remarqueReglement; }
    public PiecesJointes getPiecesJointes() { return piecesJointes; }
    public void setPiecesJointes(PiecesJointes piecesJointes) { this.piecesJointes = piecesJointes; }
    // Getters pour les pièces jointes individuelles
    public String getPvReceptionProvisoire() { 
        return piecesJointes != null && piecesJointes.pvReceptionProvisoire != null ? 
               piecesJointes.pvReceptionProvisoire.nomFichier : null; 
    }
    public String getPvReceptionDefinitif() { 
        return piecesJointes != null && piecesJointes.pvReceptionDefinitive != null ? 
               piecesJointes.pvReceptionDefinitive.nomFichier : null; 
    }
    public String getAttestationReference() { 
        return piecesJointes != null && piecesJointes.attestationReference != null ? 
               piecesJointes.attestationReference.nomFichier : null; 
    }
    public String getContrat() { 
        return piecesJointes != null && piecesJointes.contrat != null ? 
               piecesJointes.contrat.nomFichier : null; 
    }
    public String getSuiviExecutionDetaillePieceJointe() { 
        return piecesJointes != null && piecesJointes.suiviExecutionDetaille != null ? 
               piecesJointes.suiviExecutionDetaille.nomFichier : null; 
    }
    public String getSuiviReglementDetaillePieceJointe() { 
        return piecesJointes != null && piecesJointes.suiviReglementDetaille != null ? 
               piecesJointes.suiviReglementDetaille.nomFichier : null; 
    }
} 