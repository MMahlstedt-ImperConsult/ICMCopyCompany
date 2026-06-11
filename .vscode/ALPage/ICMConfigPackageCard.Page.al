namespace ImperConsult.CopyCompany;

using Microsoft.Foundation.Company;

page 50402 "ICM Config. Package Card"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ICM Config. Package";
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
                field("From Company Name"; Rec."ICM Source Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company';
                    ToolTip = 'Specifies the source company for the configuration package.';
                }
                field("To Company Name"; Rec."ICM Target Company Name")
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
            part(Lines; "ICM Config. Package Subform")
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
            action("Copy Tables")
            {
                Caption = 'Copy Tables';
                ToolTip = 'Copy tables from one company to another';
                Image = Copy;

                trigger OnAction()
                var
                    ICMMgtL: Codeunit "ICM Management";
                begin
                    ICMMgtL.CopyTablesFromToCompany2(Rec."ICM Code");
                end;
            }
            action("Copy Config. Package")
            {
                Caption = 'Copy Config. Package';
                ToolTip = 'Copy Config. Package';
                Image = Copy;

                trigger OnAction()
                var
                    ICMMgtL: Codeunit "ICM Management";
                begin
                    //ICMMgtL.CopyTablesFromToCompany2(Rec."ICM Code");
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
                    Page.Run(Page::"ICM Setup");
                end;
            }
            action("Configuration Packages")
            {
                Caption = 'Configuration Packages';
                ToolTip = 'Open Configuration Packages List';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Config. Package List");
                end;
            }
        }
    }

}