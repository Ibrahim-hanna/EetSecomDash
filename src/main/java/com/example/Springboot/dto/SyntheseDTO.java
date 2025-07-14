package com.example.Springboot.dto;

public class SyntheseDTO {
    private int totalProjets;
    private int totalPiecesJointes;
    private int totalUtilisateurs;

    public SyntheseDTO() {}
    public SyntheseDTO(int totalProjets, int totalPiecesJointes, int totalUtilisateurs) {
        this.totalProjets = totalProjets;
        this.totalPiecesJointes = totalPiecesJointes;
        this.totalUtilisateurs = totalUtilisateurs;
    }
    public int getTotalProjets() { return totalProjets; }
    public void setTotalProjets(int totalProjets) { this.totalProjets = totalProjets; }
    public int getTotalPiecesJointes() { return totalPiecesJointes; }
    public void setTotalPiecesJointes(int totalPiecesJointes) { this.totalPiecesJointes = totalPiecesJointes; }
    public int getTotalUtilisateurs() { return totalUtilisateurs; }
    public void setTotalUtilisateurs(int totalUtilisateurs) { this.totalUtilisateurs = totalUtilisateurs; }
} 