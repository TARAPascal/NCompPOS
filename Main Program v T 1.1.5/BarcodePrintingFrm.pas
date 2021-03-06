unit BarcodePrintingFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RpRave, RpDefine, RpBase, RpSystem, StdCtrls, Mask, JvExMask, JvSpin,
  Buttons, JvExButtons, JvBitBtn;

type
  TBarcodePrintingForm = class(TForm)
    BarcodeList: TRvSystem;
    JvBitBtn1: TJvBitBtn;
    JvBitBtn2: TJvBitBtn;
    RvProject1: TRvProject;
    JvSpinEdit1: TJvSpinEdit;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure JvBitBtn2Click(Sender: TObject);
    procedure BarcodeListPrint(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure BarcodeListBeforePrint(Sender: TObject);
  private
    procedure Print(Report: TBaseReport);
    procedure PrintTransfer(Report: TBaseReport);
    procedure PrintInvItems(Report: TBaseReport);
    procedure PrintPInvItems(Report: TBaseReport);
    { Private declarations }
  public
    FromWhere: String;
    { Public declarations }
  end;

var
  BarcodePrintingForm: TBarcodePrintingForm;

implementation
    uses DataFrm2, StockFrm;

{$R *.dfm}

procedure TBarcodePrintingForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
      DataForm2.StockQuery.Close;
      BarcodePrintingForm.FreeOnRelease;
end;

procedure TBarcodePrintingForm.JvBitBtn2Click(Sender: TObject);
begin
     BarcodeList.Execute;
end;

procedure TBarcodePrintingForm.BarcodeListBeforePrint(Sender: TObject);
begin
      if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
      begin
        BarcodeList.BaseReport.SetPaperSize(0,3,1);
      end;
end;

procedure TBarcodePrintingForm.BarcodeListPrint(Sender: TObject);
begin
      If FromWhere = 'StockA' then
        Print(BarcodeList.BaseReport)
      else
      begin
        If FromWhere = 'StockT' then
          PrintTransfer(BarcodeList.BaseReport)
        else
        begin
          If FromWhere = 'InvItem' then
            PrintInvItems(BarcodeList.BaseReport)
          else
            PrintPInvItems(BarcodeList.BaseReport);
        end;
      end;
end;

procedure TBarcodePrintingForm.Print(Report:TBaseReport);
var
   count, i, i2: Integer;
begin
//      report.SetPaperSize(Custom,1,3)
      with report do
      begin
//        SetPaperSize(0,1,3);
        count := 0;
//        Showmessage(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1'));
        if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
          RvProject1.ProjectFile := Dataform2.ProgramPath + '\Barcode.rav'
        else
          RvProject1.ProjectFile := Dataform2.ProgramPath + '\BarcodeSingle.rav';
        Dataform2.StockQuery.DisableControls;
        Dataform2.StockQuery.First;
        while not DataForm2.StockQuery.EOF do
        begin
          if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
            i2 := StrtoInt(Floattostrf(Dataform2.StockQuery.Fieldbyname('Qty').asFloat / 2,ffFixed,17,0))
          else
            i2 := StrtoInt(Floattostrf(Dataform2.StockQuery.Fieldbyname('Qty').asFloat,ffFixed,17,0));
          for i := 1 to i2 do
          begin
            If JvSpinEdit1.Value <> 0 then
            begin
              inc(count);
              If count > JvSpinEdit1.Value then
                break;
            end;
//            Showmessage(RvProject1.ProjectFile);
            RvProject1.SelectReport('Page1',False);
             If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
              RvProject1.SetParam('Barcode1',Uppercase(Dataform2.StockQuery.FieldByName('TCStockNo').asString))
             else
              RvProject1.SetParam('Barcode1',Uppercase(Dataform2.StockQuery.FieldByName('Barcode').asString));
            RvProject1.SetParam('Name',Dataform2.StockQuery.FieldByName('Description').asString);
            If StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodeprice', '0')) = True then
              RvProject1.SetParam('Price','')
            else
              RvProject1.SetParam('Price','R ' + Floattostrf(DataForm2.StockQuery.FieldByName('SalesPrice').asFloat,ffFixed,17,2));
            RvProject1.Execute;
            NewPage;
          end;
          DataForm2.StockQuery.Next;
        end;
        DataForm2.StockQuery.EnableControls;
      end;
end;

procedure TBarcodePrintingForm.PrintTransfer(Report:TBaseReport);
var
   count, i, i2: Integer;
   s: String;
begin
      with report do
      begin
        count := 0;
        if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
          RvProject1.ProjectFile := Dataform2.ProgramPath + '\Barcode.rav'
        else
          RvProject1.ProjectFile := Dataform2.ProgramPath + '\BarcodeSingle.rav';
        DataForm2.StocktrnsferItemTable.DisableControls;
        DataForm2.StocktrnsferItemTable.first;
        while not DataForm2.StocktrnsferItemTable.EOF do
        begin
          if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
            i2 := StrtoInt(Floattostrf(Dataform2.StocktrnsferItemTable.Fieldbyname('Qty').asFloat / 2,ffFixed,17,0))
          else
            i2 := StrtoInt(Floattostrf(Dataform2.StocktrnsferItemTable.Fieldbyname('Qty').asFloat,ffFixed,17,0));
          Dataform2.StockQuery.Close;
          If CheckBox1.Checked = True then
          begin
            If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
              s := 'and TCStockNo Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + ''''
            else
              s := 'and Barcode Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + '''';
          end
          else
            s := '';
          with DataForm2.StockQuery.SQL do begin
            Clear;
            Add('SELECT * FROM stock_db');
            Add('Where Nr = ' + InttoStr(DataForm2.StocktrnsferItemTableStockNo.Value));
            Add(s);
          end;
          Dataform2.StockQuery.Open;
          If Dataform2.StockQuery.RecordCount <> 0 then
          begin
            for i := 1 to i2 do
            begin
              If JvSpinEdit1.Value <> 0 then
              begin
                inc(count);
                If count > JvSpinEdit1.Value then
                  break;
              end;
              RvProject1.SelectReport('Page1',False);
              If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
                RvProject1.SetParam('Barcode1',Uppercase(Dataform2.StockQuery.FieldByName('TCStockNo').asString))
              else
                RvProject1.SetParam('Barcode1',Uppercase(Dataform2.StockQuery.FieldByName('Barcode').asString));
              RvProject1.SetParam('Name',Dataform2.StockQuery.FieldByName('Description').asString);
              If StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodeprice', '0')) = True then
                RvProject1.SetParam('Price','')
              else
                RvProject1.SetParam('Price','R ' + Floattostrf(DataForm2.StockQuery.FieldByName('SalesPrice').asFloat,ffFixed,17,2));
              RvProject1.Execute;
              NewPage;
            end;
          end;
          DataForm2.StocktrnsferItemTable.Next;
        end;
        DataForm2.StocktrnsferItemTable.EnableControls;
      end;
end;

procedure TBarcodePrintingForm.CheckBox1Click(Sender: TObject);
var
      s: String;
begin
    If FromWhere = 'StockA' then
    begin
      If CheckBox1.Checked = True then
      begin
        If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
          s := 'and TCStockNo Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + ''''
        else
          s := 'and Barcode Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + '''';
        Dataform2.StockQuery.Close;
        with DataForm2.StockQuery.SQL do begin
          Clear;
          Add('SELECT * FROM stock_db');
          Add('Where NonStockItem = "False"');
          Add('and Qty > 0');
          Add('and Barcode <> ''''');
          Add(s);
        end;
        Dataform2.StockQuery.Open;
      end
      else
      begin
        Dataform2.StockQuery.Close;
        with DataForm2.StockQuery.SQL do begin
          Clear;
          Add('SELECT * FROM stock_db');
          Add('Where NonStockItem = "False"');
          Add('and Qty > 0');
          Add('and Barcode <> ''''');
        end;
        Dataform2.StockQuery.Open;
      end;
    end;
end;

procedure TBarcodePrintingForm.Edit1Exit(Sender: TObject);
var
      s: String;
begin
      If CheckBox1.Checked = True then
      begin
        If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
          s := 'and TCStockNo Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + ''''
        else
          s := 'and Barcode Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + '''';
        Dataform2.StockQuery.Close;
        with DataForm2.StockQuery.SQL do begin
          Clear;
          Add('SELECT * FROM stock_db');
          Add('Where NonStockItem = "False"');
          Add('and Qty > 0');
          Add('and Barcode <> ''''');
          Add(s);
        end;
        Dataform2.StockQuery.Open;
      end;
end;

procedure TBarcodePrintingForm.Edit2Exit(Sender: TObject);
var
      s : String;
begin
      If CheckBox1.Checked = True then
      begin
        If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
          s := 'and TCStockNo Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + ''''
        else
          s := 'and Barcode Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + '''';
        Dataform2.StockQuery.Close;
        with DataForm2.StockQuery.SQL do begin
          Clear;
          Add('SELECT * FROM stock_db');
          Add('Where NonStockItem = "False"');
          Add('and Qty > 0');
          Add('and Barcode <> ''''');
          Add(s);
        end;
        Dataform2.StockQuery.Open;
      end;
end;

procedure TBarcodePrintingForm.PrintInvItems(Report:TBaseReport);
var
   count, i, i2: Integer;
   s: String;
begin
      with report do
      begin
        count := 0;
        if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
          RvProject1.ProjectFile := Dataform2.ProgramPath + '\Barcode.rav'
        else
          RvProject1.ProjectFile := Dataform2.ProgramPath + '\BarcodeSingle.rav';
        DataForm2.InvoiceItemTable.DisableControls;
        DataForm2.InvoiceItemTable.first;
        while not DataForm2.InvoiceItemTable.EOF do
        begin
          if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
            i2 := StrtoInt(Floattostrf(Dataform2.InvoiceItemTable.Fieldbyname('Qty').asFloat / 2,ffFixed,17,0))
          else
            i2 := StrtoInt(Floattostrf(Dataform2.InvoiceItemTable.Fieldbyname('Qty').asFloat,ffFixed,17,0));
          Dataform2.StockQuery.Close;
          If CheckBox1.Checked = True then
          begin
            If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
              s := 'and TCStockNo Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + ''''
            else
              s := 'and Barcode Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + '''';
          end
          else
            s := '';
          with DataForm2.StockQuery.SQL do begin
            Clear;
            Add('SELECT * FROM stock_db');
            Add('Where Nr = ' + InttoStr(DataForm2.InvoiceItemTableStockNo.Value));
            Add(s);
          end;
          Dataform2.StockQuery.Open;
          If Dataform2.StockQuery.RecordCount <> 0 then
          begin
            for i := 1 to i2 do
            begin
              If JvSpinEdit1.Value <> 0 then
              begin
                inc(count);
                If count > JvSpinEdit1.Value then
                  break;
              end;
              RvProject1.SelectReport('Page1',False);
              If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
                RvProject1.SetParam('Barcode1',Uppercase(Dataform2.StockQuery.FieldByName('TCStockNo').asString))
              else
                RvProject1.SetParam('Barcode1',Uppercase(Dataform2.StockQuery.FieldByName('Barcode').asString));
              RvProject1.SetParam('Name',Dataform2.StockQuery.FieldByName('Description').asString);
              If StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodeprice', '0')) = True then
                RvProject1.SetParam('Price','')
              else
                RvProject1.SetParam('Price','R ' + Floattostrf(DataForm2.StockQuery.FieldByName('SalesPrice').asFloat,ffFixed,17,2));
              RvProject1.Execute;
              NewPage;
            end;
          end;
          DataForm2.InvoiceItemTable.Next;
        end;
        DataForm2.InvoiceItemTable.EnableControls;
      end;
end;

procedure TBarcodePrintingForm.PrintPInvItems(Report:TBaseReport);
var
   count, i, i2: Integer;
begin
      with report do
      begin
        count := 0;
        if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
          RvProject1.ProjectFile := Dataform2.ProgramPath + '\Barcode.rav'
        else
          RvProject1.ProjectFile := Dataform2.ProgramPath + '\BarcodeSingle.rav';
        DataForm2.PurchaseItemTable.DisableControls;
        DataForm2.PurchaseItemTable.first;
        while not DataForm2.PurchaseItemTable.EOF do
        begin
          if StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodetype', '-1')) = True then
            i2 := StrtoInt(Floattostrf(Dataform2.PurchaseItemTable.Fieldbyname('Qty').asFloat / 2,ffFixed,17,0))
          else
            i2 := StrtoInt(Floattostrf(Dataform2.PurchaseItemTable.Fieldbyname('Qty').asFloat,ffFixed,17,0));
//          Dataform2.StockQuery.Close;
//          If CheckBox1.Checked = True then
//          begin
//            If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
//              s := 'and TCStockNo Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + ''''
//            else
//              s := 'and Barcode Between ''' + Edit1.Text + ''' AND ''' + Edit2.Text + '''';
//          end
//          else
//            s := '';
//          with DataForm2.StockQuery.SQL do begin
//            Clear;
//            Add('SELECT * FROM stock_db');
//            Add('Where Nr = ' + InttoStr(DataForm2.PurchaseItemTableStockNo.Value));
//            Add(s);
//          end;
//          Dataform2.StockQuery.Open;
//          If Dataform2.StockQuery.RecordCount <> 0 then
//          begin
            for i := 1 to i2 do
            begin
              If JvSpinEdit1.Value <> 0 then
              begin
                inc(count);
                If count > JvSpinEdit1.Value then
                  break;
              end;
              RvProject1.SelectReport('Page1',False);
              If StrtoBool(Dataform2.GlobalTableTCStockNoBarcode.Value) = True then
                RvProject1.SetParam('Barcode1',Uppercase(Dataform2.PurchaseItemTable.FieldByName('TCStockNo').asString))
              else
                RvProject1.SetParam('Barcode1',Uppercase(Dataform2.PurchaseItemTable.FieldByName('Barcode').asString));
              RvProject1.SetParam('Name',Dataform2.PurchaseItemTable.FieldByName('Description').asString);
              If StrtoBool(DataForm2.IniFile.ReadString ('Settings', 'Barcodeprice', '0')) = True then
                RvProject1.SetParam('Price','')
              else
                RvProject1.SetParam('Price','R ' + Floattostrf(DataForm2.PurchaseItemTable.FieldByName('Price').asFloat,ffFixed,17,2));
              RvProject1.Execute;
              NewPage;
            end;
    //      end;
          DataForm2.PurchaseItemTable.Next;
        end;
        DataForm2.PurchaseItemTable.EnableControls;
      end;
end;

end.
