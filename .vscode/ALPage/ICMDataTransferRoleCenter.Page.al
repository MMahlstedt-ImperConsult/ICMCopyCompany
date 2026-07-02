namespace ImperConsult.CopyCompany;

using System.Environment.Configuration;

page 50409 "ICM Data Transfer Role Center"
{
    PageType = RoleCenter;
    Caption = 'ICM Data Transfer Role Center';

    layout
    {
        area(RoleCenter)
        {

        }
    }

    actions
    {
        area(Sections)
        {
            group(DataTransfer)
            {
                Caption = 'Data Transfer';
                action(DataTransferTables)
                {
                    Caption = 'Data Transfer Tables List';
                    ApplicationArea = All;
                    RunObject = Page "ICM Data Transfer Tables List";
                }
                action(DataTransferPackageList)
                {
                    Caption = 'Data Transfer Package List';
                    ApplicationArea = All;
                    RunObject = Page "ICM Data Transfer Package List";
                }
                action(DataTransferPackageLogList)
                {
                    Caption = 'Transfer Data Log List';
                    ApplicationArea = All;
                    RunObject = Page "ICM Transfer Data Log List";
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                action(DataTransferSetup)
                {
                    Caption = 'Data Transfer Setup';
                    ApplicationArea = All;
                    RunObject = Page "ICM Data Transfer Setup";
                }
                action(CopyCompany)
                {
                    Caption = 'Copy Company';
                    ApplicationArea = All;
                    RunObject = Report "Copy Company";
                }

            }
        }
    }

}