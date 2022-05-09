tableextension 87000 "wan Gen. Bus. Posting Group" extends "Gen. Business Posting Group"
{
    fields
    {
        field(87000; "wan Late Payment Text Code"; Code[20])
        {
            CaptionML = ENU = 'Late Payment Text Code', FRA = 'Code texte retard de paiement';
            DataClassification = ToBeClassified;
            TableRelation = "Standard Text";
        }
    }
}
