# DATA EXPLORATION

# Total COVID-19 hospital cases (confirmed or suspected - includes ICU), total COVID-19 deaths, and death percentage

	SELECT SUM(inpatient_beds_used_covid) AS covid_cases,
	SUM(deaths_covid) AS covid_deaths,
	ROUND((SUM(deaths_covid)/SUM(inpatient_beds_used_covid) * 100),2) AS fatal_percentage
	FROM covid_influenza_data;

# Percentage of COVID-19 deaths from highest to lowest, grouped by state and year

	SELECT state, YEAR(record_date) as year,
	SUM(inpatient_beds_used_covid) AS covid_cases,
	SUM(deaths_covid) AS covid_deaths,
	ROUND((SUM(deaths_covid)/SUM(inpatient_beds_used_covid) * 100),2) AS fatal_percentage
	FROM covid_influenza_data cid
	JOIN state_data sd
		ON cid.record_id = sd.record_id
	GROUP BY state, year
	ORDER BY fatal_percentage DESC;

# Total hospitals reporting COVID-19 related cases, total COVID-19 deaths - ordered by death percentage by state.

	WITH cte AS
	(
		SELECT sd.state,
		SUM(total_adult_patients_hospitalized_conf_suspected_covid_coverage +
			total_ped_patients_hospitalized_conf_suspected_covid_coverage +
			adult_icu_bed_covid_utilization_coverage) AS covid_cases_reported,
		SUM(deaths_covid_coverage) AS covid_deaths_reported
		FROM covid_influenza_data cid
		JOIN state_data sd
			ON cid.record_id = sd.record_id
		WHERE deaths_covid_coverage > 0
		GROUP BY state
	)

	SELECT state, covid_cases_reported, covid_deaths_reported,
	ROUND((covid_deaths_reported/covid_cases_reported) * 100, 2) AS fatal_percentage
	FROM cte
	ORDER BY fatal_percentage DESC;
    
# Looking at the top 5 states with highest death percentage by hospital reporting over time
 
	SELECT sd.state,
	SUM(total_adult_patients_hospitalized_conf_suspected_covid_coverage +
		total_ped_patients_hospitalized_conf_suspected_covid_coverage +
		adult_icu_bed_covid_utilization_coverage) AS covid_cases_reported,
	SUM(deaths_covid_coverage) AS covid_deaths_reported,
    	CONCAT('Q', QUARTER(record_date), ' ', DATE_FORMAT(record_date, '%Y')) AS period
	FROM covid_influenza_data cid
	JOIN state_data sd
		ON cid.record_id = sd.record_id
	WHERE deaths_covid_coverage > 0 and sd.state IN ('MI','DC','MT','MA','AL')
	GROUP BY state, period
    	ORDER BY YEAR(period) ASC;
    
# Looking at COVID-19 confirmed cases by adult age for each state reported

	SELECT sd.state,
	SUM(`previous_day_admission_adult_covid_conf_18-19`) AS 18_19,
	SUM(`previous_day_admission_adult_covid_conf_20-29`) AS 20_29,
	SUM(`previous_day_admission_adult_covid_conf_30-39`) AS 30_39,
	SUM(`previous_day_admission_adult_covid_conf_40-49`) AS 40_49,
	SUM(`previous_day_admission_adult_covid_conf_50-59`) AS 50_59,
	SUM(`previous_day_admission_adult_covid_conf_60-69`) AS 60_69,
	SUM(`previous_day_admission_adult_covid_conf_70-79`) AS 70_79,
	SUM(`previous_day_admission_adult_covid_conf_80+`) AS above_80,
	SUM(`previous_day_admission_adult_covid_conf_unknown`) AS unk
	FROM covid_influenza_data cid
	JOIN state_data sd
		ON cid.record_id = sd.record_id
	GROUP BY state
	ORDER BY state;
    
# Looking at COVID-19 confirmed cases by child age for each state reported

	SELECT sd.state,
	SUM(previous_day_admission_pediatric_covid_conf_0_4) AS 0_4,
	SUM(previous_day_admission_pediatric_covid_conf_5_11) AS 5_11,
	SUM(previous_day_admission_pediatric_covid_conf_12_17) AS 12_17,
	SUM(previous_day_admission_pediatric_covid_conf_unknown) AS unk
	FROM covid_influenza_data cid
	JOIN state_data sd
		ON cid.record_id = sd.record_id
	GROUP BY state
	ORDER BY state;
    
