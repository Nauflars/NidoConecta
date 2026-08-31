# Playwright MCP

Node.js y npm estan instalados para poder usar Playwright y su servidor MCP.

En esta maquina, si `node`, `npm` o `npx` no aparecen hasta abrir una terminal nueva, usar:

```powershell
$env:Path = "C:\Program Files\nodejs;$env:Path"
```

## Comprobar Playwright

```powershell
npx playwright --version
npx @playwright/mcp --help
```

## Arrancar MCP

Usar Chrome del sistema para evitar descargar navegadores cuando haya certificados corporativos:

```powershell
npx @playwright/mcp --browser chrome --executable-path "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

Si se quiere modo sin ventana:

```powershell
npx @playwright/mcp --browser chrome --headless --executable-path "C:\Program Files\Google\Chrome\Application\chrome.exe"
```

## Nota De Certificados

`npx playwright install chromium` puede fallar con `SELF_SIGNED_CERT_IN_CHAIN` en redes corporativas. En ese caso, usar Chrome instalado con `--executable-path`.
