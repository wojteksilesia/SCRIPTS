SET SERVEROUTPUT ON;
DECLARE
    inxXML XMLTYPE;
    
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
    
    inxXML:=XMLTYPE.CREATEXML(
'<SHOPPING>
    <ID_SHOP>5</ID_SHOP>
    <SHOPPING_DATE>20190214</SHOPPING_DATE>
    <PRODUCTS>
        <PRODUCT>
            <ID_PRODUCT>1</ID_PRODUCT>
            <PRICE>3.24</PRICE>
            <WEIGHT>124</WEIGHT>
        </PRODUCT>
        <PRODUCT>
            <ID_PRODUCT>3</ID_PRODUCT>
            <PRICE>12</PRICE>
            <WEIGHT></WEIGHT>
        </PRODUCT>
    </PRODUCTS>
</SHOPPING>');

--DBMS_OUTPUT.PUT_LINE(lxInXML.GetStringVal());

        ldStart_time := SYSDATE;
        lvParams := inxXML.GetStringVal();
        
        EXECUTE IMMEDIATE q'[ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '. ']';
        
        
        lnId_shop := inxXML.EXTRACT('/SHOPPING/ID_SHOP/text()').GETNUMBERVAL();
        
        ldShopping_date := TO_DATE(inxXML.EXTRACT('/SHOPPING/SHOPPING_DATE/text()').GETSTRINGVAL(),'YYYYMMDD');
        
        SELECT *
        BULK COLLECT INTO ltProduct_vector
        FROM XMLTABLE('/SHOPPING/PRODUCTS/PRODUCT' PASSING inxXML COLUMNS ID_PRODUCT NUMBER PATH './ID_PRODUCT',
                                                                          PRICE NUMBER PATH './PRICE',
                                                                          WEIGHT VARCHAR2(4000) PATH './WEIGHT');
        
        --DBMS_OUTPUT.PUT_LINE(ltProduct_vector.COUNT);
        
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

END;
/