namespace DefaultPublisher;

table 50400 "ICM Table"
{
    DataPerCompany = false;
    Caption = 'Company Table Information';

    fields
    {
        field(1; "ICM Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
        }
        field(2; "ICM Table Name"; Text[249])
        {
            Caption = 'Table Name';
            Editable = false;
        }
        field(3; "ICM Company Name"; Text[30])
        {
            Caption = 'Company Name';
            Editable = false;
        }
        field(4; "ICM Data Per Company"; Boolean)
        {
            Caption = 'Data Per Company';
            Editable = false;
        }
        field(5; "ICM Has Records"; Boolean)
        {
            Caption = 'Has Records';
            Editable = false;
        }
        field(6; "ICM Record Count"; Integer)
        {
            Caption = 'Record Count';
            Editable = false;
        }
        field(7; "ICM Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "ICM Included in the License" = false then
                    Error(Text001Lbl);

                if "ICM Table Subtype" <> 'Normal' then
                    Error(Text002Lbl);
            end;
        }
        field(8; "ICM Table Caption"; Text[249])
        {
            Caption = 'Table Caption';
            Editable = false;
        }
        field(9; "ICM Table Subtype"; Text[30])
        {
            Caption = 'Table Subtype';
            Editable = false;
        }
        field(10; "ICM Included in the License"; boolean)
        {
            Caption = 'Included in the License';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "ICM Company Name", "ICM Table ID")
        {
            Clustered = true;
        }
        key(NK1; "ICM Table Name")
        {
        }
    }
    var
        Text001Lbl: Label 'This table is not included in the license. Active status cannot be set to true.';
        Text002Lbl: Label 'Only tables with subtype "Normal" can be set to active.';
}
