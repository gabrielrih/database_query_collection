-- Get all available input formats
select name
from system.formats
where is_input = 1
order by name;
