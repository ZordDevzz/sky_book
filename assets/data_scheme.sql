-- Enable Foreign Key support (SQLite has this off by default)
PRAGMA foreign_keys = ON;

-- 1. USERS
CREATE TABLE IF NOT EXISTS User (
    UserId TEXT PRIMARY KEY, -- Store UUID strings here
    Username TEXT UNIQUE NOT NULL,
    PasswdHash TEXT NOT NULL,
    PfpUrl TEXT,
    CreatedAt TEXT DEFAULT (datetime('now'))
);

-- 2. AUTHORS
CREATE TABLE IF NOT EXISTS Author (
    AuthorId TEXT PRIMARY KEY, -- Store UUID strings here
    Name TEXT NOT NULL
);

-- 3. BOOKS
CREATE TABLE IF NOT EXISTS Book (
    BookId TEXT PRIMARY KEY, -- Store UUID strings here
    Title TEXT NOT NULL,
    AuthorId TEXT NOT NULL,
    Description TEXT,
    CoverImageUrl TEXT,
    ReleaseDate TEXT, -- Format: YYYY-MM-DD
    -- Simulating ENUM using CHECK constraint
    Status TEXT CHECK(Status IN ('Ongoing', 'Completed', 'Halt')) DEFAULT 'Ongoing',
    Rating REAL DEFAULT 0.0,
    ViewCount_Total INTEGER DEFAULT 0,
	ViewCount_Monthly INTEGER DEFAULT 0,
	ViewCount_Weekly INTEGER DEFAULT 0,
    FOREIGN KEY (AuthorId) REFERENCES Author(AuthorId) ON DELETE SET NULL
);

-- 4. CHAPTERS
-- Using REAL for ChapterIndex to allow 1.5, 10.1 inserts
CREATE TABLE IF NOT EXISTS Chapter (
    ChapterId TEXT PRIMARY KEY, -- Store UUID strings here
    BookId TEXT NOT NULL,
    Title TEXT NOT NULL,
    Content TEXT NOT NULL,
    ChapterIndex REAL NOT NULL, 
    WordCount INTEGER,
    PublishDate TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (BookId) REFERENCES Book(BookId) ON DELETE CASCADE
);

-- 5. TAGS (Categories)
CREATE TABLE IF NOT EXISTS Tag (
    TagId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT UNIQUE NOT NULL
);

-- 6. BOOK_TAGS (Many-to-Many Junction)
CREATE TABLE IF NOT EXISTS Book_Tag (
    BookId TEXT NOT NULL,
    TagId INTEGER NOT NULL,
    PRIMARY KEY (BookId, TagId),
    FOREIGN KEY (BookId) REFERENCES Book(BookId) ON DELETE CASCADE,
    FOREIGN KEY (TagId) REFERENCES Tag(TagId) ON DELETE CASCADE
);

-- 7. SHELF (User's Library & Progress)
CREATE TABLE IF NOT EXISTS Shelf (
    UserId TEXT NOT NULL,
    BookId TEXT NOT NULL,
    LastReadChapterId TEXT, -- Can be NULL if added to shelf but not started
    LastReadDate TEXT DEFAULT (datetime('now')),
    IsArchived INTEGER DEFAULT 0, -- 0 = False, 1 = True
    PRIMARY KEY (UserId, BookId),
    FOREIGN KEY (UserId) REFERENCES User(UserId) ON DELETE CASCADE,
    FOREIGN KEY (BookId) REFERENCES Book(BookId) ON DELETE CASCADE,
    FOREIGN KEY (LastReadChapterId) REFERENCES Chapter(ChapterId) ON DELETE SET NULL
);

-- USEFUL INDICES FOR PERFORMANCE
-- Search books by title quickly
CREATE INDEX idx_book_title ON Book(Title);
-- Get all chapters for a book, sorted (The most common query)
CREATE INDEX idx_chapter_order ON Chapter(BookId, ChapterIndex);
-- Find a user's library quickly
CREATE INDEX idx_shelf_user ON Shelf(UserId);