/* Set graphics output size */
ODS GRAPHICS / WIDTH=1200px HEIGHT=600px;

/* Assign library for permanent datasets */
LIBNAME mydata "/home/u63174806/sasuser.v94/permanent_data";

/* Extract release year */
DATA mydata.games_yearly;
    SET mydata.combined;
    release_year = YEAR(INPUT(release_date, ANYDTDTE.));
    IF release_year >= 1997 AND release_year <= 2024;
RUN;

/* Identify Indie Games using Tags and Genres */
PROC SQL;
    CREATE TABLE mydata.indie_games AS
    SELECT DISTINCT app_id, "Indie" AS game_type 
    FROM mydata.tags WHERE tag = "Indie"
    UNION 
    SELECT DISTINCT app_id, "Indie" AS game_type 
    FROM mydata.genres WHERE genre = "Indie";
QUIT;

/* Count Total and Indie Games Released Each Year */
PROC SQL;
    CREATE TABLE mydata.games_per_year AS
    SELECT g.release_year, 
           COUNT(*) AS total_games, 
           SUM(CASE WHEN i.app_id IS NOT NULL THEN 1 ELSE 0 END) AS indie_games
    FROM mydata.games_yearly AS g
    LEFT JOIN mydata.indie_games AS i
    ON g.app_id = i.app_id
    GROUP BY g.release_year
    ORDER BY g.release_year;
QUIT;

/* Calculate Cumulative Total Games Released */
DATA mydata.games_cumulative;
    SET mydata.games_per_year;
    RETAIN cumulative_games 0;
    cumulative_games + total_games;
RUN;

/* Create the Graph */
TITLE "Total, Cumulative, and Indie Games Released Each Year";
PROC SGPLOT DATA=mydata.games_cumulative;
    VBAR release_year / RESPONSE=cumulative_games 
                        FILLATTRS=(COLOR=STEELBLUE) 
                        TRANSPARENCY=0.4 
                        LEGENDLABEL="Games Published Yearly (Cumulative)";
    
    VBAR release_year / RESPONSE=total_games 
                        FILLATTRS=(COLOR=DARKBLUE) 
                        LEGENDLABEL="Games Published Yearly";
    
    VBAR release_year / RESPONSE=indie_games 
                        FILLATTRS=(COLOR=PURPLE) 
                        LEGENDLABEL="Indie Games Published Yearly";
    
    XAXIS LABEL="Year" VALUES=(1997 TO 2024 BY 1) GRID;
    YAXIS LABEL="Number of Games" GRID;
    KEYLEGEND / TITLE="Games Published";
RUN;

/* Reset graphics settings */
ODS GRAPHICS / RESET;

/* Clear library reference */
LIBNAME mydata CLEAR;