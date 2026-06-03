page 50402 "CMI Config. Package Card"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "CMI Config. Package";
    Caption = 'Configuration Package';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Package Code';
                    ToolTip = 'Specifies the code of the configuration package.';
                }
                field("Description"; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the configuration package.';
                }
                field("From Company Name"; Rec."From Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'From Company';
                    ToolTip = 'Specifies the source company for the configuration package.';
                }
                field("To Company Name"; Rec."To Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'To Company';
                    ToolTip = 'Specifies the target company for the configuration package.';
                }
            }
            part(Lines; "CMI Config. Package Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Package Code" = field(Code);
                SubPageView = sorting("Package Code", "Table ID");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Copy Tables")
            {
                Caption = 'Copy Tables';
                ToolTip = 'Copy tables from one company to another';
                Image = Copy;

                trigger OnAction()
                var
                    ICMMgtL: Codeunit "ICM Management";
                begin
                    ICMMgtL.CopyTablesFromToCompany2(Rec.Code);
                end;
            }
        }
    }

}