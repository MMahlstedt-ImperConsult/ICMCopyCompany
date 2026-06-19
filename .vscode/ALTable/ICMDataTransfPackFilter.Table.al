namespace ImperConsult.CopyCompany;

using System.Reflection;

table 50407 "ICM Data Transf. Pack. Filter"
{
    Caption = 'ICM Data Transfer Package Filter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            TableRelation = "ICM Data Transfer Package";
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
        }
        field(5; "Field ID"; Integer)
        {
            Caption = 'Field ID';

            trigger OnValidate()
            var
                "Field": Record "Field";
                TypeHelper: Codeunit "Type Helper";
            begin
                Field.Get("Table ID", "Field ID");
                TypeHelper.TestFieldIsNotObsolete(Field);
                CalcFields("Field Name", "Field Caption");
            end;
        }
        field(6; "Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table ID"),
                                                        "No." = field("Field ID")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Field Caption"; Text[250])
        {
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table ID"),
                                                              "No." = field("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "Field Filter"; Text[250])
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
        key(Key1; "Package Code", "Table ID", "Field ID")
        {
            Clustered = true;
        }
    }

    local procedure ValidateFieldFilter()
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.Open("Table ID");
        if "Field Filter" <> '' then begin
            FieldRef := RecRef.Field("Field ID");
            FieldRef.SetFilter("Field Filter");
        end;
    end;
}

