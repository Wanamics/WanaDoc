namespace Wanamics.WanaDoc.Prepayment;

using Microsoft.Finance.ReceivablesPayables;

tableextension 87301 "wan Prepayment Inv. Line Buff." extends "Prepayment Inv. Line Buffer"
{
    fields
    {
        field(87500; "wan Indentation"; Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
        }
    }
}
