namespace DefaultPublisher;

using Microsoft.Inventory.Item;
using System.Reflection;

codeunit 50400 "ICM Management"
{
    procedure FillCompanyTableInformation()
    var
        AllObjWithCaptionL: Record AllObjWithCaption;
        ICMTableL: Record "ICM Table";
        RecRefL: RecordRef;
        TableCountL: Integer;
    begin
        AllObjWithCaptionL.SetRange("Object Type", AllObjWithCaptionL."Object Type"::Table);
        AllObjWithCaptionL.SetRange("Object ID", 1, 99999999);

        if AllObjWithCaptionL.FindSet() then begin
            if GuiAllowed then Begin
                WindowDialog.Open(Text005Lbl +
                  '#1###################\' +
                  '#2###################'
                );
                WindowDialogIndex1 := 0;
                WindowDialogCount1 := AllObjWithCaptionL.Count;
            End;

            repeat
                if GuiAllowed then Begin
                    WindowDialogIndex1 += 1;
                    WindowDialog.Update(1, FormatPercentage(WindowDialogIndex1 / WindowDialogCount1 * 100));
                End;

                if AllObjWithCaptionL."Object Type" <> AllObjWithCaptionL."Object Type"::System then
                    //    if CheckTableInLicense(AllObjWithCaptionL."Object ID") and HasTableRecords(AllObjWithCaptionL."Object ID") then
                    if CheckTableInLicense(AllObjWithCaptionL."Object ID") then
                        UpdateICMTableLine(AllObjWithCaptionL, ICMTableL);


            until AllObjWithCaptionL.Next() = 0;
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
    local procedure UpdateICMTableLine(var TableInfo: Record AllObjWithCaption; var ICMTable: Record "ICM Table")
    var
        RecRef: RecordRef;
        RecordCount: Integer;
    begin
        if not ICMTable.Get(TableInfo."Object ID") then begin
            ICMTable.Init();
            ICMTable."ICM Table ID" := TableInfo."Object ID";
            ICMTable."ICM Table Name" := TableInfo."Object Name";
            ICMTable."ICM Table Caption" := TableInfo."Object Caption";
            ICMTable."ICM Table Subtype" := TableInfo."Object Subtype";
            ICMTable."ICM Company Name" := CompanyName();
            ICMTable."ICM Active" := false;

            ICMTable.Insert();
        end;

        if ICMTable."ICM Table Subtype" = 'Normal' then begin
            if SafeOpenTable(TableInfo."Object ID", RecRef) then begin
                RecordCount := RecRef.Count();
                ICMTable."ICM Has Records" := RecordCount > 0;
                ICMTable."ICM Record Count" := RecordCount;
                ICMTable."ICM Included in the License" := CheckTableInLicense(TableInfo."Object ID");
                ICMTable."ICM Active" := true;
                ICMtable.Modify();
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


    /// <summary>
    /// Copies the table contents from FromCompany to ToCompany for all active Lines in ICM Table
    /// </summary>
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
