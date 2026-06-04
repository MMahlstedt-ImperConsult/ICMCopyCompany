table 50401 "ICM Setup"
{
    Caption = 'ICM Setup';
    DataClassification = ToBeClassified;
    Extensible = true;
    DataPerCompany = false;

    fields
    {
        field(1; "ICM Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            Editable = false;
        }
        field(2; "ICM Table data processing"; Enum "ICM Table Data Processing")
        {
            Caption = 'Table data processing';
        }
    }

    keys
    {
        key(PK; "ICM Primary Key")
        {
            Clustered = true;
        }
    }

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
