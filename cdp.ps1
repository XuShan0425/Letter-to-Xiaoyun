param([string]$Expression)
$wsUrl=(Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:9333/json' | ConvertFrom-Json | Where-Object {$_.type -eq 'page' -and $_.url -like 'file:*'} | Select-Object -First 1).webSocketDebuggerUrl
$ws=[System.Net.WebSockets.ClientWebSocket]::new(); $ws.ConnectAsync([Uri]$wsUrl,[Threading.CancellationToken]::None).GetAwaiter().GetResult()
$id=1; $msg=@{id=$id;method='Runtime.evaluate';params=@{expression=$Expression;returnByValue=$true;awaitPromise=$true}}|ConvertTo-Json -Compress -Depth 10
$bytes=[Text.Encoding]::UTF8.GetBytes($msg); $ws.SendAsync([ArraySegment[byte]]::new($bytes),[System.Net.WebSockets.WebSocketMessageType]::Text,$true,[Threading.CancellationToken]::None).GetAwaiter().GetResult()
$buf=New-Object byte[] 1048576; $sb=[Text.StringBuilder]::new(); do {$res=$ws.ReceiveAsync([ArraySegment[byte]]::new($buf),[Threading.CancellationToken]::None).GetAwaiter().GetResult(); [void]$sb.Append([Text.Encoding]::UTF8.GetString($buf,0,$res.Count))} while(!$res.EndOfMessage)
$sb.ToString()
