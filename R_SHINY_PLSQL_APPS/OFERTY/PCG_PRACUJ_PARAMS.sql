CREATE OR REPLACE PACKAGE PCG_PRACUJ_PARAMS AS

PROCEDURE CREATE_LOG(invFunction_name IN VARCHAR2, indStart_time IN DATE, indEnd_time IN DATE, invInput_parameters IN VARCHAR2 DEFAULT NULL, invError IN VARCHAR2,inxXML IN XMLTYPE DEFAULT NULL);
PROCEDURE PRACUJ_ADD_CITY(invCity IN VARCHAR2, invCode IN VARCHAR2);
PROCEDURE PRACUJ_ADD_TECH (invTech IN VARCHAR2, invCode IN VARCHAR2);
PROCEDURE PRACUJ_REGISTER_DAILY_DATA (inxXML XMLTYPE);


END PCG_PRACUJ_PARAMS;
/
-------------------------------------------------------------------
-------------------------------------------------------------------


CREATE OR REPLACE PACKAGE BODY PCG_PRACUJ_PARAMS AS

PROCEDURE CREATE_LOG (invFunction_name IN VARCHAR2, indStart_time IN DATE, indEnd_time IN DATE, invInput_parameters IN VARCHAR2 DEFAULT NULL, invError IN VARCHAR2,inxXML IN XMLTYPE DEFAULT NULL) IS

		PRAGMA AUTONOMOUS_TRANSACTION;
	
	BEGIN
	
		INSERT INTO PRACUJ_LOGS
		(FUNCTION_NAME, START_TIME, END_TIME, INPUT_PARAMETERS, ERROR_DESC,XML_IN)
		VALUES
		(invFunction_name, indStart_time, indEnd_time, invInput_parameters, invError,inxXML)
		;
		
		COMMIT;
	
	EXCEPTION
		WHEN OTHERS THEN 
			RAISE;
	
	END CREATE_LOG;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
		
PROCEDURE PRACUJ_ADD_CITY (invCity IN VARCHAR2, invCode IN VARCHAR2) IS

		ldStart_time DATE;
		ldEnd_time DATE;
		lvParam VARCHAR2(4000);
		lvFunction_name VARCHAR2(4000) := 'PRACUJ_ADD_CITY';
		lvError VARCHAR2(4000);
		lnId_city NUMBER;

	BEGIN
		
		lvParam := 'invCity: ' || invCity || ' invCode: ' || invCode;
		ldStart_time := SYSDATE;
		
		INSERT INTO PRACUJ_CITIES
		(NAME, CODE)
		VALUES
		(UPPER(invCity), LOWER(invCode))
		RETURNING ID INTO lnId_city;
		
		-- MAPPING NEW CITY TO EACH TECHNOLOGY
		FOR rec IN (SELECT ID FROM PRACUJ_TECHNOLOGIES)
		LOOP
			INSERT INTO PRACUJ_CITY_OFFER
			(ID_CITY, ID_TECHNOLOGY)
			VALUES
			(lnId_city, rec.ID);
		END LOOP;
		
		COMMIT;
		
		ldEnd_time := SYSDATE;
		
		CREATE_LOG(invFunction_name => lvFunction_name,
				   indStart_time => ldStart_time,
				   indEnd_time => ldEnd_time,
				   invInput_parameters => lvParam,
				   invError => NULL			   
				   );
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
			
			CREATE_LOG(invFunction_name => lvFunction_name,
				   indStart_time => ldStart_time,
				   indEnd_time => ldEnd_time,
				   invInput_parameters => lvParam,
				   invError => lvError		   
				   );
			RAISE;
			
	END PRACUJ_ADD_CITY;
------------------------------------------------------------------------------
------------------------------------------------------------------------------

PROCEDURE PRACUJ_ADD_TECH (invTech IN VARCHAR2, invCode IN VARCHAR2) IS

		ldStart_time DATE;
		ldEnd_time DATE;
		lvParam VARCHAR2(4000);
		lvFunction_name VARCHAR2(4000) := 'PRACUJ_ADD_TECH';
		lvError VARCHAR2(4000);
		lnId_tech NUMBER;

	BEGIN
		
		lvParam := 'invTech: ' || invTech || ' invCode: ' || invCode;
		ldStart_time := SYSDATE;
		
		INSERT INTO PRACUJ_TECHNOLOGIES
		(NAME, CODE)
		VALUES
		(invTech, invCode)
		RETURNING ID INTO lnId_tech;
		
		-- Map new technology to each city
		FOR rec IN (SELECT ID FROM PRACUJ_CITIES)
		LOOP
			INSERT INTO PRACUJ_CITY_OFFER
			(ID_CITY, ID_TECHNOLOGY)
			VALUES
			(rec.ID, lnId_tech);
		END LOOP;
		
		COMMIT;
		
		ldEnd_time := SYSDATE;
		
		CREATE_LOG(invFunction_name => lvFunction_name,
				   indStart_time => ldStart_time,
				   indEnd_time => ldEnd_time,
				   invInput_parameters => lvParam,
				   invError => NULL			   
				   );
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
			
			CREATE_LOG(invFunction_name => lvFunction_name,
				   indStart_time => ldStart_time,
				   indEnd_time => ldEnd_time,
				   invInput_parameters => lvParam,
				   invError => lvError		   
				   );
			RAISE;
			
	END PRACUJ_ADD_TECH;


