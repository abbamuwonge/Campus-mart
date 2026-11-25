
from sqlalchemy import create_engine, MetaData, insert, inspect, text

from app.config import DATABASE_URL, BASE_DIR

SQLITE_URL = f"sqlite:///{BASE_DIR / 'campusmart.db'}"

TABLE_NAMES = [
    "users",
    "categories",
    "items",
    "orders",
    "favorites",
    "messages",
]


def migrate():
    source = create_engine(
        SQLITE_URL,
        connect_args={"check_same_thread": False},
    )

    destination = create_engine(
        DATABASE_URL,
        connect_args={"sslmode": "require"},
    )

    source_metadata = MetaData()
    target_metadata = MetaData()

    source_metadata.reflect(bind=source, only=TABLE_NAMES)
    target_metadata.reflect(bind=destination, only=TABLE_NAMES)

    try:
        with source.connect() as src:
            with destination.begin() as dst:

                # Never import into a database that already has records.
                for name in TABLE_NAMES:
                    count = dst.execute(
                        text(f'SELECT COUNT(*) FROM "{name}"')
                    ).scalar_one()

                    if count != 0:
                        raise RuntimeError(
                            f"Target table {name} is not empty. "
                            "Migration cancelled."
                        )

                print("Starting SQLite to PostgreSQL migration...")

                # SQLAlchemy orders tables according to foreign keys.
                for table in source_metadata.sorted_tables:
                    name = table.name

                    if name not in TABLE_NAMES:
                        continue

                    rows = src.execute(table.select()).mappings().all()

                    if rows:
                        target_table = target_metadata.tables[name]
                        dst.execute(
                            insert(target_table),
                            [dict(row) for row in rows],
                        )

                    print(f"{name}: {len(rows)} records copied")

                # Reset PostgreSQL auto-increment sequences after
                # preserving the original SQLite primary keys.
                for name in TABLE_NAMES:
                    table = target_metadata.tables[name]

                    for column in table.primary_key.columns:
                        if column.autoincrement in (True, "auto"):
                            quoted_table = (
                                destination.dialect.identifier_preparer
                                .quote(name)
                            )
                            quoted_column = (
                                destination.dialect.identifier_preparer
                                .quote(column.name)
                            )

                            dst.execute(
                                text(
                                    f"""
                                    SELECT setval(
                                        pg_get_serial_sequence(
                                            :table_name, :column_name
                                        ),
                                        COALESCE(MAX({quoted_column}), 1),
                                        MAX({quoted_column}) IS NOT NULL
                                    )
                                    FROM {quoted_table}
                                    """
                                ),
                                {
                                    "table_name": f"public.{name}",
                                    "column_name": column.name,
                                },
                            )

                print("\nMigration completed successfully.")

        # Verify the final record counts.
        with destination.connect() as dst:
            print("\nPostgreSQL verification:")

            for name in TABLE_NAMES:
                count = dst.execute(
                    text(f'SELECT COUNT(*) FROM "{name}"')
                ).scalar_one()

                print(f"{name}: {count}")

    finally:
        source.dispose()
        destination.dispose()


if __name__ == "__main__":
    migrate()
