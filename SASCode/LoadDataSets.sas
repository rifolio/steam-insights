/* Define a permanent library named 'mydata' */
LIBNAME mydata "/home/u63174806/sasuser.v94/permanent_data";

%macro import_csv(file_name, dataset_name);
    %web_drop_table(WORK.&dataset_name.);
    
    PROC IMPORT DATAFILE="/home/u63174806/sasuser.v94/CSVs/&file_name..csv"
        DBMS=CSV
        OUT=WORK.&dataset_name.
        REPLACE;
        GETNAMES=YES;
        GUESSINGROWS=MAX;
    RUN;

    /* Convert release_date to SAS Date if the dataset contains this column */
    DATA mydata.&dataset_name.;
        SET WORK.&dataset_name.;
        IF VTYPE(release_date) = 'C' THEN 
            release_date_fixed = INPUT(release_date, YYMMDD10.); 
        ELSE 
            release_date_fixed = release_date;
        FORMAT release_date_fixed DATE9.; 
        DROP release_date;
        RENAME release_date_fixed = release_date;
    RUN;

    /* Save metadata to a PDF file */
    ODS PDF FILE="/home/u63174806/sasuser.v94/pdfs/&dataset_name._metadata.pdf";
    
    PROC CONTENTS DATA=mydata.&dataset_name.; 
    RUN;

    ODS PDF CLOSE;

    %web_open_table(mydata.&dataset_name.);
%mend import_csv;

/* Importing all datasets */
%import_csv(categories, categories);
%import_csv(games, games);
%import_csv(genres, genres);
%import_csv(reviews, reviews);
%import_csv(tags, tags);
%import_csv(steamspy_insights, steamspy_insights);
%import_csv(combined, combined);
