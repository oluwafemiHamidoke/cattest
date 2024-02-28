-- =============================================
-- Author:     Paul B. Felix
-- Create Date: 20180615
-- Description: Remove all non-Alphanumeric characters from input string
-- =============================================
CREATE Function [dbo].[RemoveNonAlphaNumericCharacters](@String VarChar(1000))
Returns VarChar(1000)
AS
BEGIN


    Declare @KeepValues as varchar(50)
    Set @KeepValues = '%[^a-z^A-Z^0-9]%'
    While PatIndex(@KeepValues, @String) > 0
        Set @String = Stuff(@String, PatIndex(@KeepValues, @String), 1, '')

    Return @String
End