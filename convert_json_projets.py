import json

# Mapping des clés JSON -> Java
KEY_MAP = {
    "Client": "client",
    "N° Projet/CONTRAT": "numeroProjet",
    "Désignation projet": "designation",
    "Type de projet": "typeProjet",
    "Responsable CP Interne": "responsableInterne",
    "Responsable CP Externe": "responsableExterne",
    "Durée contractuelle": "dureeContractuelle",
    "Date de début": "dateDebut",
    "Date de fin effective": "dateFinEffective",
    "% Avancement": "avancement",
    "Statut EXE": "statutExecution",
    "Montant total contrat TTC": "montantContratTTC",
    "Montant avenant": "montantAvenant",
    "Montant cumulé attachement TTC": "montantCumul",
    "Montant total encaisse TTC": "montantEncaisse",
    "Solde restant": "soldeRestant",
    "Statut Facturation": "statutFacturation",
    "Remarques": "remarques",
    "pieces_jointes": "piecesJointes"
}

# Mapping pour les sous-clés de piecesJointes
PIECES_JOINTES_KEY_MAP = {
    "contrat": "contrat",
    "pv_reception_provisoire": "pvReceptionProvisoire",
    "pv_reception_definitive": "pvReceptionDefinitive",
    "attestation_reference": "attestationReference",
    "suivi_execution_detaille": "suiviExecutionDetaille",
    "suivi_reglement_detaille": "suiviReglementDetaille"
}

PIECE_JOINTE_KEY_MAP = {
    "nom_fichier": "nomFichier",
    "statut": "statut",
    "format": "format"
}

def convert_piece_jointe(piece):
    if isinstance(piece, dict):
        return {PIECE_JOINTE_KEY_MAP.get(k, k): v for k, v in piece.items()}
    return piece

def convert_pieces_jointes(pj_dict):
    return {PIECES_JOINTES_KEY_MAP.get(k, k): convert_piece_jointe(v) for k, v in pj_dict.items()}

# Conversion d'une entrée
def convert_entry(entry):
    new_entry = {}
    for k, v in entry.items():
        new_key = KEY_MAP.get(k, k)
        if new_key == "piecesJointes" and isinstance(v, dict):
            new_entry[new_key] = convert_pieces_jointes(v)
        else:
            new_entry[new_key] = v
    return new_entry

# Lecture du fichier source
with open("src/main/resources/projets_tous_complets.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# Conversion
converted = [convert_entry(e) for e in data]

# Sauvegarde du résultat
with open("src/main/resources/projets_tous_complets_converted.json", "w", encoding="utf-8") as f:
    json.dump(converted, f, ensure_ascii=False, indent=2)

print("Conversion terminée ! Fichier généré : projets_tous_complets_converted.json") 