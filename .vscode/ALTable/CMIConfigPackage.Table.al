table 50402 "CMI Config. Package"
{
    DataClassification = ToBeClassified;
    Caption = 'Configuration Package';
    LookupPageId = "CMI Config. Package List";
    DrillDownPageId = "CMI Config. Package List";
    DataPerCompany = false;

    fields
    {
        field(1; "ICM Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "ICM Description"; Text[50])
        {
            Caption = 'Description';
        }
        field(3; "ICM Source Company Name"; Text[30])
        {
            Caption = 'Source Company Name';
            TableRelation = Company.Name;
            trigger onValidate()
            begin
                if "ICM Source Company Name" = "ICM Target Company Name" then begin
                    Error(Text001Err);
                end;
                if xRec."ICM Source Company Name" <> "ICM Source Company Name" then
                    ICMMgt.UpdateConfigPackageLines("ICM Code");
            end;
        }
        field(4; "ICM Target Company Name"; Text[30])
        {
            Caption = 'Target Company Name';
            TableRelation = Company.Name;
            trigger onValidate()
            begin
                if "ICM Source Company Name" = "ICM Target Company Name" then begin
                    Error(Text001Err);
                end;
                if xRec."ICM Target Company Name" <> "ICM Target Company Name" then
                    ICMMgt.UpdateConfigPackageLines("ICM Code");
            end;
        }
        field(5; "No. of Tables"; Integer)
        {
            CalcFormula = count("CMI Config. Package Line" where("ICM Package Code" = field("ICM Code")));
            Caption = 'No. of Tables';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "ICM Code")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        if "ICM Source Company Name" = '' then
            "ICM Source Company Name" := CompanyName();

        ICMMgt.UpdateConfigPackageLines("ICM Code");
    end;

    var
        ICMMgt: Codeunit "ICM Management";
        Text001Err: Label 'The target company must be different from the source company.';
}