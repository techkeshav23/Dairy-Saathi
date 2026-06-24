# Downloads real product/banner photos from Pexels (with loremflickr fallback)
# into assets/images/products as <id>.jpg. Run once to bundle the catalog images.
$ErrorActionPreference = 'SilentlyContinue'
$dest = Join-Path $PSScriptRoot '..\assets\images\products'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36'

$items = @(
  @{id='p1';  kw='basmati,rice';      urls=@('https://images.pexels.com/photos/7593252/pexels-photo-7593252.jpeg','https://images.pexels.com/photos/15879426/pexels-photo-15879426.jpeg')},
  @{id='p2';  kw='wheat,flour';       urls=@('https://images.pexels.com/photos/6294374/pexels-photo-6294374.jpeg','https://images.pexels.com/photos/6287219/pexels-photo-6287219.jpeg')},
  @{id='p3';  kw='cooking,oil';       urls=@('https://images.pexels.com/photos/6213754/pexels-photo-6213754.jpeg','https://images.pexels.com/photos/12284682/pexels-photo-12284682.jpeg')},
  @{id='p4';  kw='salt';              urls=@('https://images.pexels.com/photos/6690146/pexels-photo-6690146.jpeg','https://images.pexels.com/photos/13060679/pexels-photo-13060679.jpeg')},
  @{id='p5';  kw='lentils,dal';       urls=@('https://images.pexels.com/photos/8996219/pexels-photo-8996219.jpeg','https://images.pexels.com/photos/6363501/pexels-photo-6363501.jpeg')},
  @{id='p6';  kw='sugar';             urls=@('https://images.pexels.com/photos/5469034/pexels-photo-5469034.jpeg','https://images.pexels.com/photos/6940868/pexels-photo-6940868.jpeg')},
  @{id='p7';  kw='tea';               urls=@('https://images.pexels.com/photos/6087517/pexels-photo-6087517.jpeg','https://images.pexels.com/photos/6087604/pexels-photo-6087604.jpeg')},
  @{id='p8';  kw='coffee,jar';        urls=@('https://images.pexels.com/photos/13696028/pexels-photo-13696028.jpeg','https://images.pexels.com/photos/35819421/pexels-photo-35819421.jpeg')},
  @{id='p9';  kw='cola,bottle';       urls=@('https://images.pexels.com/photos/4113617/pexels-photo-4113617.jpeg','https://images.pexels.com/photos/4113624/pexels-photo-4113624.jpeg')},
  @{id='p10'; kw='juice,bottle';      urls=@('https://images.pexels.com/photos/8679336/pexels-photo-8679336.jpeg','https://images.pexels.com/photos/5946781/pexels-photo-5946781.jpeg')},
  @{id='p11'; kw='water,bottle';      urls=@('https://images.pexels.com/photos/15524063/pexels-photo-15524063.jpeg','https://images.pexels.com/photos/11860562/pexels-photo-11860562.jpeg')},
  @{id='p12'; kw='potato,chips';      urls=@('https://images.pexels.com/photos/568805/pexels-photo-568805.jpeg','https://images.pexels.com/photos/479628/pexels-photo-479628.jpeg')},
  @{id='p13'; kw='namkeen,snack';     urls=@('https://images.pexels.com/photos/6576317/pexels-photo-6576317.jpeg','https://images.pexels.com/photos/15534253/pexels-photo-15534253.jpeg')},
  @{id='p14'; kw='biscuits';          urls=@('https://images.pexels.com/photos/5985991/pexels-photo-5985991.jpeg','https://images.pexels.com/photos/37108654/pexels-photo-37108654.jpeg')},
  @{id='p15'; kw='cookies';           urls=@('https://images.pexels.com/photos/5847103/pexels-photo-5847103.jpeg','https://images.pexels.com/photos/310575/pexels-photo-310575.jpeg')},
  @{id='p16'; kw='toothpaste';        urls=@('https://images.pexels.com/photos/5240717/pexels-photo-5240717.jpeg','https://images.pexels.com/photos/5240345/pexels-photo-5240345.jpeg')},
  @{id='p17'; kw='soap,bar';          urls=@('https://images.pexels.com/photos/6690839/pexels-photo-6690839.jpeg','https://images.pexels.com/photos/4202469/pexels-photo-4202469.jpeg')},
  @{id='p18'; kw='shampoo,bottle';    urls=@('https://images.pexels.com/photos/4154194/pexels-photo-4154194.jpeg','https://images.pexels.com/photos/7440056/pexels-photo-7440056.jpeg')},
  @{id='p19'; kw='razor,shaving';     urls=@('https://images.pexels.com/photos/5240766/pexels-photo-5240766.jpeg','https://images.pexels.com/photos/7253884/pexels-photo-7253884.jpeg')},
  @{id='p20'; kw='detergent';         urls=@('https://images.pexels.com/photos/5591837/pexels-photo-5591837.jpeg','https://images.pexels.com/photos/5591956/pexels-photo-5591956.jpeg')},
  @{id='p21'; kw='dishwash,soap';     urls=@('https://images.pexels.com/photos/6195894/pexels-photo-6195894.jpeg','https://images.pexels.com/photos/4440618/pexels-photo-4440618.jpeg')},
  @{id='p22'; kw='cleaning,bottle';   urls=@('https://images.pexels.com/photos/4258247/pexels-photo-4258247.jpeg','https://images.pexels.com/photos/6612221/pexels-photo-6612221.jpeg')},
  @{id='p23'; kw='butter';            urls=@('https://images.pexels.com/photos/5562157/pexels-photo-5562157.jpeg','https://images.pexels.com/photos/4397260/pexels-photo-4397260.jpeg')},
  @{id='p24'; kw='milk,powder';       urls=@('https://images.pexels.com/photos/6944039/pexels-photo-6944039.jpeg','https://images.pexels.com/photos/8108249/pexels-photo-8108249.jpeg')},
  @{id='p25'; kw='bread,loaf';        urls=@('https://images.pexels.com/photos/209206/pexels-photo-209206.jpeg','https://images.pexels.com/photos/1383908/pexels-photo-1383908.jpeg')},
  @{id='p26'; kw='noodles';           urls=@('https://images.pexels.com/photos/6940988/pexels-photo-6940988.jpeg','https://images.pexels.com/photos/29269189/pexels-photo-29269189.jpeg')},
  @{id='p27'; kw='jam,jar';           urls=@('https://images.pexels.com/photos/9160297/pexels-photo-9160297.jpeg','https://images.pexels.com/photos/7586251/pexels-photo-7586251.jpeg')},
  @{id='p28'; kw='food,packet';       urls=@('https://images.pexels.com/photos/4228202/pexels-photo-4228202.jpeg','https://images.pexels.com/photos/11251712/pexels-photo-11251712.jpeg')},
  @{id='p29'; kw='notebook';          urls=@('https://images.pexels.com/photos/273034/pexels-photo-273034.jpeg','https://images.pexels.com/photos/272980/pexels-photo-272980.jpeg')},
  @{id='p30'; kw='pen';               urls=@('https://images.pexels.com/photos/5250892/pexels-photo-5250892.jpeg','https://images.pexels.com/photos/6187604/pexels-photo-6187604.jpeg')},
  @{id='b1';  kw='warehouse,boxes';   urls=@('https://images.pexels.com/photos/4483862/pexels-photo-4483862.jpeg','https://images.pexels.com/photos/4480797/pexels-photo-4480797.jpeg'); banner=$true},
  @{id='b2';  kw='delivery,truck';    urls=@('https://images.pexels.com/photos/6407553/pexels-photo-6407553.jpeg','https://images.pexels.com/photos/5410923/pexels-photo-5410923.jpeg'); banner=$true},
  @{id='b3';  kw='grocery,store';     urls=@('https://images.pexels.com/photos/26861411/pexels-photo-26861411.jpeg','https://images.pexels.com/photos/36317181/pexels-photo-36317181.jpeg'); banner=$true}
)

