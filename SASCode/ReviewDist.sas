LIBNAME mydata "/home/u63174806/sasuser.v94/permanent_data";

PROC SQL;
    CREATE TABLE mydata.indie_games AS
    SELECT DISTINCT t.app_id, "Indie" AS game_type
    FROM mydata.tags AS t
    INNER JOIN mydata.genres AS g
    ON t.app_id = g.app_id
    WHERE t.tag = "Indie" AND g.genre = "Indie"; /* Must be Indie in both datasets */
QUIT;

PROC SQL;
    CREATE TABLE mydata.review_data AS
    SELECT c.app_id, 
           c.review_score, 
           COALESCE(i.game_type, "Non-Indie") AS game_type
    FROM mydata.combined AS c
    LEFT JOIN mydata.indie_games AS i
    ON c.app_id = i.app_id
    WHERE c.review_score IS NOT NULL; /* Ensure valid review scores */
QUIT;

DATA mydata.review_data_filtered;
    SET mydata.review_data;
    /* Convert review_score to numeric */
    review_numeric = INPUT(review_score, BEST12.);
    IF review_numeric >= 1 AND review_numeric <= 10;
RUN;

TITLE "Review Score Distribution for Indie Games (1-10)";
PROC SGPLOT DATA=mydata.review_data_filtered;
    WHERE game_type = "Indie"; /* Select Indie Games */
    HISTOGRAM review_numeric / BINWIDTH=1 SCALE=PERCENT FILLATTRS=(COLOR=YELLOW);
    DENSITY review_numeric / TYPE=KERNEL LINEATTRS=(COLOR=BLACK); /* Smoothed Density Curve */
    XAXIS LABEL="Review Score (1-10)" VALUES=(1 TO 10 BY 1);
    YAXIS LABEL="Percentage of Games";
RUN;

TITLE "Review Score Distribution for Non-Indie Games (1-10)";
PROC SGPLOT DATA=mydata.review_data_filtered;
    WHERE game_type = "Non-Indie"; /* Select Non-Indie Games */
    HISTOGRAM review_numeric / BINWIDTH=1 SCALE=PERCENT FILLATTRS=(COLOR=BLUE);
    DENSITY review_numeric / TYPE=KERNEL LINEATTRS=(COLOR=BLACK); /* Smoothed Density Curve */
    XAXIS LABEL="Review Score (1-10)" VALUES=(1 TO 10 BY 1);
    YAXIS LABEL="Percentage of Games";
RUN;

LIBNAME mydata CLEAR;
