permissionset 50400 "ICM Copy Company"
{
    Assignable = true;
    Permissions = tabledata "ICM Table" = RIMD,
        table "ICM Table" = X,
        codeunit "ICM Management" = X,
        page "ICM Tables List" = X,
        report "ICM Copy Tables" = X,
        tabledata "ICM Setup" = RIMD,
        table "ICM Setup" = X,
        page "ICM Setup" = X,
        tabledata "ICM Data Transfer Package" = RIMD,
        tabledata "ICM Data Transfer Package Line" = RIMD,
        table "ICM Data Transfer Package" = X,
        table "ICM Data Transfer Package Line" = X,
        page "ICM Config. Package Card" = X,
        page "ICM Config. Package Subform" = X,
        page "ICM Config. Package List" = X,
        tabledata "ICM Data Transf. Package Field" = RIMD,
        table "ICM Data Transf. Package Field" = X,
        page "ICM Config. Package Fields" = X,
        tabledata "ICM Table Field" = RIMD,
        table "ICM Table Field" = X,
        page "ICM Table Fields" = X;
}