CREATE TABLE [sis].[SerialNumber] (
    [SerialNumber_ID] INT           IDENTITY (1, 1) NOT NULL,
    [SerialNumber]    CHAR (8)      NOT NULL,
    [Build_Date]      DATETIME2 (0) NULL,
    [TestDate] DATETIME2(0) NULL,
    [ShippedDate] DATETIME2(0) NULL,
    CONSTRAINT [PK_SerialNumber] PRIMARY KEY NONCLUSTERED ([SerialNumber_ID] ASC),
    CONSTRAINT [UQ_SerialNumber] UNIQUE CLUSTERED ([SerialNumber] ASC)
);



