CREATE TABLE [admin].[Group_Details] (
    [Group_ID]          INT Identity(1,1)         NOT NULL,
    [Group_Code]        VARCHAR (10) NOT NULL,
    [Group_Description] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Group_Details] PRIMARY KEY CLUSTERED ([Group_ID] ASC),
    CONSTRAINT [UQ_Group_Details_Group_Code] UNIQUE NONCLUSTERED ([Group_Code] ASC)
);



