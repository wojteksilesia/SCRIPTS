SYS:
CREATE USER CHESS IDENTIFIED BY chess;
GRANT CREATE SESSION, CREATE SEQUENCE, CREATE TRIGGER, CREATE TABLE, CREATE PROCEDURE, CREATE VIEW TO CHESS;
ALTER USER CHESS QUOTA UNLIMITED ON SYSTEM;

CHESS:
CREATE TABLE OPENING_TRAINING 
(
 ID NUMBER PRIMARY KEY,
 OPENING VARCHAR2(4000),
 COLOUR VARCHAR2(40),
 REPEAT_1_DATE DATE,
 IS_DONE_1 NUMBER,
 REPEAT_2_DATE DATE,
 IS_DONE_2 NUMBER, 
 REPEAT_3_DATE DATE,
 IS_DONE_3 NUMBER,
 REPEAT_4_DATE DATE,
 IS_DONE_4 NUMBER,
 REPEAT_5_DATE DATE,
 IS_DONE_5 NUMBER,
 TIMESTAMP_CREATED DATE,
 TIMESTAMP_MODIFIED DATE
);

ALTER TABLE CHESS.OPENING_TRAINING ADD CONSTRAINT CHESS_TRAINING_UK UNIQUE(OPENING,COLOUR);

CREATE TABLE POSITIONAL_PICTURES 
   (
    ID_PICTURE NUMBER, 
	PICTURE_NAME VARCHAR2(4000), 
	SOLUTION VARCHAR2(4000 ), 
	MOVE VARCHAR2(20), 
	PLAYERS VARCHAR2(200), 
	TIMESTAMP_CREATED DATE, 
	TIMESTAMP_MODIFIED DATE
   );

CREATE OR REPLACE VIEW V_REPEAT_TODAY AS
SELECT OPENING,COLOUR 
FROM OPENING_TRAINING
WHERE 1=1
AND
 (
  (IS_DONE_1=0 AND TRUNC(REPEAT_1_DATE)=TRUNC(SYSDATE)) OR
  (IS_DONE_2=0 AND TRUNC(REPEAT_2_DATE)=TRUNC(SYSDATE)) OR
  (IS_DONE_3=0 AND TRUNC(REPEAT_3_DATE)=TRUNC(SYSDATE)) OR
  (IS_DONE_4=0 AND TRUNC(REPEAT_4_DATE)=TRUNC(SYSDATE)) OR
  (IS_DONE_5=0 AND TRUNC(REPEAT_5_DATE)=TRUNC(SYSDATE)) 
);


CREATE OR REPLACE VIEW V_DONE_TODAY AS
SELECT OPENING,COLOUR 
FROM OPENING_TRAINING
WHERE 1=1
AND
 (
  (IS_DONE_1=1 AND TRUNC(REPEAT_1_DATE)=TRUNC(SYSDATE)) OR
  (IS_DONE_2=1 AND TRUNC(REPEAT_2_DATE)=TRUNC(SYSDATE)) OR
  (IS_DONE_3=1 AND TRUNC(REPEAT_3_DATE)=TRUNC(SYSDATE)) OR
  (IS_DONE_4=1 AND TRUNC(REPEAT_4_DATE)=TRUNC(SYSDATE)) OR
  (IS_DONE_5=1 AND TRUNC(REPEAT_5_DATE)=TRUNC(SYSDATE)) 
);


CREATE OR REPLACE VIEW V_REPEAT_TOMORROW AS
SELECT OPENING,COLOUR 
FROM OPENING_TRAINING
WHERE 1=1
AND
 (
  (IS_DONE_1=0 AND TRUNC(REPEAT_1_DATE)=TRUNC(SYSDATE+1)) OR
  (IS_DONE_2=0 AND TRUNC(REPEAT_2_DATE)=TRUNC(SYSDATE+1)) OR
  (IS_DONE_3=0 AND TRUNC(REPEAT_3_DATE)=TRUNC(SYSDATE+1)) OR
  (IS_DONE_4=0 AND TRUNC(REPEAT_4_DATE)=TRUNC(SYSDATE+1)) OR
  (IS_DONE_5=0 AND TRUNC(REPEAT_5_DATE)=TRUNC(SYSDATE+1)) 
);


