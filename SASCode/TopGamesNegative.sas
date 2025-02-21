LIBNAME mydata "/home/u63174806/sasuser.v94/permanent_data";

PROC SQL;
    CREATE TABLE mydata.indie_games AS
    SELECT DISTINCT app_id, "Indie" AS game_type /* Keep only games tagged as Indie */
    FROM mydata.tags
    WHERE tag = "Indie"

    UNION /* Combine with genre-based indie classification */

    SELECT DISTINCT app_id, "Indie" AS game_type /* Keep only games with Indie genre */
    FROM mydata.genres
    WHERE genre = "Indie";
QUIT;

PROC SQL;
    CREATE TABLE mydata.top_negative_games AS
    SELECT c.app_id, 
           c.name, 
           INPUT(c.negative, COMMA12.) AS negative_count, /* Convert to numeric */
           INPUT(c.total, COMMA12.) AS total_count, /* Convert to numeric */
           COALESCE(i.game_type, "Non-Indie") AS game_type /* If game is Indie, assign "Indie", else "Non-Indie" */
    FROM mydata.combined AS c
    LEFT JOIN mydata.indie_games AS i /* Left join to check if game is Indie */
    ON c.app_id = i.app_id
    WHERE c.review_score_description = "Overwhelmingly Negative"
    ORDER BY negative_count DESC; /* Order by highest negative reviews */
QUIT;

DATA mydata.top_negative_games;
    SET mydata.top_negative_games (OBS=12);
RUN;

DATA mydata.top_negative_games_ratio;
    SET mydata.top_negative_games;
    negative_ratio = negative_count; /* Calculate percentage */
RUN;

PROC SORT DATA=mydata.top_negative_games_ratio;
    BY DESCENDING negative_ratio; /* Ensures worst-rated games appear at the top */
RUN;

DATA attrmap;
    LENGTH ID VALUE $20 FILLCOLOR $8;
    ID = "game_type"; VALUE = "Indie"; FILLCOLOR = "YELLOW"; OUTPUT;
    ID = "game_type"; VALUE = "Non-Indie"; FILLCOLOR = "BLUE"; OUTPUT;
RUN;

TITLE "Top Overwhelmingly Negative Rated Games (By Number of Reviews)";
PROC SGPLOT DATA=mydata.top_negative_games_ratio DATATTRMAP=attrmap;
    HBAR name / RESPONSE=negative_ratio
               GROUP=game_type /* Assigns different colors to Indie & Non-Indie */
               GROUPDISPLAY=CLUSTER /* Ensures different colors are applied */
               DATALABEL
               ATTRID=game_type; /* Apply the color mapping */
    XAXIS LABEL="Number of Negative Reviews" GRID;
    YAXIS LABEL="Game Name" DISCRETEORDER=DATA; /* Keeps correct order */
    KEYLEGEND / TITLE="Game Type"; /* Adds a legend for Indie & Non-Indie */
RUN;

LIBNAME mydata CLEAR;
