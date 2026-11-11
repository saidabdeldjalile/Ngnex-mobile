with open('Views/ProductsForm.pas', 'r', encoding='utf-8') as f:
    c = f.read()

import re

pattern = r'procedure TFrameProducts\.LoadData;.*?end;'
replacement = '''procedure TFrameProducts.LoadData;
var
  SortParam: string;
begin
  if DM = nil then Exit;

  case cmbSort.ItemIndex of
    1: SortParam := 'price_asc';
    2: SortParam := 'price_desc';
    3: SortParam := 'newest';
  else
    SortParam := 'name_asc';
  end;

  DM.ProductService.FetchProducts(FProductList, FCurrentCategoryID, FSearchText, SortParam);

  if not FSearchText.Trim.IsEmpty then
    lblFilterStatus.Text := Format('Recherche: "%s" (%d équipement(s))', [FSearchText, FProductList.Count])
  else if FCurrentCategoryID > 0 then
    lblFilterStatus.Text := Format('Catégorie sélectionnée (%d équipement(s))', [FProductList.Count])
  else
    lblFilterStatus.Text := Format('Tous les équipements POS (%d articles)', [FProductList.Count]);
end;'''

c_new, count = re.subn(pattern, replacement, c, count=1, flags=re.DOTALL)
if count > 0:
    with open('Views/ProductsForm.pas', 'w', encoding='utf-8', newline='\r\n') as f:
        f.write(c_new)
    print('ProductsForm.pas LoadData updated successfully')
else:
    print('Failed to match pattern')

