Create Table [sis_stage].[FlashApplication_Translation] (
    [FlashApplication_ID]        INT            NOT NULL,
    [Language_ID]                INT            NOT NULL,
    [Description]                NVARCHAR (720) NULL,
    CONSTRAINT [PK_FlashApplication_Translation] PRIMARY KEY CLUSTERED ([FlashApplication_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_FlashApplication_Translation_FlashApplication] FOREIGN KEY ([FlashApplication_ID]) REFERENCES [sis_stage].[FlashApplication] ([FlashApplication_ID])
);
