CREATE TABLE [sis].[Kit_Effectivity]
     (	
        [Kit_Effectivity_ID]                    [int]   Identity(1,1)   NOT NULL
	  , [Kit_ID]					            [int]				    NOT NULL
      , [SerialNumberPrefix_ID]                 [int]                   NULL
	  , [SerialNumberRange_ID]                  [int]                   NULL
      , [Type]                                  VARCHAR(15)             NULL
      , [Parent_ID]                             [INT]                   NULL
     
       CONSTRAINT [PK_Kit_Effectivity_ID]       PRIMARY KEY CLUSTERED ( [Kit_Effectivity_ID] ASC)
     , CONSTRAINT [FK_Kit_Effectivity_Kit]      FOREIGN KEY           ( [Kit_ID] )                REFERENCES [sis].[Kit] ([Kit_ID])
     , CONSTRAINT [FK_Kit_Effectivity_Prime]    FOREIGN KEY           ( [Parent_ID] )             REFERENCES [sis].[Kit_Effectivity] ([Kit_Effectivity_ID])
     );
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Kit_Effectivity]   ON [sis].[Kit_Effectivity]
    ([Kit_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC, [Type] ASC , [Parent_ID] ASC);
GO

/****** Object:  Index [IX_Kit_effectivity_parent]    Script Date: 14-10-2021 16:00:04 ******/
CREATE NONCLUSTERED INDEX [IX_Kit_effectivity_parent] ON [sis].[Kit_Effectivity]
(
	[Parent_ID] ASC
)
INCLUDE([SerialNumberPrefix_ID],[SerialNumberRange_ID])
GO

create nonclustered index IX_Kit_effectivity_prefix on sis.Kit_Effectivity (SerialNumberPrefix_ID) include (Kit_Effectivity_ID, Kit_ID, SerialNumberRange_ID);
GO