# Create a VIEW to further analyze the adult COVID-19 cases by age with minimal script

	CREATE VIEW adult_covid_age AS
		SELECT sd.state,
		SUM(`previous_day_admission_adult_covid_conf_18-19`) AS 18_19,
		SUM(`previous_day_admission_adult_covid_conf_20-29`) AS 20_29,
		SUM(`previous_day_admission_adult_covid_conf_30-39`) AS 30_39,
		SUM(`previous_day_admission_adult_covid_conf_40-49`) AS 40_49,
		SUM(`previous_day_admission_adult_covid_conf_50-59`) AS 50_59,
		SUM(`previous_day_admission_adult_covid_conf_60-69`) AS 60_69,
		SUM(`previous_day_admission_adult_covid_conf_70-79`) AS 70_79,
		SUM(`previous_day_admission_adult_covid_conf_80+`) AS above_80,
		SUM(`previous_day_admission_adult_covid_conf_unknown`) AS unk
		FROM covid_influenza_data cid
		JOIN state_data sd
			ON cid.record_id = sd.record_id
		GROUP BY state
		ORDER BY state;

# Create a VIEW to further analyze the pediatric COVID-19 cases by age with minimal script

	CREATE VIEW child_covid_age AS
		SELECT sd.state,
		SUM(previous_day_admission_pediatric_covid_conf_0_4) AS 0_4,
		SUM(previous_day_admission_pediatric_covid_conf_5_11) AS 5_11,
		SUM(previous_day_admission_pediatric_covid_conf_12_17) AS 12_17,
		SUM(previous_day_admission_pediatric_covid_conf_unknown) AS unk
		FROM covid_influenza_data cid
		JOIN state_data sd
			ON cid.record_id = sd.record_id
		GROUP BY state
		ORDER BY state;

# Percentages and state total of COVID-19 adult cases by age, ordered on highest total
 
	WITH cte_adult AS 
	(
		SELECT *,
		(18_19 + 20_29 + 30_39 + 40_49 + 50_59 + 60_69 + 70_79 + above_80 + unk) AS state_total
		FROM adult_covid_age
		ORDER BY state_total DESC
	)
	SELECT state,
	ROUND((18_19/state_total) * 100, 2) AS 18_19_prcnt,
	ROUND((20_29/state_total) * 100, 2) AS 20_29_prcnt,
	ROUND((30_39/state_total) * 100, 2) AS 30_39_prcnt,
    	ROUND((40_49/state_total) * 100, 2) AS 40_49_prcnt,
	ROUND((50_59/state_total) * 100, 2) AS 50_59_prcnt,
	ROUND((60_69/state_total) * 100, 2) AS 60_69_prcnt,
    	ROUND((70_79/state_total) * 100, 2) AS 70_79_prcnt,
    	ROUND((above_80/state_total) * 100, 2) AS above_80_prcnt,
	ROUND((unk/state_total) * 100, 2) AS unk_prcnt,
	state_total
	FROM cte_adult;
    
# Percentages and state total of COVID-19 pediatric cases by age, ordered on highest total
 
	WITH cte_child AS 
	(
		SELECT *,
		(0_4+5_11+12_17+unk) AS state_total
		FROM child_covid_age
		ORDER BY state_total DESC
	)
	SELECT state,
	ROUND((0_4/state_total) * 100, 2) AS 0_4_prcnt,
	ROUND((5_11/state_total) * 100, 2) AS 5_11_prcnt,
	ROUND((12_17/state_total) * 100, 2) AS 12_17_prcnt,
	ROUND((unk/state_total) * 100, 2) AS unk_prcnt,
	state_total
	FROM cte_child;

