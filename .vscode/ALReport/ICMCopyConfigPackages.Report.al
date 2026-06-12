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
                ICMConfigPackageNew.Init();
                ICMConfigPackageNew.TransferFields(UseICMConfigPackage);
                ICMConfigPackageNew."ICM Code" := NewPackageCode;
                ICMConfigPackageNew."ICM Source Company Name" := SourceCompanyName;
                ICMConfigPackageNew."ICM Target Company Name" := TargetCompanyName;
                ICMConfigPackageNew.Insert();

                ICMConfigPackageLines.SetRange("ICM Package Code", UseICMConfigPackage."ICM Code");
                if ICMConfigPackageLines.FindSet() then
                    repeat
                        ICMConfigPackageLinesNew.Init();
                        ICMConfigPackageLinesNew.TransferFields(ICMConfigPackageLines);
                        ICMConfigPackageLinesNew."ICM Package Code" := NewPackageCode;
                        ICMConfigPackageLinesNew.Insert();
                    until ICMConfigPackageLines.Next() = 0;

                ICMConfigPackageFields.SetRange("ICM Package Code", UseICMConfigPackage."ICM Code");
                if ICMConfigPackageFields.FindSet() then
                    repeat
                        ICMConfigPackageFieldsNew.Init();
                        ICMConfigPackageFieldsNew.TransferFields(ICMConfigPackageFields);
                        ICMConfigPackageFieldsNew."ICM Package Code" := NewPackageCode;
                        ICMConfigPackageFieldsNew.Insert();
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
                            if ICMConfigPackageNew.Get(NewPackageCode) then
                                Error(PackageAlreadyExistsErr, NewPackageCode);
                        end;
                    }
                    field(FromCompany; SourceCompanyName)
                    {
                        Caption = 'From Company';
                        ToolTip = 'The company to copy data from';
                        TableRelation = Company.Name;
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            if SourceCompanyName = TargetCompanyName then
                                Error(Text001Err);

                        end;
                    }
                    field(ToCompany; TargetCompanyName)
                    {
                        Caption = 'To Company';
                        ToolTip = 'The company to copy data to';
                        TableRelation = Company.Name;
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if SourceCompanyName = TargetCompanyName then
                                Error(Text001Err);
                        end;
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
    }

    procedure Set(ICMConfigPackageR: Record "ICM Config. Package")
    begin
        UseICMConfigPackage := ICMConfigPackageR;
        SourceCompanyName := UseICMConfigPackage."ICM Source Company Name";
        TargetCompanyName := UseICMConfigPackage."ICM Target Company Name";
    end;

    var
        UseICMConfigPackage: Record "ICM Config. Package";
        ICMConfigPackageNew: Record "ICM Config. Package";
        ICMConfigPackageLines: Record "ICM Config. Package Line";
        ICMConfigPackageLinesNew: Record "ICM Config. Package Line";
        ICMConfigPackageFields: Record "ICM Config. Package Field";
        ICMConfigPackageFieldsNew: Record "ICM Config. Package Field";
        NewPackageCode: Code[20];
        SourceCompanyName: Text[30];
        TargetCompanyName: Text[30];
        CopyData: Boolean;
        PackageAlreadyExistsErr: Label 'Package %1 already exists.';
        Text001Err: Label 'The target company must be different from the source company.';
}