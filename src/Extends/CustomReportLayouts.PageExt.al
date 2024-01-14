pageextension 87301 "wan Custom Report Layouts" extends "Custom Report Layouts"
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
        addlast(Category_Category4)
        {
            actionref(wanDocumentContent_Promoted; wanDocumentContent)
            {
            }
        }

    }
}
