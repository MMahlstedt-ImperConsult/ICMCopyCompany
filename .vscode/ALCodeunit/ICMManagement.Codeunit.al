namespace ImperConsult.CopyCompany;

using Microsoft.Inventory.Item;
using System.Reflection;
using System.Environment;
using Microsoft.Foundation.Company;


codeunit 50400 "ICM Management"
{
    procedure UpdateConfigPackageLines(PackageCodeR: Code[20])
    var
        ICMConfigPackLineL: Record "ICM Data Transfer Package Line";
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
                ICMConfigPackLineL.Modify();
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
        RecRefL: RecordRef;
        RecordCountL: Integer;
    begin
        Clear(RecRefL);
        if ICMTableL.Get(CompanyNameR, ICMTableL."ICM Table ID") then begin
            if ICMTableL."ICM Table Subtype" = 'Normal' then begin
                RecRefL.Open(ICMTableL."ICM Table ID");

                RecordCountL := RecRefL.Count();
                ICMTableL."ICM Has Records" := RecordCountL > 0;
                ICMTableL."ICM Record Count" := RecordCountL;
                //ICMTableL."ICM Included in the License" := CheckTableInLicense(AllObjWithCaptionR."Object ID");
                //ICMTableL."ICM Included in the License" := true;
                ICMTableL."ICM Active" := true;
                ICMTableL.Modify();

                RecRefL.Close();
            end;
        end else begin
            ICMTableL.Init();
            ICMTableL."ICM Table ID" := AllObjWithCaptionR."Object ID";
            ICMTableL."ICM Table Name" := AllObjWithCaptionR."Object Name";
            ICMTableL."ICM Table Caption" := AllObjWithCaptionR."Object Caption";
            ICMTableL."ICM Table Subtype" := AllObjWithCaptionR."Object Subtype";
            ICMTableL."ICM Company Name" := CompanyNameR;
            ICMTableL."ICM Active" := false;

            ICMTableL.Insert(true);
        end;
        /* if not ICMTableL.Get(CompanyNameR, ICMTableL."ICM Table ID") then begin
             ICMTableL.Init();
             ICMTableL."ICM Table ID" := AllObjWithCaptionR."Object ID";
             ICMTableL."ICM Table Name" := AllObjWithCaptionR."Object Name";
             ICMTableL."ICM Table Caption" := AllObjWithCaptionR."Object Caption";
             ICMTableL."ICM Table Subtype" := AllObjWithCaptionR."Object Subtype";
             ICMTableL."ICM Company Name" := CompanyNameR;
             ICMTableL."ICM Active" := false;

             ICMTableL.Insert(true);
         end else begin 

         end;

         if ICMTableL."ICM Table Subtype" = 'Normal' then begin
             //if SafeOpenTable(AllObjWithCaptionR."Object ID", RecRefL) then begin
                 RecordCountL := RecRefL.Count();
                 ICMTableL."ICM Has Records" := RecordCountL > 0;
                 ICMTableL."ICM Record Count" := RecordCountL;
                 //ICMTableL."ICM Included in the License" := CheckTableInLicense(AllObjWithCaptionR."Object ID");
                 ICMTableL."ICM Included in the License" := true;
                 ICMTableL."ICM Active" := true;
                 ICMTableL.Modify();
             //end;
         end;
         RecRefL.Close(); */
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

    procedure ActivateIncludePackageField(var CMIConfigPackageFieldR: Record "ICM Data Transf. Package Field")
    begin
        if CMIConfigPackageFieldR.FindSet(true) then
            repeat
                CMIConfigPackageFieldR."ICM Include Field" := true;
                CMIConfigPackageFieldR.Modify();
            until CMIConfigPackageFieldR.Next() = 0;
    end;

    procedure DeactivateIncludePackageField(var CMIConfigPackageFieldR: Record "ICM Data Transf. Package Field")
    var
        ICMConfigPackageLineL: Record "ICM Data Transfer Package Line";
    begin
        if ICMConfigPackageLineL.Get(CMIConfigPackageFieldR."ICM Package Code", CMIConfigPackageFieldR."ICM Table ID") then
            ICMConfigPackageLineL.TestField("ICM Apply Table Fields", ICMConfigPackageLineL."ICM Apply Table Fields"::"Some Fields");
        CMIConfigPackageFieldR.SetRange("ICM Primary Key", false);
        if CMIConfigPackageFieldR.FindSet(true) then
            repeat
                CMIConfigPackageFieldR."ICM Include Field" := false;
                CMIConfigPackageFieldR.Modify();
            until CMIConfigPackageFieldR.Next() = 0;
    end;

    procedure ActivateIncludeTableField(var CMITableFieldR: Record "ICM Table Field")
    begin
        if CMITableFieldR.FindSet(true) then
            repeat
                CMITableFieldR."ICM Include Field" := true;
                CMITableFieldR.Modify();
            until CMITableFieldR.Next() = 0;
    end;

    procedure DeactivateIncludeTableField(var CMITableFieldR: Record "ICM Table Field")
    var
        ICMTableL: Record "ICM Table";
    begin
        if ICMTableL.Get(CMITableFieldR."ICM Company Name", CMITableFieldR."ICM Table ID") then
            ICMTableL.TestField("ICM Apply Table Fields", ICMTableL."ICM Apply Table Fields"::"Some Fields");
        CMITableFieldR.SetRange("ICM Primary Key", false);
        if CMITableFieldR.FindSet(true) then
            repeat
                CMITableFieldR."ICM Include Field" := false;
                CMITableFieldR.Modify();
            until CMITableFieldR.Next() = 0;
    end;

    procedure CopyTablesFromToCompany(FromCompanyName: Text[30]; ToCompanyName: Text[30])
    var
        ICMTableL: Record "ICM Table";
        ICMTableFieldL: Record "ICM Table Field";
        ICMSetupL: Record "ICM Setup";
        SourceRecRefL: RecordRef;
        TargetRecRefL: RecordRef;
        FieldRefL: FieldRef;
        TargetFieldRefL: FieldRef;
        CopiedTableCountL: Integer;
        SkippedTableCountL: Integer;
        iL: Integer;
    begin
        ICMSetupL.Get();
        ICMTableL.SetRange("ICM Active", true);
        ICMTableL.SetRange("ICM Company Name", FromCompanyName);

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


        if ICMTableL.FindSet() then
            repeat

                if GuiAllowed then Begin
                    WindowDialogIndex1 += 1;
                    WindowDialog.Update(1, FormatPercentage(WindowDialogIndex1 / WindowDialogCount1 * 100));
                End;

                SourceRecRefL.Open(ICMTableL."ICM Table ID", false, FromCompanyName); //ICMTableL."ICM Company Name");
                TargetRecRefL.Open(ICMTableL."ICM Table ID", false, ToCompanyName);

                Clear(CopiedTableCountL);
                Clear(SkippedTableCountL);

                if ICMSetupL."ICM Table data processing" = ICMSetupL."ICM Table data processing"::"Overwrite existing data" then
                    TryDeleteAll(TargetRecRefL);

                ICMTableFieldL.Reset();
                //prüfen key
                ICMTableFieldL.SetRange("ICM Company Name", ICMTableL."ICM Company Name");
                ICMTableFieldL.SetRange("ICM Table ID", ICMTableL."ICM Table ID");
                ICMTableFieldL.SetRange("ICM Include Field", true);

                if SourceRecRefL.FindSet() then begin
                    repeat
                        //TargetRecRefL.Init();

                        if ICMTableFieldL.FindSet() then begin
                            repeat
                                FieldRefL := SourceRecRefL.Field(ICMTableFieldL."ICM Field ID");

                                if not (FieldRefL.Class() = FieldClass::FlowField) then begin
                                    TargetFieldRefL := TargetRecRefL.Field(ICMTableFieldL."ICM Field ID");
                                    TargetFieldRefL.Value := FieldRefL.Value;
                                end;
                            until ICMTableFieldL.Next() = 0;
                        end;
                        TargetRecRefL.Insert();

                    //if TryInsertRecord(TargetRecRefL) then
                    //    CopiedTableCountL += 1
                    //else
                    //    SkippedTableCountL += 1;

                    until SourceRecRefL.Next() = 0;
                end;

                CopiedTableCountL += 1;
                SourceRecRefL.Close();
                TargetRecRefL.Close();


            until ICMTableL.Next() = 0;

        if GuiAllowed then
            WindowDialog.Close();

        if GuiAllowed then
            Message(Text007Lbl, CopiedTableCountL);
        //Message(Text004Lbl, CopiedTableCountL, SkippedTableCountL);
    end;

    procedure CopyTablesFromToCompany2(PackageCodeR: Code[20])
    var
        ICMSetupL: Record "ICM Setup";
        ICMConfigPackageL: Record "ICM Data Transfer Package";
        ICMConfigPackageLineL: Record "ICM Data Transfer Package Line";
        ICMConfigPackageFieldL: Record "ICM Data Transf. Package Field";
        SourceRecRefL: RecordRef;
        TargetRecRefL: RecordRef;
        FieldRefL: FieldRef;
        TargetFieldRefL: FieldRef;
        CopiedTableCountL: Integer;
        SkippedTableCountL: Integer;
        i: Integer;
    begin
        ICMSetupL.Get();
        ICMConfigPackageL.Get(PackageCodeR);

        ICMConfigPackageLineL.Reset();
        ICMConfigPackageLineL.SetRange("ICM Package Code", PackageCodeR);
        ICMConfigPackageLineL.SetRange("ICM Active", true);

        if ICMConfigPackageLineL.IsEmpty then begin
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
            WindowDialogCount1 := ICMConfigPackageLineL.Count;
        End;

        if ICMConfigPackageLineL.FindSet() then
            repeat
                if GuiAllowed then Begin
                    WindowDialogIndex1 += 1;
                    WindowDialog.Update(1, FormatPercentage(WindowDialogIndex1 / WindowDialogCount1 * 100));
                End;

                SourceRecRefL.Open(ICMConfigPackageLineL."ICM Table ID", false, ICMConfigPackageL."ICM Source Company Name");
                TargetRecRefL.Open(ICMConfigPackageLineL."ICM Table ID", false, ICMConfigPackageL."ICM Target Company Name");

                Clear(CopiedTableCountL);
                Clear(SkippedTableCountL);

                if ICMSetupL."ICM Table data processing" = ICMSetupL."ICM Table data processing"::"Overwrite existing data" then
                    TryDeleteAll(TargetRecRefL);

                if SourceRecRefL.FindSet() then begin
                    repeat
                        //TargetRecRefL.Init();

                        ICMConfigPackageFieldL.Reset();
                        ICMConfigPackageFieldL.SetRange("ICM Package Code", ICMConfigPackageLineL."ICM Package Code");
                        ICMConfigPackageFieldL.SetRange("ICM Table ID", ICMConfigPackageLineL."ICM Table ID");
                        ICMConfigPackageFieldL.SetRange("ICM Include Field", true);
                        if ICMConfigPackageFieldL.FindSet() then begin
                            repeat
                                FieldRefL := SourceRecRefL.Field(ICMConfigPackageFieldL."ICM Field ID");

                                if not (FieldRefL.Class() = FieldClass::FlowField) then begin
                                    TargetFieldRefL := TargetRecRefL.Field(ICMConfigPackageFieldL."ICM Field ID");
                                    TargetFieldRefL.Value := FieldRefL.Value;
                                end;
                            until ICMConfigPackageFieldL.Next() = 0;
                        end;
                        TargetRecRefL.Insert();

                    //if TryInsertRecord(TargetRecRefL) then
                    //    CopiedTableCountL += 1
                    //else
                    //    SkippedTableCountL += 1;

                    until SourceRecRefL.Next() = 0;
                end;

                CopiedTableCountL += 1;

                SourceRecRefL.Close();
                TargetRecRefL.Close();


            until ICMConfigPackageLineL.Next() = 0;

        if GuiAllowed then
            WindowDialog.Close();

        if GuiAllowed then
            Message(Text007Lbl, CopiedTableCountL);
        //Message(Text004Lbl, CopiedTableCountL, SkippedTableCountL);

    end;


    [TryFunction]
    local procedure TryInsertRecord(var RecRefR: RecordRef)
    begin
        RecRefR.Insert();
    end;

    [TryFunction]
    local procedure TryDeleteAll(var RecRefR: RecordRef)
    begin
        if RecRefR.Number <> 0 then
            RecRefR.DeleteAll();
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

    local procedure CopyConfigPackage(PackageCodeR: Code[20])
    var
        ICMConfigPackageL: Record "ICM Data Transfer Package";
        ICMConfigPackageLineL: Record "ICM Data Transfer Package Line";
    begin

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
        Text004Lbl: Label '%1 table copied. %2 tables skipped.';
        Text005Lbl: Label 'The list of Tables is being updated...\\';
        Text006Lbl: Label 'The list of Tables is being copied...\\';
        Text007Lbl: Label '%1 table copied.';
}
