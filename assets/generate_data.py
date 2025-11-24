import uuid
import random
import hashlib
import os
import csv
from faker import Faker
from pathlib import Path
from datetime import datetime, timedelta

# Initialize Faker for generating random data
fake = Faker()

# --- Constants ---
NUM_AUTHORS = 40
NUM_USERS = 20
NUM_BOOKS_PER_AUTHOR = random.randint(1, 5)
MIN_CHAPTERS_PER_BOOK = 50
MAX_CHAPTERS_PER_BOOK = 250
MIN_TAGS_PER_BOOK = 3
MAX_TAGS_PER_BOOK = 5
MIN_BOOKS_PER_SHELF = 3
MAX_BOOKS_PER_SHELF = 10
MIN_CHAPTER_WORDS = 800
MAX_CHAPTER_WORDS = 3000

# --- Word Lists ---
# A list of Sino-Vietnamese words for generating names and titles (more suitable for web novels)
sino_vietnamese_words = [
    "Thiên", "Đế", "Vương", "Thần", "Linh", "Quân", "Võ", "Kiếm", "Đạo", "Sát", "Tông",
    "Hoa", "Nguyệt", "Phong", "Vân", "Kim", "Ngọc", "Thủy", "Hỏa", "Mộc", "Thổ",
    "Mộng", "Duyên", "Giới", "Thế", "Minh", "Bạch", "Hắc", "Thanh", "Huyền", "Ảo",
    "Tiên", "Hiệp", "Ngôn", "Tình", "Đại", "Long", "Phượng", "Hổ", "Sơn", "Hải",
    "Tuyết", "Băng", "Lôi", "Điện", "Càn", "Khôn", "Cửu", "U", "Minh", "Dương", "Âm",
    "Thái", "Cực", "Vô", "Cực", "Tứ", "Linh", "Thượng", "Cổ", "Viễn", "Cổ", "Hồng", "Hoang",
    "Thâm", "Sâu", "Cao", "Rộng", "Đông", "Tây", "Nam", "Bắc", "Trung", "Ương",
    "Bất", "Diệt", "Vĩnh", "Hằng", "Chân", "Thật", "Hư", "Vô", "Mịt", "Mờ", "Ảm", "Đạm"
]

# A large list of common Vietnamese words for storytelling and daily communication
storytelling_words = [
    "Xin chào", "Cảm ơn", "Vui lòng", "Làm ơn", "Xin lỗi", "Không có gì", "Tạm biệt",
    "Bạn khỏe không", "Tôi khỏe", "Tên tôi là", "Vâng", "Dạ", "Không", "Tôi không hiểu",
    "Nói chậm thôi", "Cái này giá bao nhiêu", "Bao nhiêu tiền", "Ở đâu", "Cái gì",
    "Giúp tôi", "Cứu", "Tôi muốn", "Tôi sẽ lấy nó", "Ngon", "Chúc ngon miệng", "Bia",
    "Cà phê", "Nước", "Tốt", "Tồi tệ", "To", "Nhỏ", "Đẹp", "Đi", "Đến", "Có", "Thích",
    "Muốn", "Hôm nay", "Tuần", "Năm", "Mới", "Cũ", "Yên tĩnh", "Ồn ào", "Mạnh", "Yếu",
    "Sạch", "Dơ", "Nhanh", "Chậm", "Nóng", "Lạnh", "Vui", "Buồn", "Rồi", "Xong", "Đoạn",
    "Thì", "Bèn", "Đã", "Truyện", "Truyện ngắn", "Tiểu thuyết", "Hồi ký", "Thể loại",
    "Tác giả", "Nhân vật", "Cốt truyện", "Bối cảnh", "Tình yêu", "Gia đình", "Bạn bè",
    "Cuộc sống", "Cái chết", "Hạnh phúc", "Đau khổ", "Hy vọng", "Tuyệt vọng", "Sự thật",
    "Dối trá", "Tự do", "Nô lệ", "Chiến tranh", "Hòa bình", "Công lý", "Bất công",
    "Anh hùng", "Kẻ phản diện", "Số phận", "Vận mệnh", "Tương lai", "Quá khứ", "Hiện tại",
    "Thế giới", "Vũ trụ", "Thiên đường", "Địa ngục", "Ánh sáng", "Bóng tối", "Ngày", "Đêm",
    "Mưa", "Nắng", "Gió", "Bão", "Sông", "Núi", "Biển", "Rừng", "Đồng bằng", "Thành phố",
    "Làng quê", "Nhà", "Trường", "Chợ", "Đường", "Phố", "Xe", "Người", "Động vật", "Thực vật",
    "Ăn", "Uống", "Ngủ", "Thức", "Học", "Làm", "Chơi", "Nói", "Nghe", "Nhìn", "Đi", "Đứng",
    "Ngồi", "Nằm", "Cười", "Khóc", "Yêu", "Ghét", "Giúp", "Đỡ", "Cho", "Nhận", "Mua", "Bán",
    "Mở", "Đóng", "Vào", "Ra", "Trước", "Sau", "Trên", "Dưới", "Trong", "Ngoài", "Trái",
    "Phải", "Gần", "Xa", "Lớn", "Bé", "Dài", "Ngắn", "Cao", "Thấp", "Nặng", "Nhẹ", "Nhiều",
    "Ít", "Mới", "Cũ", "Đẹp", "Xấu", "Tốt", "Tồi", "Khó", "Dễ", "Đúng", "Sai", "Thật", "Giả"
]

