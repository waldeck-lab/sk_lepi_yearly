import os
import requests
import csv
import mysql.connector
import io
import json

BASE_URL = "https://api.artdatabanken.se/species-observation-system/v1"

SEARCH_URL = f"{BASE_URL}/Observations/Search?skip=0&take=100&validateSearchFilter=false&translationCultureCode=sv-SE&sensitiveObservations=false&geoJsonExcludeNullValues=false"

API_KEY = os.getenv("SOS_API_KEY", "")
AUTH_TOKEN = os.getenv("SOS_AUTH_TOKEN", "")

MYSQL_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "ObsPerYear")
}

with open("filter_2025_lepidoptera_sk.json", encoding="utf-8") as f:
    FILTER = json.load(f)

headers = {
    "X-Api-Version": "1.5",
    "Content-Type": "application/json",
    "Cache-Control": "no-cache",
    "Ocp-Apim-Subscription-Key": API_KEY
}

if AUTH_TOKEN:
    headers["Authorization"] = AUTH_TOKEN

print("Downloading observations...")
response = requests.post(SEARCH_URL, headers=headers, json=FILTER, timeout=120)
print("HTTP status:", response.status_code)
print(response.text[:1000])
response.raise_for_status()


csv_data = response.text

print("Connecting to MySQL...")

db = mysql.connector.connect(**MYSQL_CONFIG)
cursor = db.cursor()

reader = csv.DictReader(io.StringIO(csv_data))

insert_sql = """
INSERT INTO observations (
obs_id, taxon_id, taxon_sort_order, red_list_code,
common_name, scientific_name, author_text,
individual_count, life_stage, sex, method,
locality, socken, reporter,
observed_at, source_comment, source_modified_at
)
VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
ON DUPLICATE KEY UPDATE
red_list_code=VALUES(red_list_code),
source_comment=VALUES(source_comment),
source_modified_at=VALUES(source_modified_at),
updated_at=NOW()
"""

for row in reader:

    values = (
        row.get("observationId"),
        row.get("taxonId"),
        row.get("taxonSortOrder"),
        row.get("redListCategory"),

        row.get("vernacularName"),
        row.get("scientificName"),
        row.get("author"),

        row.get("individualCount"),
        row.get("lifeStage"),
        row.get("sex"),
        row.get("samplingMethod"),

        row.get("locality"),
        row.get("province"),
        row.get("recordedBy"),

        row.get("eventDate"),
        row.get("occurrenceRemarks"),
        row.get("modified")
    )

    cursor.execute(insert_sql, values)

db.commit()

print("Import complete")

