namespace ImperConsult.CopyCompany;

page 50403 "ICM Data Transfer Pack.Subform"
{
    PageType = ListPart;
    ApplicationArea = All;
    Caption = 'Data Transfer Tables';
    SourceTable = "ICM Data Transfer Package Line";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Package Code"; Rec."ICM Package Code")
                {
                    ApplicationArea = All;
                    Caption = 'Package Code';
                    visible = false;
                }
                field("Table ID"; Rec."ICM Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                }
                field("Table Name"; Rec."ICM Table Name")
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    visible = false;
                }
                field("Table Caption"; Rec."ICM Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Table Caption';
                }
                field("ICM Active"; Rec."ICM Active")
                {
                    ApplicationArea = All;
                    Caption = 'Active';
                }
                field("Source Company Name"; Rec."ICM Source Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company Name';
                    visible = false;
                }
                field("Target Company Name"; Rec."ICM Target Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company Name';
                    visible = false;
                }
                field("ICM Log Modification"; Rec."ICM Apply Table Fields")
                {
                    ApplicationArea = All;
                    Caption = 'Apply Table Fields';
                }
                field("ICM No. of Fields Available"; Rec."ICM No. of Fields Available")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Fields Available';
                }
                field("ICM No. of Fields Included"; Rec."ICM No. of Fields Included")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Fields Included';
                }
                field("ICM Source Comp. Record Count"; Rec."ICM Source Comp. Record Count")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company Record Count';
                }
                field("ICM Target Comp. Record Count"; Rec."ICM Target Comp. Record Count")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company Record Count';
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action(PackageFilters)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Filters';
                Image = "Filter";
                ToolTip = 'View or set field filter values for a configuration package filter. By setting a value, you specify that only records with that value are included in the configuration package.';

                trigger OnAction()
                begin
                    Rec.ShowFilters();
                end;
            }
        }
    }
}