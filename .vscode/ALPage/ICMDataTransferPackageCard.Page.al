namespace ImperConsult.CopyCompany;

using Microsoft.Foundation.Company;

page 50402 "ICM Data Transfer Package Card"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ICM Data Transfer Package";
    Caption = 'Data Transfer Package';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."ICM Code")
                {
                    ApplicationArea = All;
                    Caption = 'Package Code';
                    ToolTip = 'Specifies the code of the data transfer package.';
                }
                field("Description"; Rec."ICM Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the data transfer package.';
                }
                field("Source Company Name"; Rec."ICM Source Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company';
                    ToolTip = 'Specifies the source company for the data transfer package.';
                }
                field("Target Company Name"; Rec."ICM Target Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company';
                    ToolTip = 'Specifies the target company for the data transfer package.';
                }
                field("No. of Tables"; Rec."ICM No. of Tables")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Tables';
                    ToolTip = 'Specifies the No. of Tables for the data transfer package.';
                }
            }
            part(Lines; "ICM Data Transfer Pack.Subform")
            {
                ApplicationArea = All;
                SubPageLink = "ICM Package Code" = field("ICM Code");
                SubPageView = sorting("ICM Package Code", "ICM Table ID");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CopyConfigPackage)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Copy Config. Package';
                Image = CopyWorksheet;
                ToolTip = 'Copy an existing data transfer package to create a new package based on the same content.';

                trigger OnAction()
                var
                    CopyConfigPackageL: Report "ICM Copy Config Package";
                begin
                    Rec.TestField("ICM Code");
                    CopyConfigPackageL.Set(Rec);
                    CopyConfigPackageL.RunModal();
                    Clear(CopyConfigPackageL);
                end;
            }
            separator(Sep2)
            {
                Caption = '', Locked = true;
            }
            action("Transfer Data")
            {
                Caption = 'Transfer Data Between Companies';
                ToolTip = 'Transfer data between clients for all tables where the “Active” field has been checked';
                Image = Copy;

                trigger OnAction()
                var
                    ICMMgtL: Codeunit "ICM Data Transfer Management";
                begin
                    ICMMgtL.CopyToCompanyFromDataTransferPackage(Rec."ICM Code");
                end;
            }

        }
        area(Navigation)
        {
            action("Transfer Data Log")
            {
                Caption = 'Transfer Data Log';
                ToolTip = 'Open Transfer Data Log List';
                Image = Log;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Transfer Data Log List");
                end;
            }
        }
    }

}