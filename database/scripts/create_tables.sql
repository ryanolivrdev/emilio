
CREATE TABLE IF NOT EXISTS institution (
  institution_code VARCHAR(5) NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS collection (
  collection_code VARCHAR(5) NOT NULL PRIMARY KEY,
  institution_code VARCHAR(5) NOT NULL,
  FOREIGN KEY (institution_code) REFERENCES institution(institution_code)
);

CREATE TABLE IF NOT EXISTS occurrence (
  occurrence_id VARCHAR(255) PRIMARY KEY,
  gbif_id VARCHAR(255) UNIQUE,
  catalog_number VARCHAR(255) NOT NULL UNIQUE,
  preparations VARCHAR(255),
  basic_of_record VARCHAR(255) NOT NULL,
  event_data timestamp,
  event_remarks VARCHAR(255),
  specimen_id INT NOT NULL UNIQUE,
  status BOOLEAN NOT NULL,
  location_id INT NOT NULL,
  collection_code VARCHAR(5) NOT NULL,
  copyright_id INT NOT NULL,
  recorded_by VARCHAR(255),
  FOREIGN KEY (collection_code) REFERENCES collection(collection_code)
);

CREATE TABLE IF NOT EXISTS copyright (
  id SERIAL PRIMARY KEY,
  access_rights VARCHAR(255) NOT NULL UNIQUE,
  license VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS location (
  id SERIAL PRIMARY KEY,
  local VARCHAR(255),
  municipality VARCHAR(255),
  state_province VARCHAR(255),
  country VARCHAR(255),
  continent VARCHAR(255),
  decimal_latitude VARCHAR(255),
  decimal_longitude VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS specimen (
  id SERIAL PRIMARY KEY,
  scienctific_name VARCHAR(255) NOT NULL,
  kingdom VARCHAR(255) NOT NULL,
  phylum VARCHAR(255),
  class VARCHAR(255),
  order_specimen VARCHAR(255),
  family VARCHAR(255),
  generic_name VARCHAR(255),
  specific_epithet VARCHAR(255),
  taxon_rank VARCHAR(255) NOT NULL,
  taxonomic_status VARCHAR(255),
  infraspecific_epithet VARCHAR(255),
  last_parsed timestamp NOT NULL,
  last_crawled timestamp NOT NULL,
  last_interpreted timestamp NOT NULL
);

ALTER TABLE occurrence
  ADD FOREIGN KEY (copyright_id) REFERENCES copyright(id),
  ADD FOREIGN KEY (collection_code) REFERENCES collection(collection_code),
  ADD FOREIGN KEY (location_id) REFERENCES location(id),
  ADD FOREIGN KEY (specimen_id) REFERENCES specimen(id);

CREATE TABLE IF NOT EXISTS log (
  id SERIAL PRIMARY KEY,
  message VARCHAR(900) NOT NULL,
  timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE VIEW occurrence_specimen_location_collection AS
SELECT
  o.occurrence_id,
  o.gbif_id,
  o.catalog_number,
  o.preparations,
  o.basic_of_record,
  o.event_data,
  o.event_remarks,
  o.specimen_id,
  o.status,
  o.recorded_by,
  s.scienctific_name,
  s.kingdom,
  s.phylum,
  s.class,
  s.order_specimen,
  s.family,
  s.generic_name,
  s.specific_epithet,
  s.taxon_rank,
  s.taxonomic_status,
  s.infraspecific_epithet,
  s.last_parsed,
  s.last_crawled,
  s.last_interpreted,
  l.local,
  l.municipality,
  l.state_province,
  l.country,
  l.continent,
  l.decimal_latitude,
  l.decimal_longitude,
  c.collection_code,
  c.institution_code
FROM occurrence o
INNER JOIN specimen s ON o.specimen_id = s.id
INNER JOIN location l ON o.location_id = l.id
INNER JOIN collection c ON o.collection_code = c.collection_code;

CREATE OR REPLACE VIEW recorded AS
SELECT
  recorded,
  COUNT(recorded) AS count
FROM occurrence,
  unnest(string_to_array(recorded_by, ';')) AS recorded
GROUP BY recorded