# --- File Paths ---
ASSETS_DIR = Path(__file__).parent
PFP_DIR = ASSETS_DIR / "images" / "pfp"
THUMBNAILS_DIR = ASSETS_DIR / "images" / "thumbnails"
DATA_DIR = ASSETS_DIR / "data"
OUTPUT_SQL_FILE = DATA_DIR / "generated_data.sql"
USER_PASS_CSV_FILE = DATA_DIR / "user_passwords.csv"

# --- Helper Functions ---
def get_random_pfp():
    return random.choice(os.listdir(PFP_DIR))

def get_random_thumbnail():
    return random.choice(os.listdir(THUMBNAILS_DIR))

def generate_random_name(word_list, min_words=2, max_words=5):
    return " ".join(random.choices(word_list, k=random.randint(min_words, max_words))).title()

# --- Data Generation ---
def generate_authors(num_authors):
    authors = []
    for _ in range(num_authors):
        authors.append({
            "author_id": str(uuid.uuid4()),
            "name": generate_random_name(sino_vietnamese_words, 2, 4)
        })
    return authors

def generate_users(num_users):
    users = []
    user_passwords = []
    for _ in range(num_users):
        username = fake.user_name()
        password = fake.password()
        users.append({
            "user_id": str(uuid.uuid4()),
            "username": username,
            "passwd_hash": hashlib.sha256(password.encode()).hexdigest(),
            "pfp_url": get_random_pfp(),
            "created_at": fake.past_datetime(start_date="-2y")
        })
        user_passwords.append([username, password])
    
    with open(USER_PASS_CSV_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["username", "password"])
        writer.writerows(user_passwords)
        
    return users

def generate_tags():
    tags = ["Tiên Hiệp", "Huyền Huyễn", "Khoa Huyễn", "Võng Du", "Đô Thị", "Đồng Nhân", "Dã Sử", "Cạnh Kỹ", "Kiếm Hiệp"]
    return [{"tag_id": i + 1, "name": tag} for i, tag in enumerate(tags)]

