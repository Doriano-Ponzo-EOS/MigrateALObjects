table 69000 "Table Migration Buffer"
{
    DataClassification = CustomerContent;
    Caption = 'Table Migration Buffer';

    fields
    {
        field(1; "From Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'From Table ID';
            NotBlank = true;
        }
        field(2; "From Table Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'From Table Name';
            NotBlank = true;
        }
        field(3; "From Field Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'From Field Name';
            NotBlank = true;
        }
        field(10; "To Table Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'To Table Name';
        }
        field(11; "To Field Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'To Field Name';
        }
        field(5; "Field Type"; Option)
        {
            OptionMembers = TableFilter,RecordID,OemText,Date,Time,DateFormula,Decimal,Media,MediaSet,Text,Code,Binary,BLOB,Boolean,Integer,OemCode,Option,BigInteger,Duration,GUID,DateTime;
        }
    }

    keys
    {
        key(Key1; "From Table ID", "From Table Name", "From Field Name")
        {
            Clustered = true;
        }
    }
}