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
                field("ICM Entry No."; Rec."ICM Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies the entry number.';
                }
                field("ICM Table No."; Rec."ICM Table No.")
                {
                    ApplicationArea = All;
                    Caption = 'Table No.';//'Tabellenr';
                    ToolTip = 'Specifies the table number.';
                }
                field("ICM Table Caption"; Rec."ICM Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Table Caption';//'Tabellenbeschriftung';
                    ToolTip = 'Specifies the table caption.';
                }
                field("ICM Records Available"; Rec."ICM Records Available")
                {
                    ApplicationArea = All;
                    Caption = 'Records Available';//'Datensätze vorhanden';
                    ToolTip = 'Specifies the number of records available in the source table.';
                }
                field("ICM Records Transferred"; Rec."ICM Records Transferred")
                {
                    ApplicationArea = All;
                    Caption = 'Records Transferred';//'Datensätze übertragen';
                    ToolTip = 'Specifies the number of records transferred.';
                }
                field("ICM Records Skipped"; Rec."ICM Records Skipped")
                {
                    ApplicationArea = All;
                    Caption = 'Records Skipped';//'Datensätze übertragen';
                    ToolTip = 'Specifies the number of records Skipped.';
                }
                field("ICM Source Company"; Rec."ICM Source Company")
                {
                    ApplicationArea = All;
                    Caption = 'Source Company';//'Quellmandant';
                    ToolTip = 'Specifies the source company.';
                }
                field("ICM Target Company"; Rec."ICM Target Company")
                {
                    ApplicationArea = All;
                    Caption = 'Target Company';//'Zielmandant';
                    ToolTip = 'Specifies the Target company.';
                }
                field("ICM Transferred Date"; Rec."ICM Transferred Date")
                {
                    ApplicationArea = All;
                    Caption = 'Transferred Date';//'Übertragen am';
                    ToolTip = 'Specifies the date and time when the records were transferred.';
                }
                field("ICM Transferred By"; Rec."ICM Transferred By")
                {
                    ApplicationArea = All;
                    Caption = 'Transferred By';//'Übertragen von';
                    ToolTip = 'Specifies the user who transferred the records.';
                }
                field("ICM Filter Exists"; Rec."ICM Filter Exists")
                {
                    ApplicationArea = All;
                    Caption = 'Filter Exists';//'Filter vorhanden';
                    ToolTip = 'Specifies if a filter was applied during the transfer.';
                    Visible = false;
                }
                field("ICM Package Code"; Rec."ICM Package Code")
                {
                    ApplicationArea = All;
                    Caption = 'Package Code';
                    ToolTip = 'Specifies Package Code if was applied during the transfer.';
                }
                field("ICM Filter Text"; Rec."ICM Filter Text")
                {
                    ApplicationArea = All;
                    Caption = 'Filter';
                    ToolTip = 'Specifies Filter if was applied during the transfer.';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(DatabaseRecords)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Database Data';
                Image = Database;
                ToolTip = 'View the data that has been applied to the database.';

                trigger OnAction()
                begin
                    Rec.ShowDatabaseRecords();
                end;
            }
        }
    }
}
