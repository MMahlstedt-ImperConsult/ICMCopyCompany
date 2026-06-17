namespace ImperConsult.CopyCompany;

using System.Environment;
using Microsoft.Foundation.Company;

report 50400 "ICM Copy Tables"
{
    ApplicationArea = All;
    Caption = 'Copies records from a source Company to a target Company';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(FromCompany; FromCompanyName)
                    {
                        Caption = 'Source Company';
                        ToolTip = 'The company to copy data from';
                        Editable = false;
                        ApplicationArea = All;
                    }
                    field(ToCompany; ToCompanyName)
                    {
                        Caption = 'Target Company';
                        ToolTip = 'The company to copy data to';
                        TableRelation = Company.Name;
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            ValidateCompanies();
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        ValidateCompanies();
    end;

    local procedure ValidateCompanies()
    begin
        if FromCompanyName = '' then begin
            Error(Text001Err);
        end;

        if ToCompanyName = '' then begin
            Error(Text002Err);
        end;

        if FromCompanyName = ToCompanyName then begin
            Error(Text003Err);
        end;
    end;

    trigger OnInitReport()
    begin
        FromCompanyName := CompanyName();
    end;

    trigger OnPostReport()
    var
        ICMMgt: Codeunit "ICM Data Transfer Management";
    begin
        ICMMgt.CopyTablesFromToCompany(FromCompanyName, ToCompanyName);
    end;

    var
        FromCompanyName: Text[30];
        ToCompanyName: Text[30];
        Text001Err: Label 'The “Source Company” field must be filled.';
        Text002Err: Label 'The “Target Company” field must be filled.';
        Text003Err: Label 'The target company must be different from the source company.';
}
