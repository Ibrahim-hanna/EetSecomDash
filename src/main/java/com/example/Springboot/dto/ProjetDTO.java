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
    @JsonProperty("statutFacturation")
    private String statutFacturation;
    @JsonProperty("remarques")
    private String remarques;
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
    public String getStatutFacturation() { return statutFacturation; }
    public void setStatutFacturation(String statutFacturation) { this.statutFacturation = statutFacturation; }
    public String getRemarques() { return remarques; }
    public void setRemarques(String remarques) { this.remarques = remarques; }
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