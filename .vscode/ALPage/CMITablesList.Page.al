namespace DefaultPublisher;

using DefaultPublisher;
using Microsoft.Foundation.Company;

/// <summary>
/// List-Page für Mandanten Tabelleninformationen
/// </summary>
page 50400 "ICM Tables List"
{
    ApplicationArea = All;
    Caption = 'ICM Tables List';
    PageType = List;
    SourceTable = "ICM Table";
    UsageCategory = Lists;
    Editable = true;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
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
                field("Company Name"; Rec."ICM Company Name")
                {
                    ToolTip = 'Specifies the name of the company.';
                    Visible = false;
                }
                field("Data Per Company"; Rec."ICM Data Per Company")
                {
                    ToolTip = 'Specifies if the table has data per company.';
                }
                field("Has Records"; Rec."ICM Has Records")
                {
                    ToolTip = 'Specifies if the table contains records.';
                }
                field("Table Subtype"; Rec."ICM Table Subtype")
                {
                    ToolTip = 'Specifies the subtype of the table.';
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
            action("Set Field Active for Setup Tables")
            {
                Caption = 'Set Field Active for Setup Tables';
                ToolTip = 'Set the Setup Active field for Setup tables entries to true or false';
                Image = CheckList;

                trigger OnAction()
                var
                    ICMTable: Record "ICM Table";
                    ICMMgt: Codeunit "ICM Management";
                    Choice: Integer;
                begin
                    ICMTable.SetFilter("ICM Table Name", '*%1*', 'Setup');
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
        }
    }
    var
        Text001Lbl: Label 'Activated,Deactivated,Cancel';
        Text002Lbl: Label 'Select action:';
}
