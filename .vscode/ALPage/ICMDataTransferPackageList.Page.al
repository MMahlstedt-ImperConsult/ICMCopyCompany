namespace ImperConsult.CopyCompany;

using Microsoft.Foundation.Company;

page 50404 "ICM Data Transfer Package List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ICM Data Transfer Package";
    CardPageID = "ICM Data Transfer Package Card";
    Caption = 'Data Transfer Packages';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec."ICM Code")
                {
                    ApplicationArea = All;
                    Caption = 'Code';

                }
                field(Description; Rec."ICM Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field("No. of Tables"; Rec."ICM No. of Tables")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Tables';
                }
                field("Source Company Name"; Rec."ICM Source Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company';
                }
                field("Target Company Name"; Rec."ICM Target Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company';
                }
            }
        }
        area(Factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Data Transfer Tables List")
            {
                Caption = 'Data Transfer Tables List';
                ToolTip = 'Open Data Transfer Tables List';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Data Transfer Tables List");
                end;
            }
        }
    }
    var
        SelectedPackageCodeL: Code[20];

    procedure GetSelectedPackage(): Code[20]
    begin
        exit(SelectedPackageCodeL);
    end;


    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            SelectedPackageCodeL := Rec."ICM Code";
    end;
}