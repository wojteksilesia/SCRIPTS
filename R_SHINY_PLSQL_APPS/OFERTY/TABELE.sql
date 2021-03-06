CREATE SEQUENCE SEQ_CITIES 
START WITH 1
INCREMENT BY 1;

CREATE TABLE PRACUJ_CITIES
(
	ID NUMBER PRIMARY KEY,
	NAME VARCHAR2(4000) UNIQUE NOT NULL,
	CODE VARCHAR2(4000) UNIQUE NOT NULL,
	TIMESTAMP_CREATED DATE,
	TIMESTAMP_MODIFIED DATE
);


SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CITIES_IU
BEFORE INSERT OR UPDATE 
ON PRACUJ_CITIES
FOR EACH ROW

BEGIN 
	IF INSERTING THEN 
		:NEW.ID := SEQ_CITIES.NEXTVAL;
		:NEW.TIMESTAMP_CREATED := SYSDATE;
	ELSIF UPDATING THEN
		:NEW.TIMESTAMP_MODIFIED := SYSDATE;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END TRG_CITIES_IU;
/
		
--------------------------------------------------------------

CREATE SEQUENCE SEQ_TECHNOLOGIES 
START WITH 1
INCREMENT BY 1;

CREATE TABLE PRACUJ_TECHNOLOGIES
(
	ID NUMBER PRIMARY KEY,
	NAME VARCHAR2(4000) UNIQUE NOT NULL,
	CODE VARCHAR2(4000) NOT NULL,
	TIMESTAMP_CREATED DATE,
	TIMESTAMP_MODIFIED DATE
);


SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_TECHNOLOGIES_IU
BEFORE INSERT OR UPDATE 
ON PRACUJ_TECHNOLOGIES
FOR EACH ROW

BEGIN 
	IF INSERTING THEN 
		:NEW.ID := SEQ_TECHNOLOGIES.NEXTVAL;
		:NEW.TIMESTAMP_CREATED := SYSDATE;
	ELSIF UPDATING THEN
		:NEW.TIMESTAMP_MODIFIED := SYSDATE;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END TRG_TECHNOLOGIES_IU;
/

--------------------------------------------------------------

CREATE SEQUENCE SEQ_DATES
START WITH 1
INCREMENT BY 1;

CREATE TABLE PRACUJ_DATES
(
	ID NUMBER PRIMARY KEY,
	SCRAP_DATE DATE UNIQUE NOT NULL,
	TIMESTAMP_CREATED DATE,
	TIMESTAMP_MODIFIED DATE
);


SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_DATES_IU
BEFORE INSERT OR UPDATE 
ON PRACUJ_DATES
FOR EACH ROW

BEGIN 
	IF INSERTING THEN 
		:NEW.ID := SEQ_DATES.NEXTVAL;
		:NEW.TIMESTAMP_CREATED := SYSDATE;
	ELSIF UPDATING THEN
		:NEW.TIMESTAMP_MODIFIED := SYSDATE;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END TRG_DATES_IU;
/


--------------------------------------------------------------

CREATE SEQUENCE SEQ_CITY_OFFER
START WITH 1
INCREMENT BY 1;

CREATE TABLE PRACUJ_CITY_OFFER
(
	ID NUMBER PRIMARY KEY,
	ID_CITY NUMBER REFERENCES PRACUJ_CITIES (ID) NOT NULL,
	ID_TECHNOLOGY NUMBER REFERENCES PRACUJ_TECHNOLOGIES (ID) NOT NULL,
	TIMESTAMP_CREATED DATE,
	TIMESTAMP_MODIFIED DATE
);

ALTER TABLE PRACUJ_CITY_OFFER
ADD CONSTRAINT UQ_CITY_OFFER UNIQUE (ID_CITY, ID_TECHNOLOGY);


SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CITY_OFFER_IU
BEFORE INSERT OR UPDATE 
ON PRACUJ_CITY_OFFER
FOR EACH ROW

BEGIN 
	IF INSERTING THEN 
		:NEW.ID := SEQ_CITY_OFFER.NEXTVAL;
		:NEW.TIMESTAMP_CREATED := SYSDATE;
	ELSIF UPDATING THEN
		:NEW.TIMESTAMP_MODIFIED := SYSDATE;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END TRG_CITY_OFFER_IU;
/


--------------------------------------------------------------

CREATE SEQUENCE SEQ_DAY_CITY_OFFER
START WITH 1
INCREMENT BY 1;

CREATE TABLE PRACUJ_DAY_CITY_OFFER
(
	ID NUMBER PRIMARY KEY,
	ID_CITY_OFFER NUMBER REFERENCES PRACUJ_CITY_OFFER (ID) NOT NULL,
	ID_DATE NUMBER REFERENCES PRACUJ_DATES (ID) NOT NULL,
	NUMBER_OF_OFFERS NUMBER,
	TIMESTAMP_CREATED DATE,
	TIMESTAMP_MODIFIED DATE
);

ALTER TABLE PRACUJ_DAY_CITY_OFFER
ADD CONSTRAINT UQ_DAY_CITY_OFFER UNIQUE (ID_CITY_OFFER, ID_DATE);


SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_DAY_CITY_OFFER_IU
BEFORE INSERT OR UPDATE 
ON PRACUJ_DAY_CITY_OFFER
FOR EACH ROW

BEGIN 
	IF INSERTING THEN 
		:NEW.ID := SEQ_DAY_CITY_OFFER.NEXTVAL;
		:NEW.TIMESTAMP_CREATED := SYSDATE;
	ELSIF UPDATING THEN
		:NEW.TIMESTAMP_MODIFIED := SYSDATE;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END TRG_DAY_CITY_OFFER_IU;
/

--------------------------------------------------------------

CREATE SEQUENCE SEQ_PRACUJ_LOGS
START WITH 1
INCREMENT BY 1;

CREATE TABLE PRACUJ_LOGS
(
	ID NUMBER PRIMARY KEY,
	FUNCTION_NAME VARCHAR2(4000),
	START_TIME DATE,
	END_TIME DATE,
	INPUT_PARAMETERS VARCHAR2(4000),
	XML_IN XMLTYPE,
	ERROR_DESC VARCHAR2(4000),
	TIMESTAMP_CREATED DATE
);

SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_PRACUJ_LOGS
BEFORE INSERT
ON PRACUJ_LOGS
FOR EACH ROW

BEGIN 
	IF INSERTING THEN 
		:NEW.ID := SEQ_PRACUJ_LOGS.NEXTVAL;
		:NEW.TIMESTAMP_CREATED := SYSDATE;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END TRG_PRACUJ;
/
	
	







--@C:\Users\Wojtek\Desktop\R_skrypty\APLIKACJE_SHINY\OFERTY\TABELE.sql
