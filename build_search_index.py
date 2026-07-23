#!/usr/bin/env python3
"""
Builds search-index.db from a QUL word-by-word script export (Uthmani simple
or Imlaei simple) so it can be bundled alongside qpc-v4.db and
qpc-v4-tajweed-15-lines.db for text search.

Usage:
    python3 build_search_index.py path/to/downloaded-qul-script.db search-index.db
"""
import sqlite3
import sys
import re

# Arabic diacritics including Superscript/Dagger Alif (\u0670) and Tatweel (\u0640)
ARABIC_DIACRITICS = re.compile(
    "[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED\u0640]"
)

# Common Quranic words that get expanded phonetically into non-standard Imla'ei
PHONETIC_CORRECTIONS = {
    "الرحمان": "الرحمن",
    "إلاه": "اله",
    "هاذا": "هذا",
    "هاذه": "هذه",
    "أولائك": "اولئك",
    "اولائك": "اولئك",
}


def normalize_arabic(text: str) -> str:
    """
    Strip tashkeel/tatweel and unify alef/hamza/ta-marbuta/alef-maqsura forms.
    Removes \u0670 directly without turning it into a full Alif.
    """
    if not text:
        return ""

    # 1. Strip all diacritics & dagger alifs FIRST before any normalization
    text = ARABIC_DIACRITICS.sub("", text)

    # 2. Unify Alif variants (آ أ إ -> ا)
    text = re.sub("[\u0622\u0623\u0625]", "\u0627", text)

    # 3. Unify Ta Marbuta & Alif Maqsura (ة -> ه , ى -> ي)
    text = text.replace("\u0629", "\u0647")
    text = text.replace("\u0649", "\u064A")

    text = text.strip()

    # 4. Cleanup fallback: If the input DB stored expanded phonetic forms
    for wrong, correct in PHONETIC_CORRECTIONS.items():
        text = text.replace(wrong, correct)

    return text


def main():
    if len(sys.argv) != 3:
        print("Usage: python3 build_search_index.py <source_qul_script.db> <output search-index.db>")
        sys.exit(1)

    source_path, output_path = sys.argv[1], sys.argv[2]

    src = sqlite3.connect(source_path)
    src.row_factory = sqlite3.Row

    # Detect table column names dynamically
    columns = {row["name"] for row in src.execute("PRAGMA table_info(words)")}
    id_col = "word_index" if "word_index" in columns else "id"

    rows = src.execute(
        f"SELECT {id_col} AS id, surah, ayah, text FROM words ORDER BY {id_col} ASC"
    ).fetchall()
    src.close()

    out = sqlite3.connect(output_path)
    out.execute("DROP TABLE IF EXISTS words_search")
    out.execute("""
        CREATE TABLE words_search (
            id INTEGER PRIMARY KEY,
            surah INTEGER NOT NULL,
            ayah INTEGER NOT NULL,
            text_normalized TEXT NOT NULL,
            text_display TEXT NOT NULL
        )
    """)

    out.executemany(
        "INSERT INTO words_search (id, surah, ayah, text_normalized, text_display) VALUES (?, ?, ?, ?, ?)",
        [
            (row["id"], row["surah"], row["ayah"], normalize_arabic(row["text"]), row["text"])
            for row in rows
        ]
    )

    out.execute("CREATE INDEX idx_words_search_text ON words_search(text_normalized)")
    out.commit()
    out.close()

    print(f"Successfully wrote {len(rows)} normalized rows to {output_path}")


if __name__ == "__main__":
    main()
