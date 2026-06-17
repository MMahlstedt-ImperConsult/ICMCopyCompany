namespace ImperConsult.CopyCompany;

page 50401 "ICM Data Transfer Setup"
{
    PageType = Card;
    SourceTable = "ICM Data Transfer Setup";
    Caption = 'Data Transfer Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Table data processing"; Rec."ICM Table data processing")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec."ICM Primary Key" := '';
            Rec.Insert();
        end;
    end;
}
