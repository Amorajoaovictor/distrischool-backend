$filePath = "C:\Users\amora\distrischool\teacher-service\src\main\java\br\unifor\distrischool\teacher_service\event\TeacherEvent.java"

# Ler o conteúdo
$content = [System.IO.File]::ReadAllText($filePath)

# Escrever sem BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)

Write-Host "BOM removido de TeacherEvent.java com sucesso!"
