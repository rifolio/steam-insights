ODS PDF FILE="/home/u63174806/sasuser.v94/pdfs/indie_games_report.pdf";

DATA games_cleaned;
    SET WORK.GAMES_CLEANED;
    /* Convert release_date to a valid SAS date format */
    IF NOT MISSING(release_date) THEN DO;
        date_var = INPUT(release_date, ANYDTDTE.);
        release_year = YEAR(date_var);
    END;
    ELSE release_year = .;
    DROP date_var; /* Remove the temporary variable */
RUN;

PROC SQL;
    CREATE TABLE games_genres AS 
    SELECT g.*, gen.genre 
    FROM WORK.games_cleaned AS g
    INNER JOIN WORK.genres AS gen
    ON g.app_id = gen.app_id;
QUIT;

PROC SQL;
    CREATE TABLE indie_games_per_year AS 
    SELECT release_year, COUNT(*) AS indie_count 
    FROM games_genres 
    WHERE genre = "Indie"
    GROUP BY release_year
    ORDER BY release_year;
QUIT;

PROC SQL;
    CREATE TABLE total_games_per_year AS 
    SELECT release_year, COUNT(*) AS total_count 
    FROM games_cleaned 
    GROUP BY release_year
    ORDER BY release_year;
QUIT;

PROC SQL;
    CREATE TABLE indie_ratio_per_year AS 
    SELECT t.release_year, 
           (i.indie_count / t.total_count) * 100 AS indie_percentage
    FROM total_games_per_year AS t
    LEFT JOIN indie_games_per_year AS i
    ON t.release_year = i.release_year
    ORDER BY t.release_year;
QUIT;

TITLE "Indie Games Release Statistics";
PROC PRINT DATA=indie_ratio_per_year NOOBS;
    VAR release_year indie_percentage;
RUN;

TITLE "Percentage of Games Released That Are Indie";
PROC SGPLOT DATA=indie_ratio_per_year;
    VBAR release_year / RESPONSE=indie_percentage FILLATTRS=(COLOR=Skyblue) FILLTYPE=GRADIENT;
    XAXIS LABEL="Year";
    YAXIS LABEL="Percentage of Indie Games" GRID;
RUN;

ODS PDF CLOSE;