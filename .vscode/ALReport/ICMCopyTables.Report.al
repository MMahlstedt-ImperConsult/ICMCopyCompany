namespace DefaultPublisher;

using System.Environment;
using Microsoft.Foundation.Company;

report 50400 "ICM Copy Tables"
{
    ApplicationArea = All;
    Caption = 'Copy Tables to Another Company';
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
                        Caption = 'From Company';
                        ToolTip = 'The company to copy data from';
                        Editable = false;
                        ApplicationArea = All;
                    }
                    field(ToCompany; ToCompanyName)
                    {
                        Caption = 'To Company';
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
        ICMMgt: Codeunit "ICM Management";
    begin
        ICMMgt.CopyTablesFromToCompany(FromCompanyName, ToCompanyName);
    end;

    var
        FromCompanyName: Text[30];
        ToCompanyName: Text[30];
        Text001Err: Label 'The “From Company” field must be filled.';
        Text002Err: Label 'The “To Company” field must be filled.';
        Text003Err: Label 'The target company must be different from the source company.';
}
