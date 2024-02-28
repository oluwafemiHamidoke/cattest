/****** Object:  Table [sissearch2].[ServiceIE_ProductFamily]    Script Date: 8/17/2022 5:17:01 PM ******/
CREATE TABLE [sissearch2].[ServiceIE_ProductFamily](
    [ID]                    VARCHAR (50)  NOT NULL,
    [IESystemControlNumber] VARCHAR (15)  NOT NULL,
    [ProductCodes]          VARCHAR (MAX) NULL,
    [InsertDate]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


