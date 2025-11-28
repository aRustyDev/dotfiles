-- Mission-level directive
DEFINE TABLE operation SCHEMAFULL;
DEFINE FIELD name        ON operation TYPE string;
DEFINE FIELD status      ON operation TYPE string ASSERT $value IN ["planned", "active", "complete", "aborted"] DEFAULT "planned";
DEFINE FIELD commander   ON operation TYPE option<record<person>>;
DEFINE FIELD start_time  ON operation TYPE option<datetime>;
DEFINE FIELD end_time    ON operation TYPE option<datetime>;

DEFINE TABLE unit SCHEMAFULL;
DEFINE FIELD members     ON unit TYPE array<record<person>>;
DEFINE FIELD operation   ON unit TYPE record<operation>;
DEFINE FIELD name        ON unit TYPE string; -- e.g., "drone-2", "squad-a"
DEFINE FIELD type        ON unit TYPE string ASSERT $value IN ["drone", "vehicle", "infantry", "support"];
DEFINE FIELD status      ON unit TYPE string ASSERT $value IN ["ready", "deployed", "engaged", "inactive"];

-- Time-stamped unit log (e.g., movement, engagement, report)
DEFINE TABLE log SCHEMAFULL;
DEFINE FIELD id          ON log TYPE [record<unit>, datetime]; -- [unit, timestamp]
DEFINE FIELD message     ON log TYPE string;
DEFINE FIELD status      ON log TYPE option<string>; -- e.g., "engaged", "moving", "waiting"
DEFINE FIELD lonlat      ON log TYPE option<point>;
DEFINE FIELD visibility  ON log TYPE option<string> ASSERT $value IN ["clear", "obscured", "night"];

-- Tasks assigned within a mission
DEFINE TABLE task SCHEMAFULL;
DEFINE FIELD operation   ON task TYPE record<operation>;
DEFINE FIELD name        ON task TYPE string;
DEFINE FIELD objective   ON task TYPE string;
DEFINE FIELD assigned_to ON task TYPE option<array<record<unit>>>;
DEFINE FIELD priority    ON task TYPE string ASSERT $value IN ["high", "medium", "low"];
DEFINE FIELD completed   ON task TYPE bool DEFAULT false;

CREATE operation:alpha SET name = "Operation Alpha", commander = person:one, start_time = time::now();

CREATE unit:squad1 SET operation = operation:alpha, name = "squad-1", type = "infantry", status = "deployed", members = [person:one, person:two];
CREATE unit:drone1 SET operation = operation:alpha, name = "drone-1", type = "drone", status = "ready", members = [person:three, person:four];

CREATE task SET
  operation = operation:alpha,
  name = "Secure Ridge",
  objective = "Clear hilltop sector",
  assigned_to = [unit:squad1],
  priority = "high";

-- Log messages (simulate time with + durations)
CREATE log:[unit:squad1, time::now()] SET message = "Entered zone", status = "moving", lonlat = (44.2, 6.3);
CREATE log:[unit:squad1, time::now() + 3m] SET message = "Engaged hostiles", status = "engaged", visibility = "clear";
CREATE log:[unit:drone1, time::now()] SET message = "Recon sweep complete", status = "waiting", lonlat = (44.3, 6.2);
