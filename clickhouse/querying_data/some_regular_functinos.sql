-- It'll look for the word "STREET" on the street field
select count(1) from uk_prices_1
where position(street, 'STREET') > 0;

-- The same as above but ignoring case sensitive
select count(1) from uk_prices_1
where positionCaseInsensitive(street, 'Street') > 0;
