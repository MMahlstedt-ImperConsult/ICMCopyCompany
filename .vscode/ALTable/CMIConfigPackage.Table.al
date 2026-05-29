table 50402 "CMI Config. Package"
{
    DataClassification = ToBeClassified;
    Caption = 'Configuration Package';

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

    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}