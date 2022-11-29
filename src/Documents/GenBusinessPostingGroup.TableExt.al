tableextension 87300 "wan Gen. Bus. Posting Group" extends "Gen. Business Posting Group"
{
    fields
    {
        field(87000; "wan Late Payment Text Code"; Code[20])
        {
            Caption = 'Late Payment Text Code';
            DataClassification = ToBeClassified;
            TableRelation = "Standard Text";
        }
    }
}
