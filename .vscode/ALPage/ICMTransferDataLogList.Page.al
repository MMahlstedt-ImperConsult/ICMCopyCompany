namespace ImperConsult.CopyCompany;

using Microsoft.Foundation.Company;

/// <summary>
/// List-Page für Transfer Data Log
/// </summary>
page 50407 "ICM Transfer Data Log List"
{
    ApplicationArea = All;
    Caption = 'Transfer Data Log';
    PageType = List;
    SourceTable = "ICM Transfer Data Log";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."ICM Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies the entry number.';
                }
                field("Table No."; Rec."ICM Table No.")
                {
                    ApplicationArea = All;
                    Caption = 'Table No.';//'Tabellenr';
                    ToolTip = 'Specifies the table number.';
                }
                field("Table Caption"; Rec."ICM Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Table Caption';//'Tabellenbeschriftung';
                    ToolTip = 'Specifies the table caption.';
                }
                field("Records Available"; Rec."ICM Records Available")
                {
                    ApplicationArea = All;
                    Caption = 'Records Available';//'Datensätze vorhanden';
                    ToolTip = 'Specifies the number of records available in the source table.';
                }
                field("Records Transferred"; Rec."ICM Records Transferred")
                {
                    ApplicationArea = All;
                    Caption = 'Records Transferred';//'Datensätze übertragen';
                    ToolTip = 'Specifies the number of records transferred.';
                }
                field("Records Skipped"; Rec."ICM Records Skipped")
                {
                    ApplicationArea = All;
                    Caption = 'Records Skipped';//'Datensätze übertragen';
                    ToolTip = 'Specifies the number of records Skipped.';
                }
                field("Source Company"; Rec."ICM Source Company")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company';//'Quellmandant';
                    ToolTip = 'Specifies the source company.';
                }
                field("Target Company"; Rec."ICM Target Company")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company';//'Zielmandant';
                    ToolTip = 'Specifies the Target company.';
                }
                field("Transferred Date"; Rec."ICM Transferred Date")
                {
                    ApplicationArea = All;
                    Caption = 'Transferred Date';//'Übertragen am';
                    ToolTip = 'Specifies the date and time when the records were transferred.';
                }
                field("Transferred By"; Rec."ICM Transferred By")
                {
                    ApplicationArea = All;
                    Caption = 'Transferred By';//'Übertragen von';
                    ToolTip = 'Specifies the user who transferred the records.';
                }
                field("Filter Exists"; Rec."ICM Filter Exists")
                {
                    ApplicationArea = All;
                    Caption = 'Filter Exists';//'Filter vorhanden';
                    ToolTip = 'Specifies if a filter was applied during the transfer.';
                }
            }
        }
        area(Factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }


}
