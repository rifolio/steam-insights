LIBNAME mydata "/home/u63174806/sasuser.v94/permanent_data";

PROC SQL;
    CREATE TABLE mydata.indie_games AS
    SELECT DISTINCT app_id, "Indie" AS game_type
    FROM mydata.tags
    WHERE tag = "Indie"
    UNION
    SELECT DISTINCT app_id, "Indie" AS game_type
    FROM mydata.genres
    WHERE genre = "Indie";
QUIT;

PROC SQL;
    CREATE TABLE mydata.indie_vs_nonindie AS
    SELECT COALESCE(i.game_type, "Non-Indie") AS game_type,
           COUNT(*) AS game_count
    FROM mydata.combined AS c
    LEFT JOIN mydata.indie_games AS i
    ON c.app_id = i.app_id
    GROUP BY game_type;
QUIT;

TITLE "Proportion of Indie vs. Non-Indie Games";
PROC GCHART DATA=mydata.indie_vs_nonindie;
    PIE game_type / SUMVAR=game_count 
                    VALUE=INSIDE  
                    PERCENT=INSIDE  
                    SLICE=OUTSIDE  
                    NOHEADING;
RUN;
QUIT;

LIBNAME mydata CLEAR;