$results = @()
foreach ($it in $items) {
  $out = Join-Path $dest ($it.id + '.jpg')
  $done = $false; $src = ''
  $sq = if ($it.banner) { '?auto=compress&cs=tinysrgb&w=900&h=450&fit=crop' } else { '?auto=compress&cs=tinysrgb&w=600&h=600&fit=crop' }
  foreach ($u in $it.urls) {
    try {
      Invoke-WebRequest -Uri ($u + $sq) -OutFile $out -UserAgent $ua -TimeoutSec 40 -ErrorAction Stop
      if ((Test-Path $out) -and ((Get-Item $out).Length -gt 4000)) { $done = $true; $src = 'pexels'; break }
    } catch {}
  }
  if (-not $done) {
    $lf = if ($it.banner) { "https://loremflickr.com/900/450/$($it.kw)" } else { "https://loremflickr.com/600/600/$($it.kw)" }
    try {
      Invoke-WebRequest -Uri $lf -OutFile $out -UserAgent $ua -TimeoutSec 40 -ErrorAction Stop
      if ((Test-Path $out) -and ((Get-Item $out).Length -gt 4000)) { $done = $true; $src = 'loremflickr' }
    } catch {}
  }
  $sizeKB = if (Test-Path $out) { [math]::Round((Get-Item $out).Length/1KB,1) } else { 0 }
  $results += [pscustomobject]@{ id=$it.id; ok=$done; src=$src; KB=$sizeKB }
}
$results | Format-Table -AutoSize
$failed = ($results | Where-Object { -not $_.ok }).Count
Write-Output "DONE. Downloaded $($results.Count - $failed)/$($results.Count). Failed: $failed"
