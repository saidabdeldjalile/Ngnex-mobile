Add-Type -AssemblyName System.Drawing

$assetsDir = "Assets\Images"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null
}

function Create-RoundedRectanglePath {
    param(
        [System.Drawing.Rectangle]$rect,
        [int]$radius
    )
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $radius * 2
    $arc = New-Object System.Drawing.Rectangle($rect.X, $rect.Y, $diameter, $diameter)

    $path.AddArc($arc, 180, 90)
    $arc.X = $rect.Right - $diameter
    $path.AddArc($arc, 270, 90)
    $arc.Y = $rect.Bottom - $diameter
    $path.AddArc($arc, 0, 90)
    $arc.X = $rect.Left
    $path.AddArc($arc, 90, 90)
    $path.CloseFigure()
    return $path
}

# 1. Logo NGNEX 08 (512x512)
function Generate-Logo {
    $bmp = New-Object System.Drawing.Bitmap 512, 512
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point 0, 0),
        (New-Object System.Drawing.Point 512, 512),
        [System.Drawing.Color]::FromArgb(255, 10, 37, 64),
        [System.Drawing.Color]::FromArgb(255, 13, 71, 161)
    )
    $rect = New-Object System.Drawing.Rectangle 16, 16, 480, 480
    $path = Create-RoundedRectanglePath $rect 80
    $g.FillPath($bgBrush, $path)

    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 0, 212, 255), 4)
    $g.DrawPath($pen, $path)

    $screenBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point 0, 100),
        (New-Object System.Drawing.Point 0, 260),
        [System.Drawing.Color]::FromArgb(255, 30, 41, 59),
        [System.Drawing.Color]::FromArgb(255, 15, 23, 42)
    )
    $screenRect = New-Object System.Drawing.Rectangle 120, 90, 272, 170
    $screenPath = Create-RoundedRectanglePath $screenRect 20
    $g.FillPath($screenBrush, $screenPath)
    $g.DrawPath((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 212, 255), 3)), $screenPath)

    $innerScreenRect = New-Object System.Drawing.Rectangle 135, 105, 242, 140
    $innerPath = Create-RoundedRectanglePath $innerScreenRect 10
    $innerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point 0, 105),
        (New-Object System.Drawing.Point 0, 245),
        [System.Drawing.Color]::FromArgb(255, 14, 116, 144),
        [System.Drawing.Color]::FromArgb(255, 2, 132, 199)
    )
    $g.FillPath($innerBrush, $innerPath)

    $barBrush1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 52, 211, 153))
    $barBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 251, 191, 36))
    $barBrush3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 248, 113, 113))
    $g.FillRectangle($barBrush1, 160, 175, 25, 55)
    $g.FillRectangle($barBrush2, 195, 150, 25, 80)
    $g.FillRectangle($barBrush3, 230, 130, 25, 100)
    $g.FillRectangle($barBrush1, 265, 140, 25, 90)
    $g.FillRectangle($barBrush2, 300, 120, 25, 110)

    $standBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 203, 213, 225))
    $g.FillRectangle($standBrush, 236, 260, 40, 45)
    $baseRect = New-Object System.Drawing.Rectangle 190, 300, 132, 20
    $basePath = Create-RoundedRectanglePath $baseRect 8
    $g.FillPath($standBrush, $basePath)

    $fontMain = New-Object System.Drawing.Font("Arial", 42, [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $brushCyan = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 56, 189, 248))
    $brushOrange = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 140, 0))

    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center

    $g.DrawString("NGNEX", $fontMain, $brushWhite, 210, 335, $sf)
    $g.DrawString("08", $fontMain, $brushOrange, 320, 335, $sf)
    $g.DrawString("POINT DE VENTE & CAISSE", $fontSub, $brushCyan, 256, 405, $sf)

    $bmp.Save("$assetsDir\logo_ngnex.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

# 2. Bannière Accueil (800x320)
function Generate-Banner {
    $bmp = New-Object System.Drawing.Bitmap 800, 320
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point 0, 0),
        (New-Object System.Drawing.Point 800, 320),
        [System.Drawing.Color]::FromArgb(255, 10, 25, 47),
        [System.Drawing.Color]::FromArgb(255, 13, 71, 161)
    )
    $rect = New-Object System.Drawing.Rectangle 0, 0, 800, 320
    $g.FillRectangle($bgBrush, $rect)

    $glowBrush1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 0, 212, 255))
    $g.FillEllipse($glowBrush1, 550, -80, 350, 350)
    $glowBrush2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 255, 109, 0))
    $g.FillEllipse($glowBrush2, 400, 100, 280, 280)

    $badgeRect = New-Object System.Drawing.Rectangle 40, 30, 230, 34
    $badgePath = Create-RoundedRectanglePath $badgeRect 8
    $badgeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 109, 0))
    $g.FillPath($badgeBrush, $badgePath)

    $fontBadge = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("NGNEX 08 - SOLUTIONS POS", $fontBadge, [System.Drawing.Brushes]::White, 50, 38)

    $fontTitle = New-Object System.Drawing.Font("Arial", 28, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("Equipez Votre Commerce", $fontTitle, [System.Drawing.Brushes]::White, 40, 75)
    
    $fontSubtitle = New-Object System.Drawing.Font("Arial", 15, [System.Drawing.FontStyle]::Regular)
    $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 203, 213, 225))
    $g.DrawString("Terminaux tactiles, Imprimantes tickets 80mm,", $fontSubtitle, $subBrush, 40, 125)
    $g.DrawString("Lecteurs codes-barres 2D & Balances commerciales.", $fontSubtitle, $subBrush, 40, 155)

    $fontPill = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
    $pillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 255, 255, 255))
    
    $p1 = New-Object System.Drawing.Rectangle 40, 205, 160, 32
    $g.FillPath($pillBrush, (Create-RoundedRectanglePath $p1 6))
    $g.DrawString("Garantie 12 Mois", $fontPill, [System.Drawing.Brushes]::White, 52, 212)

    $p2 = New-Object System.Drawing.Rectangle 210, 205, 150, 32
    $g.FillPath($pillBrush, (Create-RoundedRectanglePath $p2 6))
    $g.DrawString("Devis Gratuit", $fontPill, [System.Drawing.Brushes]::White, 225, 212)

    $p3 = New-Object System.Drawing.Rectangle 370, 205, 190, 32
    $g.FillPath($pillBrush, (Create-RoundedRectanglePath $p3 6))
    $g.DrawString("Livraison 58 Wilayas", $fontPill, [System.Drawing.Brushes]::White, 385, 212)

    $posRect = New-Object System.Drawing.Rectangle 620, 50, 150, 100
    $posPath = Create-RoundedRectanglePath $posRect 12
    $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59))), $posPath)
    $g.DrawPath((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 212, 255), 2)), $posPath)

    $screenMini = New-Object System.Drawing.Rectangle 630, 60, 130, 80
    $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 2, 132, 199))), (Create-RoundedRectanglePath $screenMini 6))

    $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 203, 213, 225))), 685, 150, 20, 30)
    $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 203, 213, 225))), (Create-RoundedRectanglePath (New-Object System.Drawing.Rectangle 660, 180, 70, 12) 4))

    $prtRect = New-Object System.Drawing.Rectangle 630, 205, 110, 75
    $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 51, 65, 85))), (Create-RoundedRectanglePath $prtRect 8))
    $g.FillRectangle([System.Drawing.Brushes]::White, 650, 190, 45, 20)
    $g.DrawLine((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 100, 116, 139), 1)), 655, 195, 690, 195)
    $g.DrawLine((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 100, 116, 139), 1)), 655, 200, 685, 200)

    $bmp.Save("$assetsDir\banner_pos.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

# 3. Fonction générique pour créer une photo de matériel POS stylisée (400x300)
function Generate-ProductImage {
    param(
        [string]$filename,
        [string]$categoryTitle,
        [string]$productTitle,
        [string]$badgeText,
        [System.Drawing.Color]$themeColor,
        [string]$iconType
    )

    $bmp = New-Object System.Drawing.Bitmap 400, 300
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point 0, 0),
        (New-Object System.Drawing.Point 400, 300),
        [System.Drawing.Color]::FromArgb(255, 248, 250, 252),
        [System.Drawing.Color]::FromArgb(255, 226, 232, 240)
    )
    $g.FillRectangle($bgBrush, 0, 0, 400, 300)

    $haloBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, $themeColor.R, $themeColor.G, $themeColor.B))
    $g.FillEllipse($haloBrush, 75, 40, 250, 180)

    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50, 71, 85, 105))
    $g.FillEllipse($shadowBrush, 70, 215, 260, 25)

    if ($iconType -eq "AIO") {
        $rectMonitor = New-Object System.Drawing.Rectangle 100, 50, 200, 130
        $pathMon = Create-RoundedRectanglePath $rectMonitor 12
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59))), $pathMon)
        $g.DrawPath((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 71, 85, 105), 3)), $pathMon)

        $rectScreen = New-Object System.Drawing.Rectangle 110, 60, 180, 110
        $screenGrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            (New-Object System.Drawing.Point 110, 60),
            (New-Object System.Drawing.Point 290, 170),
            [System.Drawing.Color]::FromArgb(255, 14, 165, 233),
            [System.Drawing.Color]::FromArgb(255, 3, 105, 161)
        )
        $g.FillPath($screenGrad, (Create-RoundedRectanglePath $rectScreen 6))

        $g.FillRectangle([System.Drawing.Brushes]::White, 125, 75, 45, 18)
        $g.FillRectangle([System.Drawing.Brushes]::LightGreen, 175, 75, 45, 18)
        $g.FillRectangle([System.Drawing.Brushes]::Orange, 225, 75, 45, 18)
        
        $g.FillRectangle([System.Drawing.Brushes]::White, 125, 100, 70, 50)
        $g.FillRectangle([System.Drawing.Brushes]::White, 200, 100, 70, 50)

        $standBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 148, 163, 184))
        $g.FillRectangle($standBrush, 185, 180, 30, 35)
        $g.FillPath($standBrush, (Create-RoundedRectanglePath (New-Object System.Drawing.Rectangle 150, 212, 100, 15) 6))
    }
    elseif ($iconType -eq "AIO_DUAL") {
        $rectMon1 = New-Object System.Drawing.Rectangle 70, 50, 180, 120
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59))), (Create-RoundedRectanglePath $rectMon1 10))
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 14, 165, 233))), 78, 58, 164, 104)

        $rectMon2 = New-Object System.Drawing.Rectangle 240, 70, 110, 85
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 51, 65, 85))), (Create-RoundedRectanglePath $rectMon2 8))
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 158, 11))), 246, 76, 98, 73)

        $standBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 148, 163, 184))
        $g.FillRectangle($standBrush, 175, 170, 40, 45)
        $g.FillPath($standBrush, (Create-RoundedRectanglePath (New-Object System.Drawing.Rectangle 140, 212, 110, 15) 6))
    }
    elseif ($iconType -eq "PRINTER") {
        $bodyRect = New-Object System.Drawing.Rectangle 120, 90, 160, 120
        $bodyPath = Create-RoundedRectanglePath $bodyRect 14
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59))), $bodyPath)
        $g.DrawPath((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 71, 85, 105), 3)), $bodyPath)

        $g.FillRectangle([System.Drawing.Brushes]::Black, 140, 88, 120, 8)

        $ticketRect = New-Object System.Drawing.Rectangle 145, 50, 110, 45
        $g.FillRectangle([System.Drawing.Brushes]::White, $ticketRect)
        $g.DrawRectangle((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 203, 213, 225), 1)), $ticketRect)

        $linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 100, 116, 139), 2)
        $g.DrawLine($linePen, 155, 60, 235, 60)
        $g.DrawLine($linePen, 155, 68, 220, 68)
        $g.DrawLine($linePen, 155, 76, 240, 76)
        $g.DrawLine($linePen, 155, 84, 200, 84)

        $g.FillEllipse([System.Drawing.Brushes]::LimeGreen, 140, 125, 12, 12)
        $g.FillEllipse([System.Drawing.Brushes]::Gold, 160, 125, 12, 12)
        $g.FillEllipse([System.Drawing.Brushes]::Crimson, 180, 125, 12, 12)
        
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 71, 85, 105))), (Create-RoundedRectanglePath (New-Object System.Drawing.Rectangle 220, 120, 45, 22) 4))
    }
    elseif ($iconType -eq "PRINTER_PORTABLE") {
        $bodyRect = New-Object System.Drawing.Rectangle 135, 80, 130, 140
        $bodyPath = Create-RoundedRectanglePath $bodyRect 16
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 23, 42))), $bodyPath)
        
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 51, 65, 85))), (Create-RoundedRectanglePath (New-Object System.Drawing.Rectangle 150, 95, 100, 45) 8))

        $g.FillRectangle([System.Drawing.Brushes]::White, 155, 68, 90, 28)
        $g.DrawLine((New-Object System.Drawing.Pen([System.Drawing.Color]::Gray, 1)), 165, 76, 225, 76)
        $g.DrawLine((New-Object System.Drawing.Pen([System.Drawing.Color]::Gray, 1)), 165, 84, 210, 84)

        $g.DrawString("BT", (New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::DodgerBlue, 185, 155)
    }
    elseif ($iconType -eq "SCANNER_DESKTOP") {
        $baseRect = New-Object System.Drawing.Rectangle 140, 100, 120, 115
        $basePath = Create-RoundedRectanglePath $baseRect 16
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59))), $basePath)

        $winRect = New-Object System.Drawing.Rectangle 150, 115, 100, 80
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 23, 42))), (Create-RoundedRectanglePath $winRect 8))

        $laserPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 239, 68, 68), 2)
        $g.DrawLine($laserPen, 155, 125, 245, 185)
        $g.DrawLine($laserPen, 155, 185, 245, 125)
        $g.DrawLine($laserPen, 155, 155, 245, 155)

        $g.FillEllipse([System.Drawing.Brushes]::DodgerBlue, 192, 104, 16, 8)
    }
    elseif ($iconType -eq "SCANNER_GUN") {
        $headRect = New-Object System.Drawing.Rectangle 120, 70, 140, 65
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59))), (Create-RoundedRectanglePath $headRect 14))

        $g.FillRectangle([System.Drawing.Brushes]::Black, 115, 80, 12, 45)
        $laserPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 239, 68, 68), 3)
        $g.DrawLine($laserPen, 70, 102, 115, 102)

        $handleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 23, 42))
        $polyHandle = @(
            (New-Object System.Drawing.Point 180, 130),
            (New-Object System.Drawing.Point 215, 130),
            (New-Object System.Drawing.Point 200, 215),
            (New-Object System.Drawing.Point 170, 215)
        )
        $g.FillPolygon($handleBrush, $polyHandle)

        $g.FillRectangle([System.Drawing.Brushes]::OrangeRed, 172, 145, 10, 22)

        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 116, 139))), (Create-RoundedRectanglePath (New-Object System.Drawing.Rectangle 145, 210, 85, 18) 6))
    }
    elseif ($iconType -eq "DRAWER") {
        $bodyRect = New-Object System.Drawing.Rectangle 90, 110, 220, 105
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 23, 42))), (Create-RoundedRectanglePath $bodyRect 8))

        $innerRect = New-Object System.Drawing.Rectangle 100, 125, 200, 85
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 51, 65, 85))), (Create-RoundedRectanglePath $innerRect 6))

        $g.FillRectangle([System.Drawing.Brushes]::MediumSeaGreen, 110, 135, 38, 40)
        $g.FillRectangle([System.Drawing.Brushes]::MediumSeaGreen, 155, 135, 38, 40)
        $g.FillRectangle([System.Drawing.Brushes]::MediumSeaGreen, 200, 135, 38, 40)
        $g.FillRectangle([System.Drawing.Brushes]::MediumSeaGreen, 245, 135, 42, 40)

        $g.FillEllipse([System.Drawing.Brushes]::Gold, 115, 185, 18, 18)
        $g.FillEllipse([System.Drawing.Brushes]::Silver, 145, 185, 18, 18)
        $g.FillEllipse([System.Drawing.Brushes]::Gold, 175, 185, 18, 18)
        $g.FillEllipse([System.Drawing.Brushes]::Silver, 205, 185, 18, 18)

        $g.FillRectangle([System.Drawing.Brushes]::Black, 130, 95, 140, 6)
    }
    elseif ($iconType -eq "SCALE") {
        $baseRect = New-Object System.Drawing.Rectangle 95, 130, 210, 85
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 241, 245, 249))), (Create-RoundedRectanglePath $baseRect 10))
        $g.DrawPath((New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 148, 163, 184), 2)), (Create-RoundedRectanglePath $baseRect 10))

        $trayRect = New-Object System.Drawing.Rectangle 85, 115, 230, 18
        $trayGrad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            (New-Object System.Drawing.Point 85, 115),
            (New-Object System.Drawing.Point 315, 133),
            [System.Drawing.Color]::FromArgb(255, 226, 232, 240),
            [System.Drawing.Color]::FromArgb(255, 148, 163, 184)
        )
        $g.FillPath($trayGrad, (Create-RoundedRectanglePath $trayRect 4))

        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59))), 110, 145, 80, 60)
        for ($r = 0; $r -lt 3; $r++) {
            for ($c = 0; $c -lt 3; $c++) {
                $g.FillRectangle([System.Drawing.Brushes]::CadetBlue, (115 + $c * 24), (150 + $r * 18), 20, 14)
            }
        }

        $lcdRect = New-Object System.Drawing.Rectangle 205, 145, 85, 35
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 34, 197, 94))), $lcdRect)
        $g.DrawString(" 1.540 kg", (New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 206, 147)
        $g.DrawString(" 450.00 DA", (New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)), [System.Drawing.Brushes]::Black, 206, 162)

        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 116, 139))), 275, 45, 14, 75)
        $screenTop = New-Object System.Drawing.Rectangle 240, 45, 85, 35
        $g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 41, 59))), (Create-RoundedRectanglePath $screenTop 4))
        $g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 34, 197, 94))), 245, 50, 75, 25)
    }

    $badgeRect = New-Object System.Drawing.Rectangle 15, 15, 140, 24
    $g.FillPath((New-Object System.Drawing.SolidBrush($themeColor)), (Create-RoundedRectanglePath $badgeRect 6))
    $fontBadge = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
    $g.DrawString($badgeText, $fontBadge, [System.Drawing.Brushes]::White, 22, 20)

    $fontCat = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
    $g.DrawString($categoryTitle.ToUpper(), $fontCat, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 100, 116, 139))), 16, 252)

    $fontName = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
    $g.DrawString($productTitle, $fontName, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 23, 42))), 16, 268)

    $fontWatermark = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("NGNEX 08", $fontWatermark, (New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 148, 163, 184))), 305, 18)

    $bmp.Save("$assetsDir\$filename", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

Write-Output "Generation des visuels et photos NGNEX..."

Generate-Logo
Generate-Banner

# Photos des 5 Catégories
Generate-ProductImage "cat_aio.png" "Categorie" "PC All-in-One Tactiles" "TERMINAUX POS" ([System.Drawing.Color]::FromArgb(255, 13, 71, 161)) "AIO"
Generate-ProductImage "cat_prt.png" "Categorie" "Imprimantes Tickets" "THERMIQUE & BT" ([System.Drawing.Color]::FromArgb(255, 2, 132, 199)) "PRINTER"
Generate-ProductImage "cat_scan.png" "Categorie" "Lecteurs Codes-barres" "1D & 2D QR CODE" ([System.Drawing.Color]::FromArgb(255, 217, 119, 6)) "SCANNER_GUN"
Generate-ProductImage "cat_drawer.png" "Categorie" "Tiroirs-caisses Metal" "HEAVY DUTY RJ11" ([System.Drawing.Color]::FromArgb(255, 71, 85, 105)) "DRAWER"
Generate-ProductImage "cat_scale.png" "Categorie" "Balances Professionnelles" "COMMERCE & TICKET" ([System.Drawing.Color]::FromArgb(255, 16, 185, 129)) "SCALE"

# Photos des 8 Produits
Generate-ProductImage "prod_aio_pro.png" "POS Tactile" "NGNEX Pro 15.6 Inch" "BEST SELLER" ([System.Drawing.Color]::FromArgb(255, 13, 71, 161)) "AIO"
Generate-ProductImage "prod_aio_dual.png" "Double Ecran" "NGNEX Dual 15.6/10.1" "HAUT DE GAMME" ([System.Drawing.Color]::FromArgb(255, 99, 102, 241)) "AIO_DUAL"
Generate-ProductImage "prod_prt_lan.png" "Imprimante Ticket" "Thermique 80mm USB+LAN" "260 mm/sec" ([System.Drawing.Color]::FromArgb(255, 2, 132, 199)) "PRINTER"
Generate-ProductImage "prod_prt_bt.png" "Imprimante Nomade" "Portable Bluetooth 58mm" "BATTERIE 2000mAh" ([System.Drawing.Color]::FromArgb(255, 59, 130, 246)) "PRINTER_PORTABLE"
Generate-ProductImage "prod_scan_desk.png" "Lecteur 2D" "Omnidirectionnel Desktop" "MAINS LIBRES" ([System.Drawing.Color]::FromArgb(255, 239, 68, 68)) "SCANNER_DESKTOP"
Generate-ProductImage "prod_scan_wl.png" "Douchette Sans Fil" "Laser 1D Wireless-100" "PORTEE 100M" ([System.Drawing.Color]::FromArgb(255, 245, 158, 11)) "SCANNER_GUN"
Generate-ProductImage "prod_drawer_410.png" "Tiroir-Caisse" "Metal Heavy Duty 410" "ACIER RENFORCE" ([System.Drawing.Color]::FromArgb(255, 71, 85, 105)) "DRAWER"
Generate-ProductImage "prod_scale_30.png" "Balance Commerciale" "Electronique 30kg Ticket" "HOMOLOGUEE" ([System.Drawing.Color]::FromArgb(255, 16, 185, 129)) "SCALE"

Write-Output "Generation des assets terminee avec succes !"

function Gen-ActionIcon {
    param(
        [string]$filename,
        [System.Drawing.Color]$bgColor1,
        [System.Drawing.Color]$bgColor2,
        [string]$type
    )
    $bmp = New-Object System.Drawing.Bitmap 128, 128
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $rect = New-Object System.Drawing.Rectangle 4, 4, 120, 120
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point 0,0), (New-Object System.Drawing.Point 128,128), $bgColor1, $bgColor2)
    $g.FillPath($brush, (Create-RoundedRectanglePath $rect 28))
    
    if ($type -eq 'SCAN') {
        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 6)
        $g.DrawArc($pen, 34, 34, 25, 25, 180, 90)
        $g.DrawArc($pen, 69, 34, 25, 25, 270, 90)
        $g.DrawArc($pen, 34, 69, 25, 25, 90, 90)
        $g.DrawArc($pen, 69, 69, 25, 25, 0, 90)
        $laserPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 254, 202, 202), 4)
        $g.DrawLine($laserPen, 32, 64, 96, 64)
    } elseif ($type -eq 'COMPARE') {
        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 5)
        $g.DrawLine($pen, 64, 30, 64, 95)
        $g.DrawLine($pen, 35, 45, 93, 45)
        $g.DrawLine($pen, 35, 45, 25, 68)
        $g.DrawLine($pen, 35, 45, 45, 68)
        $g.DrawLine($pen, 20, 68, 50, 68)
        $g.DrawLine($pen, 93, 45, 83, 68)
        $g.DrawLine($pen, 93, 45, 103, 68)
        $g.DrawLine($pen, 78, 68, 108, 68)
        $g.DrawLine($pen, 45, 95, 83, 95)
    } elseif ($type -eq 'CALC') {
        $calcRect = New-Object System.Drawing.Rectangle 34, 28, 60, 72
        $g.FillPath([System.Drawing.Brushes]::White, (Create-RoundedRectanglePath $calcRect 10))
        $g.FillRectangle([System.Drawing.Brushes]::DarkSlateGray, 42, 36, 44, 18)
        for ($r=0; $r -lt 2; $r++) {
            for ($c=0; $c -lt 3; $c++) {
                $g.FillEllipse([System.Drawing.Brushes]::Orange, (44 + $c*16), (60 + $r*15), 10, 10)
            }
        }
    } elseif ($type -eq 'QUOTE') {
        $docRect = New-Object System.Drawing.Rectangle 36, 26, 56, 76
        $g.FillPath([System.Drawing.Brushes]::White, (Create-RoundedRectanglePath $docRect 8))
        $linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 16, 185, 129), 4)
        $g.DrawLine($linePen, 46, 42, 75, 42)
        $g.DrawLine($linePen, 46, 54, 82, 54)
        $g.DrawLine($linePen, 46, 66, 78, 66)
        $g.DrawLine($linePen, 46, 78, 65, 78)
    }
    $targetPath = Join-Path $assetsDir $filename
    $bmp.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

Gen-ActionIcon "action_scanner.png" ([System.Drawing.Color]::FromArgb(255, 14, 165, 233)) ([System.Drawing.Color]::FromArgb(255, 2, 132, 199)) "SCAN"
Gen-ActionIcon "action_compare.png" ([System.Drawing.Color]::FromArgb(255, 139, 92, 246)) ([System.Drawing.Color]::FromArgb(255, 109, 40, 217)) "COMPARE"
Gen-ActionIcon "action_calc.png" ([System.Drawing.Color]::FromArgb(255, 245, 158, 11)) ([System.Drawing.Color]::FromArgb(255, 217, 119, 6)) "CALC"
Gen-ActionIcon "action_quote.png" ([System.Drawing.Color]::FromArgb(255, 16, 185, 129)) ([System.Drawing.Color]::FromArgb(255, 5, 150, 105)) "QUOTE"
Write-Output "Action icons OK"