CREATE OR REPLACE VIEW V_DONE_YESTERDAY AS
SELECT OPENING,COLOUR 
FROM OPENING_TRAINING
WHERE 1=1
AND
 (
  (IS_DONE_1=1 AND TRUNC(REPEAT_1_DATE)=TRUNC(SYSDATE-1)) OR
  (IS_DONE_2=1 AND TRUNC(REPEAT_2_DATE)=TRUNC(SYSDATE-1)) OR
  (IS_DONE_3=1 AND TRUNC(REPEAT_3_DATE)=TRUNC(SYSDATE-1)) OR
  (IS_DONE_4=1 AND TRUNC(REPEAT_4_DATE)=TRUNC(SYSDATE-1)) OR
  (IS_DONE_5=1 AND TRUNC(REPEAT_5_DATE)=TRUNC(SYSDATE-1)) 
);

CREATE OR REPLACE VIEW V_SHOW_MISSED AS
        SELECT Q.*,TRUNC(SYSDATE)-TRUNC(Q.MISSED_DATE) DELAY FROM
        (
          SELECT 
                OPENING,
                COLOUR,
                CASE 
                    WHEN IS_DONE_1=0 THEN REPEAT_1_DATE
                    WHEN IS_DONE_2=0 THEN REPEAT_2_DATE
                    WHEN IS_DONE_3=0 THEN REPEAT_3_DATE
                    WHEN IS_DONE_4=0 THEN REPEAT_4_DATE
                    WHEN IS_DONE_5=0 THEN REPEAT_5_DATE
                END MISSED_DATE
            FROM OPENING_TRAINING
            WHERE 1=1
            AND
            (
                (IS_DONE_1=0 AND TRUNC(REPEAT_1_DATE)<TRUNC(SYSDATE)) OR
                (IS_DONE_2=0 AND TRUNC(REPEAT_2_DATE)<TRUNC(SYSDATE)) OR
                (IS_DONE_3=0 AND TRUNC(REPEAT_3_DATE)<TRUNC(SYSDATE)) OR
                (IS_DONE_4=0 AND TRUNC(REPEAT_4_DATE)<TRUNC(SYSDATE)) OR
                (IS_DONE_5=0 AND TRUNC(REPEAT_5_DATE)<TRUNC(SYSDATE)) 
            )
            ORDER BY 3
            ) Q;



create or replace PACKAGE PCG_OPENING_TRAINING IS

PROCEDURE ADD_OPENING(ivName IN VARCHAR2, ivColor IN VARCHAR2);
PROCEDURE SHOW_DELAY;
PROCEDURE SHOW_MISSED;
PROCEDURE REPEAT_TODAY;
PROCEDURE REPEAT_TOMORROW;
PROCEDURE SET_IS_DONE(ivName IN VARCHAR2,ivRepeat_date IN VARCHAR2);
PROCEDURE REPEAT_USER_DAY(ivDate IN VARCHAR2);
PROCEDURE DONE_TODAY;
PROCEDURE DONE_YESTERDAY;
PROCEDURE ADD_PICTURE(ivPicture_name IN VARCHAR2,ivSolution IN VARCHAR2,ivMove IN VARCHAR2,ivPlayers IN VARCHAR2);

END;
/

create or replace PACKAGE BODY PCG_OPENING_TRAINING IS

PROCEDURE ADD_OPENING(ivName IN VARCHAR2, ivColor IN VARCHAR2) IS
lnId NUMBER;
ldDate DATE;
lnDate_ok NUMBER:=0;
lnX NUMBER;
leError EXCEPTION;

