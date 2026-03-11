import json
import os
import sqlite3
import time
from typing import Any

import requests

DB_PATH = "obsperyear.sqlite"
BASE_URL = "https://api.artdatabanken.se/species-observation-system/v1"
TAKE = 1000
SYNC_NAME = "skane_lepidoptera_2025_base"

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
    "Accept-Encoding": "gzip, deflate",
    "Ocp-Apim-Subscription-Key": API_KEY,
    "Authorization": f"Bearer {AUTH_TOKEN}",
}

MONTH_PERIODS = [
    ("2025-01-01", "2025-01-31"),
    ("2025-02-01", "2025-02-28"),
    ("2025-03-01", "2025-03-31"),
    ("2025-04-01", "2025-04-30"),
    ("2025-05-01", "2025-05-31"),
    ("2025-06-01", "2025-06-30"),
    ("2025-07-01", "2025-07-31"),
    ("2025-08-01", "2025-08-31"),
    ("2025-09-01", "2025-09-30"),
    ("2025-10-01", "2025-10-31"),
    ("2025-11-01", "2025-11-30"),
    ("2025-12-01", "2025-12-31"),
]


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
    province_id,
    province_name,
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
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
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
    province_id = excluded.province_id,
    province_name = excluded.province_name,
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

def fetch_page(skip: int, take: int, payload: dict[str, Any], max_retries: int = 8):
    url = (
        f"{BASE_URL}/Observations/Search"
        f"?skip={skip}&take={take}"
        f"&validateSearchFilter=false"
        f"&translationCultureCode=sv-SE"
        f"&sensitiveObservations=false"
        f"&geoJsonExcludeNullValues=false"
    )

    wait_seconds = 5

    for attempt in range(1, max_retries + 1):
        resp = requests.post(url, headers=HEADERS, json=payload, timeout=180)

        if resp.status_code == 429:
            retry_after = resp.headers.get("Retry-After")
            if retry_after:
                try:
                    wait_seconds = max(wait_seconds, int(retry_after))
                except ValueError:
                    pass
            print(f"429 Too Many Requests at skip={skip}. Sleeping {wait_seconds}s, retry {attempt}/{max_retries}")
            time.sleep(wait_seconds)
            wait_seconds = min(wait_seconds * 2, 300)
            continue

        if 500 <= resp.status_code < 600:
            print(f"Server error {resp.status_code} at skip={skip}. Sleeping {wait_seconds}s, retry {attempt}/{max_retries}")
            time.sleep(wait_seconds)
            wait_seconds = min(wait_seconds * 2, 300)
            continue

        resp.raise_for_status()
        return resp.json()

    raise RuntimeError(f"Failed to fetch page after repeated retries at skip={skip}")

def extract_row(rec: dict[str, Any]):
    obs_id = get_nested(rec, ["occurrence", "occurrenceId"])
    if not obs_id:
        return None

    taxon_attrs = get_nested(rec, ["taxon", "attributes"], {}) or {}

    red_list_code = taxon_attrs.get("redlistCategory")
    source_comment = get_nested(rec, ["occurrence", "occurrenceRemarks"])
    socken = get_nested(rec, ["location", "parish", "name"])

    
    return (
        str(obs_id),
        get_nested(rec, ["taxon", "id"]),
        get_nested(rec, ["taxon", "sortOrder"]),
        taxon_attrs.get("redlistCategory"),
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
        get_nested(rec, ["location", "province", "featureId"]),
        get_nested(rec, ["location", "province", "name"]),
        get_nested(rec, ["location", "municipality", "featureId"]),
        get_nested(rec, ["location", "municipality", "name"]),
        get_nested(rec, ["location", "decimalLatitude"]),
        get_nested(rec, ["location", "decimalLongitude"]),
        get_nested(rec, ["location", "coordinateUncertaintyInMeters"]),
        to_int_bool(get_nested(rec, ["identification", "verified"])),
        to_int_bool(get_nested(rec, ["identification", "uncertainIdentification"])),
        json.dumps(rec, ensure_ascii=False),
    )

def get_resume_skip(cur: sqlite3.Cursor) -> int:
    cur.execute("SELECT last_skip FROM sync_state WHERE sync_name = ?", (SYNC_NAME,))
    row = cur.fetchone()
    if row and row[0] is not None:
        return int(row[0])
    return 0

def save_progress(cur: sqlite3.Cursor, skip: int, total_count: int, notes: str):
    cur.execute(
        """
        INSERT INTO sync_state(sync_name, last_run_at, last_skip, last_total_count, notes)
        VALUES (?, CURRENT_TIMESTAMP, ?, ?, ?)
        ON CONFLICT(sync_name) DO UPDATE SET
            last_run_at = CURRENT_TIMESTAMP,
            last_skip = excluded.last_skip,
            last_total_count = excluded.last_total_count,
            notes = excluded.notes
        """,
        (SYNC_NAME, skip, total_count, notes)
    )

