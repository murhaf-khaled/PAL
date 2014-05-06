SET SCHEMA PAL;

-- PAL setup

CREATE TYPE PAL_T_VT_DATA AS TABLE (ID INTEGER, NEWSPEND DOUBLE);
CREATE TYPE PAL_T_VT_PARAMS AS TABLE (NAME VARCHAR(60), INTARGS INTEGER, DOUBLEARGS DOUBLE, STRINGARGS VARCHAR (100));
CREATE TYPE PAL_T_VT_RESULTS AS TABLE (MEAN DOUBLE, STD_DEV DOUBLE);
CREATE TYPE PAL_T_VT_OUTLIERS AS TABLE (ID INTEGER, OUTLIER INTEGER);

CREATE COLUMN TABLE PAL_VT_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_VT_SIGNATURE VALUES (1, 'PAL.PAL_T_VT_DATA', 'in');
INSERT INTO PAL_VT_SIGNATURE VALUES (2, 'PAL.PAL_T_VT_PARAMS', 'in');
INSERT INTO PAL_VT_SIGNATURE VALUES (3, 'PAL.PAL_T_VT_RESULTS', 'out');
INSERT INTO PAL_VT_SIGNATURE VALUES (4, 'PAL.PAL_T_VT_OUTLIERS', 'out');

CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_VT', 'AFLPAL', 'VARIANCETEST', PAL_VT_SIGNATURE);

-- app setup

CREATE VIEW V_VT_DATA AS SELECT ID, NEWSPEND FROM CUSTOMERS;
CREATE COLUMN TABLE VT_PARAMS LIKE PAL_T_VT_PARAMS;
CREATE COLUMN TABLE VT_RESULTS LIKE PAL_T_VT_RESULTS;
CREATE COLUMN TABLE VT_OUTLIERS LIKE PAL_T_VT_OUTLIERS;

INSERT INTO VT_PARAMS VALUES ('SIGMA_NUM', null, 1.0, null);
INSERT INTO VT_PARAMS VALUES ('THREAD_NUMBER', 2, null, null);

-- app runtime

UPDATE VT_PARAMS SET DOUBLEARGS=2.0 WHERE NAME='SIGMA_NUM';

TRUNCATE TABLE VT_RESULTS;
TRUNCATE TABLE VT_OUTLIERS;

CALL _SYS_AFL.PAL_VT (V_VT_DATA, VT_PARAMS, VT_RESULTS, VT_OUTLIERS) WITH OVERVIEW;

SELECT * FROM V_VT_DATA WHERE ID IN (SELECT ID FROM VT_OUTLIERS WHERE OUTLIER=1);

