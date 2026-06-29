namespace ImperConsult.CopyCompany;

using System.Environment;
using System.Security.AccessControl;
using System.Reflection;
using System.IO;

table 50406 "ICM Transfer Data Log"
{
    Caption = 'Transfer Data Log';
    DataClassification = ToBeClassified;
    Extensible = true;
    DataPerCompany = false;
    DrillDownPageId = "ICM Transfer Data Log List";
    LookupPageId = "ICM Transfer Data Log List";

    fields
    {
        field(1; "ICM Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "ICM Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table),
                                                                "Object Subtype" = const('Normal'));
        }
        field(3; "ICM Table Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table),
                                                                        "Object ID" = field("ICM Table No.")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "ICM Records Available"; Integer)
        {
            Caption = 'Records Available';
            MinValue = 0;
            Editable = false;
        }
        field(5; "ICM Records Transferred"; Integer)
        {
            Caption = 'Records Transferred';
            MinValue = 0;
            Editable = false;
        }
        field(6; "ICM Records Skipped"; Integer)
        {
            Caption = 'Records Transferred';
            MinValue = 0;
            Editable = false;
        }
        field(7; "ICM Source Company"; Text[30])
        {
            Caption = 'Source Company';
            TableRelation = Company;
        }
        field(8; "ICM Target Company"; Text[30])
        {
            Caption = 'Target Company';
            TableRelation = Company;
        }
        field(9; "ICM Transferred Date"; DateTime)
        {
            Caption = 'Transferred Date';
            Editable = false;
        }
        field(10; "ICM Transferred By"; Code[50])
        {
            Caption = 'Transferred By';
            TableRelation = User;
            Editable = false;
        }
        field(11; "ICM Filter Exists"; Boolean)
        {
            Caption = 'Filter Exists';
            Editable = false;
        }
        field(12; "ICM Page ID"; Integer)
        {
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
            Editable = false;
        }
        field(14; "Transaction ID"; Integer)
        {
            Caption = 'Transaction ID';
            Editable = false;
        }
        field(15; "ICM Package Code"; Code[20])
        {
            Caption = 'Data Transfer Package Code';
            Editable = false;
        }
        field(16; "ICM Filter Text"; Text[250])
        {
            Caption = 'Filter Text';
            Editable = false;
        }

    }

    keys
    {
        key(PK; "ICM Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "ICM Table No.", "ICM Source Company", "ICM Target Company", "ICM Transferred Date")
        {
        }
    }

    procedure GetNextEntryNo(): Integer
    var
        ICMTransferDataLog: Record "ICM Transfer Data Log";
    begin
        if ICMTransferDataLog.FindLast() then
            exit(ICMTransferDataLog."ICM Entry No." + 1)
        else
            exit(1);
    end;

    procedure ShowDatabaseRecords()
    begin
        if "ICM Page ID" <> 0 then
            PAGE.Run("ICM Page ID")
        else
            Error(DefineDrillDownPageMsg, FieldCaption("ICM Page ID"));
    end;

    var
        DefineDrillDownPageMsg: Label 'Define the drill-down page in the %1 field.';
}
