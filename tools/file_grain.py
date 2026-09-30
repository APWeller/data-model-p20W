"""Stated grain per CEDARS file, quoted verbatim from the v19 manual.

Each `stated_grain` must appear in the manual text (whitespace/quote-normalized);
parse_manual.py fails the build if one does not. `source` says where the quote lives.
The formal record key is carried separately in files.csv `key_elements`, taken from the
Data Element Summary's "Key" column.
"""

FILE_GRAIN: dict[str, dict] = {
    "A": dict(source="file description",
              stated_grain="Each of the district's schools with enrolled students will be reported in this "
                           "file using the OSPI assigned school code."),
    "B": dict(source="file description",
              stated_grain="This file contains the record(s) for each served student's enrollment occurrences "
                           "in the district during the current school year."),
    "C": dict(source="file description",
              stated_grain="A student should have a record for each enrollment."),
    "D": dict(source="file description",
              stated_grain="There should be one record for each course offered at each school within the district."),
    "E": dict(source="element E07 business rules",
              stated_grain="Element E06 – Course ID, Element E07 – Section ID and Element E08 - Term "
                           "combination must be distinct."),
    "F": dict(source="file description",
              stated_grain="There should be one entry for each staff type for each staff member."),
    "G": dict(source="file description",
              stated_grain="The Staff Schedule File will include all teachers and the courses taught by "
                           "teachers in the current school year."),
    "H": dict(source="file description",
              stated_grain="This file contains all high school credit courses where credit was attempted for "
                           "every student served during the current school year, including those students "
                           "who exit the school."),
    "I": dict(source="file description",
              stated_grain="A record must be submitted for each program, service or attribute the student "
                           "participates in or is identified with."),
    "J": dict(source="file description",
              stated_grain="There should be at least one entry for each student identified for the current "
                           "school year."),
    "K": dict(source="file description",
              stated_grain="There should be one entry for each student per enrollment into the program for "
                           "the current school year per location."),
    "L": dict(source="file description",
              stated_grain="If the student is Hispanic, there can be multiple records for the student "
                           "identifying all sub–categories of Hispanic with which the student identifies."),
    "M": dict(source="file description",
              stated_grain="For students who are multiracial, individual records will be submitted; one for "
                           "each race."),
    "N": dict(source="file description",
              stated_grain="This file consists of one record for each student served in the district during "
                           "the current school year for each absence associated with the student for each "
                           "school the student is enrolled."),
    "P": dict(source="File P stub page", title="Student Discipline File (P)", page=141,
              description="Beginning with the 2018-19 school year this file is no longer active. Student "
                          "Discipline Exclusion Data is submitted through File (R) beginning with the "
                          "2018-19 school year.",
              stated_grain="Beginning with the 2018-19 school year this file is no longer active."),
    "Q": dict(source="file description",
              stated_grain="There should be one record per student per program enrollment for the current "
                           "school year."),
    "R": dict(source="file description",
              stated_grain="This file contains a record for each exclusionary action taken for each student "
                           "involved in an incident during the current school year."),
    "S": dict(source="element S06 business rules",
              stated_grain="This ID serves to uniquely identify each restrained or isolated action record."),
    "T": dict(source="file description",
              stated_grain="This file contains all non-scheduled courses and other non-course credit "
                           "activities where high school credit was attempted while the student was enrolled "
                           "at any school in the district during the current school year or the preceding "
                           "summer school term, including those students who exit the school."),
    "U": dict(source="file description",
              stated_grain="This file captures information on all currently enrolled students referred for "
                           "an initial evaluation to determine if a student is eligible for special education."),
    "V": dict(source="file description",
              stated_grain="A record in this file represents the screening process for each student."),
}
