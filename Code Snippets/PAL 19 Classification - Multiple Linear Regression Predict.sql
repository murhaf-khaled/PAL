SET SCHEMA PAL;

-- PAL setup

CREATE TYPE PAL_T_RGP_DATA AS TABLE (ID INTEGER, INCOME DOUBLE, LOYALTY DOUBLE, NEWSPEND DOUBLE);

CREATE COLUMN TABLE PAL_RGP_SIGNATURE (ID INTEGER, TYPENAME VARCHAR(100), DIRECTION VARCHAR(100));
INSERT INTO PAL_RGP_SIGNATURE VALUES (1, 'PAL.PAL_T_RGP_DATA', 'in');
INSERT INTO PAL_RGP_SIGNATURE VALUES (2, 'PAL.PAL_T_RG_COEFF', 'in');
INSERT INTO PAL_RGP_SIGNATURE VALUES (3, 'PAL.PAL_T_RG_PARAMS', 'in');
INSERT INTO PAL_RGP_SIGNATURE VALUES (4, 'PAL.PAL_T_RG_FITTED', 'out');

CALL SYSTEM.AFL_WRAPPER_GENERATOR ('PAL_RGP', 'AFLPAL', 'FORECASTWITHLR', PAL_RGP_SIGNATURE);

-- app setup

CREATE COLUMN TABLE RGP_PREDICT LIKE PAL_T_RGP_DATA;
CREATE COLUMN TABLE RGP_PREDICTED LIKE PAL_T_RG_FITTED;

CREATE VIEW V_RGP_PREDICTED AS
	SELECT 
		CASE WHEN a.ID IS NOT NULL THEN a.ID ELSE b.ID END AS ID, 
		CASE WHEN a.LIFESPEND IS NOT NULL THEN a.LIFESPEND ELSE ROUND(b.FITTED,1) END AS LIFESPEND, 
		CASE WHEN a.INCOME IS NOT NULL THEN a.INCOME ELSE c.INCOME END AS INCOME,
		CASE WHEN a.LOYALTY IS NOT NULL THEN a.LOYALTY ELSE c.LOYALTY END AS LOYALTY,
		CASE WHEN a.NEWSPEND IS NOT NULL THEN a.NEWSPEND ELSE c.NEWSPEND END AS NEWSPEND
	 FROM V_RG_DATA a 
	 FULL JOIN RGP_PREDICTED b ON (a.ID=b.ID)
	 FULL JOIN RGP_PREDICT c ON (b.ID=c.ID)
	 ;

-- app runtime

TRUNCATE TABLE RGP_PREDICT;
INSERT INTO RGP_PREDICT VALUES (151,2.5,3.1,4.5);
INSERT INTO RGP_PREDICT VALUES (152,7.5,4.2,7.6);

TRUNCATE TABLE RGP_PREDICTED;

CALL _SYS_AFL.PAL_RGP (RGP_PREDICT, RG_COEFF, RG_PARAMS, RGP_PREDICTED) WITH OVERVIEW;
