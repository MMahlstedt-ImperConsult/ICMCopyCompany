namespace ImperConsult.CopyCompany;

using Microsoft.Foundation.Company;

page 50402 "ICM Data Transfer Package Card"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ICM Data Transfer Package";
    Caption = 'Configuration Package';

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
                    ToolTip = 'Specifies the code of the configuration package.';
                }
                field("Description"; Rec."ICM Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the configuration package.';
                }
                field("Source Company Name"; Rec."ICM Source Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company';
                    ToolTip = 'Specifies the source company for the configuration package.';
                }
                field("Target Company Name"; Rec."ICM Target Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company';
                    ToolTip = 'Specifies the target company for the configuration package.';
                }
                field("No. of Tables"; Rec."ICM No. of Tables")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Tables';
                    ToolTip = 'Specifies the No. of Tables for the configuration package.';
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
            action("Create new Company")
            {
                Caption = 'Create new Company';
                ToolTip = 'Create new Company';
                Image = Open;

                trigger OnAction()
                begin
                    Page.Run(Page::Companies);
                end;
            }
            separator(Sep1)
            {
                Caption = '', Locked = true;
            }
            action(CopyConfigPackage)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Copy Config. Package';
                Image = CopyWorksheet;
                ToolTip = 'Copy an existing configuration package to create a new package based on the same content.';

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
            action("Copy Tables")
            {
                Caption = 'Copy Tables';
                ToolTip = 'Copy tables from one company to another';
                Image = Copy;

                trigger OnAction()
                var
                    ICMMgtL: Codeunit "ICM Data Transfer Management";
                begin
                    ICMMgtL.CopyTablesFromToCompany2(Rec."ICM Code");
                end;
            }

        }
        area(Navigation)
        {
            action("ICM Setup")
            {
                Caption = 'ICM Setup';
                ToolTip = 'Open ICM Setup';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Data Transfer Setup");
                end;
            }
            action("Configuration Packages")
            {
                Caption = 'Configuration Packages';
                ToolTip = 'Open Configuration Packages List';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Data Transfer Package List");
                end;
            }
        }
    }

}