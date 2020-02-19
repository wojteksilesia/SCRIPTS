
CREATE OR REPLACE VIEW V_WATA_RETAILERS AS
	SELECT ID,NAME AS "SKLEP"
	FROM WATA_RETAILERS;


CREATE OR REPLACE VIEW V_WATA_CITIES AS
	SELECT ID, NAME AS "MIASTO"
	FROM WATA_CITIES;

CREATE OR REPLACE VIEW V_WATA_USER_SHOPS AS
	SELECT R.NAME AS "MARKET",S.ADDRESS AS "ULICA", C.NAME AS "MIASTO"
	FROM WATA_SHOPS S
	JOIN WATA_RETAILERS R ON (R.ID=S.ID_RETAILER)
	JOIN WATA_CITIES C ON (C.ID=S.ID_CITY);

CREATE OR REPLACE VIEW V_WATA_PRODUCT_TYPES AS
	SELECT ID, NAME AS "KATEGORIA"
	FROM WATA_PRODUCT_TYPES;
	
CREATE OR REPLACE VIEW V_WATA_USER_PRODUCTS AS	
	SELECT P.NAME AS "PRODUKT", PT.NAME AS "TYP"
	FROM WATA_PRODUCTS P
	JOIN WATA_PRODUCT_TYPES PT ON (P.ID_PRODUCT_TYPE=PT.ID);
	
CREATE OR REPLACE VIEW V_WATA_PROCESS_SHOPS AS
	SELECT S.ID, R.NAME || ',' || S.ADDRESS || ','|| C.NAME AS "SKLEP"
	FROM WATA_SHOPS S
	JOIN WATA_RETAILERS R ON (R.ID=S.ID_RETAILER)
	JOIN WATA_CITIES C ON (C.ID=S.ID_CITY);

CREATE OR REPLACE VIEW V_WATA_PROCESS_PRODUCTS AS
	SELECT ID, NAME AS "PRODUKT"
	FROM WATA_PRODUCTS;

CREATE OR REPLACE VIEW V_WATA_ALL_DATA AS
	SELECT 
		S.ID, 
		S.SHOPPING_DATE AS "DATA",
		P.NAME AS "PRODUKT",
		PT.NAME AS "KATEGORIA",
		SP.PRICE AS "CENA",
		SP.WEIGHT AS "WAGA",
		R.NAME AS "SKLEP",
		SH.ADDRESS AS "ADRES",
		C.NAME AS "MIASTO"
	FROM 
		WATA_SHOPPING_PRODS SP
	JOIN WATA_SHOPPING S ON (S.ID=SP.ID_SHOPPING)
	JOIN WATA_PRODUCTS P ON (P.ID=SP.ID_PRODUCT)
	JOIN WATA_SHOPS SH ON (SH.ID=S.ID_SHOP)
	JOIN WATA_RETAILERS R ON (R.ID=SH.ID_RETAILER)
	JOIN WATA_PRODUCT_TYPES PT ON (PT.ID=P.ID_PRODUCT_TYPE)
	JOIN WATA_CITIES C ON (C.ID=SH.ID_CITY);



-- @C:\Users\Wojtek\Desktop\APLIKACJA_ZAKUPOWA\WATA_VIEWS.sql