BEGIN
    IF UPPER(ivColor) NOT IN ('WHITE','BLACK') THEN
        RAISE leError;
    END IF;

    SELECT NVL(MAX(ID)+1,1) INTO lnId FROM CHESS.OPENING_TRAINING;

    ldDate:=TRUNC(SYSDATE);
    WHILE lnDate_ok=0 LOOP
        ldDate:=ldDate+1;
        SELECT COUNT(1) 
        INTO lnX 
        FROM CHESS.OPENING_TRAINING
        WHERE 1=1
        AND
            (
                (IS_DONE_1=0 AND TRUNC(REPEAT_1_DATE)=ldDate) OR
                (IS_DONE_2=0 AND TRUNC(REPEAT_2_DATE)=ldDate) OR
                (IS_DONE_3=0 AND TRUNC(REPEAT_3_DATE)=ldDate) OR
                (IS_DONE_4=0 AND TRUNC(REPEAT_4_DATE)=ldDate) OR
                (IS_DONE_5=0 AND TRUNC(REPEAT_5_DATE)=ldDate)
            );
        IF lnX<3 THEN
            lnDate_ok:=1;
        ELSE
            CONTINUE;
        END IF;
    END LOOP;


    INSERT INTO CHESS.OPENING_TRAINING
    (ID,OPENING,COLOUR,REPEAT_1_DATE, IS_DONE_1,REPEAT_2_DATE, IS_DONE_2,REPEAT_3_DATE, IS_DONE_3,REPEAT_4_DATE, IS_DONE_4,
     REPEAT_5_DATE, IS_DONE_5,TIMESTAMP_CREATED,TIMESTAMP_MODIFIED)
     VALUES
     (lnId, ivName, UPPER(ivColor),TRUNC(ldDate),0,TRUNC(ldDate)+1,0,TRUNC(ldDate)+7,0,TRUNC(ADD_MONTHS(ldDate,1)),0,TRUNC(ADD_MONTHS(ldDate,6)),0,
      SYSDATE,NULL);
    COMMIT;

EXCEPTION
    WHEN leError THEN
        dbms_output.put_line('Wrong color');
    WHEN OTHERS THEN
        ROLLBACK;
		RAISE;
        dbms_output.put_line(dbms_utility.format_error_stack()||dbms_utility.format_error_backtrace());
END ADD_OPENING;


PROCEDURE SHOW_DELAY IS
lnResult NUMBER;
BEGIN
	SELECT 
		CASE
		WHEN NVL(TRUNC(SYSDATE)-TRUNC(MIN(MIN_DATE)),0)<0 THEN 0
		ELSE NVL(TRUNC(SYSDATE)-TRUNC(MIN(MIN_DATE)),0) END
		INTO lnResult 
		FROM 
	(
		SELECT MIN(REPEAT_1_DATE) MIN_DATE
		FROM OPENING_TRAINING 
		WHERE IS_DONE_1=0
		UNION ALL
		SELECT MIN(REPEAT_2_DATE) MIN_DATE
		FROM OPENING_TRAINING 
		WHERE IS_DONE_2=0
		UNION ALL
		SELECT MIN(REPEAT_3_DATE) MIN_DATE
		FROM OPENING_TRAINING 
		WHERE IS_DONE_3=0
		UNION ALL
		SELECT MIN(REPEAT_4_DATE) MIN_DATE
		FROM OPENING_TRAINING 
		WHERE IS_DONE_4=0
		UNION ALL
		SELECT MIN(REPEAT_5_DATE) MIN_DATE
		FROM OPENING_TRAINING 
		WHERE IS_DONE_5=0
	); 

	DBMS_OUTPUT.PUT_LINE(lnResult);
EXCEPTION
	WHEN OTHERS THEN RAISE;
END SHOW_DELAY;

