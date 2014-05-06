SET SCHEMA PAL;

-- cleanup
DROP TYPE PAL_T_AP_DATA;
DROP TYPE PAL_T_AP_PARAMS;
DROP TYPE PAL_T_AP_RULES_STAT;
DROP TYPE PAL_T_AP_RULES_PRE;
DROP TYPE PAL_T_AP_RULES_POST;
DROP TYPE PAL_T_AP_PMML;
DROP TABLE PAL_AP_SIGNATURE;
CALL SYSTEM.AFL_WRAPPER_ERASER ('PAL_AP');
DROP VIEW V_AP_DATA;
DROP TABLE AP_RULES_STAT;
DROP TABLE AP_RULES_PRE;
DROP TABLE AP_RULES_POST;
DROP TABLE AP_PMML;

-- PAL setup
CREATE TYPE PAL_T_AP_DATA AS TABLE (ORDERID INTEGER, PRODUCTID INTEGER);
CREATE TYPE PAL_T_AP_PARAMS AS TABLE (NAME VARCHAR(60), INTARGS INTEGER, DOUBLEARGS DOUBLE, STRINGARGS VARCHAR (100));
CREATE TYPE PAL_T_AP_RULES_STAT AS TABLE (ID INTEGER, SUPPORT DOUBLE, CONFIDENCE DOUBLE, LIFT DOUBLE);
CREATE TYPE PAL_T_AP_RULES_PRE AS TABLE (ID INTEGER, PRODUCTID VARCHAR(10));
CREATE TYPE PAL_T_AP_RULES_POST AS TABLE (ID INTEGER, PRODUCTID VARCHAR(10));
CREATE TYPE PAL_T_AP_PMML AS TABLE (ID INTEGER, PMMLMODEL VARCHAR(5000));

CREATE COLUMN TABLE PAL_AP_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_AP_SIGNATURE VALUES (1, 'PAL.PAL_T_AP_DATA', 'in');
INSERT INTO PAL_AP_SIGNATURE VALUES (2, 'PAL.PAL_T_AP_PARAMS', 'in');
INSERT INTO PAL_AP_SIGNATURE VALUES (3, 'PAL.PAL_T_AP_RULES_STAT', 'out');
INSERT INTO PAL_AP_SIGNATURE VALUES (4, 'PAL.PAL_T_AP_RULES_PRE', 'out');
INSERT INTO PAL_AP_SIGNATURE VALUES (5, 'PAL.PAL_T_AP_RULES_POST', 'out');
INSERT INTO PAL_AP_SIGNATURE VALUES (6, 'PAL.PAL_T_AP_PMML', 'out');

CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_AP', 'AFLPAL', 'APRIORIRULE2', PAL_AP_SIGNATURE);

-- app setup
CREATE VIEW V_AP_DATA AS 
	SELECT ORDERID, PRODUCTID 
		FROM FCTCUSTOMERORDER 
		ORDER BY ORDERID, PRODUCTID
	;
CREATE COLUMN TABLE AP_RULES_STAT LIKE PAL_T_AP_RULES_STAT;
CREATE COLUMN TABLE AP_RULES_PRE LIKE PAL_T_AP_RULES_PRE;
CREATE COLUMN TABLE AP_RULES_POST LIKE PAL_T_AP_RULES_POST;
CREATE COLUMN TABLE AP_PMML LIKE PAL_T_AP_PMML;

-- app runtime
DROP TABLE #AP_PARAMS;
CREATE LOCAL TEMPORARY COLUMN TABLE #AP_PARAMS LIKE PAL_T_AP_PARAMS;
INSERT INTO #AP_PARAMS VALUES ('THREAD_NUMBER', 2, null, null);
INSERT INTO #AP_PARAMS VALUES ('MIN_SUPPORT', null, 0.001, null);
INSERT INTO #AP_PARAMS VALUES ('MIN_CONFIDENCE', null, 0.001, null);
--INSERT INTO #AP_PARAMS VALUES ('MIN_LIFT', null, 1.0, null);
INSERT INTO #AP_PARAMS VALUES ('MAX_ITEM_LENGTH', 5, null, null);
--INSERT INTO #AP_PARAMS VALUES ('MAX_CONSEQUENT', 1, null, null);
INSERT INTO #AP_PARAMS VALUES ('PMML_EXPORT', 0, null, null);
TRUNCATE TABLE AP_RULES_STAT;
TRUNCATE TABLE AP_RULES_PRE;
TRUNCATE TABLE AP_RULES_POST;
TRUNCATE TABLE AP_PMML;

CALL _SYS_AFL.PAL_AP (V_AP_DATA, #AP_PARAMS, AP_RULES_STAT, AP_RULES_PRE, AP_RULES_POST, AP_PMML) WITH OVERVIEW;

--SELECT * FROM V_AP_DATA;
SELECT * FROM AP_RULES_STAT; --ORDER BY LIFT DESC;
SELECT * FROM AP_RULES_PRE; --WHERE ID=4183;
SELECT * FROM AP_RULES_POST; --WHERE ID=4183;
--SELECT * FROM AP_PMML;
