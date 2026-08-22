$dir = "C:\Users\User\AppData\Local\Temp\claude\C--Users-User--cache\dce1f2f1-a8b4-4e66-a2e3-b184cb84d5f1\scratchpad\greenarch-site"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8765/")
$listener.Start()
while ($listener.IsListening) {
  $context = $listener.GetContext()
  $req = $context.Request
  $res = $context.Response
  $path = $req.Url.LocalPath
  if ($path -eq "/") { $path = "/index.html" }
  $filePath = Join-Path $dir $path.TrimStart('/')
  if (Test-Path $filePath -PathType Leaf) {
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
    $ct = switch ($ext) {
      ".html" { "text/html; charset=utf-8" }
      ".css"  { "text/css" }
      ".js"   { "application/javascript" }
      ".png"  { "image/png" }
      ".jpg"  { "image/jpeg" }
      ".jpeg" { "image/jpeg" }
      ".svg"  { "image/svg+xml" }
      ".xml"  { "application/xml" }
      default { "application/octet-stream" }
    }
    $res.ContentType = $ct
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $res.StatusCode = 404
  }
  $res.OutputStream.Close()
}
