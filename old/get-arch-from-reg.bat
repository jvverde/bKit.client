@echo OFF
:: http://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" /v Identifier
