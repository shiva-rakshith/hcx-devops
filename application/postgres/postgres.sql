\c postgres hcxpostgresql

CREATE TABLE IF NOT EXISTS mock_participant(
    parent_participant_code char varying , 
    child_participant_code char varying primary key, 
    primary_email char varying,
    password char varying,
    private_key char varying,
);

\q
