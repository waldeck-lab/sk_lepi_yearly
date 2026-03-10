CREATE DATABASE IF NOT EXISTS ObsPerYear;
USE ObsPerYear;

CREATE TABLE observations (
    obs_id BIGINT PRIMARY KEY,
    taxon_id INT NOT NULL,
    taxon_sort_order INT,
    red_list_code VARCHAR(10),

    common_name VARCHAR(255),
    scientific_name VARCHAR(255),
    author_text VARCHAR(255),

    individual_count VARCHAR(50),
    life_stage VARCHAR(100),
    sex VARCHAR(50),
    method VARCHAR(255),

    locality VARCHAR(255),
    socken VARCHAR(255),
    reporter VARCHAR(255),

    observed_at DATETIME,
    source_comment TEXT,

    source_modified_at DATETIME,

    imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_taxon (taxon_id),
    INDEX idx_date (observed_at),
    INDEX idx_modified (source_modified_at),
    INDEX idx_redlist (red_list_code)
);
