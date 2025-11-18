namespace Wanamics.WanaDoc.Indentation;

using Microsoft.Utilities;
table 87302 "wan Indentation Setup"
{
    Caption = 'WanaDoc Indentation Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
        }
        field(2; "Title Code"; Code[20])
        {
            Caption = 'Title Code';
            TableRelation = "Standard Text";
            InitValue = '§';
        }
        field(3; "Total Code"; Code[20])
        {
            Caption = 'Total Code';
            TableRelation = "Standard Text";
            InitValue = '=';
        }
        field(4; "Title Style"; enum "wan Indentation Style")
        {
            Caption = 'Title Style';
            InitValue = StrongAccent;
        }
        field(5; "Total Style"; enum "wan Indentation Style")
        {
            Caption = 'Total Style';
            InitValue = StandardAccent;
        }
        field(6; "Indent Width"; Integer)
        {
            Caption = 'Indent Width';
            InitValue = 3;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
