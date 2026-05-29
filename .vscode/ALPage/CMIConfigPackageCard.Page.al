page 50402 "CMI Config. Package Card"
{
    PageType = Document;
    ;
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
            }
            part(Lines; "CMI Config. Package Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Package Code" = field(Code);
                SubPageView = sorting("Package Code", "Table ID");
            }
        }
    }

}