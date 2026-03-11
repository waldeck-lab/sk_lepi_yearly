import csv
import sqlite3
from pathlib import Path

DB_PATH = "obsperyear.sqlite"
TAXON_CSV = "proj_taxonomy/Taxon.csv"

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
    taxon_path = Path(TAXON_CSV)
    if not taxon_path.exists():
        raise FileNotFoundError(f"Missing file: {taxon_path}")

    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    cur.execute("""
    CREATE TABLE IF NOT EXISTS taxa (
        taxon_id INTEGER PRIMARY KEY,
        accepted_taxon_id INTEGER,
        parent_taxon_id INTEGER,
        scientific_name TEXT,
        author_text TEXT,
        vernacular_name TEXT,
        taxon_rank TEXT,
        family_name TEXT,
        genus_name TEXT,
        species_name TEXT,
        order_name TEXT,
        class_name TEXT,
        phylum_name TEXT,
        kingdom_name TEXT,
        taxonomic_status TEXT,
        raw_json TEXT,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
    """)

    cur.execute("CREATE INDEX IF NOT EXISTS idx_taxa_family ON taxa(family_name)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_taxa_order ON taxa(order_name)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_taxa_rank ON taxa(taxon_rank)")

    insert_sql = """
    INSERT INTO taxa (
        taxon_id,
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
        raw_json,
        updated_at
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
    ON CONFLICT(taxon_id) DO UPDATE SET
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
        raw_json = excluded.raw_json,
        updated_at = CURRENT_TIMESTAMP
    """

    inserted = 0

    with open(taxon_path, "r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f, delimiter="\t")
        print("Columns found:")
        print(reader.fieldnames)

        for row in reader:
            taxon_id = lsid_to_int(row.get("taxonId"))
            if taxon_id is None:
                continue

            values = (
                taxon_id,
                lsid_to_int(row.get("acceptedNameUsageID")),
                lsid_to_int(row.get("parentNameUsageID")),
                row.get("scientificName"),
                row.get("scientificNameAuthorship"),
                None,  # fyller på svenska namn senare från VernacularName.csv
                row.get("taxonRank"),
                row.get("family"),
                row.get("genus"),
                row.get("species"),
                row.get("order"),
                row.get("class"),
                row.get("phylum"),
                row.get("kingdom"),
                row.get("taxonomicStatus"),
                str(row),
            )

            cur.execute(insert_sql, values)
            inserted += 1

            if inserted <= 3:
                print(
                    f"Sample {inserted}: "
                    f"taxon_id={values[0]}, sci={values[3]}, rank={values[6]}, family={values[7]}"
                )

    conn.commit()

    print(f"Imported/updated {inserted} taxa")

    cur.execute("SELECT COUNT(*) FROM taxa")
    print("Rows now in taxa:", cur.fetchone()[0])

    conn.close()

if __name__ == "__main__":
    main()
