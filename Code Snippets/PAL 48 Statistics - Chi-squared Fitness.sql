SET SCHEMA PAL;

-- cleanup
DROP TYPE PAL_T_SC_DATA;
DROP TYPE PAL_T_SC_RESULTS;
DROP TYPE PAL_T_SC_RESULTS_INFO;
DROP TABLE PAL_SC_SIGNATURE;
CALL SYSTEM.AFL_WRAPPER_ERASER ('PAL_SC');
DROP TABLE SC_DATA;
DROP TABLE SC_RESULTS;
DROP TABLE SC_RESULTS_INFO;

-- PAL setup
CREATE TYPE PAL_T_SC_DATA AS TABLE (ID INTEGER, OBSERVED DOUBLE, P DOUBLE);
CREATE TYPE PAL_T_SC_RESULTS AS TABLE (ID INTEGER, OBSERVED DOUBLE, EXPECTED DOUBLE, RESIDUAL DOUBLE);
CREATE TYPE PAL_T_SC_RESULTS_INFO AS TABLE (NAME VARCHAR(100), VALUE DOUBLE);

CREATE COLUMN TABLE PAL_SC_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_SC_SIGNATURE VALUES (1, 'PAL.PAL_T_SC_DATA', 'in');
INSERT INTO PAL_SC_SIGNATURE VALUES (2, 'PAL.PAL_T_SC_RESULTS', 'out');
INSERT INTO PAL_SC_SIGNATURE VALUES (3, 'PAL.PAL_T_SC_RESULTS_INFO', 'out');

CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_SC', 'AFLPAL', 'CHISQTESTFIT', PAL_SC_SIGNATURE);

-- app setup
CREATE COLUMN TABLE SC_DATA LIKE PAL_T_SC_DATA;
INSERT INTO SC_DATA VALUES (0, 519, 0.3);
INSERT INTO SC_DATA VALUES (1, 364, 0.2);
INSERT INTO SC_DATA VALUES (2, 363, 0.2);
INSERT INTO SC_DATA VALUES (3, 200, 0.1);
INSERT INTO SC_DATA VALUES (4, 212, 0.1);
INSERT INTO SC_DATA VALUES (5, 193, 0.1);
CREATE COLUMN TABLE SC_RESULTS LIKE PAL_T_SC_RESULTS;
CREATE COLUMN TABLE SC_RESULTS_INFO LIKE PAL_T_SC_RESULTS_INFO;

-- app runtime
TRUNCATE TABLE SC_RESULTS;
TRUNCATE TABLE SC_RESULTS_INFO;

CALL _SYS_AFL.PAL_SC (SC_DATA, SC_RESULTS, SC_RESULTS_INFO) WITH OVERVIEW;

SELECT * FROM SC_DATA;
SELECT * FROM SC_RESULTS;
SELECT * FROM SC_RESULTS_INFO;
