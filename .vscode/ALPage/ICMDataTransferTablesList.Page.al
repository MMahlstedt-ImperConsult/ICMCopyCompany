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
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Create new Company")
            {
                Caption = 'Create new Company';
                ToolTip = 'Create new Company';
                Image = Open;

                trigger OnAction()
                begin
                    Page.Run(Page::Companies);
                end;
            }

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
            separator(Sep1)
            {
                Caption = '', Locked = true;
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
            separator(Sep2)
            {
                Caption = '', Locked = true;
            }
            action("Copy Tables")
            {
                Caption = 'Copy Tables';
                ToolTip = 'Copy tables from one company to another';
                Image = Copy;

                trigger OnAction()
                begin
                    Report.Run(Report::"ICM Copy Tables");
                end;
            }
            separator(Sep3)
            {
                Caption = '', Locked = true;
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
        }
        area(Navigation)
        {
            action("Configuration Packages")
            {
                Caption = 'Configuration Packages';
                ToolTip = 'Open Configuration Packages List';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Data Transfer Package List");
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
