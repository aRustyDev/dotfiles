-- Activities in a project schedule
DEFINE TABLE activity SCHEMAFULL;
DEFINE FIELD name         ON activity TYPE string;
DEFINE FIELD description  ON activity TYPE option<string>;
DEFINE FIELD start        ON activity TYPE datetime;
DEFINE FIELD end          ON activity TYPE datetime;
DEFINE FIELD duration     ON activity COMPUTED end - start;
DEFINE FIELD progress     ON activity TYPE float ASSERT $value IN 0.0..=1.0;
DEFINE FIELD assigned_to  ON activity TYPE option<record<employee>>;
DEFINE FIELD followed_by  ON activity COMPUTED <-depends_on<-activity;

-- Milestones
DEFINE TABLE milestone SCHEMAFULL;
DEFINE FIELD project      ON milestone TYPE record<project>;
DEFINE FIELD activities   ON milestone TYPE array<record<activity>>;
DEFINE FIELD name         ON milestone TYPE string;
DEFINE FIELD last_updated ON milestone VALUE time::now();
DEFINE FIELD progress     ON milestone COMPUTED math::mean(activities.progress);
DEFINE FIELD is_complete  ON milestone COMPUTED activities.all(|$a| $a.progress > 0.95);

-- Graph-style dependency links
DEFINE TABLE depends_on SCHEMAFULL TYPE RELATION IN activity OUT activity;
DEFINE TABLE activity_of SCHEMAFULL TYPE RELATION IN activity OUT project;

CREATE project:one;

CREATE activity:one SET name = "Project kickoff", start = time::now(), end = time::now() + 2d, progress = 1.0, project = project:one;
CREATE activity:two SET name = "Pour concrete", start = time::now() + 90d, end = time::now() + 100d, progress = 0.0, project = project:one;
CREATE activity:three SET name = "Dry concrete", start = time::now() + 100d, end = time::now() + 107d, progress = 0.0, project = project:two;
CREATE activity:four SET name = "Build on top of concrete", start = time::now() + 107d, end = time::now() + 150d, progress = 0.0, project = project:two;

RELATE activity:two->depends_on->activity:one;
RELATE activity:three->depends_on->activity:two;
RELATE activity:four->depends_on->activity:three;
RELATE [activity:one,activity:two,activity:three, activity:four]->activity_of->project:one;

CREATE milestone:one SET project = project:one, activities = [activity:one], name = "Project start";
CREATE milestone:two SET project = project:one, activities = [activity:two, activity:three, activity:four], name = "Initial construction";

-- See all graph connections between activity and project records
SELECT *, ->?, <-? FROM activity, project;

-- View the current milestones
SELECT * FROM milestone;
