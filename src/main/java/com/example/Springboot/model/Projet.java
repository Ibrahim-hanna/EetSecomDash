package com.example.Springboot.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
public class Projet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = true, unique = true)
    private String numeroProjet; // N° Projet / CONTRAT (clé)

    private String client;
    private String designation;
    private String typeProjet;
    private String responsableInterne;
    private String responsableExterne;
    private String dureeContractuelle;

    private String montantContratTTC;
    private String montantAvenant;
    private String contratPieceJointe; // chemin ou nom du fichier

    private LocalDate dateDebut;
    private LocalDate dateFinEffective;
    private String avancement;
    private String statutExecution;
    private String montantCumul;
    private String montantEncaisse;
    private String soldeRestant;
    private String statutFacturation;

    private String remarques;

    // Pièces jointes réception
    private String pvReceptionProvisoire; // chemin ou nom du fichier
    private String pvReceptionDefinitif;
    private String attestationReference;

    // Pièces jointes Suivi détaillé
    private String suiviExecutionDetaillePieceJointe; // chemin ou nom du fichier
    private String suiviReglementDetaillePieceJointe; // chemin ou nom du fichier

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNumeroProjet() { return numeroProjet; }
    public void setNumeroProjet(String numeroProjet) { this.numeroProjet = numeroProjet; }
    public String getClient() { return client; }
    public void setClient(String client) { this.client = client; }
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
    public String getMontantContratTTC() { return montantContratTTC; }
    public void setMontantContratTTC(String montantContratTTC) { this.montantContratTTC = montantContratTTC; }
    public String getMontantAvenant() { return montantAvenant; }
    public void setMontantAvenant(String montantAvenant) { this.montantAvenant = montantAvenant; }
    public String getContratPieceJointe() { return contratPieceJointe; }
    public void setContratPieceJointe(String contratPieceJointe) { this.contratPieceJointe = contratPieceJointe; }
    public java.time.LocalDate getDateDebut() { return dateDebut; }
    public void setDateDebut(java.time.LocalDate dateDebut) { this.dateDebut = dateDebut; }
    public java.time.LocalDate getDateFinEffective() { return dateFinEffective; }
    public void setDateFinEffective(java.time.LocalDate dateFinEffective) { this.dateFinEffective = dateFinEffective; }
    public String getAvancement() { return avancement; }
    public void setAvancement(String avancement) { this.avancement = avancement; }
    public String getStatutExecution() { return statutExecution; }
    public void setStatutExecution(String statutExecution) { this.statutExecution = statutExecution; }
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
    public String getPvReceptionProvisoire() { return pvReceptionProvisoire; }
    public void setPvReceptionProvisoire(String pvReceptionProvisoire) { this.pvReceptionProvisoire = pvReceptionProvisoire; }
    public String getPvReceptionDefinitif() { return pvReceptionDefinitif; }
    public void setPvReceptionDefinitif(String pvReceptionDefinitif) { this.pvReceptionDefinitif = pvReceptionDefinitif; }
    public String getAttestationReference() { return attestationReference; }
    public void setAttestationReference(String attestationReference) { this.attestationReference = attestationReference; }
    public String getSuiviExecutionDetaillePieceJointe() { return suiviExecutionDetaillePieceJointe; }
    public void setSuiviExecutionDetaillePieceJointe(String suiviExecutionDetaillePieceJointe) { this.suiviExecutionDetaillePieceJointe = suiviExecutionDetaillePieceJointe; }
    public String getSuiviReglementDetaillePieceJointe() { return suiviReglementDetaillePieceJointe; }
    public void setSuiviReglementDetaillePieceJointe(String suiviReglementDetaillePieceJointe) { this.suiviReglementDetaillePieceJointe = suiviReglementDetaillePieceJointe; }
} 