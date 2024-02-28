CREATE TABLE [SOC].[serialNumberAvailability](
[SerialNumberPrefix] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[BeginSN] [int] NOT NULL,
[endSN] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
[SerialNumberPrefix] ASC,
[BeginSN] ASC,
[endSN] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
