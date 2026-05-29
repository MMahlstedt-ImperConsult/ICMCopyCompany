table 50403 "CMI Config. Package Line"
{
    DataClassification = ToBeClassified;
    Caption = 'Configuration Package Table';

    fields
    {
        field(1; "Package Code"; Code[20])
        {
            Caption = 'Package Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = ToBeClassified;
        }
        field(3; "Table Name"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table),
                                                                        "Object ID" = field("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Package Code", "Table ID")
        {
            Clustered = true;
        }
    }

}