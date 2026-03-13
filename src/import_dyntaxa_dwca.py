# file: ./src/import_dyntaxa_dwca.py
# Description: Imports/updates last fetched DWCA CSV into the SQLite local DB

import csv
import json
import os
import sqlite3
from pathlib import Path

ROOT_DIR = Path(os.getenv("SKLEPI_ROOT", Path(__file__).resolve().parents[1]))
DB_PATH = Path(os.getenv("SKLEPI_DB_PATH", ROOT_DIR / "db" / "obsperyear.sqlite"))
TAXONOMY_DIR = Path(os.getenv("SKLEPI_TAXONOMY_DIR", ROOT_DIR / "dwca"))
TAXON_CSV = TAXONOMY_DIR / "Taxon.csv"


def lsid_to_int(value):
    if not value:
        return None
    value = value.strip()
    if ":" in value:
        try:
            return int(value.split(":")[-1])
        except ValueError:
            return None
    try:
        return int(value)
    except ValueError:
        return None


def main():
    if not TAXON_CSV.exists():
        raise FileNotFoundError(f"Missing file: {TAXON_CSV}")

    if not DB_PATH.exists():
        raise FileNotFoundError(
            f"Database file does not exist: {DB_PATH}. "
            f"Initialize it first with schema.sql."
        )

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    insert_sql = """
    INSERT INTO taxa (
        taxon_id,
        taxon_lsid,
        accepted_taxon_id,
        parent_taxon_id,
        scientific_name,
        author_text,
        vernacular_name,
        taxon_rank,
        family_name,
        genus_name,
        species_name,
        order_name,
        class_name,
        phylum_name,
        kingdom_name,
        taxonomic_status,
        nomenclatural_status,
        taxon_remarks,
        raw_json,
        updated_at
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
    ON CONFLICT(taxon_id) DO UPDATE SET
        taxon_lsid = excluded.taxon_lsid,
        accepted_taxon_id = excluded.accepted_taxon_id,
        parent_taxon_id = excluded.parent_taxon_id,
        scientific_name = excluded.scientific_name,
        author_text = excluded.author_text,
        vernacular_name = excluded.vernacular_name,
        taxon_rank = excluded.taxon_rank,
        family_name = excluded.family_name,
        genus_name = excluded.genus_name,
        species_name = excluded.species_name,
        order_name = excluded.order_name,
        class_name = excluded.class_name,
        phylum_name = excluded.phylum_name,
        kingdom_name = excluded.kingdom_name,
        taxonomic_status = excluded.taxonomic_status,
        nomenclatural_status = excluded.nomenclatural_status,
        taxon_remarks = excluded.taxon_remarks,
        raw_json = excluded.raw_json,
        updated_at = CURRENT_TIMESTAMP
    """

    inserted = 0

    with open(TAXON_CSV, "r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f, delimiter="\t")
        print("Columns found:")
        print(reader.fieldnames)

        for row in reader:
            taxon_lsid = row.get("taxonId")
            taxon_id = lsid_to_int(taxon_lsid)
            if taxon_id is None:
                continue

            values = (
                taxon_id,
                taxon_lsid,
                lsid_to_int(row.get("acceptedNameUsageID")),
                lsid_to_int(row.get("parentNameUsageID")),
                row.get("scientificName"),
                row.get("scientificNameAuthorship"),
                None,
                row.get("taxonRank"),
                row.get("family"),
                row.get("genus"),
                row.get("species"),
                row.get("order"),
                row.get("class"),
                row.get("phylum"),
                row.get("kingdom"),
                row.get("taxonomicStatus"),
                row.get("nomenclaturalStatus"),
                row.get("taxonRemarks"),
                json.dumps(row, ensure_ascii=False),
            )

            cur.execute(insert_sql, values)
            inserted += 1

            if inserted <= 3:
                print(
                    f"Sample {inserted}: "
                    f"taxon_id={values[0]}, sci={values[4]}, rank={values[7]}, family={values[8]}"
                )

    conn.commit()

    print(f"Imported/updated {inserted} taxa")

    cur.execute("SELECT COUNT(*) FROM taxa")
    print("Rows now in taxa:", cur.fetchone()[0])

    conn.close()


if __name__ == "__main__":
    main()
