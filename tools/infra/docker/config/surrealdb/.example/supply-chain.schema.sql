-- Vendors who supply goods or services
DEFINE TABLE vendor SCHEMAFULL;
DEFINE FIELD name ON vendor TYPE string;

-- Contracts awarded under a project
DEFINE TABLE contract SCHEMAFULL;
DEFINE FIELD project        ON contract TYPE record<project>;
DEFINE FIELD vendor         ON contract TYPE record<vendor>;
DEFINE FIELD title          ON contract TYPE string;
DEFINE FIELD original_value ON contract TYPE int;
DEFINE FIELD total_value    ON contract COMPUTED
    original_value + math::sum(SELECT VALUE amount FROM change_order WHERE contract = $parent.id);
DEFINE FIELD currency ON contract TYPE "dollars" | "euro";
DEFINE FIELD start   ON contract TYPE datetime;
DEFINE FIELD end     ON contract TYPE datetime;

-- Deliverables expected under a contract
DEFINE TABLE deliverable SCHEMAFULL;
DEFINE FIELD contract    ON deliverable TYPE record<contract>;
DEFINE FIELD description ON deliverable TYPE string;
DEFINE FIELD due_date    ON deliverable TYPE datetime;
DEFINE FIELD received    ON deliverable TYPE option<datetime>;
DEFINE FIELD status      ON deliverable COMPUTED IF $parent.received { "complete" } ELSE { "pending" };

-- Change orders during a project
DEFINE TABLE change_order SCHEMAFULL;
DEFINE FIELD contract    ON change_order TYPE record<contract>;
DEFINE FIELD amount      ON change_order TYPE int;
DEFINE FIELD description ON change_order TYPE string;
DEFINE FIELD signed_on   ON change_order TYPE option<datetime>;

-- Total committed value of a project (sum of all contract values)
DEFINE FIELD total_commitment ON project COMPUTED
  math::sum((SELECT VALUE value FROM contract WHERE project = $parent.id));

CREATE project:one;
CREATE vendor:one SET name = "Good vendor";
    CREATE contract:one SET project = project:one, currency = "euro", start = d'2025-12-01', end = d'2026-01-01', original_value = 1000, title = "Services for so-and-so project", vendor = vendor:one;
CREATE change_order SET contract = contract:one, amount = 500, description = "Highway wasn't set up yet";
SELECT * FROM contract;
