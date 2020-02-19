CREATE OR REPLACE PACKAGE PCG_WATA_PARAMS AS

PROCEDURE CREATE_LOG (invFunction IN VARCHAR2, indStart IN DATE, indEnd IN DATE, invParameters IN VARCHAR2, invError IN VARCHAR2);
PROCEDURE ADD_CITY (invCity IN VARCHAR2);
PROCEDURE ADD_RETAILER (invRetailer IN VARCHAR2);
PROCEDURE ADD_SHOP (innId_retailer IN NUMBER, invAddress IN VARCHAR2, inId_city IN NUMBER);
PROCEDURE ADD_PRODUCT_TYPE (invProduct_type IN VARCHAR2);
PROCEDURE ADD_PRODUCT (invProduct_desc IN VARCHAR2, innId_product_type IN NUMBER);
PROCEDURE ADD_SHOPPING_LIST (inxXML IN XMLTYPE);


END PCG_WATA_PARAMS;
/
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------




CREATE OR REPLACE PACKAGE BODY PCG_WATA_PARAMS AS
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

PROCEDURE CREATE_LOG (invFunction IN VARCHAR2, indStart IN DATE, indEnd IN DATE, invParameters IN VARCHAR2, invError IN VARCHAR2) IS

	PRAGMA AUTONOMOUS_TRANSACTION;

	BEGIN 
		INSERT INTO WATA_LOGS
		(FUNCTION_NAME, START_TIME, END_TIME, PARAMETERS_IN, ERROR_DETAILS)
		VALUES
		(invFunction, indStart, indEnd, invParameters, invError);
		
		COMMIT;

	END CREATE_LOG;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

PROCEDURE ADD_CITY (invCity IN VARCHAR2) IS
		
		lvFunction VARCHAR2(4000):= 'ADD_CITY';
		ldStart_time DATE;
		ldEnd_time DATE;
		lvError VARCHAR2(4000);
		lvParams VARCHAR2(4000);
		
	BEGIN
		
		ldStart_time := SYSDATE;
		lvParams := 'invCity: ' || invCity;
		
		INSERT INTO WATA_CITIES
		(NAME)
		VALUES
		(UPPER(invCity));
		
		COMMIT;
		
		ldEnd_time := SYSDATE;
				
		CREATE_LOG(invFunction=>lvFunction,
				   indStart=>ldStart_time,
				   indEnd=>ldEnd_time,
				   invParameters=> lvParams,
				   invError=>NULL
				   );
	EXCEPTION
		WHEN OTHERS THEN 
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
			
			CREATE_LOG(	invFunction=>lvFunction,
						indStart=>ldStart_time,
						indEnd=>ldEnd_time,
						invParameters=>lvParams,
						invError=>lvError
					   );
			RAISE;
				
	END ADD_CITY;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
PROCEDURE ADD_RETAILER (invRetailer IN VARCHAR2) IS
		
		lvFunction VARCHAR2(4000):= 'ADD_RETAILER';
		ldStart_time DATE;
		ldEnd_time DATE;
		lvError VARCHAR2(4000);
		lvParams VARCHAR2(4000);
		
	BEGIN
		
		ldStart_time := SYSDATE;
		lvParams := 'invRetailer: ' || invRetailer;
		
		INSERT INTO WATA_RETAILERS
		(NAME)
		VALUES
		(UPPER(invRetailer));
		
		COMMIT;
		
		ldEnd_time := SYSDATE;
				
		CREATE_LOG(invFunction=>lvFunction,
				   indStart=>ldStart_time,
				   indEnd=>ldEnd_time,
				   invParameters=> lvParams,
				   invError=>NULL
				   );
	EXCEPTION
		WHEN OTHERS THEN 
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
			
			CREATE_LOG(	invFunction=>lvFunction,
						indStart=>ldStart_time,
						indEnd=>ldEnd_time,
						invParameters=>lvParams,
						invError=>lvError
					   );
			RAISE;
				
	END ADD_RETAILER;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
