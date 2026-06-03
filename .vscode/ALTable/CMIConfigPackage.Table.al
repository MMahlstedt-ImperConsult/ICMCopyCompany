table 50402 "CMI Config. Package"
{
    DataClassification = ToBeClassified;
    Caption = 'Configuration Package';
    LookupPageId = "CMI Config. Package List";
    DrillDownPageId = "CMI Config. Package List";
    DataPerCompany = false;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "From Company Name"; Text[30])
        {
            Caption = 'From Company Name';
            TableRelation = Company.Name;
        }
        field(4; "To Company Name"; Text[30])
        {
            Caption = 'To Company Name';
            TableRelation = Company.Name;
            trigger onValidate()
            begin
                if "From Company Name" = "To Company Name" then begin
                    Error(Text001Err);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        if "From Company Name" = '' then
            "From Company Name" := CompanyName();


    end;

    var
        Text001Err: Label 'The target company must be different from the source company.';
}