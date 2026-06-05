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
        tabledata "ICM Config. Package" = RIMD,
        tabledata "ICM Config. Package Line" = RIMD,
        table "ICM Config. Package" = X,
        table "ICM Config. Package Line" = X,
        page "ICM Config. Package Card" = X,
        page "ICM Config. Package Subform" = X,
        page "ICM Config. Package List" = X,
        tabledata "ICM Config. Package Field" = RIMD,
        table "ICM Config. Package Field" = X,
        page "ICM Config. Package Fields" = X;
}