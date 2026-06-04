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
        tabledata "CMI Config. Package" = RIMD,
        tabledata "CMI Config. Package Line" = RIMD,
        table "CMI Config. Package" = X,
        table "CMI Config. Package Line" = X,
        page "CMI Config. Package Card" = X,
        page "CMI Config. Package Subform" = X,
        page "CMI Config. Package List" = X,
        tabledata "CMI Config. Package Field" = RIMD,
        table "CMI Config. Package Field" = X,
        page "ICM Config. Package Fields" = X;
}