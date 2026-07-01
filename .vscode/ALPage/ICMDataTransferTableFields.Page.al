namespace ImperConsult.CopyCompany;

page 50406 "ICM Data Transfer Table Fields"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ICM Data Transfer Table Field";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Data Transfer Table Fields';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ICM Table ID"; Rec."ICM Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                    ToolTip = 'Specifies the Table ID.';
                    Visible = false;
                }
                field("ICM Company Name"; Rec."ICM Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    ToolTip = 'Specifies the name of the company.';
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
                    CMITableFieldL: Record "ICM Data Transfer Table Field";
                    ICMMgt: Codeunit "ICM Data Transfer Management";
                    Choice: Integer;
                begin
                    CMITableFieldL.CopyFilters(Rec);
                    ICMMgt.ActivateIncludeTableField(CMITableFieldL);
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
                    CMITableFieldL: Record "ICM Data Transfer Table Field";
                    ICMMgt: Codeunit "ICM Data Transfer Management";
                    Choice: Integer;
                begin
                    Rec.CalcFields("ICM Apply Table Fields");
                    Rec.TestField("ICM Apply Table Fields", "ICM Apply Table Fields"::"Some Fields");
                    CMITableFieldL.CopyFilters(Rec);
                    ICMMgt.DeactivateIncludeTableField(CMITableFieldL);
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
        ICMTableL: Record "ICM Data Transfer Table";
    begin
        ICMTableL.Get(Rec."ICM Company Name", Rec."ICM Table ID");
        exit((not Rec."ICM Primary Key") and (ICMTableL."ICM Apply Table Fields" <> ICMTableL."ICM Apply Table Fields"::"All Fields"));
    end;

    procedure SetActionsVisible()
    var
        ICMDataTransferTable: Record "ICM Data Transfer Table";
    begin
        if ICMDataTransferTable.Get(Rec."ICM Company Name", Rec."ICM Table ID") then
            if ICMDataTransferTable."ICM Apply Table Fields" = ICMDataTransferTable."ICM Apply Table Fields"::"Some Fields" then
                ActionsVisible := true
            else
                ActionsVisible := false;
    end;

    var
        IncludedEditable: Boolean;
        ActionsVisible: Boolean;
}