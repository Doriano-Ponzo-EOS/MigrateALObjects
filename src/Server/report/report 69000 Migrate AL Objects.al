report 69000 "Migrate AL Objects"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Migrate AL Objects';

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(FolderPath; FolderPath)
                    {
                        ApplicationArea = All;
                        Caption = 'Folder Path';
                    }

                    field(MigrateAppsourceObjects; MigrateAppsourceObjects)
                    {
                        ApplicationArea = All;
                        Caption = 'Migrate Appsource Objects';
                    }
                    field(RemoveAppsourceObjects; RemoveAppsourceObjects)
                    {
                        ApplicationArea = All;
                        Caption = 'Remove Appsource Objects';
                    }
                    field(RemoveNotAppsuorceObjects; RemoveNotAppsuorceObjects)
                    {
                        ApplicationArea = All;
                        Caption = 'Remove Not Appsource Objects';
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            myInt: Integer;
        begin
            FolderPath := 'C:\run\my\ALObjects';
        end;
    }

    trigger OnPreReport()
    begin
        ReadFilesFromFolder()
    end;

    procedure ReadFilesFromFolder()
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        FileMgt: Codeunit "File Management";
        ALFile: File;
        ALFile2: File;
        ALFileExtensionTok: Label '*.al';
        FileContent: Text;
        IStream: InStream;
        OStream: OutStream;
        Txt: Text;
        NewTxt: Text;
        Dlg: Dialog;
        FileCount: Integer;
        LineCount: Integer;
        FromFileName: Text;
        ToFileName: Text;
        Appsource: Boolean;
        AppsourceObject: Boolean;
        Text001Msg: Label 'Processing %1 of %2';
    begin
        TempNameValueBuffer.Reset();
        TempNameValueBuffer.DeleteAll();
        Clear(FileCount);

        FileMgt.GetServerDirectoryFilesListInclSubDirs(TempNameValueBuffer, FolderPath);
        if TempNameValueBuffer.FindSet() then begin
            if GuiAllowed then
                Dlg.Open(StrSubstNo(Text001Msg, FileCount, TempNameValueBuffer.Count));
            repeat
                Clear(IStream);
                Clear(OStream);
                Clear(LineCount);
                Clear(AppsourceObject);

                FileCount += 1;
                if GuiAllowed then
                    Dlg.Open(StrSubstNo(Text001Msg, FileCount, TempNameValueBuffer.Count));

                if FileMgt.GetExtension(TempNameValueBuffer.Name) = 'al' then begin
                    ALFile.Open(TempNameValueBuffer.Name);

                    //ALFile2.Create(FolderPath + '\Processed\' + TempNameValueBuffer.Value + '_new.al');
                    ALFile2.Create(FolderPath + '\' + TempNameValueBuffer.Value + '_new.al');
                    ALFile2.CreateOutStream(OStream);

                    ALFile.CreateInStream(IStream);

                    while not (IStream.EOS) do begin
                        LineCount += 1;
                        IStream.ReadText(Txt);
                        NewTxt := ProcessLine(Txt, LineCount, Appsource);
                        if LineCount = 1 then
                            AppsourceObject := Appsource;
                        OStream.WriteText(NewTxt);
                        OStream.WriteText();
                    end;

                    FromFileName := ALFile2.Name;
                    ToFileName := ALFile.Name;
                    ALFile2.Close();
                    ALFile.Close();

                    if AppsourceObject then begin
                        if MigrateAppsourceObjects then
                            File.Copy(FromFileName, ToFileName);
                        if RemoveAppsourceObjects then
                            File.Erase(ToFileName);
                    end else begin
                        if RemoveNotAppsuorceObjects then
                            File.Erase(ToFileName);
                    end;

                    File.Erase(FromFileName);
                end;
            until TempNameValueBuffer.Next() = 0;
            if GuiAllowed then
                Dlg.Close();
        end;
    end;

    var
        FolderPath: Text[250];
        MigrateAppsourceObjects: Boolean;
        RemoveAppsourceObjects: Boolean;
        RemoveNotAppsuorceObjects: Boolean;

    procedure ProcessLine(Txt: Text; LineCount: Integer; var Appsource: Boolean) NewTxt: Text;
    var
        ALObjectMigrationBuffer: Record "AL Object Migration Buffer";
        SkipLine: Boolean;
        StringsToFind: List of [Text];
        StringToFind: Text;
        Count: Integer;
    begin
        NewTxt := Txt;
        //first line
        if LineCount = 1 then begin
            Clear(SkipLine);
            ALObjectMigrationBuffer.Reset();
            case true of
                NewTxt.StartsWith('table '):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Table);
                    end;
                NewTxt.StartsWith('page '):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Page);
                    end;
                NewTxt.StartsWith('report'):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Report);
                    end;
                NewTxt.StartsWith('codeunit'):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Codeunit);
                    end;
                NewTxt.StartsWith('query'):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Query);
                    end;
                NewTxt.StartsWith('enum '):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Enum);
                    end;
                NewTxt.StartsWith('permissionset'):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::PermissionSet);
                    end;
                NewTxt.StartsWith('tableextension'):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::TableExtension);
                    end;
                NewTxt.StartsWith('pageextension'):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::PageExtension);
                    end;
                NewTxt.StartsWith('enumextension'):
                    begin
                        ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::EnumExtension);
                    end;
                else
                    SkipLine := true;
            end;
            if not SkipLine then
                Appsource := ReplaceFromBuffer(NewTxt, ALObjectMigrationBuffer, true, true);
        end else begin
            //Variables
            ReplaceVariables(NewTxt, ': Record ', ALObjectMigrationBuffer."Object Type"::Table);
            ReplaceVariables(NewTxt, ': Page ', ALObjectMigrationBuffer."Object Type"::Page);
            ReplaceVariables(NewTxt, ': Report ', ALObjectMigrationBuffer."Object Type"::Report);
            ReplaceVariables(NewTxt, ': Codeunit ', ALObjectMigrationBuffer."Object Type"::Codeunit);
            ReplaceVariables(NewTxt, ': Query ', ALObjectMigrationBuffer."Object Type"::Query);
            ReplaceVariables(NewTxt, ': Enum ', ALObjectMigrationBuffer."Object Type"::Enum);

            //Table references
            Clear(StringsToFind);
            StringsToFind.Add('TableRelation = ');
            StringsToFind.Add('CalcFormula = ');
            StringsToFind.Add('SourceTable = ');
            StringsToFind.Add(' TableNo = ');
            StringsToFind.Add('Database::');
            StringsToFind.Add('DATABASE::');
            StringsToFind.Add(' tabledata ');
            StringsToFind.Add(' TableData ');
            foreach StringToFind in StringsToFind do begin
                if NewTxt.Contains(StringToFind) then begin
                    ALObjectMigrationBuffer.Reset();
                    ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Table);
                    ReplaceFromBuffer(NewTxt, ALObjectMigrationBuffer, false, true);
                end;
            end;

            //Page references
            Clear(StringsToFind);
            StringsToFind.Add('PageId = ');
            StringsToFind.Add('PageID = ');
            StringsToFind.Add('RunObject = page');
            StringsToFind.Add('RunObject = Page');
            StringsToFind.Add(' part(');
            StringsToFind.Add('Page::');
            StringsToFind.Add('page::');
            foreach StringToFind in StringsToFind do begin
                if NewTxt.Contains(StringToFind) then begin
                    ALObjectMigrationBuffer.Reset();
                    ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Page);
                    ReplaceFromBuffer(NewTxt, ALObjectMigrationBuffer, false, true);
                end;
            end;

            //Codeunit references
            Clear(StringsToFind);
            StringsToFind.Add('Codeunit::');
            StringsToFind.Add('CODEUNIT::');
            StringsToFind.Add('RunObject = codeunit');
            StringsToFind.Add('RunObject = Codeunit');
            foreach StringToFind in StringsToFind do begin
                if NewTxt.Contains(StringToFind) then begin
                    ALObjectMigrationBuffer.Reset();
                    ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Codeunit);
                    ReplaceFromBuffer(NewTxt, ALObjectMigrationBuffer, false, true);
                end;
            end;

            //Report references
            Clear(StringsToFind);
            StringsToFind.Add('Report::');
            StringsToFind.Add('REPORT::');
            StringsToFind.Add('RunObject = report');
            StringsToFind.Add('RunObject = Report');
            StringsToFind.Add('dataitem(');
            foreach StringToFind in StringsToFind do begin
                if NewTxt.Contains(StringToFind) then begin
                    ALObjectMigrationBuffer.Reset();
                    ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Report);
                    ReplaceFromBuffer(NewTxt, ALObjectMigrationBuffer, false, true);
                end;
            end;

            //Enum references
            Clear(StringsToFind);
            StringsToFind.Add('; enum ');
            StringsToFind.Add('; Enum ');
            StringsToFind.Add('Enum::');
            StringsToFind.Add(': enum ');
            foreach StringToFind in StringsToFind do begin
                if NewTxt.Contains(StringToFind) then begin
                    ALObjectMigrationBuffer.Reset();
                    ALObjectMigrationBuffer.SetRange("Object Type", ALObjectMigrationBuffer."Object Type"::Enum);
                    ReplaceFromBuffer(NewTxt, ALObjectMigrationBuffer, false, true);
                end;
            end;
        end;
    end;

    procedure ReplaceFromBuffer(var NewTxt: Text; var ALObjectMigrationBuffer: Record "AL Object Migration Buffer"; ID: Boolean; Name: Boolean) Appsource: Boolean
    var
        Replaced: Boolean;
    begin
        Replaced := false;
        if ALObjectMigrationBuffer.FindSet() then
            repeat
                if ID then
                    if NewTxt.Contains(format(ALObjectMigrationBuffer."From Object Id")) then begin
                        NewTxt := NewTxt.Replace(format(ALObjectMigrationBuffer."From Object Id"), format(ALObjectMigrationBuffer."To Object Id"));
                        Replaced := true;
                        Appsource := ALObjectMigrationBuffer.Appsource;
                    end;
                if Name then begin
                    if ALObjectMigrationBuffer."From Object Name".Contains(' ') then begin
                        if Replaced or NewTxt.Contains('"' + ALObjectMigrationBuffer."From Object Name" + '"') then begin
                            NewTxt := NewTxt.Replace('"' + ALObjectMigrationBuffer."From Object Name" + '"', '"' + ALObjectMigrationBuffer."To Object Name" + '"');
                            Replaced := true;
                            Appsource := ALObjectMigrationBuffer.Appsource;
                        end
                    end else
                        if Replaced or NewTxt.Contains(ALObjectMigrationBuffer."From Object Name") then begin
                            NewTxt := NewTxt.Replace(ALObjectMigrationBuffer."From Object Name", '"' + ALObjectMigrationBuffer."To Object Name" + '"');
                            Replaced := true;
                            Appsource := ALObjectMigrationBuffer.Appsource;
                        end;
                end;
            until (ALObjectMigrationBuffer.Next() = 0) or Replaced;
    end;

    procedure ReplaceVariables(var NewTxt: Text; StringToFind: Text; ObjectType: Integer)
    var
        ALObjectMigrationBuffer: Record "AL Object Migration Buffer";
        Count: Integer;
    begin
        if NewTxt.Contains(StringToFind) then begin
            Count := SubStrCount(NewTxt, StringToFind);
            ALObjectMigrationBuffer.Reset();
            ALObjectMigrationBuffer.SetRange("Object Type", ObjectType);
            repeat
                ReplaceFromBuffer(NewTxt, ALObjectMigrationBuffer, false, true);
                Count -= 1;
            until Count = 0;
        end;
    end;

    procedure SubStrCount(String: Text; Substring: Text) Count: Integer
    begin
        while StrPos(String, Substring) > 0 do begin
            Count := Count + 1;
            String := CopyStr(String, StrPos(String, SubString) + StrLen(SubString));
        end;
    end;

}