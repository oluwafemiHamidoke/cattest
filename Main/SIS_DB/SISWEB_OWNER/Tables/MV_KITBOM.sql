CREATE TABLE [SISWEB_OWNER].[MV_KITBOM] (
    [KITPARTNUMBER]       VARCHAR (20)  NOT NULL,
    [KITPARTNAME]         VARCHAR (200) NOT NULL,
    [COMPONENTPARTNUMBER] VARCHAR (20)  NOT NULL,
    [COMPONENTPARTNAME]   VARCHAR (200) NOT NULL,
    [QUANTITY]            NUMERIC (10)  NOT NULL,
    [LASTMODIFIEDDATE]    DATETIME2 (6) NULL
);



GO

CREATE CLUSTERED INDEX CX_MV_KITBOM ON SISWEB_OWNER.MV_KITBOM (KITPARTNUMBER ASC);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'See: https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/5003'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'SISWEB_OWNER'
							  ,@level1type = N'TABLE'
							  ,@level1name = N'MV_KITBOM'
							  ,@level2type = N'INDEX'
							  ,@level2name = N'CX_MV_KITBOM';