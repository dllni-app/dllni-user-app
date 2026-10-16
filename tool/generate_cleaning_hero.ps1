Add-Type -AssemblyName System.Drawing

$image = [System.Drawing.Bitmap]::new(1200, 520)
$graphics = [System.Drawing.Graphics]::FromImage($image)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

function Color([int] $red, [int] $green, [int] $blue, [int] $alpha = 255) {
    return [System.Drawing.Color]::FromArgb($alpha, $red, $green, $blue)
}

function Brush([int] $red, [int] $green, [int] $blue, [int] $alpha = 255) {
    return [System.Drawing.SolidBrush]::new((Color $red $green $blue $alpha))
}

function Fill-Ellipse([int] $x, [int] $y, [int] $width, [int] $height, [System.Drawing.Brush] $brush) {
    $graphics.FillEllipse($brush, $x, $y, $width, $height)
    $brush.Dispose()
}

function Fill-RoundedRect([int] $x, [int] $y, [int] $width, [int] $height, [int] $radius, [System.Drawing.Brush] $brush) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = 2 * $radius
    $path.AddArc($x, $y, $diameter, $diameter, 180, 90)
    $path.AddArc($x + $width - $diameter, $y, $diameter, $diameter, 270, 90)
    $path.AddArc($x + $width - $diameter, $y + $height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($x, $y + $height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    $graphics.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

$background = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Point]::new(0, 0),
    [System.Drawing.Point]::new(1200, 520),
    (Color 23 168 172),
    (Color 12 53 85)
)
$graphics.FillRectangle($background, 0, 0, 1200, 520)
$background.Dispose()

# Broad translucent circles keep the illustration lively without competing with UI text.
Fill-Ellipse -140 -235 720 720 (Brush 117 235 219 34)
Fill-Ellipse 550 -400 1050 1050 (Brush 6 35 64 54)
Fill-Ellipse 850 345 360 360 (Brush 118 227 216 19)
Fill-Ellipse 92 53 457 457 (Brush 189 255 235 37)
Fill-Ellipse 121 82 399 399 (Brush 14 103 124 150)

# A crisp window tile and a cleaning bottle, drawn as simple vector shapes.
Fill-RoundedRect 165 123 318 290 31 (Brush 224 255 247 224)
Fill-RoundedRect 178 136 292 264 23 (Brush 113 215 213 250)
Fill-RoundedRect 194 152 260 232 17 (Brush 18 133 157 105)
$windowPen = [System.Drawing.Pen]::new((Color 223 255 247 205), 9)
$graphics.DrawLine($windowPen, 324, 152, 324, 385)
$graphics.DrawLine($windowPen, 194, 270, 454, 270)
$windowPen.Dispose()

$spray = [System.Drawing.Drawing2D.GraphicsPath]::new()
$spray.AddPolygon([System.Drawing.Point[]] @(
    [System.Drawing.Point]::new(284, 265),
    [System.Drawing.Point]::new(412, 265),
    [System.Drawing.Point]::new(449, 333),
    [System.Drawing.Point]::new(428, 452),
    [System.Drawing.Point]::new(268, 452),
    [System.Drawing.Point]::new(247, 333)
))
$graphics.FillPath((Brush 226 255 248), $spray)
$spray.Dispose()
Fill-RoundedRect 308 233 83 51 12 (Brush 9 88 105)
Fill-RoundedRect 296 211 110 23 9 (Brush 226 255 248)
Fill-RoundedRect 292 196 73 18 6 (Brush 226 255 248)
Fill-RoundedRect 264 345 168 71 20 (Brush 58 209 187)
Fill-Ellipse 314 365 66 35 (Brush 225 255 250 183)

# Floating bubbles and four point glints suggest clean glass and fresh air.
foreach ($bubble in @(@(159, 103, 27), @(474, 131, 37), @(501, 315, 21), @(134, 331, 17))) {
    $bubblePen = [System.Drawing.Pen]::new((Color 215 255 246 190), 4)
    $graphics.DrawEllipse($bubblePen, $bubble[0], $bubble[1], $bubble[2], $bubble[2])
    $bubblePen.Dispose()
}
foreach ($sparkle in @(@(226, 88, 21), @(507, 207, 26), @(102, 250, 18), @(572, 105, 12))) {
    $x = $sparkle[0]; $y = $sparkle[1]; $size = $sparkle[2]
    $glintPen = [System.Drawing.Pen]::new((Color 230 255 244 225), 5)
    $glintPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $glintPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLine($glintPen, $x - $size, $y, $x + $size, $y)
    $graphics.DrawLine($glintPen, $x, $y - $size, $x, $y + $size)
    $glintPen.Dispose()
}

$target = Join-Path $PSScriptRoot '../assets/images/cleaning_hero_banner.png'
$image.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$image.Dispose()
