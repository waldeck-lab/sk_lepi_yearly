import json
import os
import sqlite3
import time
from typing import Any

import requests

DB_PATH = "obsperyear.sqlite"
BASE_URL = "https://api.artdatabanken.se/species-observation-system/v1"
TAKE = 500
SKANE_COUNTY_ID = "12"

API_KEY = os.getenv("SOS_API_KEY", "")
AUTH_TOKEN = os.getenv("SOS_AUTH_TOKEN", "")

if not API_KEY:
    raise RuntimeError("Missing SOS_API_KEY environment variable")

if not AUTH_TOKEN:
    raise RuntimeError("Missing SOS_AUTH_TOKEN environment variable")

HEADERS = {
    "X-Api-Version": "1.5",
    "Content-Type": "application/json",
    "Cache-Control": "no-cache",
    "Ocp-Apim-Subscription-Key": API_KEY,
    "Authorization": f"Bearer {AUTH_TOKEN}",
}

PAYLOAD = {
    "taxon": {
        "ids": [3000188],  # Lepidoptera
        "includeUnderlyingTaxa": True
    },
    "date": {
        "startDate": "2025-01-01",
        "endDate": "2025-12-31"
    }
}

INSERT_SQL = """
INSERT INTO observations (
    obs_id,
    taxon_id,
    taxon_sort_order,
    red_list_code,
    common_name,
    scientific_name,
    author_text,
    individual_count,
    life_stage,
    sex,
    method,
    locality,
    socken,
    reporter,
    reported_by,
    observed_at,
    observed_end_at,
    source_comment,
    source_dataset,
    county_id,
    county_name,
    municipality_id,
    municipality_name,
    decimal_latitude,
    decimal_longitude,
    coordinate_uncertainty_meters,
    verified,
    uncertain_identification,
    raw_json,
    updated_at
)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
ON CONFLICT(obs_id) DO UPDATE SET
    taxon_id = excluded.taxon_id,
    taxon_sort_order = excluded.taxon_sort_order,
    red_list_code = excluded.red_list_code,
    common_name = excluded.common_name,
    scientific_name = excluded.scientific_name,
    author_text = excluded.author_text,
    individual_count = excluded.individual_count,
    life_stage = excluded.life_stage,
    sex = excluded.sex,
    method = excluded.method,
    locality = excluded.locality,
    socken = excluded.socken,
    reporter = excluded.reporter,
    reported_by = excluded.reported_by,
    observed_at = excluded.observed_at,
    observed_end_at = excluded.observed_end_at,
    source_comment = excluded.source_comment,
    source_dataset = excluded.source_dataset,
    county_id = excluded.county_id,
    county_name = excluded.county_name,
    municipality_id = excluded.municipality_id,
    municipality_name = excluded.municipality_name,
    decimal_latitude = excluded.decimal_latitude,
    decimal_longitude = excluded.decimal_longitude,
    coordinate_uncertainty_meters = excluded.coordinate_uncertainty_meters,
    verified = excluded.verified,
    uncertain_identification = excluded.uncertain_identification,
    raw_json = excluded.raw_json,
    updated_at = CURRENT_TIMESTAMP
"""

def get_nested(d: dict[str, Any], path: list[str], default=None):
    cur = d
    for key in path:
        if not isinstance(cur, dict) or key not in cur:
            return default
        cur = cur[key]
    return cur

def to_int_bool(value):
    if value is True:
        return 1
    if value is False:
        return 0
    return None

def extract_row(rec: dict[str, Any]):
    obs_id = get_nested(rec, ["occurrence", "occurrenceId"])
    if not obs_id:
        return None

    return (
        str(obs_id),
        get_nested(rec, ["taxon", "id"]),
        get_nested(rec, ["taxon", "sortOrder"]),
        get_nested(rec, ["taxon", "attributes", "redlistCategory"]),
        get_nested(rec, ["taxon", "vernacularName"]),
        get_nested(rec, ["taxon", "scientificName"]),
        get_nested(rec, ["taxon", "author"]),
        get_nested(rec, ["occurrence", "individualCount"]),
        get_nested(rec, ["occurrence", "lifeStage", "value"]),
        get_nested(rec, ["occurrence", "sex", "value"]),
        get_nested(rec, ["occurrence", "behavior", "value"]),
        get_nested(rec, ["location", "locality"]),
        get_nested(rec, ["location", "parish", "name"]),
        get_nested(rec, ["occurrence", "recordedBy"]),
        get_nested(rec, ["occurrence", "reportedBy"]),
        get_nested(rec, ["event", "startDate"]),
        get_nested(rec, ["event", "endDate"]),
        get_nested(rec, ["occurrence", "occurrenceRemarks"]),
        rec.get("datasetName"),
        get_nested(rec, ["location", "county", "featureId"]),
        get_nested(rec, ["location", "county", "name"]),
        get_nested(rec, ["location", "municipality", "featureId"]),
        get_nested(rec, ["location", "municipality", "name"]),
        get_nested(rec, ["location", "decimalLatitude"]),
        get_nested(rec, ["location", "decimalLongitude"]),
        get_nested(rec, ["location", "coordinateUncertaintyInMeters"]),
        to_int_bool(get_nested(rec, ["identification", "verified"])),
        to_int_bool(get_nested(rec, ["identification", "uncertainIdentification"])),
        json.dumps(rec, ensure_ascii=False),
    )

def main():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    skip = 0
    seen = 0
    inserted_or_updated = 0
    kept_skane = 0

    while True:
        url = (
            f"{BASE_URL}/Observations/Search"
            f"?skip={skip}&take={TAKE}"
            f"&validateSearchFilter=false"
            f"&translationCultureCode=sv-SE"
            f"&sensitiveObservations=false"
            f"&geoJsonExcludeNullValues=false"
        )

        resp = requests.post(url, headers=HEADERS, json=PAYLOAD, timeout=120)
        resp.raise_for_status()
        data = resp.json()

        records = data.get("records", [])
        total = data.get("totalCount", 0)

        if not records:
            break

        for rec in records:
            seen += 1

            county_id = get_nested(rec, ["location", "county", "featureId"])
            if str(county_id) != SKANE_COUNTY_ID:
                continue

            row = extract_row(rec)
            if row is None:
                continue

            cur.execute(INSERT_SQL, row)
            inserted_or_updated += 1
            kept_skane += 1

        conn.commit()
        processed = min(skip + TAKE, total)
        print(f"Processed {processed}/{total} | kept Skåne: {kept_skane}")

        skip += TAKE
        time.sleep(0.2)

    cur.execute(
        """
        INSERT INTO sync_state(sync_name, last_run_at, last_skip, notes)
        VALUES (?, CURRENT_TIMESTAMP, ?, ?)
        ON CONFLICT(sync_name) DO UPDATE SET
            last_run_at = CURRENT_TIMESTAMP,
            last_skip = excluded.last_skip,
            notes = excluded.notes
        """,
        ("skane_lepidoptera_2025", skip, f"Seen={seen}, kept_skane={kept_skane}")
    )
    conn.commit()
    conn.close()

    print(f"Done. Seen={seen}, inserted_or_updated={inserted_or_updated}, kept_skane={kept_skane}")

if __name__ == "__main__":
    main()
