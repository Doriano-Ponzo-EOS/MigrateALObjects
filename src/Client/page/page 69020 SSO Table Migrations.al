page 69020 "SSO Table Migrations"
{
    ApplicationArea = All;
    Caption = 'SSO Table Migrations';
    PageType = List;
    SourceTable = "SSO Table Migration";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ToolTip = 'Specifies the value of the Table ID field.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the value of the Table Name field.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Processed Date Time"; Rec."Processed Date Time")
                {
                    ToolTip = 'Specifies the value of the Processed Date Time field.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the value of the Error Message field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(InitTables)
            {
                ApplicationArea = All;
                Caption = 'Init Tables';
                Image = Insert;

                trigger OnAction();
                var
                    TableMigrationMgt: Codeunit "SSO Table Migration Mgt.";
                begin
                    TableMigrationMgt.InitTableMigrations();
                end;
            }
            action(MigrateSelectedTables)
            {
                ApplicationArea = All;
                Caption = 'Migrate Selected Tables';
                Image = Post;
                ShortCutKey = 'F9';

                trigger OnAction();
                var
                    TableMigration: Record "SSO Table Migration";
                    TableMigrationMgt: Codeunit "SSO Table Migration Mgt.";
                begin
                    CurrPage.SetSelectionFilter(TableMigration);
                    if TableMigration.FindSet() then
                        repeat
                            TableMigration.Migrate();
                        until TableMigration.Next() = 0;
                end;
            }
        }
        area(Navigation)
        {
            action(ShowCallStack)
            {
                ApplicationArea = All;
                Caption = 'Show Call Stack';
                ToolTip = 'Show the call stacktrace message that has stopped the entry.';
                Image = Trace;

                trigger OnAction()
                begin
                    Message(Rec.GetErrorCallStack());
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(Post_InitTables; InitTables)
                {
                }
                actionref(Post_RunMigration; MigrateSelectedTables)
                {
                }
            }
        }
    }
}