PROCEDURE SHOW_MISSED IS
BEGIN
	--DBMS_OUTPUT.PUT_LINE(RPAD(LPAD('OPENING',50,' '),100,' ')|| RPAD(LPAD('DELAY',20,' '),40,' ')|| RPAD(LPAD('REPEAT_DATE',20,' '),40,' '));
    DBMS_OUTPUT.PUT_LINE(RPAD('OPENING',80,' ')|| RPAD('DELAY',15,' ')|| RPAD('REPEAT_DATE',20,' '));
    DBMS_OUTPUT.PUT_LINE(RPAD('-',115,'-'));

    FOR rec IN( 
        SELECT 
            OPENING,
            COLOUR,
            CASE 
                WHEN IS_DONE_1=0 THEN REPEAT_1_DATE
                WHEN IS_DONE_2=0 THEN REPEAT_2_DATE
                WHEN IS_DONE_3=0 THEN REPEAT_3_DATE
                WHEN IS_DONE_4=0 THEN REPEAT_4_DATE
                WHEN IS_DONE_5=0 THEN REPEAT_5_DATE
            END NEXT_DATE
        FROM OPENING_TRAINING
        WHERE 1=1
        AND
        (
            (IS_DONE_1=0 AND TRUNC(REPEAT_1_DATE)<TRUNC(SYSDATE)) OR
            (IS_DONE_2=0 AND TRUNC(REPEAT_2_DATE)<TRUNC(SYSDATE)) OR
            (IS_DONE_3=0 AND TRUNC(REPEAT_3_DATE)<TRUNC(SYSDATE)) OR
            (IS_DONE_4=0 AND TRUNC(REPEAT_4_DATE)<TRUNC(SYSDATE)) OR
            (IS_DONE_5=0 AND TRUNC(REPEAT_5_DATE)<TRUNC(SYSDATE)) 
        )
		ORDER BY 3
    )
    LOOP 
        --DBMS_OUTPUT.PUT_LINE(RPAD(LPAD(rec.OPENING,50,' '),100,' ')|| RPAD(LPAD(rec.NEXT_DATE-TRUNC(SYSDATE),20,' '),40,' ')|| RPAD(LPAD(rec.NEXT_DATE,20,' '),40,' '));
        DBMS_OUTPUT.PUT_LINE(RPAD(rec.OPENING,80,' ')|| RPAD(TRUNC(SYSDATE)-rec.NEXT_DATE,15,' ')|| RPAD(rec.NEXT_DATE,20,' '));
    END LOOP;

END SHOW_MISSED;


PROCEDURE REPEAT_TODAY IS
BEGIN 
    FOR rec IN(
        SELECT ID, OPENING,COLOUR
        FROM OPENING_TRAINING
        WHERE 1=1
        AND
        (
            (TRUNC(REPEAT_1_DATE)=TRUNC(SYSDATE) AND IS_DONE_1=0) OR
            (TRUNC(REPEAT_2_DATE)=TRUNC(SYSDATE) AND IS_DONE_2=0) OR
            (TRUNC(REPEAT_3_DATE)=TRUNC(SYSDATE) AND IS_DONE_3=0) OR
            (TRUNC(REPEAT_4_DATE)=TRUNC(SYSDATE) AND IS_DONE_4=0) OR
            (TRUNC(REPEAT_5_DATE)=TRUNC(SYSDATE) AND IS_DONE_5=0)
        )
    )
    LOOP
       DBMS_OUTPUT.PUT_LINE(RPAD(rec.ID,10,' ')||RPAD(rec.OPENING,80,' ') || RPAD(rec.COLOUR,10,' '));
    END LOOP;
END REPEAT_TODAY;

PROCEDURE REPEAT_TOMORROW IS
BEGIN 
    FOR rec IN(
        SELECT ID, OPENING,COLOUR
        FROM OPENING_TRAINING
        WHERE 1=1
        AND
        (
            (TRUNC(REPEAT_1_DATE)=TRUNC(SYSDATE+1) AND IS_DONE_1=0) OR
            (TRUNC(REPEAT_2_DATE)=TRUNC(SYSDATE+1) AND IS_DONE_2=0) OR
            (TRUNC(REPEAT_3_DATE)=TRUNC(SYSDATE+1) AND IS_DONE_3=0) OR
            (TRUNC(REPEAT_4_DATE)=TRUNC(SYSDATE+1) AND IS_DONE_4=0) OR
            (TRUNC(REPEAT_5_DATE)=TRUNC(SYSDATE+1) AND IS_DONE_5=0)
        )
    )
    LOOP
       DBMS_OUTPUT.PUT_LINE(RPAD(rec.ID,10,' ')||RPAD(rec.OPENING,80,' ') || RPAD(rec.COLOUR,10,' '));
    END LOOP;
