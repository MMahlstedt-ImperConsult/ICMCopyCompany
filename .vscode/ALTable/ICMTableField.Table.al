namespace ImperConsult.CopyCompany;

using System.Reflection;

table 50405 "ICM Table Field"
{
    DataClassification = ToBeClassified;
    LookupPageId = "ICM Table Fields";
    DrilldownPageId = "ICM Table Fields";
    DataPerCompany = false;

    fields
    {
        field(1; "ICM Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(2; "ICM Company Name"; Text[30])
        {
            Caption = 'Company Name';
            Editable = false;
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
            CalcFormula = lookup("ICM Table"."ICM Apply Table Fields" where("ICM Table ID" = field("ICM Table ID"),
                                                                            "ICM Company Name" = field("ICM Company Name")));
            Caption = 'Apply Table Fields';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "ICM Table ID", "ICM Company Name", "ICM Field ID")
        {
            Clustered = true;
        }
    }
}