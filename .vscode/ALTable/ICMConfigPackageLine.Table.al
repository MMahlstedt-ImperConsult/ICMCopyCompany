namespace ImperConsult.CopyCompany;

using System.Reflection;

table 50403 "ICM Config. Package Line"
{
    DataClassification = ToBeClassified;
    Caption = 'Configuration Package Line';
    DataPerCompany = false;

    fields
    {
        field(1; "ICM Package Code"; Code[20])
        {
            Caption = 'Package Code';
            DataClassification = ToBeClassified;
        }
        field(2; "ICM Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table),
                                                                "Object Subtype" = const('Normal'));
            trigger OnValidate()
            begin
                if ("ICM Table ID" <> 0) or (xRec."ICM Table ID" <> "ICM Table ID") then
                    InitPackageFields();
            end;
        }
        field(3; "ICM Table Name"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table),
                                                                        "Object ID" = field("ICM Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "ICM Table Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table),
                                                                        "Object ID" = field("ICM Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "ICM Source Company Name"; Text[30])
        {
            Caption = 'Source Company Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("ICM Config. Package"."ICM Source Company Name" where("ICM Code" = field("ICM Package Code")));
            Editable = false;
        }
        field(6; "ICM Target Company Name"; Text[30])
        {
            Caption = 'Target Company Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("ICM Config. Package"."ICM Target Company Name" where("ICM Code" = field("ICM Package Code")));
            Editable = false;
        }
        field(7; "ICM Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }

        field(10; "ICM Source Comp. Record Count"; Integer)
        {
            Caption = 'Source Company Record Count';
            Editable = false;
        }
        field(11; "ICM Target Comp. Record Count"; Integer)
        {
            Caption = 'Target Company Record Count';
            Editable = false;
        }
        field(14; "ICM No. of Fields Available"; Integer)
        {
            CalcFormula = count("ICM Config. Package Field" where("ICM Package Code" = field("ICM Package Code"),
                                                               "ICM Table ID" = field("ICM Table ID")));
            Caption = 'No. of Fields Included';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "ICM No. of Fields Included"; Integer)
        {
            CalcFormula = count("ICM Config. Package Field" where("ICM Package Code" = field("ICM Package Code"),
                                                               "ICM Table ID" = field("ICM Table ID"),
                                                               "ICM Include Field" = const(true)));
            Caption = 'No. of Fields Included';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "ICM Apply Table Fields"; Enum "ICM Apply Table Fields")
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
    }

    keys
    {
        key(Key1; "ICM Package Code", "ICM Table ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        InitPackageFields();
        "ICM Source Comp. Record Count" := UpdateRecordCount("ICM Source Company Name");
        "ICM Target Comp. Record Count" := UpdateRecordCount("ICM Target Company Name");
    end;

    procedure UpdateRecordCount(CompanyNameR: Text[30]): integer
    var
        RecRefL: RecordRef;
        RecordCountL: Integer;
    begin
        Clear(RecordCountL);
        if (CompanyName <> '') and ("ICM Table ID" <> 0) then begin
            RecRefL.Open("ICM Table ID");
            RecRefL.ChangeCompany(CompanyNameR);
            if RecRefL.ReadPermission() then begin
                RecordCountL := RecRefL.Count();
            end;
            RecRefL.Close();
        end;
        exit(RecordCountL);
    end;

    local procedure InitPackageFields()
    var
        FieldL: Record Field;
        ConfigPackageFieldL: Record "ICM Config. Package Field";
        ICMMgtL: Codeunit "ICM Management";
    begin
        ConfigPackageFieldL.Setrange("ICM Package Code", "ICM Package Code");
        ConfigPackageFieldL.Setrange("ICM Table ID", "ICM Table ID");
        ConfigPackageFieldL.DeleteAll();

        FieldL.Reset();
        FieldL.Setrange(TableNo, "ICM Table ID");
        FieldL.SetRange("No.", 1, 1999999999);
        FieldL.SetRange(Class, FieldL.Class::Normal);
        FieldL.SetFilter(ObsoleteState, '<>%1', FieldL.ObsoleteState::Removed);
        if FieldL.FindSet() then
            repeat
                if not ConfigPackageFieldL.Get("ICM Package Code", "ICM Table ID", FieldL."No.") then begin
                    ConfigPackageFieldL.Init;
                    ConfigPackageFieldL."ICM Package Code" := "ICM Package Code";
                    ConfigPackageFieldL."ICM Table ID" := "ICM Table ID";
                    ConfigPackageFieldL."ICM Field ID" := FieldL."No.";
                    ConfigPackageFieldL."ICM Field Caption" := FieldL."Field Caption";
                    ConfigPackageFieldL."ICM Field Name" := FieldL.FieldName;
                    ConfigPackageFieldL."ICM Primary Key" := ICMMgtL.IsKeyField("ICM Table ID", FieldL."No.");
                    if "ICM Apply Table Fields" = "ICM Apply Table Fields"::"All Fields" then
                        ConfigPackageFieldL."ICM Include Field" := true
                    else
                        ConfigPackageFieldL."ICM Include Field" := false;
                    if ConfigPackageFieldL."ICM Primary Key" then
                        ConfigPackageFieldL."ICM Include Field" := true;

                    configPackageFieldL.Insert();
                end;
            until FieldL.Next() = 0;
    end;

    local procedure UpdateTableFields()
    var
        ICMConfigPackageFieldL: Record "ICM Config. Package Field";
    begin
        ICMConfigPackageFieldL.Reset();
        ICMConfigPackageFieldL.Setrange("ICM Package Code", "ICM Package Code");
        ICMConfigPackageFieldL.Setrange("ICM Table ID", "ICM Table ID");
        if ICMConfigPackageFieldL.FindSet() then
            ICMConfigPackageFieldL.ModifyAll("ICM Include Field", true);
    end;
}