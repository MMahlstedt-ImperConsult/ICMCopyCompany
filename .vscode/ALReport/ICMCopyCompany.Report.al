namespace ImperConsult.CopyCompany;

using System.Environment;
using Microsoft.Foundation.Company;

report 50400 "ICM Copy Company"
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
                    field(FromCompany; SourceCompanyName)
                    {
                        Caption = 'Source Company';
                        ToolTip = 'The company to copy data from';
                        Editable = false;
                        ApplicationArea = All;
                    }
                    field(ToCompany; TargetCompanyName)
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
        if SourceCompanyName = '' then begin
            Error(Text001Err);
        end;

        if TargetCompanyName = '' then begin
            Error(Text002Err);
        end;

        if SourceCompanyName = TargetCompanyName then begin
            Error(Text003Err);
        end;
    end;

    trigger OnInitReport()
    begin
        SourceCompanyName := CompanyName();
    end;

    trigger OnPostReport()
    var
        ICMMgt: Codeunit "ICM Data Transfer Management";
    begin
        ICMMgt.CopyToCompanyFromDataTransferTables(SourceCompanyName, TargetCompanyName);
        TransferDataLogList.Run();
    end;

    var
        TransferDataLogList: Page "ICM Transfer Data Log List";
        SourceCompanyName: Text[30];
        TargetCompanyName: Text[30];
        Text001Err: Label 'The “Source Company” field must be filled.';
        Text002Err: Label 'The “Target Company” field must be filled.';
        Text003Err: Label 'The target company must be different from the source company.';
}
