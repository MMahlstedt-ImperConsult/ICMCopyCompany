namespace ImperConsult.CopyCompany;

page 50405 "ICM Data Transfer Pack. Fields"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ICM Data Transf. Package Field";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Package Code"; Rec."ICM Package Code")
                {
                    ApplicationArea = All;
                    Caption = 'Package Code';
                    ToolTip = 'Specifies the Package Code.';
                    Visible = false;
                }
                field("ICM Table ID"; Rec."ICM Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                    ToolTip = 'Specifies the Table ID.';
                    Visible = false;
                }
                field("ICM Field ID"; Rec."ICM Field ID")
                {
                    Caption = 'Field ID';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the ID of the field for the table';
                }
                field("ICM Field Name"; Rec."ICM Field Name")
                {
                    Caption = 'Field Name';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Name of the field';
                    Visible = false;
                }
                field("ICM Field Caption"; Rec."ICM Field Caption")
                {
                    Caption = 'Field Caption';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Caption of the field';
                }
                field("ICM Include Field"; Rec."ICM Include Field")
                {
                    Caption = 'Include Field';
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the field is included in the migration';
                    Editable = IncludedEditable;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Set Included")
            {
                Caption = 'Set Included';
                ToolTip = 'Set Included';
                Image = Open;
                Visible = ActionsVisible;

                trigger OnAction()
                var
                    CMIConfigPackageFieldL: Record "ICM Data Transf. Package Field";
                    ICMMgtL: Codeunit "ICM Data Transfer Management";
                begin
                    CMIConfigPackageFieldL.CopyFilters(Rec);
                    ICMMgtL.ActivateIncludePackageField(CMIConfigPackageFieldL);
                    CurrPage.Update(false);
                end;
            }
            action("Clear Included")
            {
                Caption = 'Clear Included';
                ToolTip = 'Clear Included';
                Image = Close;
                Visible = ActionsVisible;

                trigger OnAction()
                var
                    ICMConfigPackageFieldL: Record "ICM Data Transf. Package Field";
                    ICMMgtL: Codeunit "ICM Data Transfer Management";
                begin
                    Rec.CalcFields("ICM Apply Table Fields");
                    Rec.TestField("ICM Apply Table Fields", "ICM Apply Table Fields"::"Some Fields");
                    ICMConfigPackageFieldL.CopyFilters(Rec);
                    ICMMgtL.DeactivateIncludePackageField(ICMConfigPackageFieldL);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IncludedEditable := SetIncludedEditable();
        SetActionsVisible();
    end;

    trigger OnInit()
    begin
        ActionsVisible := true;
    end;

    local procedure SetIncludedEditable(): Boolean
    var
        ICMConfigPackageLineL: Record "ICM Data Transfer Package Line";
    begin
        ICMConfigPackageLineL.Get(Rec."ICM Package Code", Rec."ICM Table ID");
        exit((not Rec."ICM Primary Key") and (ICMConfigPackageLineL."ICM Apply Table Fields" <> ICMConfigPackageLineL."ICM Apply Table Fields"::"All Fields"));
    end;

    procedure SetActionsVisible()
    var
        ICMDataTransferPackLine: Record "ICM Data Transfer Package Line";
    begin
        if ICMDataTransferPackLine.Get(Rec."ICM Package Code", Rec."ICM Table ID") then
            if ICMDataTransferPackLine."ICM Apply Table Fields" = ICMDataTransferPackLine."ICM Apply Table Fields"::"Some Fields" then
                ActionsVisible := true
            else
                ActionsVisible := false;
    end;

    var
        IncludedEditable: Boolean;
        ActionsVisible: Boolean;
}