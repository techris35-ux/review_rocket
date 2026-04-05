# --- CONFIGURACIÓN: MODO UNIFICADO (Todo en un solo archivo) ---
$basePath = "C:\Users\mrsmi\OneDrive\Documents\ReviewRocket_Scraper"
$lista = "C:\Users\mrsmi\OneDrive\Documents\ReviewRocket_Scraper\google-maps-scraper-main\test.txt"
$scraper_exe = "C:\Users\mrsmi\OneDrive\Documents\ReviewRocket_Scraper\google-maps-scraper-main\gms.exe"
$carpeta_datos = "C:\Users\mrsmi\OneDrive\Documents\ReviewRocket_Scraper\extraccion_bruta"

# Archivos Temporales y Finales
$temp_input = Join-Path $basePath "temp_input.txt"      # Lo que lee el scraper
$temp_output = Join-Path $basePath "temp_output.csv"    # Resultado de UNA sola búsqueda
$archivo_final = Join-Path $carpeta_datos "prueba.csv"  # EL ARCHIVO MAESTRO

# --- AJUSTES DE PROFUNDIDAD Y TIEMPO ---
$tiempo_min = 40
$tiempo_max = 70

if (!(Test-Path $lista)) { Write-Host "❌ No veo el archivo test.txt" -ForegroundColor Red; return }
if (!(Test-Path $carpeta_datos)) { New-Item -ItemType Directory -Force -Path $carpeta_datos | Out-Null }

$objetivos = Get-Content $lista
Write-Host "🚀 REVIEWROCKET: Modo Unificado (Todo a prueba.csv)" -ForegroundColor Cyan
Write-Host "-------------------------------------------"

foreach ($linea in $objetivos) {
    if ([string]::IsNullOrWhiteSpace($linea)) { continue }
    
    # 1. Preparar la búsqueda actual
    $linea | Out-File -FilePath $temp_input -Encoding UTF8
    
    # Profundidad aleatoria (8 a 10)
    $depth_random = Get-Random -Minimum 13 -Maximum 20
    
    Write-Host "🔎 Scrapeando: $linea (Depth: $depth_random)" -ForegroundColor Green
    
    # 2. EJECUTAR MOTOR -> Guarda en un archivo temporal
    & $scraper_exe -input $temp_input -results $temp_output -c 1 -depth $depth_random -debug

    # 3. FUSIÓN DE DATOS (La Magia)
    if (Test-Path $temp_output) {
        if (!(Test-Path $archivo_final)) {
            # Si 'prueba.csv' no existe, movemos el temporal tal cual (con encabezados)
            Move-Item $temp_output $archivo_final -Force
            Write-Host "   📄 Archivo 'prueba.csv' creado." -ForegroundColor Cyan
        } else {
            # Si YA existe, leemos el temporal, saltamos la línea 1 (títulos) y pegamos el resto
            Get-Content $temp_output | Select-Object -Skip 1 | Add-Content $archivo_final
            Remove-Item $temp_output -Force
            Write-Host "   ➕ Datos agregados a 'prueba.csv'." -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️ No se encontraron datos para esta zona." -ForegroundColor DarkYellow
    }

    # 4. Pausa
    $espera = Get-Random -Minimum $tiempo_min -Maximum $tiempo_max
    Write-Host "⏳ Pausa de $espera segundos..." -ForegroundColor Yellow
    Start-Sleep -Seconds $espera
}

if (Test-Path $temp_input) { Remove-Item $temp_input }
Write-Host "✅ ¡TODO LISTO! Revisa tu archivo: prueba.csv" -ForegroundColor Cyan
