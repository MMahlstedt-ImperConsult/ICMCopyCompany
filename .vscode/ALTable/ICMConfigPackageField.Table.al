table 50404 "ICM Config. Package Field"
{
    DataClassification = ToBeClassified;
    LookupPageId = "ICM Config. Package Fields";

    fields
    {
        field(1; "ICM Package Code"; Code[20])
        {
            Caption = 'Package Code';
            NotBlank = true;
            TableRelation = "Config. Package";
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

            /*            trigger OnValidate()
                        begin
                            ValidateFieldIDTableRelation();
                        end; */
        }
        field(4; "ICM Field Name"; Text[30])
        {
            Caption = 'Field Name';

            /*    trigger OnValidate()
                begin
                    "XML Field Name" := GetUniqueElementName("Field Name");
                end; */
        }
        field(5; "ICM Field Caption"; Text[250])
        {
            Caption = 'Field Caption';
        }
        /*field(6; "Validate Field"; Boolean)
        {
            Caption = 'Validate Field';
            
            trigger OnValidate()
            var
                ShouldRunCheck: Boolean;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateValidateField(Rec, IsHandled);
                if IsHandled then
                    exit;

                ShouldRunCheck := not Dimension;
                OnValidateFieldOnValidateOnAfterCalcShouldRunCheck(Rec, ShouldRunCheck);
                if ShouldRunCheck then begin
                    if "Validate Field" then
                        ThrowErrorIfFieldRemoved();
                    UpdateFieldErrors();
                end;
            end; 
        } */
        field(7; "ICM Include Field"; Boolean)
        {
            Caption = 'Include Field';
            /*
            trigger OnValidate()
            var
                ShouldRunCheck: Boolean;
                IsHandled: Boolean;
            begin
                IsHandled := false;
                OnBeforeValidateIncludeField(Rec, IsHandled);
                if IsHandled then
                    exit;
                ShouldRunCheck := not Dimension;
                OnIncludeFieldOnValidateOnAfterCalcShouldRunCheck(Rec, ShouldRunCheck);
                if ShouldRunCheck then begin
                    if xRec."Include Field" and not "Include Field" and "Primary Key" then
                        Error(PrimaryKeyRequiredErr, "Field Caption");
                    if "Include Field" then
                        ThrowErrorIfFieldRemoved();
                    "Validate Field" := "Include Field";
                    UpdateFieldErrors();
                end;
            end; */
        }
        field(8; "ICM Primary Key"; Boolean)
        {
            Caption = 'Primary Key';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "ICM Package Code", "ICM Table ID", "ICM Field ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}