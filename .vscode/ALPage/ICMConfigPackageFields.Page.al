page 50405 "ICM Config. Package Fields"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CMI Config. Package Field";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Package Code"; Rec."ICM Package Code")
                {
                    ApplicationArea = All;
                    Caption = 'Package Code';
                    ToolTip = 'Specifies the Package Code.';
                    Visible = false;
                }
                field("ICM Table ID"; Rec."ICM Table ID")
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                    ToolTip = 'Specifies the Table ID.';
                    Visible = false;
                }
                field("ICM Field ID"; Rec."ICM Field ID")
                {
                    Caption = 'Field ID';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the ID of the field for the table';
                }
                field("ICM Field Name"; Rec."ICM Field Name")
                {
                    Caption = 'Field Name';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Name of the field';
                }
                field("ICM Include Field"; Rec."ICM Include Field")
                {
                    Caption = 'Include Field';
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the field is included in the migration';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }
}