.headers on
.mode tabs

SELECT DISTINCT
    o.scientific_name
FROM observations o
LEFT JOIN v_taxa_lepidoptera t
    ON t.scientific_name = o.scientific_name
WHERE t.scientific_name IS NULL
ORDER BY o.scientific_name;
