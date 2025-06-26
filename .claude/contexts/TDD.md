
  1. Import Errors (3 failures):
    - ModuleNotFoundError: No module named 'honk' - trying to patch non-existent modules
    - Incorrect import paths like from utils import findkeys instead of from goosey.utils import findkeys
  2. Function Signature Mismatches (5 failures):
    - get_nextlink() called with wrong parameter order: actual signature is (url, outfile, session, logger, auth) but test calls it with (session, url, outfile, endpoint)
    - helper_single_object() expects params tuple but test passes individual arguments
    - parse_file() missing required parameters fields and result_dir
  3. Authentication/Parameter Issues (2 failures):
    - helper_single_object() failing due to missing token_type and access_token in auth structure
    - Functions expecting proper auth tokens but getting incomplete mock data
  4. Data Type Mismatches (2 failures):
    - save_state() function expecting datetime object but getting dictionary
    - write_auth() function signature mismatch with test expectations
  5. Over-Mocking Issues (multiple):
    - Tests are mocking too much, losing track of actual function behavior
    - Mocks don't match real function signatures and requirements
