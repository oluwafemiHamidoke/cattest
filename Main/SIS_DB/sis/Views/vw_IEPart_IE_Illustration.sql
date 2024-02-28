
CREATE VIEW [sis].[vw_IEPart_IE_Illustration] as
    WITH CTE AS (
    select MS.IESystemControlNumber as IESystemControlNumber,
    ILE.Graphic_Control_Number as Graphic_Control_Number,
    ILF.Mime_Type as Mime_Type,
    IELR.Graphic_Number as Graphic_Number,
    ILF.File_Location as File_Location,
    ILF.Graphic_Type as Graphic_Type
    from sis.MediaSequence MS
    inner join sis.IEPart_Illustration_Relation IELR on IELR.IEPart_ID = MS.IEPart_ID
    inner join sis.Illustration ILE on ILE.Illustration_ID = IELR.Illustration_ID
    inner join sis.Illustration_File ILF on ILF.Illustration_ID = ILE.Illustration_ID
    union all
    select IE.IESystemControlNumber as IESystemControlNumber,
    IL.Graphic_Control_Number as Graphic_Control_Number,
    ILLF.Mime_Type as Mime_Type,
    IIR.Graphic_Number as Graphic_Number,
    ILLF.File_Location as File_Location,
    ILLF.Graphic_Type as Graphic_Type
    from sis.IE IE
    inner join sis.IE_Illustration_Relation IIR on IIR.IE_ID = IE.IE_ID
    inner join sis.Illustration IL on IL.Illustration_ID = IIR.Illustration_ID
    inner join sis.Illustration_File ILLF on ILLF.Illustration_ID = IL.Illustration_ID
)
select
    IESystemControlNumber,Graphic_Control_Number,Mime_Type,Graphic_Number,File_Location,Graphic_Type
from CTE group by IESystemControlNumber,Graphic_Control_Number,Mime_Type,Graphic_Number,File_Location,Graphic_Type