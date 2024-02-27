# DATA CLEANING - COLUMN NAMES, FORMATS, AND PRIMARY KEYS

# Update column names with incorrect syntax from upload

	ALTER TABLE covid_influenza_data
	RENAME COLUMN ï»¿record_id TO record_id;

	ALTER TABLE staffing_data
	RENAME COLUMN ï»¿record_id TO record_id;

	ALTER TABLE state_data
	RENAME COLUMN ï»¿state TO state;
    
# Update date field in state_data table to proper format

	UPDATE state_data
	SET date = DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%Y'), '%Y-%m-%d');

# Add column for new date field as a DATE data type

	ALTER TABLE state_data
	ADD COLUMN record_date DATE AFTER state;

# Assign dates from original 'date' field to 'record_date' field in proper data type

	UPDATE state_data
	SET record_date = STR_TO_DATE(date, '%Y-%m-%d');

# Drop old 'date' column and 'geocoded_state' column since there are no values for geocode

	ALTER TABLE state_data
	DROP COLUMN date,
	DROP COLUMN geocoded_state;
    
# Assign PRIMARY KEY for all tables as the 'record_id'

	ALTER TABLE state_data
        ADD PRIMARY KEY(record_id(6));
    
        ALTER TABLE bed_data
        ADD PRIMARY KEY(record_id(6));
    
        ALTER TABLE staffing_data
        ADD PRIMARY KEY(record_id(6));
    
        ALTER TABLE covid_influenza_data
        ADD PRIMARY KEY(record_id(6));
    
    
# DATA CLEANSING COMPLETE

    







