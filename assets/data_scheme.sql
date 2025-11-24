-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    passwd_hash TEXT NOT NULL,
    pfp_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. AUTHORS
CREATE TABLE IF NOT EXISTS author (
    author_id UUID PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

-- 3. BOOKS
CREATE TABLE IF NOT EXISTS book (
    book_id UUID PRIMARY KEY,
    title TEXT NOT NULL,
    author_id UUID NOT NULL,
    description TEXT,
    cover_image_url TEXT,
    release_date DATE,
    status TEXT CHECK(status IN ('Ongoing', 'Completed', 'Halt')) DEFAULT 'Ongoing',
    rating NUMERIC(3, 1) DEFAULT 0.0,
    view_count_total INTEGER DEFAULT 0,
    view_count_monthly INTEGER DEFAULT 0,
    view_count_weekly INTEGER DEFAULT 0,
    FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE SET NULL
);

-- 4. CHAPTERS
CREATE TABLE IF NOT EXISTS chapter (
    chapter_id UUID PRIMARY KEY,
    book_id UUID NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    chapter_index NUMERIC(10, 2) NOT NULL, 
    word_count INTEGER,
    publish_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE
);

-- 5. TAGS
CREATE TABLE IF NOT EXISTS tag (
    tag_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

-- 6. BOOK_TAGS
CREATE TABLE IF NOT EXISTS book_tag (
    book_id UUID NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, tag_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tag(tag_id) ON DELETE CASCADE
);

-- 7. SHELF
CREATE TABLE IF NOT EXISTS shelf (
    user_id UUID NOT NULL,
    book_id UUID NOT NULL,
    last_read_chapter_id UUID, 
    last_read_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_archived BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (user_id, book_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES book(book_id) ON DELETE CASCADE,
    FOREIGN KEY (last_read_chapter_id) REFERENCES chapter(chapter_id) ON DELETE SET NULL
);

-- INDICES
CREATE INDEX IF NOT EXISTS idx_book_title ON book(title);
CREATE INDEX IF NOT EXISTS idx_chapter_order ON chapter(book_id, chapter_index);
CREATE INDEX IF NOT EXISTS idx_shelf_user ON shelf(user_id);