# Databricks notebook source
# MAGIC %md
# MAGIC # CEDARS lineage demo
# MAGIC
# MAGIC A small, runnable slice of the warehouse (Files A, B, C, N → silver → gold) with mock data, so Unity Catalog
# MAGIC lineage has something real to record. See `demo/lineage/README.md` for what to look at afterwards.
# MAGIC
# MAGIC **Requirements:** Unity Catalog compute (serverless, a SQL-capable cluster in Standard/Dedicated access mode,
# MAGIC or a SQL warehouse). Lineage is recorded **when a query reads and writes tables**, not when a table is created,
# MAGIC so every table here is created empty and then loaded with `INSERT … SELECT` or `MERGE`.
# MAGIC
# MAGIC **Where it writes:** every table goes into one schema, set by the `catalog` and `schema` widgets (default
# MAGIC `ofmp20w_sandbox_catalog_dev.andrewweller`). The medallion layer is the table-name prefix (`bronze_`, `silver_`,
# MAGIC `ref_`, `gold_`) instead of a separate schema. The setup cell refuses to run if `bronze_location` already exists in
# MAGIC that schema and was not created by this notebook. Every table is `CREATE OR REPLACE`d, so don't reuse these names.
# MAGIC
# MAGIC Mock data only: districts 99001/99002, schools 9101/9102/9201 and SSIDs 9000000001–3 are fictitious.
# MAGIC Code values (N07, B12, B13, C09, C10) are the real ones from `seeds/ref/`.

# COMMAND ----------

dbutils.widgets.text("catalog", "ofmp20w_sandbox_catalog_dev", "Catalog")
dbutils.widgets.text("schema", "andrewweller", "Schema")
catalog = dbutils.widgets.get("catalog")
schema = dbutils.widgets.get("schema")

spark.sql(f"USE CATALOG `{catalog}`")
spark.sql(f"CREATE SCHEMA IF NOT EXISTS `{schema}`")
spark.sql(f"USE SCHEMA `{schema}`")

if spark.catalog.tableExists(f"{catalog}.{schema}.bronze_location"):
    props = {r.key: r.value for r in spark.sql("SHOW TBLPROPERTIES bronze_location").collect()}
    if props.get("cedars.demo") != "lineage":
        raise RuntimeError(f"{catalog}.{schema}.bronze_location exists and was not created by this demo; pick another schema.")

