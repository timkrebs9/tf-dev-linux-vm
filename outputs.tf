# Copyright (c) Tim Krebs
# SPDX-License-Identifier: MPL-2.0

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}