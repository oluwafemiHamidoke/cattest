-- This table is not being used or populated by any SProcs and is empty
CREATE TABLE [sis_stage].[FlashApplication_sis2Etl] (
    [FlashApplication_ID] INT NOT NULL,
    [Is_Engine_Related] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_FlashApplication_sis2Etl] PRIMARY KEY CLUSTERED ([FlashApplication_ID] ASC)
);