spark.sql("CREATE VOLUME IF NOT EXISTS landing COMMENT 'Mock CEDARS submission files (lineage demo)'")
landing = f"/Volumes/{catalog}/{schema}/landing"
print(f"Using {catalog}.{schema}; landing volume {landing}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. Land mock submission files in a volume
# MAGIC
# MAGIC Writing real files means lineage starts at the **volume path**, the way production ingestion will.
# MAGIC CEDARS dates are `MM/DD/YYYY` (manual, e.g. B14, C06, N06).

# COMMAND ----------

mock_files = {
    "file_a_location.csv": """SchoolYear,CountyDistrictCode,DistrictName,LocationId,SchoolCode,SchoolName,InitialSchoolStartDate,LastSchoolEndDate
2027,99001,Cascade Mock SD,101,9101,Cedar Elementary,09/02/2026,06/16/2027
2027,99001,Cascade Mock SD,102,9102,Fir Middle,09/02/2026,06/16/2027
2027,99002,Puget Mock SD,201,9201,Harbor Middle,09/03/2026,06/17/2027
""",
    # SSID 9000000002 moves districts mid-year and is reported with a different gender by each one
    # (survivorship picks the later district). Names and birth dates are fake and exist to show PII flow.
    "file_b_district_student.csv": """SchoolYear,ServingCountyDistrictCode,ResidentCountyDistrictCode,DistrictStudentId,SSID,LastName,FirstName,BirthDate,Gender,GradeLevel,DistrictEnrollmentDate,DistrictExitDate
2027,99001,99001,A1001,9000000001,Mockson,Ada,04/12/2018,F,3,09/02/2026,
2027,99001,99001,A1002,9000000002,Sample,Blake,08/30/2013,M,7,09/02/2026,01/15/2027
2027,99002,99002,P2002,9000000002,Sample,Blake,08/30/2013,X,7,01/20/2027,
2027,99002,99002,P2003,9000000003,Fakename,Casey,02/02/2013,F,8,09/03/2026,
""",
    "file_c_school_student.csv": """SchoolYear,ServingCountyDistrictCode,DistrictStudentId,SSID,LocationId,SchoolEnrollmentDate,SchoolExitDate,SchoolWithdrawalCode,IsPrimarySchool,CumulativeDaysPresent
2027,99001,A1001,9000000001,101,09/02/2026,,,Y,160
2027,99001,A1002,9000000002,102,09/02/2026,01/15/2027,T0,Y,82
2027,99002,P2002,9000000002,201,01/20/2027,,,Y,85
2027,99002,P2003,9000000003,201,09/03/2026,,,Y,150
""",
    # The last row uses Location ID 299, which is not in File A: it resolves to the unknown school (-1) with DQ001.
    "file_n_absence.csv": """SchoolYear,ServingCountyDistrictCode,DistrictStudentId,SSID,LocationId,AbsenceDate,AbsenceCode
2027,99001,A1001,9000000001,101,10/14/2026,EF
2027,99001,A1001,9000000001,101,11/03/2026,UP
2027,99001,A1002,9000000002,102,12/01/2026,UF
2027,99001,A1002,9000000002,102,12/02/2026,UF
2027,99002,P2002,9000000002,201,02/10/2027,EP
2027,99002,P2003,9000000003,201,03/05/2027,UF
2027,99002,P2003,9000000003,201,03/08/2027,UF
2027,99002,P2003,9000000003,299,03/09/2027,EF
""",
    # Copies of seeds/ref/absence_code.csv, gender.csv and grade_level.csv (code, description, source_order).
    "ref_absence_code.csv": """code,description,source_order
EF,Excused Full Day Absence,1
UF,Unexcused Full Day Absence,2
EP,Excused Part Day Absence,3
UP,Unexcused Part Day Absence,4
""",
    "ref_gender.csv": """code,description,source_order
F,Female,1
M,Male,2
X,Gender not exclusively Male or Female,3
""",
    "ref_grade_level.csv": """code,description,source_order
PK,Students aged 0-5 enrolled in any Pre-Kindergarten program,1
TK,Transition to Kindergarten,2
K1,Full-day Kindergarten (Program with 900 or more instructional hours annually),3
K2,Part-day Kindergarten (Program with fewer than 900 instructional hours annually),4
1,First,5
2,Second,6
3,Third,7
4,Fourth,8
5,Fifth,9
6,Sixth,10
7,Seventh,11
8,Eighth,12
9,Ninth,13
10,Tenth,14
11,Eleventh,15
12,Twelfth,16
""",
}
for name, body in mock_files.items():
    dbutils.fs.put(f"{landing}/{name}", body, overwrite=True)
display(dbutils.fs.ls(landing))

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2. Bronze: files as received (all STRING + load metadata)
# MAGIC
# MAGIC Column subsets of the real `sql/bronze/*.sql` tables.

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE bronze_location (
# MAGIC   SchoolYear STRING COMMENT 'CEDARS A01 – School Year (as received)',
# MAGIC   CountyDistrictCode STRING COMMENT 'CEDARS A02 – County District Code (as received)',
# MAGIC   DistrictName STRING COMMENT 'CEDARS A03 – District Name (as received)',
# MAGIC   LocationId STRING COMMENT 'CEDARS A04 – Location ID (as received)',
# MAGIC   SchoolCode STRING COMMENT 'CEDARS A05 – School Code (as received)',
# MAGIC   SchoolName STRING COMMENT 'CEDARS A06 – School Name (as received)',
# MAGIC   InitialSchoolStartDate STRING COMMENT 'CEDARS A07 – Initial School Start Date (as received)',
# MAGIC   LastSchoolEndDate STRING COMMENT 'CEDARS A08 – Last School End Date (as received)',
# MAGIC   _rescued_data STRING, _source_file STRING, _school_year INT, _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'CEDARS File A – Location, as received (lineage demo)'
# MAGIC TBLPROPERTIES ('cedars.file_code' = 'A', 'cedars.demo' = 'lineage');
# MAGIC
# MAGIC CREATE OR REPLACE TABLE bronze_district_student_enrollment (
# MAGIC   SchoolYear STRING COMMENT 'CEDARS B01 – School Year (as received)',
# MAGIC   ServingCountyDistrictCode STRING COMMENT 'CEDARS B02 – Serving County District Code (as received)',
# MAGIC   ResidentCountyDistrictCode STRING COMMENT 'CEDARS B03 – Home County District Code (as received)',
# MAGIC   DistrictStudentId STRING COMMENT 'CEDARS B04 – District Student ID (as received)',
# MAGIC   SSID STRING COMMENT 'CEDARS B05 – State Student ID (SSID) (as received)',
# MAGIC   LastName STRING COMMENT 'CEDARS B06 – Legal Last Name (as received)',
# MAGIC   FirstName STRING COMMENT 'CEDARS B07 – Legal First Name (as received)',
# MAGIC   BirthDate STRING COMMENT 'CEDARS B09 – Birth Date (as received)',
# MAGIC   Gender STRING COMMENT 'CEDARS B12 – Gender (as received)',
# MAGIC   GradeLevel STRING COMMENT 'CEDARS B13 – Grade Level (as received)',
# MAGIC   DistrictEnrollmentDate STRING COMMENT 'CEDARS B14 – Date Enrolled in District (as received)',
# MAGIC   DistrictExitDate STRING COMMENT 'CEDARS B15 – Date Exited from District (as received)',
# MAGIC   _rescued_data STRING, _source_file STRING, _school_year INT, _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'CEDARS File B – District Student, as received (lineage demo)'
# MAGIC TBLPROPERTIES ('cedars.file_code' = 'B');
# MAGIC
# MAGIC CREATE OR REPLACE TABLE bronze_school_student_enrollment (
# MAGIC   SchoolYear STRING COMMENT 'CEDARS C01 – School Year (as received)',
# MAGIC   ServingCountyDistrictCode STRING COMMENT 'CEDARS C02 – Serving County District Code (as received)',
# MAGIC   DistrictStudentId STRING COMMENT 'CEDARS C03 – District Student ID (as received)',
# MAGIC   SSID STRING COMMENT 'CEDARS C04 – State Student ID (SSID) (as received)',
# MAGIC   LocationId STRING COMMENT 'CEDARS C05 – Location ID (as received)',
# MAGIC   SchoolEnrollmentDate STRING COMMENT 'CEDARS C06 – Date Student Enrolled in School (as received)',
# MAGIC   SchoolExitDate STRING COMMENT 'CEDARS C08 – Date Student Exited from School (as received)',
# MAGIC   SchoolWithdrawalCode STRING COMMENT 'CEDARS C09 – School Withdrawal Code (as received)',
# MAGIC   IsPrimarySchool STRING COMMENT 'CEDARS C10 – Is this the School that is Primarily Responsible for the Student? (as received)',
# MAGIC   CumulativeDaysPresent STRING COMMENT 'CEDARS C12 – Cumulative Days Present this Enrollment Period (as received)',
# MAGIC   _rescued_data STRING, _source_file STRING, _school_year INT, _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'CEDARS File C – School Student, as received (lineage demo)'
# MAGIC TBLPROPERTIES ('cedars.file_code' = 'C');
# MAGIC
# MAGIC CREATE OR REPLACE TABLE bronze_student_absence (
# MAGIC   SchoolYear STRING COMMENT 'CEDARS N01 – School Year (as received)',
# MAGIC   ServingCountyDistrictCode STRING COMMENT 'CEDARS N02 – Serving County District Code (as received)',
# MAGIC   DistrictStudentId STRING COMMENT 'CEDARS N03 – District Student ID (as received)',
# MAGIC   SSID STRING COMMENT 'CEDARS N04 – State Student ID (SSID) (as received)',
# MAGIC   LocationId STRING COMMENT 'CEDARS N05 – Location ID (as received)',
# MAGIC   AbsenceDate STRING COMMENT 'CEDARS N06 – Absence Date (as received)',
# MAGIC   AbsenceCode STRING COMMENT 'CEDARS N07 – Absence Code (as received)',
# MAGIC   _rescued_data STRING, _source_file STRING, _school_year INT, _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'CEDARS File N – Student Absence, as received (lineage demo)'
# MAGIC TBLPROPERTIES ('cedars.file_code' = 'N');
# MAGIC
# MAGIC CREATE OR REPLACE TABLE ref_code (
# MAGIC   code_set STRING NOT NULL COMMENT 'Code set name',
# MAGIC   code STRING NOT NULL COMMENT 'Code value as reported in CEDARS',
# MAGIC   description STRING COMMENT 'Code description',
# MAGIC   source_order INT COMMENT 'Row order in the source',
# MAGIC   manual_version STRING NOT NULL COMMENT 'CEDARS manual version'
# MAGIC ) COMMENT 'CEDARS code values (subset of ref_code, lineage demo)';

# COMMAND ----------

# Ingest each landed file with read_files. inferColumnTypes => false keeps every column a STRING, as bronze requires.
def load_bronze(table: str, file_name: str) -> None:
    spark.sql(f"""
        INSERT INTO bronze_{table} BY NAME
        SELECT *,
               _metadata.file_name   AS _source_file,
               2027                  AS _school_year,
               '19.0'                AS _manual_version,
               'year-end final'      AS _submission_type,
               current_timestamp()   AS _load_ts
        FROM read_files('{landing}/{file_name}', format => 'csv', header => true,
                        inferColumnTypes => false, rescuedDataColumn => '_rescued_data')
    """)

load_bronze("location", "file_a_location.csv")
load_bronze("district_student_enrollment", "file_b_district_student.csv")
load_bronze("school_student_enrollment", "file_c_school_student.csv")
load_bronze("student_absence", "file_n_absence.csv")

for code_set in ("absence_code", "gender", "grade_level"):
    spark.sql(f"""
        INSERT INTO ref_code BY NAME
        SELECT '{code_set}' AS code_set, code, description, CAST(source_order AS INT) AS source_order, '19.0' AS manual_version
        FROM read_files('{landing}/ref_{code_set}.csv', format => 'csv', header => true, inferColumnTypes => false)
    """)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3. Silver: typed, validated, crosswalked
# MAGIC
# MAGIC Transformations worth watching in the column lineage:
# MAGIC - **Typing:** `to_date(..., 'MM/dd/yyyy')`, `CAST(... AS INT)`, and renaming to snake_case.
# MAGIC - **Crosswalk:** `school_code` in C and N comes from `xref_location`, which comes from File A, not from C or N.
# MAGIC - **Union:** `xref_student` combines ID pairs from B, C and N.
# MAGIC - **Unpivot and rank:** `student_attribute_history` turns B12/B13 into rows and ranks them for survivorship.

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE silver_location (
# MAGIC   school_year INT NOT NULL COMMENT 'CEDARS A01 – School Year',
# MAGIC   county_district_code STRING NOT NULL COMMENT 'CEDARS A02 – County District Code',
# MAGIC   district_name STRING COMMENT 'CEDARS A03 – District Name',
# MAGIC   location_id STRING NOT NULL COMMENT 'CEDARS A04 – Location ID',
# MAGIC   school_code STRING NOT NULL COMMENT 'CEDARS A05 – OSPI School Code',
# MAGIC   school_name STRING COMMENT 'CEDARS A06 – School Name',
# MAGIC   initial_school_start_date DATE COMMENT 'CEDARS A07 – Initial School Start Date',
# MAGIC   last_school_end_date DATE COMMENT 'CEDARS A08 – Last School End Date',
# MAGIC   _source_file STRING, _school_year INT, _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'CEDARS File A – Location (lineage demo)';
# MAGIC
# MAGIC INSERT INTO silver_location BY NAME
# MAGIC SELECT CAST(SchoolYear AS INT)                         AS school_year,
# MAGIC        CountyDistrictCode                              AS county_district_code,
# MAGIC        trim(DistrictName)                              AS district_name,
# MAGIC        LocationId                                      AS location_id,
# MAGIC        SchoolCode                                      AS school_code,
# MAGIC        trim(SchoolName)                                AS school_name,
# MAGIC        to_date(InitialSchoolStartDate, 'MM/dd/yyyy')   AS initial_school_start_date,
# MAGIC        to_date(LastSchoolEndDate, 'MM/dd/yyyy')        AS last_school_end_date,
# MAGIC        _source_file, _school_year, _manual_version, _submission_type, _load_ts
# MAGIC FROM bronze_location;
# MAGIC
# MAGIC CREATE OR REPLACE TABLE silver_xref_location (
# MAGIC   school_year INT NOT NULL COMMENT 'CEDARS A01 – School Year',
# MAGIC   county_district_code STRING NOT NULL COMMENT 'CEDARS A02 – County District Code',
# MAGIC   location_id STRING NOT NULL COMMENT 'CEDARS A04 – Location ID (district SIS number)',
# MAGIC   school_code STRING NOT NULL COMMENT 'CEDARS A05 – OSPI School Code',
# MAGIC   district_name STRING COMMENT 'CEDARS A03 – District Name',
# MAGIC   school_name STRING COMMENT 'CEDARS A06 – School Name',
# MAGIC   is_ambiguous BOOLEAN COMMENT 'Derived: Location ID maps to more than one A05 in the year/district',
# MAGIC   _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'Crosswalk: school year + district + Location ID -> OSPI school code, built from File A (lineage demo)';
# MAGIC
# MAGIC INSERT INTO silver_xref_location BY NAME
# MAGIC SELECT school_year, county_district_code, location_id, school_code, district_name, school_name,
# MAGIC        count(*) OVER (PARTITION BY school_year, county_district_code, location_id) > 1 AS is_ambiguous,
# MAGIC        _manual_version, _submission_type, current_timestamp() AS _load_ts
# MAGIC FROM silver_location;
# MAGIC
# MAGIC CREATE OR REPLACE TABLE silver_district_student_enrollment (
# MAGIC   school_year INT NOT NULL COMMENT 'CEDARS B01 – School Year',
# MAGIC   county_district_code STRING NOT NULL COMMENT 'CEDARS B02 – Serving County District Code',
# MAGIC   home_county_district_code STRING COMMENT 'CEDARS B03 – Home County District Code',
# MAGIC   district_student_id STRING COMMENT 'CEDARS B04 – District Student ID',
# MAGIC   ssid STRING NOT NULL COMMENT 'CEDARS B05 – State Student ID (SSID)',
# MAGIC   legal_last_name STRING COMMENT 'CEDARS B06 – Legal Last Name (PII)',
# MAGIC   legal_first_name STRING COMMENT 'CEDARS B07 – Legal First Name (PII)',
# MAGIC   birth_date DATE COMMENT 'CEDARS B09 – Birth Date (PII)',
# MAGIC   gender STRING COMMENT 'CEDARS B12 – Gender [code set: gender]',
# MAGIC   grade_level STRING COMMENT 'CEDARS B13 – Grade Level [code set: grade_level]',
# MAGIC   district_enrollment_date DATE NOT NULL COMMENT 'CEDARS B14 – Date Enrolled in District',
# MAGIC   district_exit_date DATE COMMENT 'CEDARS B15 – Date Exited from District',
# MAGIC   _source_file STRING, _school_year INT, _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'CEDARS File B – District Student (lineage demo)';
# MAGIC
# MAGIC INSERT INTO silver_district_student_enrollment BY NAME
# MAGIC SELECT CAST(SchoolYear AS INT)                         AS school_year,
# MAGIC        ServingCountyDistrictCode                       AS county_district_code,
# MAGIC        ResidentCountyDistrictCode                      AS home_county_district_code,
# MAGIC        DistrictStudentId                               AS district_student_id,
# MAGIC        SSID                                            AS ssid,
# MAGIC        LastName                                        AS legal_last_name,
# MAGIC        FirstName                                       AS legal_first_name,
# MAGIC        to_date(BirthDate, 'MM/dd/yyyy')                AS birth_date,
# MAGIC        upper(Gender)                                   AS gender,
# MAGIC        upper(GradeLevel)                               AS grade_level,
# MAGIC        to_date(DistrictEnrollmentDate, 'MM/dd/yyyy')   AS district_enrollment_date,
# MAGIC        to_date(DistrictExitDate, 'MM/dd/yyyy')         AS district_exit_date,
# MAGIC        _source_file, _school_year, _manual_version, _submission_type, _load_ts
# MAGIC FROM bronze_district_student_enrollment;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- File C and File N both resolve Location ID -> OSPI school code through xref_location (design §5.4).
# MAGIC CREATE OR REPLACE TABLE silver_school_student_enrollment (
# MAGIC   school_year INT NOT NULL COMMENT 'CEDARS C01 – School Year',
# MAGIC   county_district_code STRING NOT NULL COMMENT 'CEDARS C02 – Serving County District Code',
# MAGIC   district_student_id STRING COMMENT 'CEDARS C03 – District Student ID',
# MAGIC   ssid STRING NOT NULL COMMENT 'CEDARS C04 – State Student ID (SSID)',
# MAGIC   location_id STRING NOT NULL COMMENT 'CEDARS C05 – Location ID',
# MAGIC   school_code STRING COMMENT 'Derived: CEDARS A05 resolved from C05 via silver_xref_location',
# MAGIC   school_enrollment_date DATE NOT NULL COMMENT 'CEDARS C06 – Date Student Enrolled in School',
# MAGIC   school_exit_date DATE COMMENT 'CEDARS C08 – Date Student Exited from School',
# MAGIC   school_withdrawal_code STRING COMMENT 'CEDARS C09 – School Withdrawal Code',
# MAGIC   is_primary_school STRING COMMENT 'CEDARS C10 – Is this the School that is Primarily Responsible for the Student?',
# MAGIC   days_present INT COMMENT 'CEDARS C12 – Cumulative Days Present this Enrollment Period',
# MAGIC   _source_file STRING, _school_year INT, _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP,
# MAGIC   _dq_issues ARRAY<STRING> COMMENT 'Load metadata: failed non-rejecting checks (DQ001 = Location ID not in xref_location)'
# MAGIC ) COMMENT 'CEDARS File C – School Student (lineage demo)';
# MAGIC
# MAGIC INSERT INTO silver_school_student_enrollment BY NAME
# MAGIC SELECT CAST(c.SchoolYear AS INT)                         AS school_year,
# MAGIC        c.ServingCountyDistrictCode                       AS county_district_code,
# MAGIC        c.DistrictStudentId                               AS district_student_id,
# MAGIC        c.SSID                                            AS ssid,
# MAGIC        c.LocationId                                      AS location_id,
# MAGIC        x.school_code,
# MAGIC        to_date(c.SchoolEnrollmentDate, 'MM/dd/yyyy')     AS school_enrollment_date,
# MAGIC        to_date(c.SchoolExitDate, 'MM/dd/yyyy')           AS school_exit_date,
# MAGIC        c.SchoolWithdrawalCode                            AS school_withdrawal_code,
# MAGIC        upper(c.IsPrimarySchool)                          AS is_primary_school,
# MAGIC        CAST(c.CumulativeDaysPresent AS INT)              AS days_present,
# MAGIC        c._source_file, c._school_year, c._manual_version, c._submission_type, c._load_ts,
# MAGIC        CASE WHEN x.school_code IS NULL THEN array('DQ001') ELSE CAST(array() AS ARRAY<STRING>) END AS _dq_issues
# MAGIC FROM bronze_school_student_enrollment c
# MAGIC LEFT JOIN silver_xref_location x
# MAGIC   ON  x.school_year = CAST(c.SchoolYear AS INT)
# MAGIC   AND x.county_district_code = c.ServingCountyDistrictCode
# MAGIC   AND x.location_id = c.LocationId
# MAGIC   AND NOT x.is_ambiguous;
# MAGIC
# MAGIC CREATE OR REPLACE TABLE silver_student_absence (
# MAGIC   school_year INT NOT NULL COMMENT 'CEDARS N01 – School Year',
# MAGIC   county_district_code STRING NOT NULL COMMENT 'CEDARS N02 – Serving County District Code',
# MAGIC   district_student_id STRING COMMENT 'CEDARS N03 – District Student ID',
# MAGIC   ssid STRING NOT NULL COMMENT 'CEDARS N04 – State Student ID (SSID)',
# MAGIC   location_id STRING NOT NULL COMMENT 'CEDARS N05 – Location ID',
# MAGIC   school_code STRING COMMENT 'Derived: CEDARS A05 resolved from N05 via silver_xref_location',
# MAGIC   absence_date DATE NOT NULL COMMENT 'CEDARS N06 – Absence Date',
# MAGIC   absence_code STRING NOT NULL COMMENT 'CEDARS N07 – Absence Code [code set: absence_code]',
# MAGIC   _source_file STRING, _school_year INT, _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP,
# MAGIC   _dq_issues ARRAY<STRING> COMMENT 'Load metadata: failed non-rejecting checks (DQ001 = Location ID not in xref_location)'
# MAGIC ) COMMENT 'CEDARS File N – Student Absence (lineage demo)';
# MAGIC
# MAGIC INSERT INTO silver_student_absence BY NAME
# MAGIC SELECT CAST(n.SchoolYear AS INT)                         AS school_year,
# MAGIC        n.ServingCountyDistrictCode                       AS county_district_code,
# MAGIC        n.DistrictStudentId                               AS district_student_id,
# MAGIC        n.SSID                                            AS ssid,
# MAGIC        n.LocationId                                      AS location_id,
# MAGIC        x.school_code,
# MAGIC        to_date(n.AbsenceDate, 'MM/dd/yyyy')              AS absence_date,
# MAGIC        upper(n.AbsenceCode)                              AS absence_code,
# MAGIC        n._source_file, n._school_year, n._manual_version, n._submission_type, n._load_ts,
# MAGIC        CASE WHEN x.school_code IS NULL THEN array('DQ001') ELSE CAST(array() AS ARRAY<STRING>) END AS _dq_issues
# MAGIC FROM bronze_student_absence n
# MAGIC LEFT JOIN silver_xref_location x
# MAGIC   ON  x.school_year = CAST(n.SchoolYear AS INT)
# MAGIC   AND x.county_district_code = n.ServingCountyDistrictCode
# MAGIC   AND x.location_id = n.LocationId
# MAGIC   AND NOT x.is_ambiguous;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE silver_xref_student (
# MAGIC   school_year INT NOT NULL COMMENT 'CEDARS *01 – School Year',
# MAGIC   county_district_code STRING NOT NULL COMMENT 'CEDARS *02 – Serving County District Code',
# MAGIC   district_student_id STRING NOT NULL COMMENT 'CEDARS B04, C03, N03 – District Student ID',
# MAGIC   ssid STRING NOT NULL COMMENT 'CEDARS B05, C04, N04 – State Student ID',
# MAGIC   source_file_codes ARRAY<STRING> COMMENT 'Derived: CEDARS files that reported this ID pair',
# MAGIC   is_conflict BOOLEAN COMMENT 'Derived: district student ID maps to more than one SSID (or the reverse), DQ003',
# MAGIC   _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'Crosswalk: District Student ID -> SSID, per school year and district (lineage demo)';
# MAGIC
# MAGIC INSERT INTO silver_xref_student BY NAME
# MAGIC WITH pairs AS (
# MAGIC   SELECT school_year, county_district_code, district_student_id, ssid, 'B' AS file_code, _manual_version, _submission_type
# MAGIC   FROM silver_district_student_enrollment
# MAGIC   UNION ALL
# MAGIC   SELECT school_year, county_district_code, district_student_id, ssid, 'C', _manual_version, _submission_type
# MAGIC   FROM silver_school_student_enrollment
# MAGIC   UNION ALL
# MAGIC   SELECT school_year, county_district_code, district_student_id, ssid, 'N', _manual_version, _submission_type
# MAGIC   FROM silver_student_absence
# MAGIC ),
# MAGIC agg AS (
# MAGIC   SELECT school_year, county_district_code, district_student_id, ssid,
# MAGIC          array_sort(collect_set(file_code)) AS source_file_codes,
# MAGIC          max(_manual_version) AS _manual_version, max(_submission_type) AS _submission_type
# MAGIC   FROM pairs
# MAGIC   GROUP BY school_year, county_district_code, district_student_id, ssid
# MAGIC )
# MAGIC SELECT *,
# MAGIC        count(*) OVER (PARTITION BY school_year, county_district_code, district_student_id) > 1
# MAGIC     OR count(*) OVER (PARTITION BY school_year, county_district_code, ssid) > 1 AS is_conflict,
# MAGIC        current_timestamp() AS _load_ts
# MAGIC FROM agg;
# MAGIC
# MAGIC -- Survivorship input (design §5.1): one row per reported attribute value, ranked.
# MAGIC CREATE OR REPLACE TABLE silver_student_attribute_history (
# MAGIC   ssid STRING NOT NULL COMMENT 'CEDARS B05 – SSID',
# MAGIC   school_year INT NOT NULL COMMENT 'CEDARS B01 – School Year',
# MAGIC   county_district_code STRING NOT NULL COMMENT 'CEDARS B02 – Serving County District Code',
# MAGIC   district_enrollment_date DATE NOT NULL COMMENT 'CEDARS B14 – Date Enrolled in District (survivorship order)',
# MAGIC   is_primary_responsibility_district BOOLEAN COMMENT 'Derived: a File C enrollment with C10 = Y overlaps the B spell',
# MAGIC   attribute_element_id STRING NOT NULL COMMENT 'Derived: CEDARS element ID of the attribute (B12, B13 in this demo)',
# MAGIC   attribute_name STRING NOT NULL COMMENT 'Derived: attribute column name in silver_district_student_enrollment',
# MAGIC   attribute_value STRING COMMENT 'CEDARS B12, B13 – value as typed in silver, cast to STRING',
# MAGIC   survivorship_rank INT COMMENT 'Derived: 1 = surviving value (latest school year, then latest B14, then primary district)',
# MAGIC   _manual_version STRING, _submission_type STRING, _load_ts TIMESTAMP
# MAGIC ) COMMENT 'Every reported value of each student attribute, for survivorship auditing (lineage demo)';
# MAGIC
# MAGIC INSERT INTO silver_student_attribute_history BY NAME
# MAGIC WITH primary_spells AS (
# MAGIC   SELECT DISTINCT b.ssid, b.school_year, b.county_district_code, b.district_enrollment_date
# MAGIC   FROM silver_district_student_enrollment b
# MAGIC   JOIN silver_school_student_enrollment c
# MAGIC     ON  c.ssid = b.ssid AND c.school_year = b.school_year AND c.county_district_code = b.county_district_code
# MAGIC     AND c.is_primary_school = 'Y'
# MAGIC     AND c.school_enrollment_date <= coalesce(b.district_exit_date, DATE'9999-12-31')
# MAGIC     AND coalesce(c.school_exit_date, DATE'9999-12-31') >= b.district_enrollment_date
# MAGIC ),
# MAGIC unpivoted AS (
# MAGIC   SELECT * FROM (
# MAGIC     SELECT ssid, school_year, county_district_code, district_enrollment_date, _manual_version, _submission_type,
# MAGIC            gender AS B12, grade_level AS B13
# MAGIC     FROM silver_district_student_enrollment
# MAGIC   ) AS src UNPIVOT (attribute_value FOR attribute_element_id IN (B12, B13))
# MAGIC )
# MAGIC SELECT u.ssid, u.school_year, u.county_district_code, u.district_enrollment_date,
# MAGIC        p.ssid IS NOT NULL AS is_primary_responsibility_district,
# MAGIC        u.attribute_element_id,
# MAGIC        CASE u.attribute_element_id WHEN 'B12' THEN 'gender' WHEN 'B13' THEN 'grade_level' END AS attribute_name,
# MAGIC        u.attribute_value,
# MAGIC        row_number() OVER (PARTITION BY u.ssid, u.attribute_element_id
# MAGIC                           ORDER BY u.school_year DESC, u.district_enrollment_date DESC, p.ssid IS NOT NULL DESC) AS survivorship_rank,
# MAGIC        u._manual_version, u._submission_type, current_timestamp() AS _load_ts
# MAGIC FROM unpivoted u
# MAGIC LEFT JOIN primary_spells p
# MAGIC   ON  p.ssid = u.ssid AND p.school_year = u.school_year
# MAGIC   AND p.county_district_code = u.county_district_code AND p.district_enrollment_date = u.district_enrollment_date;

# COMMAND ----------

# MAGIC %md
# MAGIC ## 4. Gold: dimensions
# MAGIC
# MAGIC `dim_date` is generated, so it has **no upstream** in lineage. `dim_school` is loaded with `MERGE` to show that
# MAGIC MERGE is captured too. Surrogate keys are `xxhash64` of the natural key here (demo shortcut); special members
# MAGIC use -1 unknown, -2 not applicable, -3 out-of-district school 9999 (as in `sql/gold/special_members.sql`).

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE gold_dim_date (
# MAGIC   date_sk INT NOT NULL COMMENT 'Derived: Date key YYYYMMDD (-1 unknown, -2 not applicable)',
# MAGIC   full_date DATE COMMENT 'Derived: Calendar date',
# MAGIC   calendar_year INT COMMENT 'Derived: Calendar year',
# MAGIC   calendar_month INT COMMENT 'Derived: Calendar month 1-12',
# MAGIC   day_name STRING COMMENT 'Derived: Day name',
# MAGIC   is_weekend BOOLEAN COMMENT 'Derived: Saturday or Sunday',
# MAGIC   school_year_sk BIGINT COMMENT 'Derived: School year the date falls in (September-August)',
# MAGIC   CONSTRAINT dim_date_pk PRIMARY KEY (date_sk)
# MAGIC ) COMMENT 'Calendar date (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_dim_date BY NAME
# MAGIC SELECT CAST(date_format(d, 'yyyyMMdd') AS INT) AS date_sk, d AS full_date, year(d) AS calendar_year,
# MAGIC        month(d) AS calendar_month, date_format(d, 'EEEE') AS day_name, dayofweek(d) IN (1, 7) AS is_weekend,
# MAGIC        CASE WHEN month(d) >= 9 THEN year(d) + 1 ELSE year(d) END AS school_year_sk
# MAGIC FROM (SELECT explode(sequence(DATE'2026-09-01', DATE'2027-08-31')) AS d)
# MAGIC UNION ALL SELECT -1, NULL, NULL, NULL, 'Unknown', NULL, -1
# MAGIC UNION ALL SELECT -2, NULL, NULL, NULL, 'Not applicable', NULL, -2;
# MAGIC
# MAGIC CREATE OR REPLACE TABLE gold_dim_school_year (
# MAGIC   school_year_sk BIGINT NOT NULL COMMENT 'Derived: School year key = ending year',
# MAGIC   school_year INT COMMENT 'CEDARS A01 – School year (ending year)',
# MAGIC   school_year_label STRING COMMENT 'Derived: Label, e.g. 2026-27',
# MAGIC   start_date DATE COMMENT 'Derived: September 1 of the starting year',
# MAGIC   end_date DATE COMMENT 'Derived: August 31 of the ending year',
# MAGIC   CONSTRAINT dim_school_year_pk PRIMARY KEY (school_year_sk)
# MAGIC ) COMMENT 'School year (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_dim_school_year BY NAME
# MAGIC SELECT DISTINCT school_year AS school_year_sk, school_year,
# MAGIC        concat(school_year - 1, '-', right(CAST(school_year AS STRING), 2)) AS school_year_label,
# MAGIC        make_date(school_year - 1, 9, 1) AS start_date, make_date(school_year, 8, 31) AS end_date
# MAGIC FROM silver_location;
# MAGIC
# MAGIC CREATE OR REPLACE TABLE gold_dim_district (
# MAGIC   district_sk BIGINT NOT NULL COMMENT 'Surrogate key (-1 unknown, -2 not applicable)',
# MAGIC   county_district_code STRING COMMENT 'CEDARS A02 – County-district code',
# MAGIC   county_code STRING COMMENT 'CEDARS A02 – County code = first 2 digits of the county-district code',
# MAGIC   district_name STRING COMMENT 'CEDARS A03 – District name as reported in File A',
# MAGIC   is_current BOOLEAN NOT NULL COMMENT 'SCD2: current row flag',
# MAGIC   CONSTRAINT dim_district_pk PRIMARY KEY (district_sk)
# MAGIC ) COMMENT 'District (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_dim_district BY NAME
# MAGIC SELECT xxhash64('district', county_district_code) AS district_sk, county_district_code,
# MAGIC        left(county_district_code, 2) AS county_code, max(district_name) AS district_name, TRUE AS is_current
# MAGIC FROM silver_xref_location
# MAGIC GROUP BY county_district_code
# MAGIC UNION ALL SELECT -1, NULL, NULL, 'Unknown', TRUE
# MAGIC UNION ALL SELECT -2, NULL, NULL, 'Not applicable', TRUE;
# MAGIC
# MAGIC CREATE OR REPLACE TABLE gold_dim_school (
# MAGIC   school_sk BIGINT NOT NULL COMMENT 'Surrogate key (-1 unknown, -2 not applicable, -3 out-of-district)',
# MAGIC   county_district_code STRING COMMENT 'CEDARS A02 – County-district code the school belongs to',
# MAGIC   school_code STRING COMMENT 'CEDARS A05 – OSPI school code (9999 = out-of-district)',
# MAGIC   school_name STRING COMMENT 'CEDARS A06 – School name as reported in File A',
# MAGIC   is_out_of_district BOOLEAN COMMENT 'CEDARS H26 – Special member for school code 9999',
# MAGIC   is_current BOOLEAN NOT NULL COMMENT 'SCD2: current row flag',
# MAGIC   CONSTRAINT dim_school_pk PRIMARY KEY (school_sk)
# MAGIC ) COMMENT 'School (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_dim_school BY NAME
# MAGIC SELECT -1 AS school_sk, NULL AS county_district_code, NULL AS school_code, 'Unknown' AS school_name, FALSE AS is_out_of_district, TRUE AS is_current
# MAGIC UNION ALL SELECT -2, NULL, NULL, 'Not applicable', FALSE, TRUE
# MAGIC UNION ALL SELECT -3, NULL, '9999', 'Out-of-district school', TRUE, TRUE;
# MAGIC
# MAGIC MERGE INTO gold_dim_school t
# MAGIC USING (
# MAGIC   SELECT county_district_code, school_code, max_by(school_name, school_year) AS school_name
# MAGIC   FROM silver_xref_location
# MAGIC   WHERE NOT is_ambiguous
# MAGIC   GROUP BY county_district_code, school_code
# MAGIC ) s
# MAGIC ON t.county_district_code = s.county_district_code AND t.school_code = s.school_code AND t.is_current
# MAGIC WHEN MATCHED AND t.school_name <> s.school_name THEN UPDATE SET school_name = s.school_name
# MAGIC WHEN NOT MATCHED THEN INSERT (school_sk, county_district_code, school_code, school_name, is_out_of_district, is_current)
# MAGIC   VALUES (xxhash64('school', s.county_district_code, s.school_code), s.county_district_code, s.school_code, s.school_name, FALSE, TRUE);

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE gold_dim_absence_type (
# MAGIC   absence_type_sk BIGINT NOT NULL COMMENT 'Surrogate key (-1 unknown)',
# MAGIC   code STRING COMMENT 'CEDARS N07 – Code value',
# MAGIC   description STRING COMMENT 'CEDARS N07 – Code description',
# MAGIC   is_excused BOOLEAN COMMENT 'CEDARS N07 – EF, EP',
# MAGIC   is_full_day BOOLEAN COMMENT 'CEDARS N07 – EF, UF',
# MAGIC   CONSTRAINT dim_absence_type_pk PRIMARY KEY (absence_type_sk)
# MAGIC ) COMMENT 'Absence type (N07), built from ref_code (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_dim_absence_type BY NAME
# MAGIC SELECT xxhash64('absence_code', code) AS absence_type_sk, code, description,
# MAGIC        code IN ('EF', 'EP') AS is_excused, code IN ('EF', 'UF') AS is_full_day
# MAGIC FROM ref_code WHERE code_set = 'absence_code'
# MAGIC UNION ALL SELECT -1, NULL, 'Unknown', NULL, NULL;
# MAGIC
# MAGIC CREATE OR REPLACE TABLE gold_dim_grade_level (
# MAGIC   grade_level_sk BIGINT NOT NULL COMMENT 'Surrogate key (-1 unknown)',
# MAGIC   code STRING COMMENT 'CEDARS B13 – Grade level code',
# MAGIC   description STRING COMMENT 'CEDARS B13 – Grade level description',
# MAGIC   sort_order INT COMMENT 'Derived: source order from the appendix',
# MAGIC   CONSTRAINT dim_grade_level_pk PRIMARY KEY (grade_level_sk)
# MAGIC ) COMMENT 'Grade level (B13), built from ref_code (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_dim_grade_level BY NAME
# MAGIC SELECT xxhash64('grade_level', code) AS grade_level_sk, code, description, source_order AS sort_order
# MAGIC FROM ref_code WHERE code_set = 'grade_level'
# MAGIC UNION ALL SELECT -1, NULL, 'Unknown', NULL;
# MAGIC
# MAGIC -- Pivot the survivorship winners back to columns. Watch dim_student.gender in column lineage: it traces to
# MAGIC -- attribute_value, which traces to BOTH gender and grade_level upstream (lineage is not row-aware).
# MAGIC CREATE OR REPLACE TABLE gold_dim_student (
# MAGIC   student_sk BIGINT NOT NULL COMMENT 'Surrogate key (-1 unknown, -2 not applicable)',
# MAGIC   ssid STRING COMMENT 'CEDARS B05 – State Student ID (durable key)',
# MAGIC   gender STRING COMMENT 'CEDARS B12 – Gender (survivorship winner)',
# MAGIC   gender_description STRING COMMENT 'CEDARS B12 – Gender description (code set: gender)',
# MAGIC   effective_from DATE NOT NULL COMMENT 'SCD2: row effective from',
# MAGIC   effective_to DATE NOT NULL COMMENT 'SCD2: row effective to (9999-12-31 while current)',
# MAGIC   is_current BOOLEAN NOT NULL COMMENT 'SCD2: current row flag',
# MAGIC   CONSTRAINT dim_student_pk PRIMARY KEY (student_sk)
# MAGIC ) COMMENT 'Student, thin, survivorship from silver_student_attribute_history (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_dim_student BY NAME
# MAGIC SELECT xxhash64('student', h.ssid) AS student_sk, h.ssid,
# MAGIC        max(CASE WHEN h.attribute_element_id = 'B12' THEN h.attribute_value END) AS gender,
# MAGIC        max(CASE WHEN h.attribute_element_id = 'B12' THEN g.description END) AS gender_description,
# MAGIC        make_date(min(h.school_year) - 1, 9, 1) AS effective_from, DATE'9999-12-31' AS effective_to, TRUE AS is_current
# MAGIC FROM silver_student_attribute_history h
# MAGIC LEFT JOIN ref_code g ON g.code_set = 'gender' AND g.code = h.attribute_value
# MAGIC WHERE h.survivorship_rank = 1
# MAGIC GROUP BY h.ssid
# MAGIC UNION ALL SELECT -1, NULL, NULL, 'Unknown', DATE'1900-01-01', DATE'9999-12-31', TRUE
# MAGIC UNION ALL SELECT -2, NULL, NULL, 'Not applicable', DATE'1900-01-01', DATE'9999-12-31', TRUE;
# MAGIC
# MAGIC -- Restricted PII lives in its own table; lineage shows B06/B07/B09 flow here and nowhere else in gold.
# MAGIC CREATE OR REPLACE TABLE gold_dim_student_pii (
# MAGIC   ssid STRING NOT NULL COMMENT 'CEDARS B05 – State Student ID',
# MAGIC   legal_last_name STRING COMMENT 'CEDARS B06 – Legal last name (latest reported)',
# MAGIC   legal_first_name STRING COMMENT 'CEDARS B07 – Legal first name (latest reported)',
# MAGIC   birth_date DATE COMMENT 'CEDARS B09 – Birth date (latest reported)'
# MAGIC ) COMMENT 'Restricted student PII, keyed by SSID (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_dim_student_pii BY NAME
# MAGIC SELECT ssid,
# MAGIC        max_by(legal_last_name, struct(school_year, district_enrollment_date)) AS legal_last_name,
# MAGIC        max_by(legal_first_name, struct(school_year, district_enrollment_date)) AS legal_first_name,
# MAGIC        max_by(birth_date, struct(school_year, district_enrollment_date)) AS birth_date
# MAGIC FROM silver_district_student_enrollment
# MAGIC GROUP BY ssid;

# COMMAND ----------

# MAGIC %md
# MAGIC ## 5. Gold: facts and a BI view
# MAGIC
# MAGIC `fact_student_school_year` is built **from other gold facts** (gold → gold lineage), and the view on top is what a
# MAGIC Tableau user would query.

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE gold_fact_absence (
# MAGIC   school_year_sk BIGINT NOT NULL COMMENT 'CEDARS N01 – School year',
# MAGIC   student_sk BIGINT NOT NULL COMMENT 'CEDARS N04 – Student (SSID)',
# MAGIC   district_sk BIGINT NOT NULL COMMENT 'CEDARS N02 – Serving district',
# MAGIC   school_sk BIGINT NOT NULL COMMENT 'CEDARS N05 – School (Location ID via xref_location)',
# MAGIC   absence_date_sk INT NOT NULL COMMENT 'CEDARS N06 – Absence date',
# MAGIC   absence_type_sk BIGINT NOT NULL COMMENT 'CEDARS N07 – Absence type',
# MAGIC   absence_count INT COMMENT 'CEDARS N07 – Always 1',
# MAGIC   full_day_flag INT COMMENT 'CEDARS N07 – 1 when N07 is EF or UF',
# MAGIC   part_day_flag INT COMMENT 'CEDARS N07 – 1 when N07 is EP or UP',
# MAGIC   excused_flag INT COMMENT 'CEDARS N07 – 1 when N07 is EF or EP'
# MAGIC ) COMMENT 'Transaction: SSID x school x absence date (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_fact_absence BY NAME
# MAGIC SELECT a.school_year                                         AS school_year_sk,
# MAGIC        coalesce(st.student_sk, -1)                           AS student_sk,
# MAGIC        coalesce(d.district_sk, -1)                           AS district_sk,
# MAGIC        coalesce(sc.school_sk, -1)                            AS school_sk,
# MAGIC        CAST(date_format(a.absence_date, 'yyyyMMdd') AS INT)  AS absence_date_sk,
# MAGIC        coalesce(t.absence_type_sk, -1)                       AS absence_type_sk,
# MAGIC        1                                                     AS absence_count,
# MAGIC        CASE WHEN t.is_full_day THEN 1 ELSE 0 END             AS full_day_flag,
# MAGIC        CASE WHEN NOT t.is_full_day THEN 1 ELSE 0 END         AS part_day_flag,
# MAGIC        CASE WHEN t.is_excused THEN 1 ELSE 0 END              AS excused_flag
# MAGIC FROM silver_student_absence a
# MAGIC LEFT JOIN gold_dim_student st      ON st.ssid = a.ssid AND st.is_current
# MAGIC LEFT JOIN gold_dim_district d      ON d.county_district_code = a.county_district_code AND d.is_current
# MAGIC LEFT JOIN gold_dim_school sc       ON sc.county_district_code = a.county_district_code AND sc.school_code = a.school_code AND sc.is_current
# MAGIC LEFT JOIN gold_dim_absence_type t  ON t.code = a.absence_code
# MAGIC WHERE a._submission_type = 'year-end final';
# MAGIC
# MAGIC CREATE OR REPLACE TABLE gold_fact_school_enrollment (
# MAGIC   school_year_sk BIGINT NOT NULL COMMENT 'CEDARS C01 – School year',
# MAGIC   student_sk BIGINT NOT NULL COMMENT 'CEDARS C04 – Student (SSID)',
# MAGIC   district_sk BIGINT NOT NULL COMMENT 'CEDARS C02 – Serving district',
# MAGIC   school_sk BIGINT NOT NULL COMMENT 'CEDARS C05 – School (Location ID via xref_location)',
# MAGIC   entry_date_sk INT NOT NULL COMMENT 'CEDARS C06 – School enrollment date',
# MAGIC   exit_date_sk INT NOT NULL COMMENT 'CEDARS C08 – School exit date (-2 while enrolled)',
# MAGIC   grade_level_sk BIGINT NOT NULL COMMENT 'CEDARS B13 – Grade level (from the covering File B spell)',
# MAGIC   withdrawal_code STRING COMMENT 'CEDARS C09 – School withdrawal code (junk dimension in the full model)',
# MAGIC   days_present INT COMMENT 'CEDARS C12 – Cumulative days present this enrollment period',
# MAGIC   enrolled_days INT COMMENT 'Derived from CEDARS C12, N06, N07 – days present + full-day absences in the spell (approximation, design §6)'
# MAGIC ) COMMENT 'Coverage: SSID x school x school entry date (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_fact_school_enrollment BY NAME
# MAGIC WITH full_day_absences AS (
# MAGIC   SELECT c.ssid, c.county_district_code, c.location_id, c.school_enrollment_date, count(*) AS full_day_absences
# MAGIC   FROM silver_school_student_enrollment c
# MAGIC   JOIN silver_student_absence a
# MAGIC     ON  a.ssid = c.ssid AND a.county_district_code = c.county_district_code AND a.location_id = c.location_id
# MAGIC     AND a.absence_date BETWEEN c.school_enrollment_date AND coalesce(c.school_exit_date, DATE'9999-12-31')
# MAGIC   JOIN gold_dim_absence_type t ON t.code = a.absence_code AND t.is_full_day
# MAGIC   GROUP BY ALL
# MAGIC )
# MAGIC SELECT c.school_year                                                      AS school_year_sk,
# MAGIC        coalesce(st.student_sk, -1)                                        AS student_sk,
# MAGIC        coalesce(d.district_sk, -1)                                        AS district_sk,
# MAGIC        coalesce(sc.school_sk, -1)                                         AS school_sk,
# MAGIC        CAST(date_format(c.school_enrollment_date, 'yyyyMMdd') AS INT)     AS entry_date_sk,
# MAGIC        coalesce(CAST(date_format(c.school_exit_date, 'yyyyMMdd') AS INT), -2) AS exit_date_sk,
# MAGIC        coalesce(g.grade_level_sk, -1)                                     AS grade_level_sk,
# MAGIC        c.school_withdrawal_code                                           AS withdrawal_code,
# MAGIC        c.days_present,
# MAGIC        c.days_present + coalesce(f.full_day_absences, 0)                  AS enrolled_days
# MAGIC FROM silver_school_student_enrollment c
# MAGIC LEFT JOIN silver_district_student_enrollment b
# MAGIC   ON  b.ssid = c.ssid AND b.school_year = c.school_year AND b.county_district_code = c.county_district_code
# MAGIC   AND c.school_enrollment_date BETWEEN b.district_enrollment_date AND coalesce(b.district_exit_date, DATE'9999-12-31')
# MAGIC LEFT JOIN full_day_absences f
# MAGIC   ON  f.ssid = c.ssid AND f.county_district_code = c.county_district_code
# MAGIC   AND f.location_id = c.location_id AND f.school_enrollment_date = c.school_enrollment_date
# MAGIC LEFT JOIN gold_dim_student st      ON st.ssid = c.ssid AND st.is_current
# MAGIC LEFT JOIN gold_dim_district d      ON d.county_district_code = c.county_district_code AND d.is_current
# MAGIC LEFT JOIN gold_dim_school sc       ON sc.county_district_code = c.county_district_code AND sc.school_code = c.school_code AND sc.is_current
# MAGIC LEFT JOIN gold_dim_grade_level g   ON g.code = b.grade_level
# MAGIC WHERE c._submission_type = 'year-end final';

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE gold_fact_student_school_year (
# MAGIC   school_year_sk BIGINT NOT NULL COMMENT 'CEDARS *01 – School year',
# MAGIC   student_sk BIGINT NOT NULL COMMENT 'CEDARS B05 – Student (SSID)',
# MAGIC   district_sk BIGINT NOT NULL COMMENT 'CEDARS B02 – Serving district',
# MAGIC   enrolled_days INT COMMENT 'Derived from CEDARS C12, N07 – sum over school enrollments (approximation)',
# MAGIC   days_present INT COMMENT 'CEDARS C12 – sum over school enrollments',
# MAGIC   full_day_absences INT COMMENT 'CEDARS N07 – count of EF/UF',
# MAGIC   part_day_absences INT COMMENT 'CEDARS N07 – count of EP/UP',
# MAGIC   excused_absences INT COMMENT 'CEDARS N07 – count of EF/EP'
# MAGIC ) COMMENT 'Periodic snapshot: SSID x serving district x school year, built from gold facts (lineage demo)';
# MAGIC
# MAGIC INSERT INTO gold_fact_student_school_year BY NAME
# MAGIC WITH enr AS (
# MAGIC   SELECT school_year_sk, student_sk, district_sk, sum(enrolled_days) AS enrolled_days, sum(days_present) AS days_present
# MAGIC   FROM gold_fact_school_enrollment GROUP BY ALL
# MAGIC ),
# MAGIC absn AS (
# MAGIC   SELECT school_year_sk, student_sk, district_sk,
# MAGIC          sum(full_day_flag) AS full_day_absences, sum(part_day_flag) AS part_day_absences, sum(excused_flag) AS excused_absences
# MAGIC   FROM gold_fact_absence GROUP BY ALL
# MAGIC )
# MAGIC SELECT e.school_year_sk, e.student_sk, e.district_sk, e.enrolled_days, e.days_present,
# MAGIC        coalesce(a.full_day_absences, 0) AS full_day_absences,
# MAGIC        coalesce(a.part_day_absences, 0) AS part_day_absences,
# MAGIC        coalesce(a.excused_absences, 0)  AS excused_absences
# MAGIC FROM enr e
# MAGIC LEFT JOIN absn a USING (school_year_sk, student_sk, district_sk);
# MAGIC
# MAGIC CREATE OR REPLACE VIEW gold_v_student_attendance_summary
# MAGIC COMMENT 'Analyst view: attendance by student, district and year. attendance_rate uses the enrolled-days approximation (design §6).'
# MAGIC AS
# MAGIC SELECT y.school_year_label, d.district_name, s.ssid, s.gender_description,
# MAGIC        f.enrolled_days, f.days_present, f.full_day_absences, f.part_day_absences,
# MAGIC        round(f.days_present / nullif(f.enrolled_days, 0), 3) AS attendance_rate
# MAGIC FROM gold_fact_student_school_year f
# MAGIC JOIN gold_dim_school_year y ON y.school_year_sk = f.school_year_sk
# MAGIC JOIN gold_dim_district d    ON d.district_sk = f.district_sk
# MAGIC JOIN gold_dim_student s     ON s.student_sk = f.student_sk;
# MAGIC
# MAGIC SELECT * FROM gold_v_student_attendance_summary ORDER BY ssid, district_name;

# COMMAND ----------

# MAGIC %md
# MAGIC ## 6. A lineage gap, on purpose
# MAGIC
# MAGIC Two tables with the same content. The SQL one keeps its lineage. The pandas one goes through driver memory
# MAGIC (`toPandas` → `createDataFrame`), so Unity Catalog sees a write from local data and records **no upstream**.
# MAGIC The same happens with anything that leaves Spark (a CSV exported and re-imported, an external ETL tool writing by
# MAGIC path, etc.).

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE gold_demo_absence_by_school_sql AS
# MAGIC SELECT school_sk, sum(absence_count) AS absences FROM gold_fact_absence GROUP BY school_sk;

# COMMAND ----------

pdf = spark.table("gold_fact_absence").toPandas()
summary = pdf.groupby("school_sk", as_index=False)["absence_count"].sum().rename(columns={"absence_count": "absences"})
spark.createDataFrame(summary).write.mode("overwrite").saveAsTable("gold_demo_absence_by_school_pandas")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 7. Read lineage back from system tables
# MAGIC
# MAGIC Catalog Explorer → any table → **Lineage** tab shows the graph within a few minutes. The same data is queryable
# MAGIC in `system.access.table_lineage` and `system.access.column_lineage` (needs the `system.access` schema enabled and
# MAGIC `SELECT` on it; rows can take a while to appear). Re-run these cells if they come back empty.

# COMMAND ----------

display(spark.sql(f"""
    SELECT coalesce(source_table_full_name, source_path) AS source,
           source_type,
           target_table_full_name AS target,
           target_type,
           entity_type,
           max(event_time) AS last_seen
    FROM system.access.table_lineage
    WHERE target_table_catalog = '{catalog}' AND target_table_schema = '{schema}'
      AND event_date >= current_date() - INTERVAL 7 DAYS
    GROUP BY ALL
    ORDER BY target, source
"""))

# COMMAND ----------

# Walk column lineage upstream from one gold column to its bronze/volume origins.
edges = spark.sql(f"""
    SELECT DISTINCT
           target_table_full_name || '.' || target_column_name AS target,
           coalesce(source_table_full_name, source_path) || '.' || source_column_name AS source
    FROM system.access.column_lineage
    WHERE target_table_catalog = '{catalog}' AND target_table_schema = '{schema}'
      AND event_date >= current_date() - INTERVAL 7 DAYS
      AND source_column_name IS NOT NULL
""").collect()

upstream = {}
for e in edges:
    upstream.setdefault(e.target, set()).add(e.source)

def trace(column: str, depth: int = 0, seen: frozenset = frozenset()) -> None:
    print("  " * depth + column)
    if column in seen:
        return
    for src in sorted(upstream.get(column, ())):
        trace(src, depth + 1, seen | {column})

for col in ("gold_dim_student.gender", "gold_fact_school_enrollment.school_sk", "gold_v_student_attendance_summary.attendance_rate"):
    trace(f"{catalog}.{schema}.{col}")
    print()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Teardown
# MAGIC
# MAGIC Uncomment to drop the tables, view and volume this notebook created. The schema and anything else in it are left
# MAGIC alone. Lineage history for dropped tables stays in the system tables for the retention period.

# COMMAND ----------

# demo_tables = [
#     "bronze_location", "bronze_district_student_enrollment", "bronze_school_student_enrollment", "bronze_student_absence",
#     "ref_code", "silver_location", "silver_xref_location", "silver_district_student_enrollment",
#     "silver_school_student_enrollment", "silver_student_absence", "silver_xref_student", "silver_student_attribute_history",
#     "gold_dim_date", "gold_dim_school_year", "gold_dim_district", "gold_dim_school", "gold_dim_absence_type",
#     "gold_dim_grade_level", "gold_dim_student", "gold_dim_student_pii", "gold_fact_absence", "gold_fact_school_enrollment",
#     "gold_fact_student_school_year", "gold_demo_absence_by_school_sql", "gold_demo_absence_by_school_pandas",
# ]
# spark.sql("DROP VIEW IF EXISTS gold_v_student_attendance_summary")
# for t in demo_tables:
#     spark.sql(f"DROP TABLE IF EXISTS {t}")
# spark.sql("DROP VOLUME IF EXISTS landing")
