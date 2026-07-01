namespace ImperConsult.CopyCompany;

using System.Reflection;
using System.IO;

table 50403 "ICM Data Transfer Package Line"
{
    DataClassification = ToBeClassified;
    Caption = 'Data Transfer Package Line';
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
                if ("ICM Table ID" <> 0) or (xRec."ICM Table ID" <> "ICM Table ID") then begin
                    InitPackageFields();
                    "ICM Page ID" := ConfigMgt.FindPage("ICM Table ID");

                    CalcFields("ICM Source Company Name", "ICM Target Company Name");
                    "ICM Source Comp. Record Count" := UpdateRecordCount("ICM Source Company Name");
                    "ICM Target Comp. Record Count" := UpdateRecordCount("ICM Target Company Name");
                end;
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
            CalcFormula = Lookup("ICM Data Transfer Package"."ICM Source Company Name" where("ICM Code" = field("ICM Package Code")));
            Editable = false;
        }
        field(6; "ICM Target Company Name"; Text[30])
        {
            Caption = 'Target Company Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("ICM Data Transfer Package"."ICM Target Company Name" where("ICM Code" = field("ICM Package Code")));
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
            CalcFormula = count("ICM Data Transf. Package Field" where("ICM Package Code" = field("ICM Package Code"),
                                                               "ICM Table ID" = field("ICM Table ID")));
            Caption = 'No. of Fields Included';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "ICM No. of Fields Included"; Integer)
        {
            CalcFormula = count("ICM Data Transf. Package Field" where("ICM Package Code" = field("ICM Package Code"),
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
        field(17; "ICM Page ID"; Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));

            trigger OnLookup()
            var
                ConfigValidateMgt: Codeunit "Config. Validate Management";
            begin
                ConfigValidateMgt.LookupPage("ICM Page ID");
                Validate("ICM Page ID");
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
        if "ICM Table ID" <> 0 then begin
            "ICM Source Comp. Record Count" := UpdateRecordCount("ICM Source Company Name");
            "ICM Target Comp. Record Count" := UpdateRecordCount("ICM Target Company Name");
        end;
    end;

    trigger OnModify()
    begin
        if "ICM Table ID" <> 0 then begin
            "ICM Source Comp. Record Count" := UpdateRecordCount("ICM Source Company Name");
            "ICM Target Comp. Record Count" := UpdateRecordCount("ICM Target Company Name");
        end;
    end;

    procedure UpdateRecordCount(CompanyNameR: Text[30]): integer
    var
        RecRefL: RecordRef;
        RecordCountL: Integer;
    begin
        Clear(RecordCountL);
        if (CompanyNameR <> '') and ("ICM Table ID" <> 0) then begin
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
        ConfigPackageFieldL: Record "ICM Data Transf. Package Field";
        ICMMgtL: Codeunit "ICM Data Transfer Management";
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
        ICMConfigPackageFieldL: Record "ICM Data Transf. Package Field";
    begin
        ICMConfigPackageFieldL.Reset();
        ICMConfigPackageFieldL.Setrange("ICM Package Code", "ICM Package Code");
        ICMConfigPackageFieldL.Setrange("ICM Table ID", "ICM Table ID");
        if ICMConfigPackageFieldL.FindSet() then
            ICMConfigPackageFieldL.ModifyAll("ICM Include Field", true);
    end;

    procedure ShowFilters()
    var
        ICMDataTransfPackFilter: Record "ICM Data Transf. Pack. Filter";
        ConfigPackageFilters: Page "ICM Data Transf. Pack. Filters";
    begin

        ICMDataTransfPackFilter.FilterGroup(2);
        ICMDataTransfPackFilter.SetRange("ICM Package Code", "ICM Package Code");
        ICMDataTransfPackFilter.SetRange("ICM Table ID", "ICM Table ID");
        ICMDataTransfPackFilter.FilterGroup(0);
        ConfigPackageFilters.SetTableView(ICMDataTransfPackFilter);
        ConfigPackageFilters.RunModal();
        Clear(ConfigPackageFilters);
    end;

    procedure ShowDatabaseRecords()
    begin
        if "ICM Page ID" <> 0 then
            PAGE.Run("ICM Page ID")
        else
            Error(DefineDrillDownPageMsg, FieldCaption("ICM Page ID"));
    end;

    procedure ShowFilteredDatabaseRecords()
    var
        DataTransPackLineL: Record "ICM Data Transfer Package Line";
        DataTransfPackFilterL: Record "ICM Data Transf. Pack. Filter";
        ConfigValidateMgtL: Codeunit "Config. Validate Management";
        RecRefL: RecordRef;
        FieldRefL: FieldRef;
        FilterTextL: Text;
    begin
        DataTransfPackFilterL.Reset();

        RecRefL.Open("ICM Table ID");

        DataTransfPackFilterL.Reset();
        DataTransfPackFilterL.SetRange("ICM Package Code", "ICM Package Code");
        DataTransfPackFilterL.SetRange("ICM Table ID", "ICM Table ID");
        if DataTransfPackFilterL.FindSet() then begin
            repeat
                FieldRefL := RecRefL.Field(DataTransfPackFilterL."ICM Field ID");
                FilterTextL += FieldRefL.Name + ': ' + DataTransfPackFilterL."ICM Field Filter" + ' ,';
            until DataTransfPackFilterL.Next = 0;
        end;

        RecRefL.SetView(FilterTextL);
        Message(FilterTextL);
        if "ICM Page ID" <> 0 then
            PAGE.Run("ICM Page ID")
        else
            Error(DefineDrillDownPageMsg, FieldCaption("ICM Page ID"));
    end;

    var
        ConfigMgt: Codeunit "Config. Management";
        DefineDrillDownPageMsg: Label 'Define the drill-down page in the %1 field.';
}