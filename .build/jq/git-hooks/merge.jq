# Define merge logic for individual fields
def should_update_field(source_value; target_value):
  (source_value | tostring | ascii_downcase | contains("todo") | not) or
  ((target_value | tostring | ascii_downcase | contains("todo")) and
   (source_value != null and source_value != ""));

# Merge a single item from first into target
def merge_item(first_item):
  .repos |= map(
    if .owner == first_item.owner and .repo == first_item.repo then
      # Found matching entry - update fields
      . as $target |
      reduce (first_item | keys[]) as $key (.;
        if should_update_field(first_item[$key]; $target[$key]) then
          .[$key] = first_item[$key]
        else
          .
        end
      )
    else
      .
    end
  ) |
  # Check if item was found and updated
  if (.repos | map(select(.owner == first_item.owner and .repo == first_item.repo)) | length) == 0 then
    # No match found - add new entry
    .repos += [first_item]
  else
    .
  end;

# Main merge logic
. as $second |
reduce ($first[0][]) as $item ($second; merge_item($item))
