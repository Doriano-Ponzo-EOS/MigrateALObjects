page 69001 "AL Object Migrations"
{
    ApplicationArea = All;
    Caption = 'AL Object Migrations';
    PageType = List;
    SourceTable = "AL Object Migration Buffer";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Object Type"; Rec."Object Type")
                {
                }
                field("From Object ID"; Rec."From Object ID")
                {
                }
                field("To Object ID"; Rec."To Object ID")
                {
                }
                field("From Object Name"; Rec."From Object Name")
                {
                }
                field("To Object Name"; Rec."To Object Name")
                {
                }
                field(Appsource; Rec.Appsource)
                {
                }
            }
        }
    }
}