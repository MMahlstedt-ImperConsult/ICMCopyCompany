namespace ImperConsult.CopyCompany;

using System.Environment;

report 50401 "ICM Copy Config Package"
{
    ApplicationArea = All;
    Caption = 'Copy - Configuration Package';
    ProcessingOnly = true;

    dataset
    {
        dataitem("ICM Config. Package"; "ICM Config. Package")
        {
            DataItemTableView = sorting("ICM Code");

            trigger OnAfterGetRecord()
            begin
                ICMConfigPackage.Init();
                ICMConfigPackage.TransferFields(UseICMConfigPackage);
                ICMConfigPackage."ICM Code" := NewPackageCode;
                ICMConfigPackage.Insert();

                ICMConfigPackageLines.SetRange("ICM Package Code", "ICM Code");
                if ICMConfigPackageLines.FindSet() then
                    repeat
                        ICMConfigPackageLines2.Init();
                        ICMConfigPackageLines2.TransferFields(ICMConfigPackageLines);
                        ICMConfigPackageLines2."ICM Package Code" := ICMConfigPackage."ICM Code";
                        ICMConfigPackageLines2.Insert();
                    until ICMConfigPackageLines.Next() = 0;

                ICMConfigPackageFields.SetRange("ICM Package Code", "ICM Code");
                if ICMConfigPackageFields.FindSet() then
                    repeat
                        ICMConfigPackageFields2.Init();
                        ICMConfigPackageFields2.TransferFields(ICMConfigPackageFields);
                        ICMConfigPackageFields2."ICM Package Code" := ICMConfigPackageFields."ICM Package Code";
                        ICMConfigPackageFields2.Insert();
                    until ICMConfigPackageFields.Next() = 0;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("ICM Code", UseICMConfigPackage."ICM Code");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Options';
                    field(Package; NewPackageCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Package Code';
                        ToolTip = 'Specifies the code that the new configuration package gets after copying.';

                        trigger OnValidate()
                        begin
                            if ICMConfigPackage.Get(NewPackageCode) then
                                Error(PackageAlreadyExistsErr, NewPackageCode);
                        end;
                    }
                    field(FromCompany; SourceCompanyName)
                    {
                        Caption = 'From Company';
                        ToolTip = 'The company to copy data from';
                        Editable = false;
                        ApplicationArea = All;
                    }
                    field(ToCompany; TargetCompanyName)
                    {
                        Caption = 'To Company';
                        ToolTip = 'The company to copy data to';
                        TableRelation = Company.Name;
                        ApplicationArea = All;

                        //trigger OnValidate()
                        //begin
                        //    ValidateCompanies();
                        //end;
                    }
                    //field(CopyData; CopyData)
                    //{
                    //    ApplicationArea = Basic, Suite;
                    //    Caption = 'Copy Data';
                    //    ToolTip = 'Specifies if data in the configuration package is copied.';
                    //}
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    trigger OnInitReport()
    begin
        SourceCompanyName := UseICMConfigPackage."ICM Source Company Name";
        TargetCompanyName := UseICMConfigPackage."ICM Target Company Name";
    end;

    var
        UseICMConfigPackage: Record "ICM Config. Package";
        ICMConfigPackage: Record "ICM Config. Package";
        ICMConfigPackageLines: Record "ICM Config. Package Line";
        ICMConfigPackageLines2: Record "ICM Config. Package Line";
        ICMConfigPackageFields: Record "ICM Config. Package Field";
        ICMConfigPackageFields2: Record "ICM Config. Package Field";
        NewPackageCode: Code[20];
        SourceCompanyName: Text[30];
        TargetCompanyName: Text[30];
        CopyData: Boolean;
        PackageAlreadyExistsErr: Label 'Package %1 already exists.';

    procedure Set(ICMConfigPackage2: Record "ICM Config. Package")
    begin
        UseICMConfigPackage := ICMConfigPackage2;
    end;
}