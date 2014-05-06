SET SCHEMA PAL;

-- cleanup
DROP TYPE PAL_T_SS_DATA;
DROP TYPE PAL_T_SS_PARAMS;
DROP TYPE PAL_T_SS_RESULTS;
DROP TABLE PAL_SS_SIGNATURE;
CALL SYSTEM.AFL_WRAPPER_ERASER ('PAL_SS');
DROP VIEW V_SS_DATA;
DROP TABLE SS_RESULTS;

-- PAL setup
CREATE TYPE PAL_T_SS_DATA AS TABLE (LIFESPEND DOUBLE, NEWSPEND DOUBLE, INCOME DOUBLE, LOYALTY DOUBLE, CENTER_ID INTEGER);
CREATE TYPE PAL_T_SS_PARAMS AS TABLE (NAME VARCHAR(60), INTARGS INTEGER, DOUBLEARGS DOUBLE, STRINGARGS VARCHAR (100));
CREATE TYPE PAL_T_SS_RESULTS AS TABLE (SILHOUETTE DOUBLE);

CREATE COLUMN TABLE PAL_SS_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_SS_SIGNATURE VALUES (1, 'PAL.PAL_T_SS_DATA', 'in');
INSERT INTO PAL_SS_SIGNATURE VALUES (2, 'PAL.PAL_T_SS_PARAMS', 'in');
INSERT INTO PAL_SS_SIGNATURE VALUES (3, 'PAL.PAL_T_SS_RESULTS', 'out');

CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_SS', 'AFLPAL', 'SLIGHTSILHOUETTE', PAL_SS_SIGNATURE);

-- app setup
CREATE VIEW V_SS_DATA AS 
	SELECT LIFESPEND, NEWSPEND, INCOME, LOYALTY, CENTER_ID
		FROM CUSTOMERS c
		INNER JOIN KM_RESULTS r ON (r.ID=c.ID)
	;
CREATE COLUMN TABLE SS_RESULTS LIKE PAL_T_SS_RESULTS;

-- app runtime
DROP TABLE #SS_PARAMS;
CREATE LOCAL TEMPORARY COLUMN TABLE #SS_PARAMS LIKE PAL_T_SS_PARAMS;
INSERT INTO #SS_PARAMS VALUES ('THREAD_NUMBER', 2, null, null);
INSERT INTO #SS_PARAMS VALUES ('DISTANCE_LEVEL', 2, null, null); --1:Manhattan, 2:Euclidean, 3:Minkowski, 4:Chebyshev
INSERT INTO #SS_PARAMS VALUES ('NORMALIZATION', 0, null, null);
--INSERT INTO #SS_PARAMS VALUES ('MINKOWSKI_POWER', null, 3.0, null);
--INSERT INTO #SS_PARAMS VALUES ('CATEGORY_COL', 1, null, null);
--INSERT INTO #SS_PARAMS VALUES ('CATEGORY_WEIGHTS', null, 0.7, null);

TRUNCATE TABLE SS_RESULTS;

CALL _SYS_AFL.PAL_SS (V_SS_DATA, #SS_PARAMS, SS_RESULTS) WITH OVERVIEW;

SELECT * FROM V_SS_DATA;
SELECT * FROM SS_RESULTS;
