table 69020 "SSO Table Migration"
{
    DataClassification = CustomerContent;
    LookupPageId = "SSO Table Migrations";
    DrilldownPageId = "SSO Table Migrations";
    Caption = 'SSO Table Migration';

    fields
    {
        field(1; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
            NotBlank = true;
        }
        field(10; "Table Name"; Text[249])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
        }
        field(100; Status; Enum "SSO Table Migration Status")
        {
            Caption = 'Status';
        }
        field(101; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
        }
        field(102; "Error Call Stack"; Blob)
        {
            Caption = 'Error Call Stack';
        }
        field(103; "Processed Date Time"; DateTime)
        {
            Caption = 'Processed Date Time';
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
            Clustered = true;
        }
    }

    procedure Migrate(): Boolean
    var
        IsError: Boolean;
        SSOTableMigration: Record "SSO Table Migration";
    begin
        SSOTableMigration.GetBySystemId(Rec.SystemId);
        if not Codeunit.Run(Codeunit::"SSO Table Migration Mgt.", SSOTableMigration) then begin
            SSOTableMigration.SetStatusError(GetLastErrorText(), GetLastErrorCallStack());
            SSOTableMigration.Modify();
            IsError := true;
        end;
        Commit();
        exit(not IsError);
    end;

    procedure SetStatusError(ErrorTxt: Text; ErrorCallStack: Text)
    begin
        Rec.Status := Rec.Status::Error;
        Rec."Processed Date Time" := 0DT;
        Rec."Error Message" := CopyStr(ErrorTxt, 1, MaxStrLen(Rec."Error Message"));
        Rec."Processed Date Time" := 0DT;
        SetErrorCallStack(ErrorCallStack);
    end;

    procedure SetStatusProcessed()
    begin
        Rec.Status := Rec.Status::Processed;
        Rec."Processed Date Time" := CurrentDateTime();
        Rec."Error Message" := '';
        Clear(Rec."Error Call Stack");
    end;

    procedure GetErrorCallStack(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.TestField(Status, Rec.Status::Error);
        CalcFields("Error Call Stack");
        if not Rec."Error Call Stack".HasValue then
            exit;
        Rec."Error Call Stack".CreateInStream(InStream, TextEncoding::UTF8);

        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    local procedure SetErrorCallStack(ErrorCallStack: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."Error Call Stack");
        if ErrorCallStack = '' then
            exit;
        Rec."Error Call Stack".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.Write(ErrorCallStack);
    end;
}