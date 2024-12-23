namespace Wanamics.WanaDoc.Document;

using Microsoft.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;
tableextension 87300 "wan Gen. Bus. Posting Group" extends "Gen. Business Posting Group"
{
    fields
    {
        field(87300; "wan Late Payment Text Code"; Code[20])
        {
            Caption = 'Late Payment Text Code';
            DataClassification = ToBeClassified;
            TableRelation = "Standard Text";
        }
    }
}
