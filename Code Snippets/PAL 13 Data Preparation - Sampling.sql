SET SCHEMA PAL;

-- PAL setup

CREATE TYPE PAL_T_S_DATA AS TABLE (ID INTEGER, CUSTOMER NVARCHAR(60), LIFESPEND DOUBLE, NEWSPEND DOUBLE, INCOME DOUBLE, LOYALTY DOUBLE);
CREATE TYPE PAL_T_S_PARAMS AS TABLE (NAME VARCHAR(60), INTARGS INTEGER, DOUBLEARGS DOUBLE, STRINGARGS VARCHAR (100));

CREATE COLUMN TABLE PAL_S_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_S_SIGNATURE VALUES (1, 'PAL.PAL_T_S_DATA', 'in');
INSERT INTO PAL_S_SIGNATURE VALUES (2, 'PAL.PAL_T_S_PARAMS', 'in');
INSERT INTO PAL_S_SIGNATURE VALUES (3, 'PAL.PAL_T_S_DATA', 'out');

CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_S', 'AFLPAL', 'SAMPLING', PAL_S_SIGNATURE);

-- app setup

CREATE COLUMN TABLE S_PARAMS LIKE PAL_T_S_PARAMS;
CREATE COLUMN TABLE S_RESULTS LIKE PAL_T_S_DATA;

INSERT INTO S_PARAMS VALUES ('SAMPLING_METHOD', 0, null, null);
INSERT INTO S_PARAMS VALUES ('SAMPLING_SIZE', 10, null, null);	 -- use either sampling_size
--INSERT INTO S_PARAMS VALUES ('PERCENTAGE', null, 0.33, null);	 --     or percentage 
INSERT INTO S_PARAMS VALUES ('THREAD_NUMBER', 2, null, null);

-- app runtime

UPDATE S_PARAMS SET INTARGS=1 WHERE NAME='SAMPLING_METHOD';
UPDATE S_PARAMS SET INTARGS=15 WHERE NAME='SAMPLING_SIZE';

TRUNCATE TABLE S_RESULTS;

CALL _SYS_AFL.PAL_S (CUSTOMERS, S_PARAMS, S_RESULTS) WITH OVERVIEW;

SELECT * FROM S_RESULTS;