def generate_books_and_chapters(authors, tags):
    books = []
    chapters = []
    book_tags = []

    for author in authors:
        for _ in range(NUM_BOOKS_PER_AUTHOR):
            book_id = str(uuid.uuid4())
            release_date = fake.past_date(start_date="-5y")
            view_total = random.randint(1000, 1000000)
            view_monthly = random.randint(500, view_total // 4 if view_total > 2000 else 500)
            view_weekly = random.randint(100, view_monthly // 4 if view_monthly > 400 else 100)
            
            book = {
                "book_id": book_id,
                "title": generate_random_name(sino_vietnamese_words, 2, 10),
                "author_id": author["author_id"],
                "description": fake.paragraph(nb_sentences=5),
                "cover_image_url": get_random_thumbnail(),
                "release_date": release_date,
                "status": random.choice(['Ongoing', 'Completed', 'Halt']),
                "rating": round(random.uniform(3.0, 5.0), 1),
                "view_count_total": view_total,
                "view_count_monthly": view_monthly,
                "view_count_weekly": view_weekly,
            }
            books.append(book)

            # Generate chapters for the book
            num_chapters = random.randint(MIN_CHAPTERS_PER_BOOK, MAX_CHAPTERS_PER_BOOK)
            for i in range(num_chapters):
                content = " ".join(random.choices(storytelling_words, k=random.randint(MIN_CHAPTER_WORDS, MAX_CHAPTER_WORDS)))
                chapters.append({
                    "chapter_id": str(uuid.uuid4()),
                    "book_id": book_id,
                    "title": f"CH{i+1}",
                    "content": content,
                    "chapter_index": i + 1,
                    "word_count": len(content.split()),
                    "publish_date": fake.date_time_between(start_date=release_date, end_date="now")
                })

            # Assign tags to the book
            assigned_tags = random.sample(tags, k=random.randint(MIN_TAGS_PER_BOOK, MAX_TAGS_PER_BOOK))
            for tag in assigned_tags:
                book_tags.append({
                    "book_id": book_id,
                    "tag_id": tag["tag_id"]
                })
                
    return books, chapters, book_tags

def generate_shelves(users, books):
    shelves = []
    for user in users:
        num_books_on_shelf = random.randint(MIN_BOOKS_PER_SHELF, MAX_BOOKS_PER_SHELF)
        shelf_books = random.sample(books, k=num_books_on_shelf)
        for book in shelf_books:
            # Get chapters for the selected book
            book_chapters = [c for c in chapters if c["book_id"] == book["book_id"]]
            last_read_chapter = random.choice(book_chapters) if book_chapters else None
            
            shelves.append({
                "user_id": user["user_id"],
                "book_id": book["book_id"],
                "last_read_chapter_id": last_read_chapter["chapter_id"] if last_read_chapter else "NULL",
                "last_read_date": fake.past_datetime(start_date="-1y"),
                "is_archived": random.choice([True, False])
            })
    return shelves

# --- SQL Generation ---
def generate_sql_file(authors, users, tags, books, chapters, book_tags, shelves):
    with open(OUTPUT_SQL_FILE, "w", encoding="utf-8") as f:
        f.write("-- Generated data for sky_book\n\n")

        # Authors
        f.write("INSERT INTO author (author_id, name) VALUES\n")
        for i, author in enumerate(authors):
            f.write(f"('{author['author_id']}', '{author['name'].replace("'", "''")}')")
            f.write(",\n" if i < len(authors) - 1 else ";\n\n")

        # Users
        f.write("INSERT INTO users (user_id, username, passwd_hash, pfp_url, created_at) VALUES\n")
        for i, user in enumerate(users):
            f.write(f"('{user['user_id']}', '{user['username']}', '{user['passwd_hash']}', '{user['pfp_url']}', '{user['created_at']}')")
            f.write(",\n" if i < len(users) - 1 else ";\n\n")
            
        # Tags
        f.write("INSERT INTO tag (name) VALUES\n")
        for i, tag in enumerate(tags):
            f.write(f"('{tag['name']}')")
            f.write(",\n" if i < len(tags) - 1 else ";\n\n")

        # Books
        f.write("INSERT INTO book (book_id, title, author_id, description, cover_image_url, release_date, status, rating, view_count_total, view_count_monthly, view_count_weekly) VALUES\n")
        for i, book in enumerate(books):
            description = book['description'].replace("'", "''")
            f.write(f"('{book['book_id']}', '{book['title'].replace("'", "''")}', '{book['author_id']}', '{description}', '{book['cover_image_url']}', '{book['release_date']}', '{book['status']}', {book['rating']}, {book['view_count_total']}, {book['view_count_monthly']}, {book['view_count_weekly']})")
            f.write(",\n" if i < len(books) - 1 else ";\n\n")

        # Chapters
        f.write("INSERT INTO chapter (chapter_id, book_id, title, content, chapter_index, word_count, publish_date) VALUES\n")
        for i, chapter in enumerate(chapters):
            content = chapter['content'].replace("'", "''")
            f.write(f"('{chapter['chapter_id']}', '{chapter['book_id']}', '{chapter['title']}', '{content}', {chapter['chapter_index']}, {chapter['word_count']}, '{chapter['publish_date']}')")
            f.write(",\n" if i < len(chapters) - 1 else ";\n\n")

        # Book_Tags
        f.write("INSERT INTO book_tag (book_id, tag_id) VALUES\n")
        for i, bt in enumerate(book_tags):
            f.write(f"('{bt['book_id']}', {bt['tag_id']})")
            f.write(",\n" if i < len(book_tags) - 1 else ";\n\n")
            
        # Shelves
        f.write("INSERT INTO shelf (user_id, book_id, last_read_chapter_id, last_read_date, is_archived) VALUES\n")
        for i, shelf in enumerate(shelves):
            last_read_id = f"'{shelf['last_read_chapter_id']}'" if shelf['last_read_chapter_id'] != "NULL" else "NULL"
            f.write(f"('{shelf['user_id']}', '{shelf['book_id']}', {last_read_id}, '{shelf['last_read_date']}', {shelf['is_archived']})")
            f.write(",\n" if i < len(shelves) - 1 else ";\n\n")

if __name__ == "__main__":
    print("Generating data...")
    
    # Create directories if they don't exist
    DATA_DIR.mkdir(exist_ok=True)

    authors = generate_authors(NUM_AUTHORS)
    users = generate_users(NUM_USERS)
    tags = generate_tags()
    books, chapters, book_tags = generate_books_and_chapters(authors, tags)
    shelves = generate_shelves(users, books)
    
    generate_sql_file(authors, users, tags, books, chapters, book_tags, shelves)
    
    print(f"Data generation complete. SQL file created at: {OUTPUT_SQL_FILE}")
    print(f"User passwords CSV created at: {USER_PASS_CSV_FILE}")
