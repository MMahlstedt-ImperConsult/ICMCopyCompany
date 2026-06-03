table 50403 "CMI Config. Package Line"
{
    DataClassification = ToBeClassified;
    Caption = 'Configuration Package Line';
    DataPerCompany = false;

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
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table),
                                                                "Object Subtype" = const('Normal'));
        }
        field(3; "Table Name"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table),
                                                                        "Object ID" = field("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Table Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table),
                                                                        "Object ID" = field("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "From Company Name"; Text[30])
        {
            Caption = 'From Company Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("CMI Config. Package"."From Company Name" where(Code = field("Package Code")));
            Editable = false;
        }
        field(6; "To Company Name"; Text[30])
        {
            Caption = 'To Company Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("CMI Config. Package"."To Company Name" where(Code = field("Package Code")));
            Editable = false;
        }
        field(7; "ICM Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(10; "ICM Source Company Has Records"; Boolean)
        {
            Caption = 'Source Company Has Records';
            Editable = false;
        }
        field(11; "ICM Source Comp. Record Count"; Integer)
        {
            Caption = 'Source Company Record Count';
            Editable = false;
        }
        field(12; "ICM Target Company Has Records"; Boolean)
        {
            Caption = 'Target Company Has Records';
            Editable = false;
        }
        field(13; "ICM Target Comp. Record Count"; Integer)
        {
            Caption = 'Target Company Record Count';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Package Code", "Table ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ConfigPackageL: Record "CMI Config. Package";
        RecRefL: RecordRef;
        RecordCountL: Integer;
    begin
        if ConfigPackageL.Get("Package Code") then begin
            if (ConfigPackageL."From Company Name" <> '') then begin
                RecRefL.Open("Table ID");
                RecRefL.ChangeCompany(ConfigPackageL."From Company Name");
                if RecRefL.ReadPermission() then begin
                    RecordCountL := RecRefL.Count();
                    "ICM Source Company Has Records" := RecordCountL > 0;
                    "ICM Source Comp. Record Count" := RecordCountL;
                end;
            end;

            if (ConfigPackageL."To Company Name" <> '') then begin
                RecRefL.Open("Table ID");
                RecRefL.ChangeCompany(ConfigPackageL."To Company Name");
                if RecRefL.ReadPermission() then begin
                    RecordCountL := RecRefL.Count();
                    "ICM Target Company Has Records" := RecordCountL > 0;
                    "ICM Target Comp. Record Count" := RecordCountL;
                end;
            end;
            RecRefL.Close();
        end;

    end;
    //end;
}