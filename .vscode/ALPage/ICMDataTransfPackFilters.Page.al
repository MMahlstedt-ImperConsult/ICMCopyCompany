namespace ImperConsult.CopyCompany;

using System.Reflection;

page 50408 "ICM Data Transf. Pack. Filters"
{
    Caption = 'Data Transfer Package Filters';
    PageType = List;
    SourceTable = "ICM Data Transf. Pack. Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field ID"; Rec."ICM Field ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the field on which you want to filter records in the data transfer table.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        "Field": Record "Field";
                        ICMMgt: Codeunit "ICM Data Transfer Management";
                        FieldSelection: Codeunit "Field Selection";
                    begin
                        ICMMgt.SetFieldFilter(Field, Rec."ICM Table ID", 0);
                        if FieldSelection.Open(Field) then begin
                            Rec.Validate("ICM Field ID", Field."No.");
                            CurrPage.Update(true);
                        end;
                    end;
                }
                field("Field Name"; Rec."ICM Field Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the field on which you want to filter records in the data transfer table.';
                }
                field("Field Caption"; Rec."ICM Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the field caption of the field on which you want to filter records in the data transfer table.';
                }
                field("Field Filter"; Rec."ICM Field Filter")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the field filter value for a data transfer package filter. By setting a value, you specify that only records with that value are included in the data transfer package.';
                }
            }
        }
    }
}
