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
                field("ICM Active"; Rec."ICM Active")
                {
                    ApplicationArea = All;
                    Caption = 'Active';
                }
                field("From Company Name"; Rec."From Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'From Company Name';
                    visible = false;
                }
                field("To Company Name"; Rec."To Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'To Company Name';
                    visible = false;
                }
                field("ICM Source Company Has Records"; Rec."ICM Source Company Has Records")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company Has Records';
                }
                field("ICM Source Comp. Record Count"; Rec."ICM Source Comp. Record Count")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company Record Count';
                }
                field("ICM Target Company Has Records"; Rec."ICM Target Company Has Records")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company Has Records';
                }
                field("ICM Target Comp. Record Count"; Rec."ICM Target Comp. Record Count")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company Record Count';
                }
            }
        }

    }
}