namespace ImperConsult.CopyCompany;

using System.Reflection;

table 50407 "ICM Data Transf. Pack. Filter"
{
    Caption = 'ICM Data Transfer Package Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "ICM Package Code"; Code[20])
        {
            Caption = 'Package Code';
            TableRelation = "ICM Data Transfer Package";
        }
        field(2; "ICM Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(5; "ICM Field ID"; Integer)
        {
            Caption = 'Field ID';

            trigger OnValidate()
            var
                "Field": Record "Field";
                TypeHelper: Codeunit "Type Helper";
            begin
                Field.Get("ICM Table ID", "ICM Field ID");
                TypeHelper.TestFieldIsNotObsolete(Field);
                CalcFields("ICM Field Name", "ICM Field Caption");
            end;
        }
        field(6; "ICM Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("ICM Table ID"),
                                                        "No." = field("ICM Field ID")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "ICM Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("ICM Table ID"),
                                                              "No." = field("ICM Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "ICM Field Filter"; Text[250])
        {
            Caption = 'Field Filter';

            trigger OnValidate()
            begin
                ValidateFieldFilter();
            end;
        }
    }

    keys
    {
        key(Key1; "ICM Package Code", "ICM Table ID", "ICM Field ID")
        {
            Clustered = true;
        }
    }

    local procedure ValidateFieldFilter()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.Open("ICM Table ID");
        if "ICM Field Filter" <> '' then begin
            FieldRef := RecRef.Field("ICM Field ID");
            FieldRef.SetFilter("ICM Field Filter");
        end;
    end;
}

