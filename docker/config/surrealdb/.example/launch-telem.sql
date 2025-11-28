-- A specific launch instance (e.g., Falcon 9 Flight 100)
DEFINE TABLE launch SCHEMAFULL;
DEFINE FIELD name         ON launch TYPE string;
DEFINE FIELD vehicle_name ON launch TYPE option<string>;
DEFINE FIELD scheduled_at ON launch TYPE datetime;
DEFINE FIELD liftoff_at   ON launch TYPE option<datetime>;
DEFINE FIELD status       ON launch TYPE string ASSERT $value IN ["scheduled", "launched", "scrubbed", "failed", "success"] DEFAULT "scheduled";
DEFINE FIELD completed    ON launch TYPE option<datetime>;

-- Components involved in the launch
DEFINE TABLE component SCHEMAFULL;
DEFINE FIELD launch     ON component TYPE record<launch>;
DEFINE FIELD name       ON component TYPE string; -- e.g., "first_stage", "engine_1"
DEFINE FIELD type       ON component TYPE string ASSERT $value IN ["stage", "engine", "payload", "fairing"];

-- Time-series telemetry linked to a component
DEFINE TABLE telemetry SCHEMAFULL;
DEFINE FIELD id            ON telemetry TYPE [record<component>, datetime]; -- [component, ulid]
DEFINE FIELD altitude_m    ON telemetry TYPE option<float>;
DEFINE FIELD velocity_mps  ON telemetry TYPE option<float>;
DEFINE FIELD thrust_kN     ON telemetry TYPE option<float>;
DEFINE FIELD pressure_kPa  ON telemetry TYPE option<float>;
DEFINE FIELD temperature_C ON telemetry TYPE option<float>;
DEFINE FIELD status        ON telemetry TYPE option<string>;

CREATE launch:one SET name = "Launch 1", vehicle_name = "Fire rocket", scheduled_at = time::now() - 5s, liftoff_at = time::now() - 1s;
CREATE component:one SET launch = launch:one, name = "Engine 1", type = "engine";
CREATE component:two SET launch = launch:one, name = "Engine 2", type = "engine";

-- Add durations to all datetimes below to simulate passage of time
CREATE telemetry:[component:one, time::now()] SET temperature_c = 30.5, status = "good";
CREATE telemetry:[component:one, time::now() + 1s] SET temperature_c = 30.7, status = "good";
CREATE telemetry:[component:one, time::now() + 2s] SET temperature_c = 30.9, status = "good";
CREATE telemetry:[component:one, time::now() + 3s] SET temperature_c = 35.0, status = "good";
CREATE telemetry:[component:two, time::now()] SET temperature_c = 30.5, status = "good";
CREATE telemetry:[component:two, time::now() + 1s] SET temperature_c = 30.7, status = "good";
CREATE telemetry:[component:two, time::now() + 2s] SET temperature_c = 30.9, status = "good";
CREATE telemetry:[component:two, time::now() + 3s] SET temperature_c = 35.0, status = "good";

UPDATE launch:one SET completed = time::now() + 5s;

-- Get all telemetry for component:two during launch:one
SELECT * FROM telemetry:[component:two, launch:one.liftoff_at]..=[component:two, launch:one.completed];

-- Or LIVE SELECT during the flight
LIVE SELECT * FROM telemetry WHERE id[0] = component:two;
