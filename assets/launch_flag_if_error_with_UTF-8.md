  ```shell
  powershell -ExecutionPolicy Bypass -Command "Get-Content -Path
  'Your_script.ps1' -Encoding UTF8 -Raw | Invoke-Expression"
  ```