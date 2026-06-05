namespace DefaultPublisher;

using Microsoft.Inventory.Item;
using System.Reflection;
using System.Environment;
using Microsoft.Foundation.Company;


codeunit 50400 "ICM Management"
{
    procedure UpdateConfigPackageLines(PackageCodeR: Code[20])
    var
        ICMConfigPackLineL: Record "ICM Config. Package Line";
        RecRefL: RecordRef;
        RecordCountL: Integer;
    begin
        IcMConfigPackLineL.Reset();
        IcMConfigPackLineL.SetRange("ICM Package Code", PackageCodeR);
        if ICMConfigPackLineL.FindSet() then begin
            repeat
                Clear(RecordCountL);
                ICMConfigPackLineL.CalcFields("ICM Source Company Name", "ICM Target Company Name");
                if (ICMConfigPackLineL."ICM Source Company Name" <> '') then begin
                    RecRefL.Open(ICMConfigPackLineL."ICM Table ID");
                    RecRefL.ChangeCompany(ICMConfigPackLineL."ICM Source Company Name");
                    if RecRefL.ReadPermission() then begin
                        RecordCountL := RecRefL.Count();
                        ICMConfigPackLineL."ICM Source Comp. Record Count" := RecordCountL;
                    end;
                    RecRefL.Close();
                end;

                Clear(RecordCountL);
                if (ICMConfigPackLineL."ICM Target Company Name" <> '') then begin
                    RecRefL.Open(ICMConfigPackLineL."ICM Table ID");
                    RecRefL.ChangeCompany(ICMConfigPackLineL."ICM Target Company Name");
                    if RecRefL.ReadPermission() then begin
                        RecordCountL := RecRefL.Count();
                        ICMConfigPackLineL."ICM Target Comp. Record Count" := RecordCountL;
                    end;
                    RecRefL.Close();
                end;
                ICMConfigPackLineL.Modify(true);
            until ICMConfigPackLineL.Next() = 0;
        end;
    end;

    procedure FillCompanyTableInformation()
    var
        AllObjWithCaptionL: Record AllObjWithCaption;
        CompanyL: Record Company;
        ICMTableL: Record "ICM Table";
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


    procedure CheckTableInLicense(TableId: Integer): Boolean
    var
        RecRefL: RecordRef;
        HasPermissionL: Boolean;
    begin
        if SafeOpenTable(TableId, RecRefL) then begin
            if RecRefL.ReadPermission() then begin
                HasPermissionL := true;
            end;
            RecRefL.Close();
        end;
        exit(HasPermissionL);

    end;

    [TryFunction]
    local procedure SafeOpenTable(TableID: Integer; var RecRef: RecordRef)
    begin
        RecRef.Open(TableID);
    end;

    local procedure HasTableRecords(TableNo: Integer): Boolean
    var
        RecRef: RecordRef;
        RecordCount: Integer;
    begin
        //RecRef.Open(TableNo);
        if SafeOpenTable(TableNo, RecRef) then begin
            if RecRef.ReadPermission() then begin
                RecordCount := RecRef.Count();
                exit(RecordCount > 0);
            end;
            RecRef.Close();
        end;
    end;

    /// <summary>
    /// Inserts a Line into "ICM Table" if it does not already exist
    /// </summary>
    local procedure UpdateICMTableLine(var AllObjWithCaptionR: Record AllObjWithCaption; CompanyNameR: Text[30])
    var
        ICMTableL: Record "ICM Table";
        RecRef: RecordRef;
        RecordCount: Integer;
    begin
        if not ICMTableL.Get(CompanyNameR, ICMTableL."ICM Table ID") then begin
            ICMTableL.Init();
            ICMTableL."ICM Table ID" := AllObjWithCaptionR."Object ID";
            ICMTableL."ICM Table Name" := AllObjWithCaptionR."Object Name";
            ICMTableL."ICM Table Caption" := AllObjWithCaptionR."Object Caption";
            ICMTableL."ICM Table Subtype" := AllObjWithCaptionR."Object Subtype";
            ICMTableL."ICM Company Name" := CompanyNameR;
            ICMTableL."ICM Active" := false;

            ICMTableL.Insert();
        end;

        if ICMTableL."ICM Table Subtype" = 'Normal' then begin
            if SafeOpenTable(AllObjWithCaptionR."Object ID", RecRef) then begin
                RecordCount := RecRef.Count();
                ICMTableL."ICM Has Records" := RecordCount > 0;
                ICMTableL."ICM Record Count" := RecordCount;
                //ICMTableL."ICM Included in the License" := CheckTableInLicense(AllObjWithCaptionR."Object ID");
                ICMTableL."ICM Included in the License" := true;
                ICMTableL."ICM Active" := true;
                ICMTableL.Modify();
            end;
        end;
        recRef.Close();
    end;

    /// <summary>
    /// Sets the Active field to the specified value in all filtered rows of the ICM table
    /// </summary>
    procedure SetActiveStatus(var ICMTable: Record "ICM Table"; ActiveStatus: Boolean)
    begin
        if ICMTable.FindSet(true) then
            repeat
                if ActiveStatus = true then begin
                    if ICMTable."ICM Included in the License" and (ICMTable."ICM Table Subtype" = 'Normal') then begin

                        ICMTable."ICM Active" := ActiveStatus;
                        ICMTable.Modify();
                    end;
                end else begin
                    ICMTable."ICM Active" := ActiveStatus;
                    ICMTable.Modify();
                end;
            until ICMTable.Next() = 0;

        if guiAllowed then
            Message(Text002Lbl, ActiveStatus);
    end;

    procedure ActivateIncludeField(var CMIConfigPackageFieldR: Record "ICM Config. Package Field")
    begin
        //to Do: Primärschlüssel berücksichtigen
        if CMIConfigPackageFieldR.FindSet(true) then
            repeat
                CMIConfigPackageFieldR."ICM Include Field" := true;
                CMIConfigPackageFieldR.Modify();
            until CMIConfigPackageFieldR.Next() = 0;
    end;

    procedure DeactivateIncludeField(var CMIConfigPackageFieldR: Record "ICM Config. Package Field")
    begin
        //to Do: Primärschlüssel berücksichtigen
        if CMIConfigPackageFieldR.FindSet(true) then
            repeat
                CMIConfigPackageFieldR."ICM Include Field" := false;
                CMIConfigPackageFieldR.Modify();
            until CMIConfigPackageFieldR.Next() = 0;
    end;

    procedure CopyTablesFromToCompany(FromCompanyName: Text[30]; ToCompanyName: Text[30])
    var
        ICMTable: Record "ICM Table";
        ICMSetup: Record "ICM Setup";
        SourceRecRef: RecordRef;
        TargetRecRef: RecordRef;
        FieldRef: FieldRef;
        TargetFieldRef: FieldRef;
        CopiedTableCount: Integer;
        SkippedTableCount: Integer;
        i: Integer;
    begin
        ICMSetup.Get();
        ICMTable.SetRange("ICM Active", true);

        if not ICMTable.FindSet() then begin
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
            WindowDialogCount1 := ICMTable.Count;
        End;

        repeat
        begin

            if GuiAllowed then Begin
                WindowDialogIndex1 += 1;
                WindowDialog.Update(1, FormatPercentage(WindowDialogIndex1 / WindowDialogCount1 * 100));
            End;

            SourceRecRef.Open(ICMTable."ICM Table ID", false, FromCompanyName);

            TargetRecRef.Open(ICMTable."ICM Table ID", false, ToCompanyName);

            CopiedTableCount := ICMTable.Count();

            if ICMSetup."ICM Table data processing" = ICMSetup."ICM Table data processing"::"Overwrite existing data" then
                TryDeleteAll(TargetRecRef);

            if SourceRecRef.FindSet() then begin
                repeat
                    TargetRecRef.Init();

                    for i := 1 to SourceRecRef.FieldCount() do begin
                        FieldRef := SourceRecRef.FieldIndex(i);


                        if not (FieldRef.Class() = FieldClass::FlowField) then begin
                            TargetFieldRef := TargetRecRef.FieldIndex(i);
                            TargetFieldRef.Value := FieldRef.Value;
                        end;
                    end;

                    if TryInsertRecord(TargetRecRef) then
                        CopiedTableCount += 1
                    else
                        SkippedTableCount += 1;

                until SourceRecRef.Next() = 0;
            end;

            SourceRecRef.Close();
            TargetRecRef.Close();

        end;
        until ICMTable.Next() = 0;

        if GuiAllowed then
            WindowDialog.Close();

        if GuiAllowed then
            Message(Text004Lbl, CopiedTableCount);
    end;

    procedure CopyTablesFromToCompany2(PackageCode: Code[20])
    var
        ICMTable: Record "ICM Table";
        ICMSetup: Record "ICM Setup";
        SourceRecRef: RecordRef;
        TargetRecRef: RecordRef;
        FieldRef: FieldRef;
        TargetFieldRef: FieldRef;
        CopiedTableCount: Integer;
        SkippedTableCount: Integer;
        i: Integer;
    begin
        Message('ToDo: Applying configuration package and copying tables.');
        /*
        ICMSetup.Get();
        ICMTable.SetRange("ICM Active", true);

        if not ICMTable.FindSet() then begin
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
            WindowDialogCount1 := ICMTable.Count;
        End;

        repeat
        begin

            if GuiAllowed then Begin
                WindowDialogIndex1 += 1;
                WindowDialog.Update(1, FormatPercentage(WindowDialogIndex1 / WindowDialogCount1 * 100));
            End;

            SourceRecRef.Open(ICMTable."ICM Table ID", false, FromCompanyName);

            TargetRecRef.Open(ICMTable."ICM Table ID", false, ToCompanyName);

            CopiedTableCount := ICMTable.Count();

            if ICMSetup."Table data processing" = ICMSetup."Table data processing"::"Overwrite existing data" then
                TryDeleteAll(TargetRecRef);

            if SourceRecRef.FindSet() then begin
                repeat
                    TargetRecRef.Init();

                    for i := 1 to SourceRecRef.FieldCount() do begin
                        FieldRef := SourceRecRef.FieldIndex(i);


                        if not (FieldRef.Class() = FieldClass::FlowField) then begin
                            TargetFieldRef := TargetRecRef.FieldIndex(i);
                            TargetFieldRef.Value := FieldRef.Value;
                        end;
                    end;

                    //TargetRecRef.Insert();
                    if TryInsertRecord(TargetRecRef) then
                        CopiedTableCount += 1
                    else
                        SkippedTableCount += 1;

                until SourceRecRef.Next() = 0;
            end;

            SourceRecRef.Close();
            TargetRecRef.Close();

        end;
        until ICMTable.Next() = 0;

        if GuiAllowed then
            WindowDialog.Close();

        if GuiAllowed then
            Message(Text004Lbl, CopiedTableCount);
            */
    end;


    [TryFunction]
    local procedure TryInsertRecord(var RecRef: RecordRef)
    begin
        RecRef.Insert();
    end;

    [TryFunction]
    local procedure TryDeleteAll(var RecRef: RecordRef)
    begin
        RecRef.DeleteAll();
    end;

    procedure LookupCompanyName(var CurrentCompanyNameR: Text[30]; var ICMTableR: Record "ICM Table")
    var
        CompanyL: Record Company;
    begin
        Commit();
        if PAGE.RunModal(PAGE::Companies, CompanyL) = ACTION::LookupOK then begin
            CurrentCompanyNameR := CompanyL.Name;
            SetCompanyName(CurrentCompanyNameR, ICMTableR);
        end;
    end;

    local procedure SetCompanyName(var CurrentCompanyNameR: Text[30]; var ICMTableR: Record "ICM Table")
    begin
        ICMTableR.FilterGroup := 2;
        ICMTableR.SetRange("ICM Company Name", CurrentCompanyNameR);
        ICMTableR.FilterGroup := 0;
        if ICMTableR.Find('-') then;
    end;

    procedure ApplyConfigurationPackage(PackageCodeR: Code[20]; var ICMTableR: Record "ICM Table")
    var
        ICMConfigPackageLineL: Record "ICM Config. Package Line";
    begin
        //Message('Package %1 wird angewendet...', PackageCode);
        ICMConfigPackageLineL.Reset();
        ICMConfigPackageLineL.SetRange("ICM Package Code", PackageCodeR);

        if ICMConfigPackageLineL.FindSet() then begin
            ICMTableR.Reset();
            ICMTableR.ModifyAll("ICM Active", false);
            repeat
                ICMTableR.SetRange("ICM Table ID", ICMConfigPackageLineL."ICM Table ID");
                if ICMTableR.FindSet() then begin
                    ICMTableR.ModifyAll("ICM Active", true);
                end;
            until ICMConfigPackageLineL.Next() = 0;
        end;
    end;

    procedure IsKeyField(TableID: Integer; FieldID: Integer): Boolean
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        KeyFieldCount: Integer;
    begin
        RecRef.Open(TableID);
        KeyRef := RecRef.KeyIndex(1);
        for KeyFieldCount := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(KeyFieldCount);
            if FieldRef.Number = FieldID then
                exit(true);
        end;

        exit(false);
    end;

    procedure FormatPercentage(adPercentage: Decimal): Text
    var
        ltPercentage: Text;
        liPercentagePicture: integer;
    begin
        ltPercentage := format(Round(adPercentage, 1, '='), 2);
        liPercentagePicture := Round(adPercentage, 4, '<');
        case liPercentagePicture of
            0:                                                //(hier sind keine grafischen Symbole. Es sieht nur so aus...)
                exit(StrSubstNo('▓▒░░░░░░░░[%1%]░░░░░░░░░░', ltPercentage));
            4:
                exit(StrSubstNo('█▓▒░░░░░░░[%1%]░░░░░░░░░░', ltPercentage));
            8:
                exit(StrSubstNo('██▓▒░░░░░░[%1%]░░░░░░░░░░', ltPercentage));
            12:
                exit(StrSubstNo('███▓▒░░░░░[%1%]░░░░░░░░░░', ltPercentage));
            16:
                exit(StrSubstNo('████▓▒░░░░[%1%]░░░░░░░░░░', ltPercentage));
            20:
                exit(StrSubstNo('█████▓▒░░░[%1%]░░░░░░░░░░', ltPercentage));
            24:
                exit(StrSubstNo('██████▓▒░░[%1%]░░░░░░░░░░', ltPercentage));
            28:
                exit(StrSubstNo('███████▓▒░[%1%]░░░░░░░░░░', ltPercentage));
            32:
                exit(StrSubstNo('████████▓░[%1%]░░░░░░░░░░', ltPercentage));
            36:
                exit(StrSubstNo('█████████▓[%1%]░░░░░░░░░░', ltPercentage));
            40:
                exit(StrSubstNo('██████████[%1%]░░░░░░░░░░', ltPercentage));
            44:
                exit(StrSubstNo('██████████[%1%]░░░░░░░░░░', ltPercentage));
            48:
                exit(StrSubstNo('██████████[%1%]░░░░░░░░░░', ltPercentage));
            52:
                exit(StrSubstNo('██████████[%1%]░░░░░░░░░░', ltPercentage));
            56:
                exit(StrSubstNo('██████████[%1%]▒░░░░░░░░░', ltPercentage));
            60:
                exit(StrSubstNo('██████████[%1%]▓▒░░░░░░░░', ltPercentage));
            64:
                exit(StrSubstNo('██████████[%1%]█▓▒░░░░░░░', ltPercentage));
            68:
                exit(StrSubstNo('██████████[%1%]██▓▒░░░░░░', ltPercentage));
            72:
                exit(StrSubstNo('██████████[%1%]███▓▒░░░░░', ltPercentage));
            76:
                exit(StrSubstNo('██████████[%1%]████▓▒░░░░', ltPercentage));
            80:
                exit(StrSubstNo('██████████[%1%]█████▓▒░░░', ltPercentage));
            84:
                exit(StrSubstNo('██████████[%1%]██████▓▒░░', ltPercentage));
            88:
                exit(StrSubstNo('██████████[%1%]███████▓▒░', ltPercentage));
            92:
                exit(StrSubstNo('██████████[%1%]████████▓▒', ltPercentage));
            96:
                if adPercentage < 98.5 then
                    exit(StrSubstNo('██████████[%1%]█████████▓', ltPercentage))
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
        Text004Lbl: Label '%1 tables copied.';
        Text005Lbl: Label 'The list of Tables is being updated...\\';
        Text006Lbl: Label 'The list of Tables is being copied...\\';
}
