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
        page "ICM Setup" = X;
}