page 50403 "ICM Config. Package Subform"
{
    PageType = ListPart;
    ApplicationArea = All;
    Caption = 'Tables';
    SourceTable = "ICM Config. Package Line";

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
                field("ICM No. of Fields Included"; Rec."ICM No. of Fields Included")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Fields Included';
                    //DrillDown = true;
                    //DrillDownPageID = "ICM Config. Package Fields";
                    trigger OnAssistEdit()
                    begin
                        //ChangeLogSetupTable.TestField("Log Modification", ChangeLogSetupTable."Log Modification"::"Some Fields");
                        Rec.TestField("ICM Apply Table Fields", Rec."ICM Apply Table Fields"::"Some Fields");
                        AssistEdit();
                    end;
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

    local procedure AssistEdit()
    var
        ConfigPackageFieldL: Record "ICM Config. Package Field";
        ConfigPackageFieldsL: Page "ICM Config. Package Fields";
    begin
        ConfigPackageFieldL.Reset();
        ConfigPackageFieldL.SetRange("ICM Package Code", Rec."ICM Package Code");
        ConfigPackageFieldL.SetRange("ICM Table ID", Rec."ICM Table ID");
        ConfigPackageFieldsL.SetTableView(ConfigPackageFieldL);
        ConfigPackageFieldsL.Run();
    end;
}