$ErrorActionPreference = "Stop"

# repo root = parent directory of this script's folder
$repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $repo

$book = Get-Content .\Book.txt | Where-Object { $_ -and -not $_.StartsWith("#") }

$html = @()
$html += "<!doctype html><html><head><meta charset='utf-8'>"
$html += "<title>EX280 Book Preview</title>"
$html += "<style>body{font-family:Segoe UI,Arial;max-width:980px;margin:40px auto;line-height:1.5}
pre{background:#f6f8fa;padding:12px;overflow:auto}
code{font-family:Consolas,monospace}
img{max-width:100%;height:auto;border:1px solid #ddd;padding:8px}
h1,h2,h3{margin-top:28px}</style></head><body>"
$html += "<h1>EX280 — Preview</h1>"

foreach ($p in $book) {
  $content = Get-Content -Encoding utf8 $p -Raw
  $c = $content
  $c = $c -replace '```bash', '<pre><code>'
  $c = $c -replace '```', '</code></pre>'
  $c = $c -replace '!\[(.*?)\]\((.*?)\)', '<figure><img src="$2" alt="$1"><figcaption>$1</figcaption></figure>'
  $c = $c -replace '^### (.*)$', '<h3>$1</h3>'
  $c = $c -replace '^## (.*)$', '<h2>$1</h2>'
  $c = $c -replace '^# (.*)$', '<h1>$1</h1>'
  $c = $c -replace "`r?`n", "<br>`n"
  $html += "<hr><div>$c</div>"
}

$html += "</body></html>"
$html -join "`n" | Set-Content -Encoding utf8 .\preview.html
Write-Host "Generated preview.html"

