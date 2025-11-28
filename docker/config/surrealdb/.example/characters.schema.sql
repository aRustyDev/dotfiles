-- Characters controlled by players
DEFINE TABLE character SCHEMAFULL;
DEFINE FIELD name     ON character TYPE string;
DEFINE FIELD level    ON character TYPE int DEFAULT 1;
DEFINE FIELD xp       ON character TYPE int DEFAULT 0;
DEFINE FIELD class    ON character TYPE string ASSERT $value IN ["warrior", "mage", "rogue"];
DEFINE FIELD stats    ON character TYPE { str: int, dex: int, int: int };

-- Items in the game world
DEFINE TABLE item SCHEMAFULL;
DEFINE FIELD name     ON item TYPE string;
DEFINE FIELD type     ON item TYPE string ASSERT $value IN ["weapon", "armor", "potion"];
DEFINE FIELD rarity   ON item TYPE string ASSERT $value IN ["common", "rare", "epic", "legendary"];
DEFINE FIELD effects  ON item TYPE array<{ str: int } | { heal: int }>; // etc.

-- Items possessed by characters
DEFINE TABLE owns TYPE RELATION IN character OUT item;
DEFINE FIELD equipped ON owns TYPE bool DEFAULT false;

-- Quests available in the world
DEFINE TABLE quest SCHEMAFULL;
DEFINE FIELD name      ON quest TYPE string;
DEFINE FIELD required_level ON quest TYPE int DEFAULT 1;
DEFINE FIELD rewards   ON quest TYPE { exp: int, items: array<record<item>> };

-- Character quest progress
DEFINE TABLE quest_log TYPE RELATION IN character OUT quest;
DEFINE FIELD status       ON quest_log TYPE string ASSERT $value IN ["active", "completed"];
DEFINE FIELD started_at   ON quest_log TYPE datetime DEFAULT time::now();
DEFINE FIELD completed_at ON quest_log TYPE option<datetime>;

-- Events
DEFINE TABLE character_event SCHEMAFULL;
DEFINE FIELD character  ON character_event TYPE record<character>;
DEFINE FIELD details    ON character_event TYPE
    { type: "combat", exp: int, against: string, summary: string } |
    { type: "item_used", item: record<item>, summary: string } |
    { type: "quest_update", summary: string };
DEFINE FIELD ts         ON character_event TYPE datetime DEFAULT time::now();

-- Create a new character
CREATE character:aria SET name = "Aria", class = "mage", stats = { str: 4, dex: 6, int: 12 };

-- Give Aria an item
RELATE character:aria->owns->(CREATE ONLY item SET name = "Wand of Sparks", type = "weapon", rarity = "rare", effects = { int: 2 });

-- Start a quest
RELATE character:aria->quest_log->quest:slime_hunt SET status = "active";
