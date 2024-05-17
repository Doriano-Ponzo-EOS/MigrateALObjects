table 69001 "AL Object Migration Buffer"
{
    DataClassification = CustomerContent;
    Caption = 'AL Object Migration Buffer';

    fields
    {
        field(1; "Object Type"; Option)
        {
            Caption = 'Object Type';
            OptionMembers = "TableData","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System","FieldNumber",,,"PageExtension","TableExtension","Enum","EnumExtension","Profile","ProfileExtension","PermissionSet","PermissionSetExtension","ReportExtension";
            OptionCaption = 'TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber,,,PageExtension,TableExtension,Enum,EnumExtension,Profile,ProfileExtension,PermissionSet,PermissionSetExtension,ReportExtension';
        }
        field(2; "From Object ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'From Object ID';
            NotBlank = true;
        }
        field(3; "To Object ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'From Object ID';
        }
        field(10; "From Object Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'From Object Name';
            NotBlank = true;
        }
        field(11; "To Object Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'To Object Name';
        }
        field(12; "Appsource"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Appsource';
        }
    }

    keys
    {
        key(Key1; "Object Type", "From Object ID")
        {
            Clustered = true;
        }
    }
}