namespace DefaultPublisher;

using DefaultPublisher;
using Microsoft.Foundation.Company;

/// <summary>
/// List-Page für Tabelleninformationen
/// </summary>
page 50400 "ICM Tables List"
{
    ApplicationArea = All;
    Caption = 'Tables List';
    PageType = Worksheet;
    SourceTable = "ICM Table";
    UsageCategory = Tasks;
    AutosplitKey = true;
    delayedinsert = true;
    savevalues = true;


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
                field("Included in the License"; Rec."ICM Included in the License")
                {
                    ToolTip = 'Specifies if the table is included in the license.';
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
            action("Update tables")
            {
                Caption = 'Update tables';
                ToolTip = 'Fills the table with data from the current Company';
                Image = Refresh;

                trigger OnAction()
                var
                    ICMMgt: Codeunit "ICM Management";
                begin
                    ICMMgt.FillCompanyTableInformation();
                    CurrPage.Update(false);
                end;
            }
            action("Set Field Active")
            {
                Caption = 'Set Field Active';
                ToolTip = 'Set the Active field to true or false';
                Image = CheckList;

                trigger OnAction()
                var
                    ICMTable: Record "ICM Table";
                    ICMMgt: Codeunit "ICM Management";
                    Choice: Integer;
                begin
                    ICMTable.CopyFilters(Rec);
                    Choice := StrMenu(Text001Lbl, 1, Text002Lbl);
                    case Choice of
                        1:
                            ICMMgt.SetActiveStatus(ICMTable, true);
                        2:
                            ICMMgt.SetActiveStatus(ICMTable, false);
                        3:
                            exit;
                    end;
                    CurrPage.Update(false);
                end;
            }
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
            action("Apply configuration package")
            {
                Caption = 'Apply configuration package';
                ToolTip = 'Apply configuration package to fill tables';
                Image = Setup;

                trigger OnAction()
                var
                    CMIConfigPackageListL: Page "ICM Config. Package List";
                    SelectedPackageCodeL: Code[20];
                begin
                    if CMIConfigPackageListL.RunModal() = Action::OK then begin
                        SelectedPackageCodeL := CMIConfigPackageListL.GetSelectedPackage();
                        if SelectedPackageCodeL <> '' then
                            ICMMgt.ApplyConfigurationPackage(SelectedPackageCodeL, Rec);
                        ShowActive := true;
                        Rec.Reset();
                        Rec.SetRange("ICM Active", ShowActive);
                        CurrPage.Update(false);
                    end;
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
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action("ICM Setup")
            {
                Caption = 'ICM Setup';
                ToolTip = 'Open ICM Setup';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Setup");
                end;
            }
            action("Configuration Packages")
            {
                Caption = 'Configuration Packages';
                ToolTip = 'Open Configuration Packages List';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"ICM Config. Package List");
                end;
            }
        }
    }
    var
        ShowActive: Boolean;
        ICMMgt: Codeunit "ICM Management";
        CompanyName: Text[30];
        Text001Lbl: Label 'Activated,Deactivated,Cancel';
        Text002Lbl: Label 'Select action:';
}
