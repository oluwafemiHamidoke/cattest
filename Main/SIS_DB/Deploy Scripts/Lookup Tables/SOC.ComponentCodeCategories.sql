BEGIN TRANSACTION;

PRINT 'Populating Lookup Table SOC.ComponentCodeCategories'

MERGE INTO SOC.ComponentCodeCategories AS tgt
USING
(VALUES 
('1000','ENGINE'), 
('3000','TRANSMISSION & DRIVE LINE'), 
('4000','DRIVETRAIN'), 
('5000','IMPLEMENT CONTROLS'), 
('6000','IMPLEMENTS'), 
('7000','MACHINE') ) 
src(Component_Code,Name)
ON tgt.Component_Code = src.Component_Code
WHEN NOT MATCHED BY TARGET
	  THEN
	  INSERT(Component_Code,Name)
	  VALUES (src.Component_Code,src.Name)
WHEN MATCHED AND 
  EXISTS (SELECT tgt.* EXCEPT SELECT src.*)
  THEN  UPDATE
            SET Component_Code = src.Component_Code
              , Name = src.Name;
 
--ROLLBACK TRANSACTION
COMMIT TRANSACTION;
GO