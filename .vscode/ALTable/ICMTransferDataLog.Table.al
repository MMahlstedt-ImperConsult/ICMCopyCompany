namespace ImperConsult.CopyCompany;

using System.Environment;
using System.Security.AccessControl;

table 50406 "ICM Transfer Data Log"
{
    Caption = 'Transfer Data Log';
    DataClassification = ToBeClassified;
    Extensible = true;
    DataPerCompany = true;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Table No."; Code[20])
        {
            Caption = 'Table No.';//'Tabellenr';
            //TableRelation = "Object";
        }
        field(3; "Table Caption"; Text[250])
        {
            Caption = 'Table Caption';//Tabellenbeschriftung';
            Editable = false;
        }
        field(4; "Records Available"; Integer)
        {
            Caption = 'Records Available';//'Datensätze vorhanden';
            MinValue = 0;
            Editable = false;
        }
        field(5; "Records Transferred"; Integer)
        {
            Caption = 'Records Transferred';//Datensätze übertragen';
            MinValue = 0;
            Editable = false;
        }
        field(6; "Source Company"; Text[30])
        {
            Caption = 'Source Company';//Quellmandant';
            TableRelation = Company;
        }
        field(7; "Target Company"; Text[30])
        {
            Caption = 'Target Company';//Zielmandant';
            TableRelation = Company;
        }
        field(8; "Transferred Date"; DateTime)
        {
            Caption = 'Transferred Date';//Übertragen am';
            Editable = false;
        }
        field(9; "Transferred By"; Code[50])
        {
            Caption = 'Transferred By';//Übertragen von';
            TableRelation = User;
            Editable = false;
        }
        field(10; "Filter Exists"; Boolean)
        {
            Caption = 'Filter Exists';//Filter vorhanden';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SK1; "Table No.", "Source Company", "Target Company", "Transferred Date")
        {
        }
    }

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin
    end;

    trigger OnDelete()
    begin
    end;

    trigger OnRename()
    begin
    end;
}
