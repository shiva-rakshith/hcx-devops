\c postgres hcxpostgresql

DROP TABLE payersystem_data;

CREATE DATABASE mock_service;

\c mock_service hcxpostgresql

CREATE TABLE IF NOT EXISTS payersystem_data
 (
     request_id character varying PRIMARY KEY,
     sender_code character varying,
     recipient_code character varying,
     action character varying,
     raw_payload character varying,
     request_fhir character varying,
     response_fhir character varying,
     status character varying,
     additional_info JSON,
     created_on bigInt,
     updated_on bigInt,
     on_action_status character varying
 ); 

CREATE TABLE IF NOT EXISTS mock_participant(
    parent_participant_code char varying , 
    child_participant_code char varying primary key, 
    primary_email char varying,
    password char varying,
    private_key char varying
);

\q
