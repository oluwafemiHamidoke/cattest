CREATE TABLE [sis].[Kit]
     (
	   [Kit_ID]							[int]IDENTITY(1,1) 			NOT NULL
	 , [Number]						[varchar](50)				NOT NULL   -- Loading nvarchar(7) data here
	 , [Name]						[nvarchar](500)				NOT NULL
	 , [Display_Name]				[nvarchar](500)
     , [Change_Level]				[varchar](4)
	 , [Part_Type]						[nvarchar](20)
	 , [Serviceability_Indicator]		[varchar](1)						   -- previous[SERVICEABILITY] [nvarchar](25) need to convert to nvarchar(1)
     , [Note] NVARCHAR(1000) NULL
     , [Long_Description] NVARCHAR (2000) NULL,
    CONSTRAINT [PK_Kit]              PRIMARY KEY CLUSTERED
     (
	   [Kit_ID] ASC
     )
     );
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Kit]
    ON [sis].[Kit]([Number] ASC);
GO