def build_payload(start_date: str, end_date: str) -> dict:
    return {
        "taxon": {
            "ids": [3000188],
            "includeUnderlyingTaxa": True
        },
        "geographics": {
            "areas": [
                {
                    "areaType": "County",
                    "featureId": "12"
                }
            ]
        },
        "date": {
            "startDate": start_date,
            "endDate": end_date,
            "dateFilterType": "BetweenStartDateAndEndDate"
        },
        "dataProvider": {
            "ids": [1]
        },
        "occurrenceStatus": "present",
        "determinationFilter": "NotUnsureDetermination",
        "notRecoveredFilter": "DontIncludeNotRecovered",
        "output": {
            "fieldSet": "Minimum",
            "fields": [
                "datasetName",
                "event.startDate",
                "event.endDate",
                "identification.verified",
                "identification.uncertainIdentification",
                "location.locality",
                "location.county",
                "location.province",
                "location.parish",
                "location.municipality",
                "location.decimalLatitude",
                "location.decimalLongitude",
                "location.coordinateUncertaintyInMeters",
                "occurrence.occurrenceId",
                "occurrence.recordedBy",
                "occurrence.reportedBy",
                "occurrence.individualCount",
                "occurrence.occurrenceRemarks",
                "taxon.id",
                "taxon.sortOrder",
                "taxon.scientificName",
                "taxon.vernacularName",
                "taxon.author",
                "taxon.attributes.redlistCategory",
                "taxon.attributes.isRedlisted",
                "taxon.family",
                "taxon.order"
            ]
        }
    }


def get_resume_state(cur: sqlite3.Cursor):
    cur.execute(
        "SELECT notes FROM sync_state WHERE sync_name = ?",
        (SYNC_NAME,)
    )
    row = cur.fetchone()
    if not row or not row[0]:
        return 0, 0

    notes = row[0]
    # format: month_index=3;skip=2000;seen=...
    parts = {}
    for item in notes.split(";"):
        if "=" in item:
            k, v = item.split("=", 1)
            parts[k] = v

    month_index = int(parts.get("month_index", 0))
    skip = int(parts.get("skip", 0))
    return month_index, skip


def save_progress(cur: sqlite3.Cursor, month_index: int, skip: int, total_count: int, seen: int, inserted_or_updated: int):
    notes = f"month_index={month_index};skip={skip};seen={seen};inserted_or_updated={inserted_or_updated}"
    cur.execute(
        """
        INSERT INTO sync_state(sync_name, last_run_at, last_skip, last_total_count, notes)
        VALUES (?, CURRENT_TIMESTAMP, ?, ?, ?)
        ON CONFLICT(sync_name) DO UPDATE SET
            last_run_at = CURRENT_TIMESTAMP,
            last_skip = excluded.last_skip,
            last_total_count = excluded.last_total_count,
            notes = excluded.notes
        """,
        (SYNC_NAME, skip, total_count, notes)
    )


def main():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    month_index, resume_skip = get_resume_state(cur)
    seen = 0
    inserted_or_updated = 0

    print(f"Starting sync from month_index={month_index}, skip={resume_skip}")

    for mi in range(month_index, len(MONTH_PERIODS)):
        start_date, end_date = MONTH_PERIODS[mi]
        payload = build_payload(start_date, end_date)
        skip = resume_skip if mi == month_index else 0

        print(f"Syncing period {start_date} -> {end_date} from skip={skip}")

        while True:
            data = fetch_page(skip=skip, take=TAKE, payload=payload)

            records = data.get("records", [])
            total_count = data.get("totalCount", 0)

            if not records:
                print(f"No more records for period {start_date} -> {end_date}")
                break

            for rec in records:
                row = extract_row(rec)
                if row is None:
                    continue
                cur.execute(INSERT_SQL, row)
                inserted_or_updated += 1
                seen += 1

            next_skip = skip + TAKE
            save_progress(cur, mi, next_skip, total_count, seen, inserted_or_updated)
            conn.commit()

            processed = min(next_skip, total_count)
            print(f"{start_date}..{end_date} | Processed {processed}/{total_count} | inserted_or_updated={inserted_or_updated}")

            if processed >= total_count:
                break

            skip = next_skip
            time.sleep(0.5)

        # next month starts from skip 0
        resume_skip = 0
        save_progress(cur, mi + 1, 0, 0, seen, inserted_or_updated)
        conn.commit()

    conn.close()
    print(f"Done. seen={seen}, inserted_or_updated={inserted_or_updated}")

if __name__ == "__main__":
    main()
