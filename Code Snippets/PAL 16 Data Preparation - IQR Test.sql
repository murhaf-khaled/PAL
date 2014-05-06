SET SCHEMA PAL;

-- PAL setup

CREATE TYPE PAL_T_IQR_DATA AS TABLE (ID INTEGER, NEWSPEND DOUBLE);
CREATE TYPE PAL_T_IQR_PARAMS AS TABLE (NAME VARCHAR(60), INTARGS INTEGER, DOUBLEARGS DOUBLE, STRINGARGS VARCHAR (100));
CREATE TYPE PAL_T_IQR_RESULTS AS TABLE (Q1 DOUBLE, Q3 DOUBLE);
CREATE TYPE PAL_T_IQR_OUTLIERS AS TABLE (ID INTEGER, OUTLIER INTEGER);

CREATE COLUMN TABLE PAL_IQR_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_IQR_SIGNATURE VALUES (1, 'PAL.PAL_T_IQR_DATA', 'in');
INSERT INTO PAL_IQR_SIGNATURE VALUES (2, 'PAL.PAL_T_IQR_PARAMS', 'in');
INSERT INTO PAL_IQR_SIGNATURE VALUES (3, 'PAL.PAL_T_IQR_RESULTS', 'out');
INSERT INTO PAL_IQR_SIGNATURE VALUES (4, 'PAL.PAL_T_IQR_OUTLIERS', 'out');

CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_IQR', 'AFLPAL', 'IQRTEST', PAL_IQR_SIGNATURE);

-- app setup

CREATE VIEW V_IQR_DATA AS SELECT ID, NEWSPEND FROM CUSTOMERS;
CREATE COLUMN TABLE IQR_PARAMS LIKE PAL_T_IQR_PARAMS;
CREATE COLUMN TABLE IQR_RESULTS LIKE PAL_T_IQR_RESULTS;
CREATE COLUMN TABLE IQR_OUTLIERS LIKE PAL_T_IQR_OUTLIERS;

INSERT INTO IQR_PARAMS VALUES ('MULTIPLIER', null, 1.5, null);

-- app runtime

UPDATE IQR_PARAMS SET DOUBLEARGS=2.0 WHERE NAME='MULTIPLIER';

TRUNCATE TABLE IQR_RESULTS;
TRUNCATE TABLE IQR_OUTLIERS;

CALL _SYS_AFL.PAL_IQR (V_IQR_DATA, IQR_PARAMS, IQR_RESULTS, IQR_OUTLIERS) WITH OVERVIEW;

SELECT * FROM V_IQR_DATA WHERE ID IN (SELECT ID FROM IQR_OUTLIERS WHERE OUTLIER=1);

