namespace ImperConsult.CopyCompany;
using System.Reflection;

table 50400 "ICM Data Transfer Table"
{
    DataPerCompany = false;
    Caption = 'Company Table Information';

    fields
    {
        field(1; "ICM Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
            trigger OnValidate()
            begin
                if ("ICM Table ID" <> 0) or (xRec."ICM Table ID" <> "ICM Table ID") then
                    InitPackageFields();
            end;
        }
        field(2; "ICM Table Name"; Text[249])
        {
            Caption = 'Table Name';
            Editable = false;
        }
        field(3; "ICM Company Name"; Text[30])
        {
            Caption = 'Company Name';
            Editable = false;
        }
        field(4; "ICM Data Per Company"; Boolean)
        {
            Caption = 'Data Per Company';
            Editable = false;
        }
        field(5; "ICM Has Records"; Boolean)
        {
            Caption = 'Has Records';
            Editable = false;
        }
        field(6; "ICM Record Count"; Integer)
        {
            Caption = 'Record Count';
            Editable = false;
        }
        field(7; "ICM Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "ICM Included in the License" = false then
                    Error(Text001Lbl);

                if "ICM Table Subtype" <> 'Normal' then
                    Error(Text002Lbl);
            end;
        }
        field(8; "ICM Table Caption"; Text[249])
        {
            Caption = 'Table Caption';
            Editable = false;
        }
        field(9; "ICM Table Subtype"; Text[30])
        {
            Caption = 'Table Subtype';
            Editable = false;
        }
        field(10; "ICM Included in the License"; boolean)
        {
            Caption = 'Included in the License';
            Editable = false;
        }
        field(11; "ICM No. of Fields Available"; Integer)
        {
            CalcFormula = count("ICM Data Transfer Table Field" where("ICM Table ID" = field("ICM Table ID"),
                                                    "ICM Company Name" = field("ICM Company Name")));
            Caption = 'No. of Fields Available';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "ICM No. of Fields Included"; Integer)
        {
            CalcFormula = count("ICM Data Transfer Table Field" where("ICM Table ID" = field("ICM Table ID"),
                                                            "ICM Company Name" = field("ICM Company Name"),
                                                            "ICM Include Field" = const(true)));
            Caption = 'No. of Fields Included';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "ICM Apply Table Fields"; Enum "ICM Apply Table Fields")
        {
            Caption = 'Apply Table Fields';
            DataClassification = CustomerContent;
            Trigger OnValidate()
            begin
                if ("ICM Apply Table Fields" <> xRec."ICM Apply Table Fields") and
                 ("ICM Apply Table Fields" = "ICM Apply Table Fields"::"All Fields") then
                    UpdateTableFields();
            end;
        }
        field(14; "ICM Records transferred"; boolean)
        {
            Caption = 'Records has been transferred ';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "ICM Company Name", "ICM Table ID")
        {
            Clustered = true;
        }
        key(NK1; "ICM Table Name")
        {
        }
    }

    trigger OnInsert()
    begin
        InitPackageFields();
    end;

    trigger OnDelete()
    var
        TableFieldL: Record "ICM Data Transfer Table Field";
    begin
        TableFieldL.Setrange("ICM Company Name", "ICM Company Name");
        TableFieldL.Setrange("ICM Table ID", "ICM Table ID");
        TableFieldL.DeleteAll();
    end;

    local procedure InitPackageFields()
    var
        FieldL: Record Field;
        TableFieldL: Record "ICM Data Transfer Table Field";
        ICMMgtL: Codeunit "ICM Data Transfer Management";
    begin
        TableFieldL.Setrange("ICM Company Name", "ICM Company Name");
        TableFieldL.Setrange("ICM Table ID", "ICM Table ID");
        TableFieldL.DeleteAll();

        FieldL.Reset();
        FieldL.Setrange(TableNo, "ICM Table ID");
        FieldL.SetRange("No.", 1, 1999999999);
        FieldL.SetRange(Class, FieldL.Class::Normal);

        FieldL.SetFilter(ObsoleteState, '<>%1', FieldL.ObsoleteState::Removed);
        if FieldL.FindSet() then
            repeat
                if not TableFieldL.Get("ICM Table ID", "ICM Company Name", FieldL."No.") then begin
                    TableFieldL.Init;
                    TableFieldL."ICM Company Name" := "ICM Company Name";
                    TableFieldL."ICM Table ID" := "ICM Table ID";
                    TableFieldL."ICM Field ID" := FieldL."No.";
                    TableFieldL."ICM Field Caption" := FieldL."Field Caption";
                    TableFieldL."ICM Field Name" := FieldL.FieldName;
                    TableFieldL."ICM Primary Key" := ICMMgtL.IsKeyField("ICM Table ID", FieldL."No.");

                    if "ICM Apply Table Fields" = "ICM Apply Table Fields"::"All Fields" then
                        TableFieldL."ICM Include Field" := true
                    else
                        TableFieldL."ICM Include Field" := false;
                    if TableFieldL."ICM Primary Key" then
                        TableFieldL."ICM Include Field" := true;

                    TableFieldL.Insert();
                end;
            until FieldL.Next() = 0;
    end;

    local procedure UpdateTableFields()
    var
        TableFieldL: Record "ICM Data Transfer Table Field";
    begin
        TableFieldL.Reset();
        TableFieldL.Setrange("ICM Company Name", "ICM Company Name");
        TableFieldL.Setrange("ICM Table ID", "ICM Table ID");
        if TableFieldL.FindSet() then
            TableFieldL.ModifyAll("ICM Include Field", true);
    end;

    var
        Text001Lbl: Label 'This table is not included in the license. Active status cannot be set to true.';
        Text002Lbl: Label 'Only tables with subtype "Normal" can be set to active.';
}
