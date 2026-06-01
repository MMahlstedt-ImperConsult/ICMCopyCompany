page 50403 "CMI Config. Package Subform"
{
    PageType = ListPart;
    ApplicationArea = All;
    Caption = 'Tables';
    SourceTable = "CMI Config. Package Line";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Package Code"; Rec."Package Code")
                {
                    ApplicationArea = All;
                    Caption = 'Package Code';
                    visible = false;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    visible = false;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Table Caption';
                }
            }
        }

    }
}