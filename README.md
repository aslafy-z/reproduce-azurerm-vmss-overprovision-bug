# reproduce-azurerm-vmss-overprovision-bug

Reproduction for bug described in https://github.com/hashicorp/terraform-provider-azurerm/issues/13576

## Reproduction steps

1. `terraform apply`
2. Uncomment `overprovision = false`
3. `terraform apply`
4. `terraform plan` shows needed changes
