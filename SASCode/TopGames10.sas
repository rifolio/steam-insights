LIBNAME mydata "/home/u63174806/sasuser.v94/permanent_data";

PROC SQL;
    CREATE TABLE genre_counts AS
    SELECT genre, COUNT(*) AS game_count
    FROM mydata.GENRES /* Using the permanent dataset */
    GROUP BY genre
    ORDER BY game_count DESC;
QUIT;

PROC SQL;
    CREATE TABLE tag_counts AS
    SELECT tag, COUNT(*) AS game_count
    FROM mydata.TAGS /* Using the permanent dataset */
    GROUP BY tag
    ORDER BY game_count DESC;
QUIT;

PROC SQL;
    CREATE TABLE category_counts AS
    SELECT category, COUNT(*) AS game_count
    FROM mydata.CATEGORIES /* Using the permanent dataset */
    GROUP BY category
    ORDER BY game_count DESC;
QUIT;

PROC SGPLOT DATA=genre_counts (OBS=10);
    HBAR genre / RESPONSE=game_count 
                 FILLTYPE=GRADIENT 
                 FILLATTRS=(COLOR=BLUE) /* Change color */
                 DATALABEL;
    TITLE "Top 10 Most Popular Genres";
    XAXIS LABEL="Number of Games" GRID;
    YAXIS LABEL="Genre" DISCRETEORDER=DATA; /* Keeps correct order */
RUN;

PROC SGPLOT DATA=tag_counts (OBS=10);
    HBAR tag / RESPONSE=game_count 
                 FILLTYPE=GRADIENT 
                 FILLATTRS=(COLOR=GREEN) /* Change color */
                 DATALABEL;
    TITLE "Top 10 Most Popular Tags";
    XAXIS LABEL="Number of Games" GRID;
    YAXIS LABEL="Tag" DISCRETEORDER=DATA; /* Keeps correct order */
RUN;

PROC SGPLOT DATA=category_counts (OBS=10);
    HBAR category / RESPONSE=game_count 
                   FILLTYPE=GRADIENT 
                   FILLATTRS=(COLOR=ORANGE) /* Change color */
                   DATALABEL;
    TITLE "Top 10 Most Popular Categories";
    XAXIS LABEL="Number of Games" GRID;
    YAXIS LABEL="Category" DISCRETEORDER=DATA; /* Keeps correct order */
RUN;

LIBNAME mydata CLEAR;