END REPEAT_TOMORROW;


PROCEDURE SET_IS_DONE(ivName IN VARCHAR2,ivRepeat_date IN VARCHAR2) IS
    ldDate DATE;
    lnUpdate NUMBER;
BEGIN
    IF ivRepeat_date='SYSDATE' THEN
        ldDate:=TRUNC(SYSDATE);
    ELSIF ivRepeat_date IS NOT NULL THEN
        ldDate:=TRUNC(TO_DATE(ivRepeat_date,'YYYYMMDD'));
    END IF;

    --Co aktualizujemy
    FOR rec IN (SELECT * FROM OPENING_TRAINING WHERE OPENING=ivName)
    LOOP
        IF rec.IS_DONE_1=0 THEN
            lnUpdate:=1;
        ELSIF rec.IS_DONE_2=0 THEN
            lnUpdate:=2;
        ELSIF rec.IS_DONE_3=0 THEN
            lnUpdate:=3;
        ELSIF rec.IS_DONE_4=0 THEN
            lnUpdate:=4;
        ELSIF rec.IS_DONE_5=0 THEN
            lnUpdate:=5;
        END IF;
    END LOOP;

    IF lnUpdate IS NOT NULL THEN
        IF lnUpdate=1 THEN
            UPDATE OPENING_TRAINING 
            SET 
                REPEAT_1_DATE=NVL(ldDate,REPEAT_1_DATE), 
                IS_DONE_1=1,
                REPEAT_2_DATE=NVL(ldDate,REPEAT_1_DATE)+1,
                REPEAT_3_DATE=NVL(ldDate,REPEAT_1_DATE)+7,
                REPEAT_4_DATE=ADD_MONTHS(NVL(ldDate,REPEAT_1_DATE),1),
                REPEAT_5_DATE=ADD_MONTHS(NVL(ldDate,REPEAT_1_DATE),6),
                TIMESTAMP_MODIFIED=SYSDATE
            WHERE OPENING=ivName;

        ELSIF lnUpdate=2 THEN
            UPDATE OPENING_TRAINING 
            SET 
                REPEAT_2_DATE=NVL(ldDate,REPEAT_2_DATE), 
                IS_DONE_2=1,
                TIMESTAMP_MODIFIED=SYSDATE
            WHERE OPENING=ivName;

        ELSIF lnUpdate=3 THEN
            UPDATE OPENING_TRAINING 
            SET 
                REPEAT_3_DATE=NVL(ldDate,REPEAT_3_DATE), 
                IS_DONE_3=1,
                TIMESTAMP_MODIFIED=SYSDATE
            WHERE OPENING=ivName;         
        ELSIF lnUpdate=4 THEN
            UPDATE OPENING_TRAINING 
            SET 
                REPEAT_4_DATE=NVL(ldDate,REPEAT_4_DATE), 
                IS_DONE_4=1,
                TIMESTAMP_MODIFIED=SYSDATE
            WHERE OPENING=ivName;   
         ELSIF lnUpdate=5 THEN
            UPDATE OPENING_TRAINING 
            SET 
                REPEAT_5_DATE=NVL(ldDate,REPEAT_5_DATE), 
                IS_DONE_5=1,
                TIMESTAMP_MODIFIED=SYSDATE
            WHERE OPENING=ivName;   
        END IF;
        COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SET_IS_DONE;

PROCEDURE REPEAT_USER_DAY(ivDate IN VARCHAR2) IS
	ldDate DATE;
