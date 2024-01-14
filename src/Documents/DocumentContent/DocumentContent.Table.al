table 87301 "wan Document Content"
{
    Caption = 'Document Content';
    LookupPageId = "wan Document Contents";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            NotBlank = true;
            BlankZero = true;
        }
        field(2; Placement; Enum "wan Document Content Placement")
        {
            Caption = 'Placement';
            NotBlank = true;
            BlankZero = true;
        }
        field(3; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(4; "Content"; Blob)
        {
            Caption = 'Content';
        }
        field(10; "Report Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = const(Report), "Object ID" = field("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; "Report ID", Placement, "Language Code")
        {
            Clustered = true;
        }
    }
}