PROCEDURE ADD_SHOP (innId_retailer IN NUMBER, invAddress IN VARCHAR2, inId_city IN NUMBER) IS

		lvFunction VARCHAR2(4000):= 'ADD_SHOP';
		ldStart_time DATE;
		ldEnd_time DATE;
		lvError VARCHAR2(4000);
		lvParams VARCHAR2(4000);
		lnCounter NUMBER;
		leAlready_exsists EXCEPTION;
	
	BEGIN
		
		ldStart_time := SYSDATE;
		lvParams := 'innId_retailer: ' || innId_retailer || ' invAddress: ' || invAddress || ' inId_city: ' || inId_city;
		
		SELECT COUNT(1)
		INTO lnCounter
		FROM WATA_SHOPS
		WHERE ID_RETAILER=innId_retailer
		AND ADDRESS=invAddress
		AND ID_CITY=inId_city;
		
		IF lnCounter>0 THEN
			RAISE leAlready_exsists;
		END IF;
		
		INSERT INTO WATA_SHOPS
		(ID_RETAILER, ADDRESS, ID_CITY)
		VALUES
		(innId_retailer, invAddress, inId_city);
		
		COMMIT;
		
		ldEnd_time := SYSDATE;
		
		CREATE_LOG(invFunction=>lvFunction,
				   indStart=>ldStart_time,
				   indEnd=>ldEnd_time,
				   invParameters=> lvParams,
				   invError=>NULL
				   );		
		
	EXCEPTION
		WHEN OTHERS THEN 
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
			
			CREATE_LOG(	invFunction=>lvFunction,
						indStart=>ldStart_time,
						indEnd=>ldEnd_time,
						invParameters=>lvParams,
						invError=>lvError
					   );
			RAISE;
				
	END ADD_SHOP;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
PROCEDURE ADD_PRODUCT_TYPE (invProduct_type IN VARCHAR2) IS
		
		lvFunction VARCHAR2(4000):= 'ADD_PRODUCT_TYPE';
		ldStart_time DATE;
		ldEnd_time DATE;
		lvError VARCHAR2(4000);
		lvParams VARCHAR2(4000);
		
	BEGIN
		
		ldStart_time := SYSDATE;
		lvParams := 'invProduct_type: ' || invProduct_type;
		
		INSERT INTO WATA_PRODUCT_TYPES
		(NAME)
		VALUES
		(UPPER(invProduct_type));
		
		COMMIT;
		
		ldEnd_time := SYSDATE;
				
		CREATE_LOG(invFunction=>lvFunction,
				   indStart=>ldStart_time,
				   indEnd=>ldEnd_time,
				   invParameters=> lvParams,
				   invError=>NULL
				   );
	EXCEPTION
		WHEN OTHERS THEN 
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
			
			CREATE_LOG(	invFunction=>lvFunction,
						indStart=>ldStart_time,
						indEnd=>ldEnd_time,
						invParameters=>lvParams,
						invError=>lvError
					   );
			RAISE;
				
	END ADD_PRODUCT_TYPE;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
PROCEDURE ADD_PRODUCT (invProduct_desc IN VARCHAR2, innId_product_type IN NUMBER) IS

		lvFunction VARCHAR2(4000):= 'ADD_PRODUCT';
		ldStart_time DATE;
		ldEnd_time DATE;
		lvError VARCHAR2(4000);
		lvParams VARCHAR2(4000);
		lnCounter NUMBER;
	
	BEGIN
		
		ldStart_time := SYSDATE;
		lvParams := 'invProduct_desc: ' || invProduct_desc || ' innId_product_type: ' || innId_product_type;
		
		
		INSERT INTO WATA_PRODUCTS
		(NAME, ID_PRODUCT_TYPE)
		VALUES
		(invProduct_desc, innId_product_type);
		
		COMMIT;
		
		ldEnd_time := SYSDATE;
		
		CREATE_LOG(invFunction=>lvFunction,
				   indStart=>ldStart_time,
				   indEnd=>ldEnd_time,
				   invParameters=> lvParams,
				   invError=>NULL
				   );		
		
	EXCEPTION
		WHEN OTHERS THEN 
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
			
			CREATE_LOG(	invFunction=>lvFunction,
						indStart=>ldStart_time,
						indEnd=>ldEnd_time,
						invParameters=>lvParams,
						invError=>lvError
					   );
			RAISE;
				
	END ADD_PRODUCT;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
