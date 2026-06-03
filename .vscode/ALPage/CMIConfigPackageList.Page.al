page 50404 "CMI Config. Package List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CMI Config. Package";
    CardPageID = "CMI Config. Package Card";
    Caption = 'Configuration Packages';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Code';

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field("From Company Name"; Rec."From Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'From Company';
                }
                field("To Company Name"; Rec."To Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'To Company';
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
    var
        SelectedPackageCodeL: Code[20];

    procedure GetSelectedPackage(): Code[20]
    begin
        exit(SelectedPackageCodeL);
    end;


    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            SelectedPackageCodeL := Rec."Code";
    end;
}