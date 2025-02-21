LIBNAME mydata "/home/u63174806/sasuser.v94/permanent_data";

PROC SQL;
    CREATE TABLE mydata.selected_games AS 
    SELECT app_id, name, release_date, is_free, type 
    FROM mydata.games;
QUIT;

PROC SQL;
    CREATE TABLE mydata.selected_steamspy AS 
    SELECT app_id, developer, publisher, owners_range 
    FROM mydata.steamspy_insights;
QUIT;

PROC SQL;
    CREATE TABLE mydata.selected_reviews AS 
    SELECT app_id, review_score, review_score_description, positive, negative, total 
    FROM mydata.reviews;
QUIT;

PROC SQL;
    CREATE TABLE mydata.combined AS 
    SELECT g.app_id, g.name, g.release_date, g.is_free, g.type, 
           s.developer, s.publisher, s.owners_range,
           r.review_score, r.review_score_description, 
           INPUT(r.positive, COMMA12.) AS positive, 
           INPUT(r.negative, COMMA12.) AS negative,
           INPUT(r.total, COMMA12.) AS total 
    FROM mydata.selected_games AS g
    INNER JOIN mydata.selected_steamspy AS s ON g.app_id = s.app_id
    INNER JOIN mydata.selected_reviews AS r ON g.app_id = r.app_id;
QUIT;

DATA mydata.combined;
    SET mydata.combined;
    IF VTYPE(release_date) = 'C' THEN 
        release_date_fixed = INPUT(release_date, YYMMDD10.); 
    ELSE 
        release_date_fixed = release_date; 
    FORMAT release_date_fixed DATE9.; 
    DROP release_date; 
    RENAME release_date_fixed = release_date;
RUN;

PROC PRINT DATA=mydata.combined (OBS=10);
    TITLE "Sample of Combined Data";
RUN;
