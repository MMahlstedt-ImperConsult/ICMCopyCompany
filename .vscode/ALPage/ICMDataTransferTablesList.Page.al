namespace ImperConsult.CopyCompany;

using Microsoft.Foundation.Company;

/// <summary>
/// List-Page für Tabelleninformationen
/// </summary>
page 50400 "ICM Data Transfer Tables List"
{
    ApplicationArea = All;
    Caption = 'Tables List';
    PageType = Worksheet;
    SourceTable = "ICM Data Transfer Table";
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(Content)
        {
            group(Group)
            {
                Caption = 'General';

                field("Company"; CompanyName)
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    Lookup = true;
                    ToolTip = 'Specifies the name of a the company.';

                    trigger OnLookup(var Text: Text): boolean
                    begin
                        CurrPage.SaveRecord();
                        ICMMgt.LookupCompanyName(CompanyName, Rec);
                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        if CompanyName = '' then begin
                            Rec.FilterGroup := 2;
                            Rec.SetRange("ICM Company Name");
                            Rec.FilterGroup := 0;

                            CurrPage.Update(false);
                            exit;
                        end;

                        CurrPage.SaveRecord();
                        ICMMgt.LookupCompanyName(CompanyName, Rec);
                        ICMMgt.FillCompanyTableInformation();
                        CurrPage.Update(false);
                    end;
                }

            }
            repeater(General)
            {
                field("Company Name"; Rec."ICM Company Name")
                {
                    ToolTip = 'Specifies the name of the company.';
                    Visible = true;
                }
                field(ID; Rec."ICM Table ID")
                {
                    ToolTip = 'Specifies the unique identifier of the table.';
                }
                field(Name; Rec."ICM Table Name")
                {
                    ToolTip = 'Specifies the name of the table.';
                    Visible = false;
                }
                field("Table Caption"; Rec."ICM Table Caption")
                {
                    ToolTip = 'Specifies the caption of the table.';
                }
                field("Data Per Company"; Rec."ICM Data Per Company")
                {
                    ToolTip = 'Specifies if the table has data per company.';
                    Visible = false;
                }
                field("Has Records"; Rec."ICM Has Records")
                {
                    ToolTip = 'Specifies if the table contains records.';
                }
                field("Table Subtype"; Rec."ICM Table Subtype")
                {
                    ToolTip = 'Specifies the subtype of the table.';
                    Visible = false;
                }
                field("ICM Apply Table Fields"; Rec."ICM Apply Table Fields")
                {
                    ToolTip = 'Specifies the subtype of the table.';
                }
                field("No. of Fields Available"; Rec."ICM No. of Fields Available")
                {
                    ToolTip = 'Specifies the number of fields available for migration.';
                }
                field("No. of Fields Included"; Rec."ICM No. of Fields Included")
                {
                    ToolTip = 'Specifies the number of fields included for migration.';
                }
                field("Included in the License"; Rec."ICM Included in the License")
                {
                    ToolTip = 'Specifies if the table is included in the license.';
                    Visible = false;
                }
                field("Record Count"; Rec."ICM Record Count")
                {
                    ToolTip = 'Specifies the number of records in the table.';
                }
                field("Active"; Rec."ICM Active")
                {
                    ToolTip = 'Specifies if the table information is active.';
                }
                field("ICM Records transferred"; Rec."ICM Records transferred")
                {
                    ToolTip = 'Specifies if the Records has been transferred.';
                }
                field("ICM Page ID"; Rec."ICM Page ID")
                {
                    ToolTip = 'Specifies the Page ID for the table';
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Update tables")
            {
                Caption = 'Update tables';
                ToolTip = 'Fill the page with information about all available tables and update any changed data';
                Image = Refresh;

                trigger OnAction()
                var
                    ICMMgt: Codeunit "ICM Data Transfer Management";
                begin
                    ICMMgt.FillCompanyTableInformation();
                    CurrPage.Update(false);
                end;
            }
            action("Set Field Active")
            {
                Caption = 'Set Field Active to true or false';
                ToolTip = 'Set the Active field for selected rows or all filtered rows';
                Image = CheckList;

                trigger OnAction()
                var
                    ICMTableL: Record "ICM Data Transfer Table";
                    ICMMgtL: Codeunit "ICM Data Transfer Management";
                    ChoiceL: Integer;
                    SelectedCountL: Integer;
                begin
                    CurrPage.SetSelectionFilter(ICMTableL);
                    SelectedCountL := ICMTableL.Count();

                    ICMTableL.CopyFilters(Rec);

                    ChoiceL := StrMenu(Text001Lbl, 1, Text002Lbl);
                    case ChoiceL of
                        1:
                            ICMMgtL.SetActiveStatus(ICMTableL, true);
                        2:
                            ICMMgtL.SetActiveStatus(ICMTableL, false);
                        3:
                            exit;
                    end;
                    CurrPage.Update(false);
                end;
            }
            action("Transfer Data")
            {
                Caption = 'Transfer Data Between Companies';
                ToolTip = 'Transfer data between clients for all tables where the “Active” field has been checked';
                Image = Copy;

                trigger OnAction()
                begin
                    Report.Run(Report::"ICM Copy Company");
                end;
            }
            action("Toggle Active Tables Visibility")
            {
                Caption = 'Toggle Active Tables Visibility';
                ToolTip = 'Filter to show active tables';
                Image = Filter;

                trigger OnAction()
                begin
                    ShowActive := not ShowActive;
                    Rec.SetRange("ICM Active", ShowActive);
                    if CompanyName <> '' then
                        Rec.SetRange("ICM Company Name", CompanyName);
                    CurrPage.Update(false);
                end;
            }
            action("Test")
            {
                Caption = 'Test';
                ToolTip = 'Test';
                Image = Refresh;

                trigger OnAction()
                var
                    ICMMgt: Codeunit "ICM Data Transfer Management";
                begin
                    ICMMgt.TestDeleteData('My Company');
                end;
            }
        }
        area(Navigation)
        {
            action("Data Transfer Packages")
            {
                Caption = 'Data Transfer Packages';
                ToolTip = 'Open Data Transfer Packages List';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Data Transfer Package List");
                end;
            }
            action(PackageFields)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Fields';
                Image = CheckList;
                ToolTip = 'View the fields that are used in the Data Transfer Process.';

                trigger OnAction()
                var
                    DataTransferTableFieldsL: Record "ICM Data Transfer Table Field";
                begin
                    DataTransferTableFieldsL.Reset();
                    DataTransferTableFieldsL.SetRange("ICM Company Name", Rec."ICM Company Name");
                    DataTransferTableFieldsL.SetRange("ICM Table ID", Rec."ICM Table ID");

                    Page.Run(Page::"ICM Data Transfer Table Fields", DataTransferTableFieldsL);
                end;
            }
            action("Transfer Data Log")
            {
                Caption = 'Transfer Data Log';
                ToolTip = 'Open Transfer Data Log List';
                Image = Log;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Transfer Data Log List");
                end;
            }
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

    var
        ShowActive: Boolean;
        ICMMgt: Codeunit "ICM Data Transfer Management";
        CompanyName: Text[30];
        Text001Lbl: Label 'Activated,Deactivated,Cancel';
        Text002Lbl: Label 'Select action:';
}
