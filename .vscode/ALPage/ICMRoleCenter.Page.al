page 50409 "ICM Role Center"
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
                    Caption = 'Data Transfer Tables';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "ICM Data Transfer Tables List";
                }
                action(DataTransferPackageList)
                {
                    Caption = 'Data Transfer Package List';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "ICM Data Transfer Package List";
                }
                action(DataTransferPackageLogList)
                {
                    Caption = 'Transfer Data Log List';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "ICM Transfer Data Log List";
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                action(DataTransferSetup)
                {
                    Caption = 'Setup';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "ICM Data Transfer Setup";
                }
            }
        }
    }

}