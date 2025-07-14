package com.example.Springboot.dto;

public class SuiviExecutionDTO {
    private int totalProjets;
    private int projetsEnCours;
    private int projetsTermines;
    private int projetsEnAttente;

    public SuiviExecutionDTO() {}
    public SuiviExecutionDTO(int total, int enCours, int termines, int enAttente) {
        this.totalProjets = total;
        this.projetsEnCours = enCours;
        this.projetsTermines = termines;
        this.projetsEnAttente = enAttente;
    }
    public int getTotalProjets() { return totalProjets; }
    public void setTotalProjets(int totalProjets) { this.totalProjets = totalProjets; }
    public int getProjetsEnCours() { return projetsEnCours; }
    public void setProjetsEnCours(int projetsEnCours) { this.projetsEnCours = projetsEnCours; }
    public int getProjetsTermines() { return projetsTermines; }
    public void setProjetsTermines(int projetsTermines) { this.projetsTermines = projetsTermines; }
    public int getProjetsEnAttente() { return projetsEnAttente; }
    public void setProjetsEnAttente(int projetsEnAttente) { this.projetsEnAttente = projetsEnAttente; }
} 