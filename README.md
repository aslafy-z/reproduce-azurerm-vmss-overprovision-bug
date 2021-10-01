# reproduce-azurerm-vmss-overprovision-bug

1. `terraform apply`
2. Uncomment `overprovision = false`
3. `terraform apply`
4. `terraform plan` shows needed changes