BEGIN
	ldDate:=TRUNC(TO_DATE(ivDate,'YYYYMMDD'));
    FOR rec IN(
        SELECT ID, OPENING,COLOUR
        FROM OPENING_TRAINING
        WHERE 1=1
        AND
        (
            (TRUNC(REPEAT_1_DATE)=TRUNC(ldDate) AND IS_DONE_1=0) OR
            (TRUNC(REPEAT_2_DATE)=TRUNC(ldDate) AND IS_DONE_2=0) OR
            (TRUNC(REPEAT_3_DATE)=TRUNC(ldDate) AND IS_DONE_3=0) OR
            (TRUNC(REPEAT_4_DATE)=TRUNC(ldDate) AND IS_DONE_4=0) OR
            (TRUNC(REPEAT_5_DATE)=TRUNC(ldDate) AND IS_DONE_5=0)
        )
    )
    LOOP
       DBMS_OUTPUT.PUT_LINE(RPAD(rec.ID,10,' ')||RPAD(rec.OPENING,80,' ') || RPAD(rec.COLOUR,10,' '));
    END LOOP;
END REPEAT_USER_DAY;

PROCEDURE DONE_TODAY IS
BEGIN
    FOR rec IN(
        SELECT ID, OPENING,COLOUR
        FROM OPENING_TRAINING
        WHERE 1=1
        AND
        (
            (TRUNC(REPEAT_1_DATE)=TRUNC(SYSDATE) AND IS_DONE_1=1) OR
            (TRUNC(REPEAT_2_DATE)=TRUNC(SYSDATE) AND IS_DONE_2=1) OR
            (TRUNC(REPEAT_3_DATE)=TRUNC(SYSDATE) AND IS_DONE_3=1) OR
            (TRUNC(REPEAT_4_DATE)=TRUNC(SYSDATE) AND IS_DONE_4=1) OR
            (TRUNC(REPEAT_5_DATE)=TRUNC(SYSDATE) AND IS_DONE_5=1)
        )
    )
    LOOP
       DBMS_OUTPUT.PUT_LINE(RPAD(rec.ID,10,' ')||RPAD(rec.OPENING,80,' ') || RPAD(rec.COLOUR,10,' '));
    END LOOP;
END DONE_TODAY;


PROCEDURE DONE_YESTERDAY IS
BEGIN
    FOR rec IN(
        SELECT ID, OPENING,COLOUR
        FROM OPENING_TRAINING
        WHERE 1=1
        AND
        (
            (TRUNC(REPEAT_1_DATE)=TRUNC(SYSDATE-1) AND IS_DONE_1=1) OR
            (TRUNC(REPEAT_2_DATE)=TRUNC(SYSDATE-1) AND IS_DONE_2=1) OR
            (TRUNC(REPEAT_3_DATE)=TRUNC(SYSDATE-1) AND IS_DONE_3=1) OR
            (TRUNC(REPEAT_4_DATE)=TRUNC(SYSDATE-1) AND IS_DONE_4=1) OR
            (TRUNC(REPEAT_5_DATE)=TRUNC(SYSDATE-1) AND IS_DONE_5=1)
        )
    )
    LOOP
       DBMS_OUTPUT.PUT_LINE(RPAD(rec.ID,10,' ')||RPAD(rec.OPENING,80,' ') || RPAD(rec.COLOUR,10,' '));
    END LOOP;
END DONE_YESTERDAY;


PROCEDURE ADD_PICTURE(ivPicture_name IN VARCHAR2,ivSolution IN VARCHAR2,ivMove IN VARCHAR2,ivPlayers IN VARCHAR2) IS
    lnId NUMBER;
BEGIN
    SELECT NVL(MAX(ID_PICTURE)+1,1) INTO lnId FROM POSITIONAL_PICTURES;

    INSERT INTO POSITIONAL_PICTURES
    (ID_PICTURE,PICTURE_NAME,SOLUTION,MOVE,PLAYERS,TIMESTAMP_CREATED,TIMESTAMP_MODIFIED)
    VALUES
    (lnId,ivPicture_name,ivSolution,UPPER(ivMove),ivPlayers,SYSDATE,NULL);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END ADD_PICTURE;

END PCG_OPENING_TRAINING;
/