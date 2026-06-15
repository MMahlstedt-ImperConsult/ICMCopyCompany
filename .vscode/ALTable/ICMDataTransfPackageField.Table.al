namespace ImperConsult.CopyCompany;

using System.Reflection;

table 50404 "ICM Data Transf. Package Field"
{
    DataClassification = ToBeClassified;
    LookupPageId = "ICM Config. Package Fields";
    DrilldownPageId = "ICM Config. Package Fields";
    DataPerCompany = false;
    Caption = 'Data Transfer Package Field';

    fields
    {
        field(1; "ICM Package Code"; Code[20])
        {
            Caption = 'Package Code';
            NotBlank = true;
            TableRelation = "ICM Data Transfer Package";
        }
        field(2; "ICM Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(3; "ICM Field ID"; Integer)
        {
            Caption = 'Field ID';
            NotBlank = true;
            TableRelation = Field."No." where(TableNo = field("ICM Table ID"));
            ValidateTableRelation = false;
        }
        field(4; "ICM Field Name"; Text[30])
        {
            Caption = 'Field Name';
        }
        field(5; "ICM Field Caption"; Text[250])
        {
            Caption = 'Field Caption';
        }
        field(7; "ICM Include Field"; Boolean)
        {
            Caption = 'Include Field';
            trigger OnValidate()
            begin
                if "ICM Include Field" = false then
                    TestField("ICM Primary Key", false);
            end;
        }
        field(8; "ICM Primary Key"; Boolean)
        {
            Caption = 'Primary Key';
            Editable = false;
        }
        field(9; "ICM Apply Table Fields"; Enum "ICM Apply Table Fields")
        {
            CalcFormula = lookup("ICM Data Transfer Package Line"."ICM Apply Table Fields" where("ICM Package Code" = field("ICM Package Code"),
                                                                                           "ICM Table ID" = field("ICM Table ID")));
            Caption = 'Apply Table Fields';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "ICM Package Code", "ICM Table ID", "ICM Field ID")
        {
            Clustered = true;
        }
    }

}