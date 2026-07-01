namespace ImperConsult.CopyCompany;

using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using System.Reflection;
using System.Environment;
using System.IO;

codeunit 50400 "ICM Data Transfer Management"
{
    procedure UpdateConfigPackageLines(PackageCodeR: Code[20])
    var
        ICMDataTransPackLineL: Record "ICM Data Transfer Package Line";
        RecRefL: RecordRef;
        RecordCountL: Integer;
    begin
        ICMDataTransPackLineL.Reset();
        ICMDataTransPackLineL.SetRange("ICM Package Code", PackageCodeR);
        if ICMDataTransPackLineL.FindSet() then begin
            repeat
                Clear(RecordCountL);
                ICMDataTransPackLineL.CalcFields("ICM Source Company Name", "ICM Target Company Name");
                if (ICMDataTransPackLineL."ICM Source Company Name" <> '') then begin
                    RecRefL.Open(ICMDataTransPackLineL."ICM Table ID");
                    RecRefL.ChangeCompany(ICMDataTransPackLineL."ICM Source Company Name");
                    if RecRefL.ReadPermission() then begin
                        RecordCountL := RecRefL.Count();
                        ICMDataTransPackLineL."ICM Source Comp. Record Count" := RecordCountL;
                    end;
                    RecRefL.Close();
                end;

                Clear(RecordCountL);
                if (ICMDataTransPackLineL."ICM Target Company Name" <> '') then begin
                    RecRefL.Open(ICMDataTransPackLineL."ICM Table ID");
                    RecRefL.ChangeCompany(ICMDataTransPackLineL."ICM Target Company Name");
                    if RecRefL.ReadPermission() then begin
                        RecordCountL := RecRefL.Count();
                        ICMDataTransPackLineL."ICM Target Comp. Record Count" := RecordCountL;
                    end;
                    RecRefL.Close();
                end;
                ICMDataTransPackLineL.Modify();
            until ICMDataTransPackLineL.Next() = 0;
        end;
    end;

    procedure FillCompanyTableInformation()
    var
        AllObjWithCaptionL: Record AllObjWithCaption;
        CompanyL: Record Company;
        ICMDataTransferTableL: Record "ICM Data Transfer Table";
        RecRefL: RecordRef;
        TableCountL: Integer;
    begin

        CompanyL.Reset();

        if CompanyL.FindSet() then begin

            if GuiAllowed then Begin
                WindowDialog.Open(Text005Lbl +
                '#1###################\' +
                '#2###################'
                );
                WindowDialogIndex1 := 0;
                WindowDialogCount1 := AllObjWithCaptionL.Count;
            End;

            repeat
                AllObjWithCaptionL.Reset();
                AllObjWithCaptionL.ChangeCompany(CompanyL.Name);
                AllObjWithCaptionL.SetRange("Object Type", AllObjWithCaptionL."Object Type"::Table);
                AllObjWithCaptionL.SetRange("Object Subtype", 'Normal');
                AllObjWithCaptionL.SetRange("Object ID", 1, 99999999);

                if AllObjWithCaptionL.FindSet() then
                    repeat
                        if GuiAllowed then Begin
                            WindowDialogIndex1 += 1;
                            WindowDialog.Update(1, FormatPercentage(WindowDialogIndex1 / WindowDialogCount1 * 100));
                        End;

                        if AllObjWithCaptionL."Object Type" <> AllObjWithCaptionL."Object Type"::System then
                            if CheckTableInLicense(AllObjWithCaptionL."Object ID") then
                                UpdateICMTableLine(AllObjWithCaptionL, CompanyL.Name);

                    until AllObjWithCaptionL.Next() = 0;
            until CompanyL.Next() = 0;
        end;

        if GuiAllowed then
            WindowDialog.Close();

        if guiAllowed then
            Message(Text001Lbl);
    end;


    procedure CheckTableInLicense(TableIdR: Integer): Boolean
    var
        RecRefL: RecordRef;
        HasPermissionL: Boolean;
    begin
        if SafeOpenTable(TableIdR, RecRefL) then begin
            if RecRefL.ReadPermission() then begin
                HasPermissionL := true;
            end;
            RecRefL.Close();
        end;
        exit(HasPermissionL);

    end;

    [TryFunction]
    local procedure SafeOpenTable(TableIDR: Integer; var RecRefR: RecordRef)
    begin
        RecRefR.Open(TableIDR);
    end;

    local procedure HasTableRecords(TableNoR: Integer): Boolean
    var
        RecRefL: RecordRef;
        RecordCountLL: Integer;
    begin
        if SafeOpenTable(TableNoR, RecRefL) then begin
            if RecRefL.ReadPermission() then begin
                RecordCountLL := RecRefL.Count();
                exit(RecordCountLL > 0);
            end;
            RecRefL.Close();
        end;
    end;

    /// <summary>
    /// Inserts a Line into "ICM Data Transfer Table" if it does not already exist
    /// </summary>
    local procedure UpdateICMTableLine(var AllObjWithCaptionR: Record AllObjWithCaption; CompanyNameR: Text[30])
    var
        ICMDataTransferTableL: Record "ICM Data Transfer Table";
        ConfigMgtL: Codeunit "Config. Management";
        RecRefL: RecordRef;
        RecordCountL: Integer;
    begin
        Clear(RecRefL);
        if ICMDataTransferTableL.Get(CompanyNameR, AllObjWithCaptionR."Object ID") then begin
            if ICMDataTransferTableL."ICM Table Subtype" = 'Normal' then begin
                RecRefL.Open(ICMDataTransferTableL."ICM Table ID");

                RecordCountL := RecRefL.Count();
                ICMDataTransferTableL."ICM Has Records" := RecordCountL > 0;
                ICMDataTransferTableL."ICM Record Count" := RecordCountL;
                ICMDataTransferTableL.Modify();

                RecRefL.Close();
            end;
        end else begin
            ICMDataTransferTableL.Init();
            ICMDataTransferTableL."ICM Table ID" := AllObjWithCaptionR."Object ID";
            ICMDataTransferTableL."ICM Table Name" := AllObjWithCaptionR."Object Name";
            ICMDataTransferTableL."ICM Table Caption" := AllObjWithCaptionR."Object Caption";
            ICMDataTransferTableL."ICM Table Subtype" := AllObjWithCaptionR."Object Subtype";
            ICMDataTransferTableL."ICM Company Name" := CompanyNameR;
            ICMDataTransferTableL."ICM Active" := false;
            ICMDataTransferTableL."ICM Included in the License" := CheckTableInLicense(AllObjWithCaptionR."Object ID");
            ICMDataTransferTableL."ICM Page ID" := ConfigMgtL.FindPage(ICMDataTransferTableL."ICM Table ID");

            ICMDataTransferTableL.Insert(true);
        end;
    end;

    /// <summary>
    /// Sets the Active field to the specified value in all filtered rows of the ICM table
    /// </summary>
    procedure SetActiveStatus(var ICMDataTransferTableR: Record "ICM Data Transfer Table"; ActiveStatusR: Boolean)
    begin
        if ICMDataTransferTableR.FindSet(true) then
            repeat
                if ActiveStatusR = true then begin
                    if ICMDataTransferTableR."ICM Included in the License" and (ICMDataTransferTableR."ICM Table Subtype" = 'Normal') then begin
                        ICMDataTransferTableR."ICM Active" := ActiveStatusR;
                        ICMDataTransferTableR.Modify();
                    end;
                end else begin
                    ICMDataTransferTableR."ICM Active" := ActiveStatusR;
                    ICMDataTransferTableR.Modify();
                end;
            until ICMDataTransferTableR.Next() = 0;

        if guiAllowed then
            Message(Text002Lbl, ActiveStatusR);
    end;

    procedure ActivateIncludePackageField(var CMIDataTransferPackageFieldR: Record "ICM Data Transf. Package Field")
    begin
        if CMIDataTransferPackageFieldR.FindSet(true) then
            repeat
                CMIDataTransferPackageFieldR."ICM Include Field" := true;
                CMIDataTransferPackageFieldR.Modify();
            until CMIDataTransferPackageFieldR.Next() = 0;
    end;

    procedure DeactivateIncludePackageField(var CMIDataTransfPackageFieldR: Record "ICM Data Transf. Package Field")
    var
        ICMDataTransferPackageLineL: Record "ICM Data Transfer Package Line";
    begin
        if ICMDataTransferPackageLineL.Get(CMIDataTransfPackageFieldR."ICM Package Code", CMIDataTransfPackageFieldR."ICM Table ID") then
            ICMDataTransferPackageLineL.TestField("ICM Apply Table Fields", ICMDataTransferPackageLineL."ICM Apply Table Fields"::"Some Fields");
        CMIDataTransfPackageFieldR.SetRange("ICM Primary Key", false);
        if CMIDataTransfPackageFieldR.FindSet(true) then
            repeat
                CMIDataTransfPackageFieldR."ICM Include Field" := false;
                CMIDataTransfPackageFieldR.Modify();
            until CMIDataTransfPackageFieldR.Next() = 0;
    end;

    procedure ActivateIncludeTableField(var ICMTableFieldR: Record "ICM Data Transfer Table Field")
    begin
        if ICMTableFieldR.FindSet(true) then
            repeat
                ICMTableFieldR."ICM Include Field" := true;
                ICMTableFieldR.Modify();
            until ICMTableFieldR.Next() = 0;
    end;

    procedure DeactivateIncludeTableField(var ICMTableFieldR: Record "ICM Data Transfer Table Field")
    var
        ICMDataTransferTableL: Record "ICM Data Transfer Table";
    begin
        if ICMDataTransferTableL.Get(ICMTableFieldR."ICM Company Name", ICMTableFieldR."ICM Table ID") then
            ICMDataTransferTableL.TestField("ICM Apply Table Fields", ICMDataTransferTableL."ICM Apply Table Fields"::"Some Fields");
        ICMTableFieldR.SetRange("ICM Primary Key", false);
        if ICMTableFieldR.FindSet(true) then
            repeat
                ICMTableFieldR."ICM Include Field" := false;
                ICMTableFieldR.Modify();
            until ICMTableFieldR.Next() = 0;
    end;

    procedure CopyToCompanyFromDataTransferTables(SourceCompanyR: Text[30]; TargetCompanyR: Text[30])
    var
        ICMTableL: Record "ICM Data Transfer Table";
        ICMTransferDataLogL: Record "ICM Transfer Data Log";
        ICMTableFieldL: Record "ICM Data Transfer Table Field";
        ICMSetupL: Record "ICM Data Transfer Setup";
        ICMTransferDataLogListL: Page "ICM Transfer Data Log List";
        SourceRecRefL: RecordRef;
        TargetRecRefL: RecordRef;
        FieldRefL: FieldRef;
        TargetFieldRefL: FieldRef;
        ErrorTextL: Text;
        CopiedTableCountL: Integer;
        SkippedTableCountL: Integer;
        CopiedRecordCountL: Integer;
        SkippedRecordCountL: Integer;
        NextEntryNoL: Integer;
        RecordsTransferedL: Boolean;
        iL: Integer;
    begin
        ICMSetupL.Get();
        ICMTableL.SetRange("ICM Active", true);
        ICMTableL.SetRange("ICM Has Records", true);
        ICMTableL.SetRange("ICM Company Name", SourceCompanyR);

        if ICMTableL.IsEmpty() then begin
            if guiAllowed then
                Message(Text003Lbl);
            exit;
        end;

        if GuiAllowed then Begin
            WindowDialog.Open(Text006Lbl +
              '#1###################\' +
              '#2###################'
            );
            WindowDialogIndex1 := 0;
            WindowDialogCount1 := ICMTableL.Count;
        End;

        //Clear(CopiedTableCountL);
        //Clear(SkippedTableCountL);

        if ICMTableL.FindSet() then
            repeat
                Clear(RecordsTransferedL);
                Clear(CopiedRecordCountL);
                Clear(SkippedRecordCountL);

                if GuiAllowed then Begin
                    WindowDialogIndex1 += 1;
                    WindowDialog.Update(1, FormatPercentage(WindowDialogIndex1 / WindowDialogCount1 * 100));
                End;

                SourceRecRefL.Open(ICMTableL."ICM Table ID", false, SourceCompanyR);
                TargetRecRefL.Open(ICMTableL."ICM Table ID", false, TargetCompanyR);

                if ICMSetupL."ICM Table data processing" = ICMSetupL."ICM Table data processing"::"Overwrite existing data" then
                    ErrorTextL := DeleteAllWithLog(TargetRecRefL);
                //TryDeleteAll(TargetRecRefL);

                ICMTransferDataLogL.Reset();
                NextEntryNoL := ICMTransferDataLogL.GetNextEntryNo;
                ICMTransferDataLogL."ICM Entry No." := NextEntryNoL;
                ICMTransferDataLogL."ICM Table No." := ICMTableL."ICM Table ID";
                //ICMTransferDataLogL."ICM Records Available" := SourceRecRefL.Count();
                ICMTransferDataLogL."ICM Source Company" := SourceCompanyR;
                ICMTransferDataLogL."ICM Target Company" := TargetCompanyR;
                ICMTransferDataLogL."ICM Page ID" := ICMTableL."ICM Page ID";
                ICMTransferDataLogL."ICM Error Text" := CopyStr(ErrorTextL, 1, MaxStrLen(ICMTransferDataLogL."ICM Error Text"));
                ICMTransferDataLogL.Insert();

                ICMTableFieldL.Reset();
                ICMTableFieldL.SetRange("ICM Company Name", ICMTableL."ICM Company Name");
                ICMTableFieldL.SetRange("ICM Table ID", ICMTableL."ICM Table ID");
                ICMTableFieldL.SetRange("ICM Include Field", true);

                if SourceRecRefL.FindSet() then begin
                    repeat

                        if ICMTableFieldL.FindSet() then begin
                            repeat
                                FieldRefL := SourceRecRefL.Field(ICMTableFieldL."ICM Field ID");

                                if not (FieldRefL.Class() = FieldClass::FlowField) then begin
                                    TargetFieldRefL := TargetRecRefL.Field(ICMTableFieldL."ICM Field ID");
                                    TargetFieldRefL.Value := FieldRefL.Value;
                                end;
                            until ICMTableFieldL.Next() = 0;
                        end;

                        if (ICMSetupL."ICM Table data processing" = ICMSetupL."ICM Table data processing"::"Keep existing data") and
                            TargetRecRefL.Find('=') then
                            SkippedRecordCountL += 1
                        else begin
                            if TryInsertRecord(TargetRecRefL) then begin
                                CopiedRecordCountL += 1;
                                RecordsTransferedL := true;
                            end else
                                SkippedRecordCountL += 1;
                        end;


                    until SourceRecRefL.Next() = 0;
                end;

                if ICMTransferDataLogL.Get(NextEntryNoL) then begin
                    ICMTransferDataLogL."ICM Records Available" := ICMTableL."ICM Record Count"; //SourceRecRefL.Count();
                    ICMTransferDataLogL."ICM Records Transferred" := CopiedRecordCountL;
                    ICMTransferDataLogL."ICM Records Skipped" := SkippedRecordCountL;
                    ICMTransferDataLogL."ICM Transferred By" := UserId;
                    ICMTransferDataLogL."ICM Transferred Date" := CurrentDateTime;
                    ICMTransferDataLogL.Modify();
                end;
                //CopiedTableCountL += 1;

                ICMTableL."ICM Records transferred" := RecordsTransferedL;
                ICMTableL.Modify();

                SourceRecRefL.Close();
                TargetRecRefL.Close();

            until ICMTableL.Next() = 0;

        if GuiAllowed then
            WindowDialog.Close();
    end;

    procedure CopyToCompanyFromDataTransferPackage(PackageCodeR: Code[20])
    var
        ICMSetupL: Record "ICM Data Transfer Setup";
        ICMDataTransferPackageL: Record "ICM Data Transfer Package";
        ICMDataTransferPackageLineL: Record "ICM Data Transfer Package Line";
        ICMDataTransfPackageFieldL: Record "ICM Data Transf. Package Field";
        ICMTransferDataLogL: Record "ICM Transfer Data Log";
        DataTransfPackFilterL: Record "ICM Data Transf. Pack. Filter";
        TransferDataLogListL: Page "ICM Transfer Data Log List";
        SourceRecRefL: RecordRef;
        TargetRecRefL: RecordRef;
        RecRefL: RecordRef;
        FilterTextL: Text;
        ErrorTextL: Text;
        FieldRefL: FieldRef;
        TargetFieldRefL: FieldRef;
        CopiedTableCountL: Integer;
        SkippedTableCountL: Integer;
        CopiedRecordCountL: Integer;
        SkippedRecordCountL: Integer;
        NextEntryNoL: Integer;
        iL: Integer;
    begin
        ICMSetupL.Get();
        ICMDataTransferPackageL.Get(PackageCodeR);

        ICMDataTransferPackageLineL.Reset();
        ICMDataTransferPackageLineL.SetRange("ICM Package Code", PackageCodeR);
        ICMDataTransferPackageLineL.SetRange("ICM Active", true);

        if ICMDataTransferPackageLineL.IsEmpty then begin
            if guiAllowed then
                Message(Text003Lbl);
            exit;
        end;

        if GuiAllowed then Begin
            WindowDialog.Open(Text006Lbl +
              '#1###################\' +
              '#2###################'
            );
            WindowDialogIndex1 := 0;
            WindowDialogCount1 := ICMDataTransferPackageLineL.Count;
        End;

        if ICMDataTransferPackageLineL.FindSet() then
            repeat
                if GuiAllowed then Begin
                    WindowDialogIndex1 += 1;
                    WindowDialog.Update(1, FormatPercentage(WindowDialogIndex1 / WindowDialogCount1 * 100));
                End;

                SourceRecRefL.Open(ICMDataTransferPackageLineL."ICM Table ID", false, ICMDataTransferPackageL."ICM Source Company Name");
                TargetRecRefL.Open(ICMDataTransferPackageLineL."ICM Table ID", false, ICMDataTransferPackageL."ICM Target Company Name");

                if ICMSetupL."ICM Table data processing" = ICMSetupL."ICM Table data processing"::"Overwrite existing data" then
                    //TryDeleteAll(TargetRecRefL);
                    ErrorTextL := DeleteAllWithLog(TargetRecRefL);

                NextEntryNoL := CreateTransferDataLogFromPackage(ICMTransferDataLogL, ICMDataTransferPackageL, ICMDataTransferPackageLineL, SourceRecRefL);
                //ICMTransferDataLogL."ICM Error Text" := CopyStr(ErrorTextL, 1, MaxStrLen(ICMTransferDataLogL."ICM Error Text"));

                //add Filter
                DataTransfPackFilterL.Reset();
                DataTransfPackFilterL.SetRange("ICM Package Code", ICMDataTransferPackageL."ICM Code");
                DataTransfPackFilterL.SetRange("ICM Table ID", ICMDataTransferPackageLineL."ICM Table ID");
                if DataTransfPackFilterL.FindSet() then
                    repeat
                        if DataTransfPackFilterL."ICM Field Filter" <> '' then begin
                            FieldRefL := SourceRecRefL.Field(DataTransfPackFilterL."ICM Field ID");
                            FieldRefL.SetFilter(StrSubstNo('%1', DataTransfPackFilterL."ICM Field Filter"));
                        end;
                    until DataTransfPackFilterL.Next() = 0;

                FilterTextL := SourceRecRefL.GetView();

                if SourceRecRefL.FindSet() then begin
                    repeat
                        ICMDataTransfPackageFieldL.Reset();
                        ICMDataTransfPackageFieldL.SetRange("ICM Package Code", ICMDataTransferPackageLineL."ICM Package Code");
                        ICMDataTransfPackageFieldL.SetRange("ICM Table ID", ICMDataTransferPackageLineL."ICM Table ID");
                        ICMDataTransfPackageFieldL.SetRange("ICM Include Field", true);
                        if ICMDataTransfPackageFieldL.FindSet() then begin
                            repeat
                                FieldRefL := SourceRecRefL.Field(ICMDataTransfPackageFieldL."ICM Field ID");

                                if not (FieldRefL.Class() = FieldClass::FlowField) then begin
                                    TargetFieldRefL := TargetRecRefL.Field(ICMDataTransfPackageFieldL."ICM Field ID");
                                    TargetFieldRefL.Value := FieldRefL.Value;
                                end;
                            until ICMDataTransfPackageFieldL.Next() = 0;
                        end;

                        if (ICMSetupL."ICM Table data processing" = ICMSetupL."ICM Table data processing"::"Keep existing data") and
                                                    TargetRecRefL.Find('=') then
                            SkippedRecordCountL += 1
                        else begin
                            if TryInsertRecord(TargetRecRefL) then
                                CopiedRecordCountL += 1
                            else
                                SkippedRecordCountL += 1;
                        end;

                    until SourceRecRefL.Next() = 0;
                end;

                CopiedTableCountL += 1;

                UpdateTransferDataLog(ICMTransferDataLogL, NextEntryNoL, CopiedRecordCountL, SkippedRecordCountL, FilterTextL, ErrorTextL);
                SourceRecRefL.Close();
                TargetRecRefL.Close();


            until ICMDataTransferPackageLineL.Next() = 0;

        if GuiAllowed then
            WindowDialog.Close();

        TransferDataLogListL.Run();

    end;

    [TryFunction]
    local procedure TryInsertRecord(var RecRefR: RecordRef)
    begin
        RecRefR.Insert();
    end;

    local procedure CreateTransferDataLogFromPackage(var ICMTransferDataLogR: Record "ICM Transfer Data Log"; ICMDataTransferPackageR: Record "ICM Data Transfer Package"; ICMDataTransferPackageLineR: Record "ICM Data Transfer Package Line"; SourceRecRefR: RecordRef): Integer
    var
        NextEntryNoL: Integer;
    begin
        ICMTransferDataLogR.Reset();
        NextEntryNoL := ICMTransferDataLogR.GetNextEntryNo;
        ICMTransferDataLogR."ICM Entry No." := NextEntryNoL;
        ICMTransferDataLogR."ICM Table No." := ICMDataTransferPackageLineR."ICM Table ID";
        ICMTransferDataLogR."ICM Records Available" := SourceRecRefR.Count();
        ICMTransferDataLogR."ICM Package Code" := ICMDataTransferPackageR."ICM Code";
        ICMTransferDataLogR."ICM Source Company" := ICMDataTransferPackageR."ICM Source Company Name";
        ICMTransferDataLogR."ICM Target Company" := ICMDataTransferPackageR."ICM Target Company Name";
        ICMTransferDataLogR."ICM Page ID" := ICMDataTransferPackageLineR."ICM Page ID";
        ICMTransferDataLogR.Insert();

        exit(NextEntryNoL);
    end;

    local procedure UpdateTransferDataLog(var ICMTransferDataLogR: Record "ICM Transfer Data Log"; EntryNoR: Integer; CopiedRecordCountR: Integer; SkippedRecordCountR: Integer; FilterTextR: Text; ErrorTextR: Text)
    begin
        if ICMTransferDataLogR.Get(EntryNoR) then begin
            ICMTransferDataLogR."ICM Records Transferred" := CopiedRecordCountR;
            ICMTransferDataLogR."ICM Records Skipped" := SkippedRecordCountR;
            ICMTransferDataLogR."ICM Filter Text" := FilterTextR;
            if FilterTextR <> '' then
                ICMTransferDataLogR."ICM Filter Exists" := true;
            ICMTransferDataLogR."ICM Error Text" := CopyStr(ErrorTextR, 1, MaxStrLen(ICMTransferDataLogR."ICM Error Text"));
            ICMTransferDataLogR."ICM Transferred By" := UserId;
            ICMTransferDataLogR."ICM Transferred Date" := CurrentDateTime;
            ICMTransferDataLogR.Modify();
        end;
    end;

    [TryFunction]
    local procedure TryDeleteAll(var RecRefR: RecordRef)
    begin
        if RecRefR.Number <> 0 then
            RecRefR.DeleteAll();
    end;

    local procedure DeleteAllWithLog(var RecRefR: RecordRef): Text
    var
        ErrorTextL: Text;
    begin
        if not TryDeleteAll(RecRefR) then begin
            ErrorTextL := GetLastErrorText();
        end;
        exit(ErrorTextL)
    end;

    procedure LookupCompanyName(var CurrentCompanyNameR: Text[30]; var ICMTableR: Record "ICM Data Transfer Table")
    var
        CompanyL: Record Company;
    begin
        Commit();
        if PAGE.RunModal(PAGE::Companies, CompanyL) = ACTION::LookupOK then begin
            CurrentCompanyNameR := CompanyL.Name;
            SetCompanyName(CurrentCompanyNameR, ICMTableR);
        end;
    end;

    local procedure SetCompanyName(var CurrentCompanyNameR: Text[30]; var ICMTableR: Record "ICM Data Transfer Table")
    begin
        ICMTableR.FilterGroup := 2;
        ICMTableR.SetRange("ICM Company Name", CurrentCompanyNameR);
        ICMTableR.FilterGroup := 0;
        if ICMTableR.Find('-') then;
    end;

    procedure IsKeyField(TableIDR: Integer; FieldIDR: Integer): Boolean
    var
        RecRefL: RecordRef;
        FieldRefL: FieldRef;
        KeyRefL: KeyRef;
        KeyFieldCountL: Integer;
    begin
        RecRefL.Open(TableIDR);
        KeyRefL := RecRefL.KeyIndex(1);
        for KeyFieldCountL := 1 to KeyRefL.FieldCount do begin
            FieldRefL := KeyRefL.FieldIndex(KeyFieldCountL);
            if FieldRefL.Number = FieldIDR then
                exit(true);
        end;

        exit(false);
    end;

    procedure SetFieldFilter(var FieldR: Record "Field"; TableIDR: Integer; FieldIDR: Integer)
    begin
        FieldR.Reset();
        if TableIDR > 0 then
            FieldR.SetRange(TableNo, TableIDR);
        if FieldIDR > 0 then
            FieldR.SetRange("No.", FieldIDR)
        else
            FieldR.SetFilter("No.", '<>%1&<>%2&<>%3&<>%4&<>%5',
                    FieldR.FieldNo(SystemId),
                    FieldR.FieldNo(SystemCreatedAt),
                    FieldR.FieldNo(SystemCreatedBy),
                    FieldR.FieldNo(SystemModifiedAt),
                    FieldR.FieldNo(SystemModifiedBy));
        FieldR.SetRange(Class, FieldR.Class::Normal);
        FieldR.SetRange(Enabled, true);
        FieldR.SetFilter(ObsoleteState, '<>%1', FieldR.ObsoleteState::Removed);
    end;

    procedure FormatPercentage(adPercentageR: Decimal): Text
    var
        PercentageL: Text;
        PercentagePictureL: integer;
    begin
        PercentageL := format(Round(adPercentageR, 1, '='), 2);
        PercentagePictureL := Round(adPercentageR, 4, '<');
        case PercentagePictureL of
            0:                                                //(hier sind keine grafischen Symbole. Es sieht nur so aus...)
                exit(StrSubstNo('▓▒░░░░░░░░[%1%]░░░░░░░░░░', PercentageL));
            4:
                exit(StrSubstNo('█▓▒░░░░░░░[%1%]░░░░░░░░░░', PercentageL));
            8:
                exit(StrSubstNo('██▓▒░░░░░░[%1%]░░░░░░░░░░', PercentageL));
            12:
                exit(StrSubstNo('███▓▒░░░░░[%1%]░░░░░░░░░░', PercentageL));
            16:
                exit(StrSubstNo('████▓▒░░░░[%1%]░░░░░░░░░░', PercentageL));
            20:
                exit(StrSubstNo('█████▓▒░░░[%1%]░░░░░░░░░░', PercentageL));
            24:
                exit(StrSubstNo('██████▓▒░░[%1%]░░░░░░░░░░', PercentageL));
            28:
                exit(StrSubstNo('███████▓▒░[%1%]░░░░░░░░░░', PercentageL));
            32:
                exit(StrSubstNo('████████▓░[%1%]░░░░░░░░░░', PercentageL));
            36:
                exit(StrSubstNo('█████████▓[%1%]░░░░░░░░░░', PercentageL));
            40:
                exit(StrSubstNo('██████████[%1%]░░░░░░░░░░', PercentageL));
            44:
                exit(StrSubstNo('██████████[%1%]░░░░░░░░░░', PercentageL));
            48:
                exit(StrSubstNo('██████████[%1%]░░░░░░░░░░', PercentageL));
            52:
                exit(StrSubstNo('██████████[%1%]░░░░░░░░░░', PercentageL));
            56:
                exit(StrSubstNo('██████████[%1%]▒░░░░░░░░░', PercentageL));
            60:
                exit(StrSubstNo('██████████[%1%]▓▒░░░░░░░░', PercentageL));
            64:
                exit(StrSubstNo('██████████[%1%]█▓▒░░░░░░░', PercentageL));
            68:
                exit(StrSubstNo('██████████[%1%]██▓▒░░░░░░', PercentageL));
            72:
                exit(StrSubstNo('██████████[%1%]███▓▒░░░░░', PercentageL));
            76:
                exit(StrSubstNo('██████████[%1%]████▓▒░░░░', PercentageL));
            80:
                exit(StrSubstNo('██████████[%1%]█████▓▒░░░', PercentageL));
            84:
                exit(StrSubstNo('██████████[%1%]██████▓▒░░', PercentageL));
            88:
                exit(StrSubstNo('██████████[%1%]███████▓▒░', PercentageL));
            92:
                exit(StrSubstNo('██████████[%1%]████████▓▒', PercentageL));
            96:
                if adPercentageR < 98.5 then
                    exit(StrSubstNo('██████████[%1%]█████████▓', PercentageL))
                else
                    exit('██████████[100]██████████');
            100:
                exit('██████████[100]██████████');
            else
                exit('                         ');
        end;
    end;

    var
        WindowDialog: Dialog;
        WindowDialogCount1: Integer;
        WindowDialogIndex1: Integer;
        Text001Lbl: Label 'Lines has been updated.';
        Text002Lbl: Label 'The Field Active has been set to %1 for all filtered table lines.';
        Text003Lbl: Label 'No active tables found.';
        Text004Lbl: Label '%1 table copied. %2 tables skipped.';
        Text005Lbl: Label 'The list of Tables is being updated...\\';
        Text006Lbl: Label 'The list of Tables is being copied...\\';
        Text007Lbl: Label '%1 table copied from Company %2 to Company %3.';
}