# Comparing child and adult cases of COVID-19 to total dealths by state. Ordered on death percent
    
	WITH cte_compare AS
	(
		SELECT sd.state,
		(18_19 + 20_29 + 30_39 + 40_49 + 50_59 + 60_69 + 70_79 + above_80 + aca.unk) AS adult_cases,
		(0_4+5_11+12_17+cca.unk) AS child_cases,
		SUM(deaths_covid) AS total_covid_deaths
		FROM covid_influenza_data cid
		JOIN state_data sd
			ON cid.record_id = sd.record_id
		JOIN adult_covid_age aca
			ON sd.state = aca.state
		JOIN child_covid_age cca
			ON aca.state = cca.state
		GROUP BY sd.state
	)
	SELECT *,
	ROUND(total_covid_deaths/(adult_cases + child_cases) * 100,2) AS death_percent_of_total
	FROM cte_compare
	ORDER BY death_percent_of_total DESC;

# Looking at average available (and reported) inpatient/icu beds and pediatric 
# versus those beds in use for COVID-19 patients by state for month and year

	SELECT sd.state, 
	MONTHNAME(sd.record_date) AS month_name, 
	YEAR(sd.record_date) AS years,
	ROUND(AVG(inpatient_beds),2) AS avg_inp_avl, 
	ROUND(AVG(inpatient_beds_used_covid),2) AS avg_inp_used,
    	ROUND(AVG(all_pediatric_inpatient_beds),2) AS avg_ped_avl, 
	ROUND(AVG(all_pediatric_inpatient_bed_occupied),2) AS avg_ped_used
	FROM bed_data bd
	JOIN state_data sd
		ON bd.record_id = sd.record_id
	JOIN covid_influenza_data cid
		ON sd.record_id = cid.record_id
	GROUP BY state, month_name, years
	HAVING (avg_inp_avl != 0 OR avg_inp_avl != '' 
	AND avg_inp_used != 0 OR avg_inp_used != '')
    	OR (avg_ped_avl != 0 OR avg_ped_avl != '' 
	AND avg_ped_used != 0 OR avg_ped_used != '');

# Exploring daily staff shortages reported and anticpated shortages for week by # of hospitals per state

	SELECT YEAR(record_date) AS years,
	WEEK(record_date) AS weeks,
	state,
	SUM(critical_staffing_shortage_today_yes) AS num_hosp_daily_shortage,
	SUM(critical_staffing_shortage_anticipated_within_week_yes) AS num_hosp_wk_antic_shortage
	FROM staffing_data stf
	JOIN state_data sd
		ON stf.record_id = sd.record_id
	GROUP BY state, years, weeks
	HAVING num_hosp_daily_shortage != 0 OR num_hosp_daily_shortage != ''
	AND num_hosp_wk_antic_shortage != 0 OR num_hosp_wk_antic_shortage != ''
	ORDER BY years, weeks, state;

# Exploring confirmed COVID-19 cases versus suspected

	SELECT state,
	SUM(previous_day_admission_adult_covid_conf) AS adult_conf,
	SUM(previous_day_admission_adult_covid_suspected) AS adult_suspected,
	SUM(previous_day_admission_pediatric_covid_conf) AS child_conf,
	SUM(previous_day_admission_pediatric_covid_suspected) AS child_suspected
	FROM covid_influenza_data cid
	JOIN state_data sd
		ON cid.record_id = sd.record_id
	GROUP BY state
	ORDER BY state;
    
# Exploring confirmed COVID-19 cases versus suspected with timeseries breakdown

	SELECT YEAR(record_date) AS years,
    	CONCAT('Q',QUARTER(record_date)) AS qtr,
    	state,
	SUM(previous_day_admission_adult_covid_conf) AS adult_conf,
	SUM(previous_day_admission_adult_covid_suspected) AS adult_suspected,
	SUM(previous_day_admission_pediatric_covid_conf) AS child_conf,
	SUM(previous_day_admission_pediatric_covid_suspected) AS child_suspected
	FROM covid_influenza_data cid
	JOIN state_data sd
		ON cid.record_id = sd.record_id
	GROUP BY years, qtr, state
    	HAVING (adult_conf > 0 AND adult_suspected > 0)
    	OR (child_conf > 0 AND child_suspected > 0)
	ORDER BY years, qtr, state;
    
# DATA EXPLORATION COMPLETE