PROCEDURE ADD_SHOPPING_LIST (inxXML IN XMLTYPE) IS

		lvFunction VARCHAR2(4000):= 'ADD_SHOPPING_LIST';
		ldStart_time DATE;
		ldEnd_time DATE;
		lvError VARCHAR2(4000);
		lvParams VARCHAR2(4000);
    
		lnId_shop NUMBER;
		ldShopping_date DATE;
		lnId_shopping NUMBER;
    
		TYPE PRODUCT_REC IS RECORD
		(
			r_id_product NUMBER,
			r_price NUMBER,
			r_weight VARCHAR2(4000)
		);
    
		TYPE PRODUCT_TABLE IS TABLE OF PRODUCT_REC;
    
		ltProduct_vector PRODUCT_TABLE;
	
	BEGIN
        
		ldStart_time := SYSDATE;
        lvParams := inxXML.GetStringVal();		

        EXECUTE IMMEDIATE q'[ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '. ']';
        
        
        lnId_shop := inxXML.EXTRACT('/SHOPPING/ID_SHOP/text()').GETNUMBERVAL();
        
        ldShopping_date := TO_DATE(inxXML.EXTRACT('/SHOPPING/SHOPPING_DATE/text()').GETSTRINGVAL(),'YYYY-MM-DD');
        
        SELECT *
        BULK COLLECT INTO ltProduct_vector
        FROM XMLTABLE('/SHOPPING/PRODUCTS/PRODUCT' PASSING inxXML COLUMNS ID_PRODUCT NUMBER PATH './ID_PRODUCT',
                                                                          PRICE NUMBER PATH './PRICE',
                                                                          WEIGHT VARCHAR2(4000) PATH './WEIGHT');
        
        
        INSERT INTO WATA_SHOPPING
        (ID_SHOP,SHOPPING_DATE)
        VALUES
        (lnId_shop, ldShopping_date)
        RETURNING ID INTO lnId_shopping;
        
        FOR i IN 1..ltProduct_vector.COUNT LOOP
            INSERT INTO WATA_SHOPPING_PRODS
            (ID_SHOPPING, ID_PRODUCT, PRICE, WEIGHT)
            VALUES
            (lnId_shopping,ltProduct_vector(i).r_id_product,ltProduct_vector(i).r_price,ltProduct_vector(i).r_weight);
        END LOOP;
        
        COMMIT;
        
        ldEnd_time := SYSDATE;
        
        PCG_WATA_PARAMS.CREATE_LOG(invFunction=>lvFunction,
				   indStart=>ldStart_time,
				   indEnd=>ldEnd_time,
				   invParameters=> lvParams,
				   invError=>NULL
				   );

	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
        
			ldEnd_time := SYSDATE;
			lvError := DBMS_UTILITY.FORMAT_ERROR_STACK ||' '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        
			PCG_WATA_PARAMS.CREATE_LOG(	invFunction=>lvFunction,
										indStart=>ldStart_time,
										indEnd=>ldEnd_time,
										invParameters=>lvParams,
										invError=>lvError
									  );
			RAISE;
	
	END ADD_SHOPPING_LIST;

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
END PCG_WATA_PARAMS;
/


-- @C:\Users\Wojtek\Desktop\APLIKACJA_ZAKUPOWA\PCG_WATA_PARAMS.sql