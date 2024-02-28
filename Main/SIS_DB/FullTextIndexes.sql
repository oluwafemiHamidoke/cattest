CREATE FULLTEXT INDEX ON [sis].[Chain_Temp]
    ([Chain] LANGUAGE 1033)
    KEY INDEX [PK_Chain_Temp]
    ON [FT_Chain];

GO
CREATE FULLTEXT INDEX ON [sis_stage].[Chain_Temp]
    ([Chain] LANGUAGE 1033)
    KEY INDEX [PK_Chain_Temp]
    ON [FT_Chain];

