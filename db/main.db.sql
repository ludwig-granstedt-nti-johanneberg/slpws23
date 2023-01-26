BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Teams" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Users" (
	"id"	INTEGER NOT NULL UNIQUE,
	"password-digest"	TEXT NOT NULL,
	"username"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Users-Teams" (
	"user"	INTEGER NOT NULL,
	"team"	INTEGER NOT NULL UNIQUE,
	FOREIGN KEY("user") REFERENCES "Users"("id"),
	FOREIGN KEY("team") REFERENCES "Teams"("id")
);
CREATE TABLE IF NOT EXISTS "Teams-TeamPokemon" (
	"team"	INTEGER NOT NULL,
	"pokemon"	INTEGER NOT NULL UNIQUE,
	FOREIGN KEY("pokemon") REFERENCES "TeamPokemon"("id"),
	FOREIGN KEY("team") REFERENCES "Teams"("id")
);
CREATE TABLE IF NOT EXISTS "Abilities" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT,
	"effect"	TEXT NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "PokemonSpecies" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL UNIQUE,
	"sprite"	BLOB,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "TeamPokemon" (
	"id"	INTEGER NOT NULL,
	"nickname"	TEXT,
	"ability"	INTEGER NOT NULL,
	"species"	INTEGER NOT NULL,
	FOREIGN KEY("species") REFERENCES "PokemonSpecies"("id"),
	FOREIGN KEY("ability") REFERENCES "Abilities"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "PokemonSpecies-Abilities" (
	"pokemon"	INTEGER NOT NULL,
	"ability"	INTEGER NOT NULL,
	FOREIGN KEY("pokemon") REFERENCES "PokemonSpecies"("id"),
	FOREIGN KEY("ability") REFERENCES "Abilities"("id")
);
CREATE TABLE IF NOT EXISTS "TeamPokemon-Moves" (
	"pokemon"	INTEGER NOT NULL,
	"move"	INTEGER NOT NULL,
	FOREIGN KEY("move") REFERENCES "Moves"("id"),
	FOREIGN KEY("pokemon") REFERENCES "TeamPokemon"("id")
);
CREATE TABLE IF NOT EXISTS "Types" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL UNIQUE,
	"icon"	BLOB,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "PokemonSpecies-Types" (
	"pokemon"	INTEGER NOT NULL,
	"type"	INTEGER NOT NULL,
	FOREIGN KEY("pokemon") REFERENCES "PokemonSpecies"("id"),
	FOREIGN KEY("type") REFERENCES "Types"("id")
);
CREATE TABLE IF NOT EXISTS "Moves" (
	"id"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL UNIQUE,
	"power"	INTEGER,
	"accuracy"	INTEGER,
	"effect"	TEXT NOT NULL,
	"type"	INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("type") REFERENCES "Types"("id")
);
CREATE TABLE IF NOT EXISTS "Types-Weaknesses" (
	"type"	INTEGER NOT NULL,
	"weakness"	INTEGER NOT NULL,
	FOREIGN KEY("type") REFERENCES "Types"("id"),
	FOREIGN KEY("weakness") REFERENCES "Types"("id")
);
CREATE TABLE IF NOT EXISTS "Types-Resistances" (
	"type"	INTEGER NOT NULL,
	"resistance"	INTEGER NOT NULL,
	FOREIGN KEY("type") REFERENCES "Types"("id"),
	FOREIGN KEY("resistance") REFERENCES "Types"("id")
);
CREATE TABLE IF NOT EXISTS "Types-Immunities" (
	"type"	INTEGER NOT NULL,
	"immunity"	INTEGER NOT NULL,
	FOREIGN KEY("immunity") REFERENCES "Types"("id"),
	FOREIGN KEY("type") REFERENCES "Types"("id")
);
CREATE TABLE IF NOT EXISTS "Users-Friends" (
	"user"	INTEGER NOT NULL,
	"friend"	INTEGER NOT NULL,
	FOREIGN KEY("friend") REFERENCES "Users"("id"),
	FOREIGN KEY("user") REFERENCES "Users"("id")
);
INSERT INTO "Teams" VALUES (1,'test');
COMMIT;
