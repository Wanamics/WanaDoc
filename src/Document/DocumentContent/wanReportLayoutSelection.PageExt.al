namespace Wanamics.WanaDoc.Document;

using Microsoft.Foundation.Reporting;
pageextension 87301 "wan Report Layout Selection" extends "Report Layout Selection"
{
    actions
    {
        addlast(processing)
        {
            action(wanDocumentContent)
            {
                Caption = 'Document Content';
                ApplicationArea = All;
                Image = Text;
                trigger OnAction()
                var
                    DocumentContent: Record "wan Document Content";
                begin
                    DocumentContent.SetRange("Report ID", Rec."Report ID");
                    Page.Run(0, DocumentContent);
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(wanDocumentContent_Promoted; wanDocumentContent)
            {
            }
        }

    }
}
