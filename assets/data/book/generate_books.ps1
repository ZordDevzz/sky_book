# Script to generate random book data with more realistic content.
# This version uses literal UTF-8 characters and is intended to be run via Invoke-Expression.

$ErrorActionPreference = "Stop"

# Define the directory to save the book files
$outputDir = "D:\source\Mobile\sky_book\assets\data\book"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# --- Word lists for generating meaningful names ---
$titlePrefixes = @("Vô Cực", "Tuyệt Thế", "Độc Bộ", "Kinh Thiên", "Bất Diệt", "Thái Cổ", "Cửu U", "Linh Vũ", "Hỗn Độn")
$titleMain = @("Kiếm", "Đao", "Thần", "Ma", "Tiên", "Yêu", "Phật", "Long", "Phượng", "Quyền", "Chưởng")
$titleSuffixes = @("Ký", "Truyện", "Lục", "Quyết", "Tôn", "Điển", "Hành", "Ca", "Đồ")
$authorSurnames = @("Mặc", "Lãnh", "Tiêu", "Cổ", "Yến", "Tần", "Vô", "Đông Phương", "Tây Môn", "Nam Cung")
$authorMiddleNames = @("Phong", "Vân", "Thiên", "Nguyệt", "Tử", "Ngạo", "Nhất", "Bán", "Lão")
$authorLastNames = @("Trần", "Sư", "Tà", "Quân", "Cơ", "Vô Kỵ", "Chi Thu", "Thư Sinh", "Cư Sĩ")

# --- Lists for generating richer content ---
$loremIpsumWords = @("chương", "truyện", "của", "và", "là", "một", "trong", "có", "không", "với", "được", "cho", "khi", "thì", "từ", "đến", "đó", "này", "về", "các", "như", "đã", "để", "ra", "vào", "cũng", "lại", "nói", "tôi", "người", "làm", "gì", "biết", "rằng", "những", "ai", "hắn", "y", "nàng", "chàng", "tại", "vì", "sao", "bởi", "nên", "phải", "cần", "muốn", "thấy", "nhìn", "nghe", "hiểu", "rõ", "hơn", "nữa", "rất", "lắm", "quá")
$allTags = @("Tiên Hiệp", "Kiếm Hiệp", "Huyền Huyễn", "Đô Thị", "Võng Du", "Trọng Sinh", "Xuyên Không", "Dị Năng", "Lịch Sử")
$descStarts = @("Câu chuyện kể về hành trình của một thiếu niên bình thường,", "Trong một thế giới phép thuật đầy rẫy nguy hiểm và cạm bẫy,", "Sau một tai nạn bất ngờ, nhân vật chính của chúng ta tỉnh dậy ở một thế giới hoàn toàn xa lạ,", "Đây là một câu chuyện về tình yêu, thù hận và sự phản bội,")
$descMiddles = @("trên con đường khám phá bí mật về thân thế của mình và tìm kiếm sức mạnh tối thượng.", "anh ta phải đối mặt với những kẻ thù hùng mạnh và những âm mưu kinh thiên động địa.", "nơi mà kẻ mạnh làm vua, kẻ yếu chỉ có thể phục tùng.", "với những trận chiến nảy lửa và những tình tiết không thể đoán trước.")
$descEnds = @("Liệu cuối cùng, anh có thể bảo vệ được những người mình yêu thương?", "Số phận của cả thế giới nằm trong tay anh.", "Tất cả sẽ được hé lộ trong từng chương truyện.", "Đây là một tác phẩm không thể bỏ lỡ cho các fan của thể loại này.")

# --- Helper Functions ---
function Get-RandomTitle { return "$($titlePrefixes | Get-Random) $($titleMain | Get-Random) $($titleSuffixes | Get-Random)" }
function Get-RandomAuthor {
    $surname = $authorSurnames | Get-Random
    if ((Get-Random -Maximum 2) -eq 0) { return "$surname $($authorLastNames | Get-Random)" }
    else { return "$surname $($authorMiddleNames | Get-Random) $($authorLastNames | Get-Random)" }
}
function Get-RandomText {
    param([int]$minWords, [int]$maxWords)
    $wordCount = Get-Random -Minimum $minWords -Maximum ($maxWords + 1)
    $text = for ($i = 0; $i -lt $wordCount; $i++) { $loremIpsumWords[(Get-Random -Maximum $loremIpsumWords.Count)] }
    return ($text -join " ") + "."
}
function Get-RandomDescription {
    return "$($descStarts | Get-Random) $($descMiddles | Get-Random) $($descEnds | Get-Random)"
}

# --- Main Script Logic ---
for ($i = 3; $i -le 50; $i++) {
    $book = @{
        title = (Get-RandomTitle)
        author = (Get-RandomAuthor)
        tags = $allTags | Get-Random -Count (Get-Random -Minimum 2 -Maximum 5)
        description = (Get-RandomDescription)
        coverImageUrl = $null
        releaseDate = (Get-Date).AddDays(- (Get-Random -Minimum 1 -Maximum 3650)).ToString("o")
        status = "Completed"
        rating = [Math]::Round(((Get-Random -Minimum 30 -Maximum 51) / 10.0), 1)
        viewCountTotal = (Get-Random -Minimum 1000 -Maximum 2000000)
        viewCountMonthly = (Get-Random -Minimum 10 -Maximum 1000)
        viewCountWeekly = (Get-Random -Minimum 1 -Maximum 200)
        chapters = @()
    }
    $numChapters = Get-Random -Minimum 10 -Maximum 201
    for ($j = 1; $j -le $numChapters; $j++) {
        $chapter = @{
            title = "Chương $j"
            content = Get-RandomText -minWords 500 -maxWords 3000
            chapterIndex = $j
            publishDate = (Get-Date).AddDays(- (Get-Random -Minimum 1 -Maximum 365)).ToString("o")
        }
        $book.chapters += $chapter
    }
    $jsonContent = $book | ConvertTo-Json -Depth 10
    $filePath = Join-Path $outputDir "book$i.json"
    Set-Content -Path $filePath -Value $jsonContent -Encoding UTF8
    Write-Output "Creating file: book$i.json"
}
Write-Output "Done creating 48 book files with richer content."