------------------------------------------------------------------------------
------------------------------------------------------------------------------

PROCEDURE PRACUJ_REGISTER_DAILY_DATA (inxXML XMLTYPE) IS

		ldStart_time DATE;
		ldEnd_time DATE;
		--lvParam VARCHAR2(4000);
		lvFunction_name VARCHAR2(4000) := 'PRACUJ_REGISTER_DAILY_DATA';
		lvError VARCHAR2(4000);
		lnId_scrap_date NUMBER;
		lnCounter NUMBER;
		
		TYPE REC_CITY_OFFER IS RECORD
		(
			R_ID_CITY_OFFER NUMBER,
			R_COUNTER NUMBER
		);
		
		TYPE CITY_OFFER_TABLE IS TABLE OF REC_CITY_OFFER;
		
		ltCity_offer CITY_OFFER_TABLE;
		
	BEGIN
		
		--lvParam := inxXML.GETSTRINGVAL();
		ldStart_time := SYSDATE;
		
		BEGIN
			
			SELECT ID
			INTO lnId_scrap_date
			FROM PRACUJ_DATES
			WHERE TRUNC(SCRAP_DATE) = TRUNC(SYSDATE);
		
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				INSERT INTO PRACUJ_DATES
				(SCRAP_DATE)
				VALUES
				(TRUNC(SYSDATE))
				RETURNING ID INTO lnId_scrap_date;
		END;
		
		SELECT *
		BULK COLLECT INTO ltCity_offer
		FROM XMLTABLE('/OFFERS/OFFER' PASSING inxXML COLUMNS ID_CITY_TECH NUMBER PATH './ID_CITY_TECH',
															 COUNTER NUMBER PATH './COUNTER');
		
		FOR i IN 1..ltCity_offer.COUNT LOOP
			
			lnCounter:=0;
			
			SELECT COUNT(1) 
			INTO lnCounter
			FROM PRACUJ_DAY_CITY_OFFER
			WHERE ID_DATE=lnId_scrap_date
			AND ID_CITY_OFFER=ltCity_offer(i).R_ID_CITY_OFFER;
			
			IF lnCounter>=1 THEN
				UPDATE PRACUJ_DAY_CITY_OFFER
				SET NUMBER_OF_OFFERS=ltCity_offer(i).R_COUNTER
				WHERE ID_CITY_OFFER=ltCity_offer(i).R_ID_CITY_OFFER
				AND ID_DATE=lnId_scrap_date;
			ELSE
				INSERT INTO PRACUJ_DAY_CITY_OFFER
				(ID_CITY_OFFER, ID_DATE, NUMBER_OF_OFFERS)
				VALUES
				(ltCity_offer(i).R_ID_CITY_OFFER, lnId_scrap_date, ltCity_offer(i).R_COUNTER);
			END IF;
		
		END LOOP;
			
		COMMIT;
			
			
		ldEnd_time := SYSDATE;
		
		CREATE_LOG(invFunction_name => lvFunction_name,
				   indStart_time => ldStart_time,
				   indEnd_time => ldEnd_time,
				   --invInput_parameters => lvParam,
				   invError => NULL,
				   inxXML => inxXML
				   );
		
	EXCEPTION 
		WHEN OTHERS THEN 			
			ROLLBACK;
				
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
			
			CREATE_LOG(invFunction_name => lvFunction_name,
				   indStart_time => ldStart_time,
				   indEnd_time => ldEnd_time,
				   --invInput_parameters => lvParam,
				   invError => lvError,
				   inxXML => inxXML
				   );
			RAISE;	
	
	END PRACUJ_REGISTER_DAILY_DATA;
				
		
		
		
		
		
		

------------------------------------------------------------------------------
------------------------------------------------------------------------------
END PCG_PRACUJ_PARAMS;
/



--@C:\Users\Wojtek\Desktop\R_skrypty\APLIKACJE_SHINY\OFERTY\PCG_PRACUJ_PARAMS.sql


		