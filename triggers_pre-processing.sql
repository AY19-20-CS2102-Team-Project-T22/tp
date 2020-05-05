/*pre-processing data in Users relation*/
CREATE OR REPLACE FUNCTION clean_username () RETURNS TRIGGER AS $$
BEGIN
	NEW.userName = btrim(regexp_replace(NEW.userName, '\s+', ' ', 'g'));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clean_realname () RETURN TRIGGER AS $$
BEGIN
	NEW.lastName = btrim(regexp_replace(NEW.lastName, '\s+', ' ', 'g'));
	NEW.firstName = btrim(regexp_replace(NEW.firstName, '\s+', ' ', 'g'));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION clean_email () RETURN TRIGGER AS $$
BEGIN
	NEW.email = lower(regexp_replace(NEW.email, '\s', '', 'g'));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_email_trigger
	BEFORE UPDATE OF email OR INSERT 
	ON Users
	FOR EACH ROW
	EXECUTE FUNCTION clean_email();

CREATE TRIGGER clean_username_trigger
	BEFORE UPDATE OF userName OR INSERT
	ON Users
	FOR EACH ROW
	EXECUTE FUNCTION clean_username();

CREATE TRIGGER clean_realname_trigger
	BEFORE UPDATE OF lastName, firstName OR INSERT
	ON Users
	FOR EACH ROW
	EXECUTE FUNCTION clean_realname();

/*pre-processing bank name of creditcards relation*/
CREATE OR REPLACE FUNCTION clean_bankname () RETURN TRIGGER AS $$
BEGIN
	NEW.bank = btrim(regexp_replace(NEW.bank, '\s+', ' ', 'g'));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_bankname_trigger
	BEFORE UPDATE OF bank OR INSERT
	ON CreditCards
	FOR EACH ROW
	EXECUTE FUNCTION clean_bankname();

/*pre-processing restaurant name of restaurant relation*/
CREATE OR REPLACE FUNCTION clean_restaurantname () RETURN TRIGGER AS $$
BEGIN
	NEW.name = btrim(regexp_replace(NEW.name, '\s+', ' ', 'g'));
	RETURN NEW
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_restaurantname_trigger
	BEFORE UPDATE OF name OR INSERT
	ON Restaurants
	FOR EACH ROW
	EXECUTE FUNCTION clean_restaurantname();

/*pre-processing name of food relation*/
CREATE OR REPLACE FUNCTION clean_foodname () RETURN TRIGGER AS $$
BEGIN
	NEW.name = btrim(regexp_replace(NEW.name, '\s+', ' ', 'g'));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_foodname_trigger
	BEFORE UPDATE OF name OR INSERT
	ON Foods
	FOR EACH ROW
	EXECUTE clean_foodname();

/*pre-processing name of food relation*/
CREATE OR REPLACE FUNCTION clean_foodname () RETURN TRIGGER AS $$
BEGIN
	NEW.name = btrim(regexp_replace(NEW.name, '\s+', ' ', 'g'));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_foodname_trigger
	BEFORE UPDATE OF name OR INSERT
	ON Foods
	FOR EACH ROW
	EXECUTE clean_foodname();

/*pre-processing category of foodcategory relation*/
CREATE OR REPLACE FUNCTION clean_foodcategory () RETURN TRIGGER AS $$
BEGIN
	NEW.category = btrim(regexp_replace(NEW.category, '\s+', ' ', 'g'));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_foodcategory_trigger
	BEFORE UPDATE OF category OR INSERT
	ON FoodCategories
	FOR EACH ROW
	EXECUTE clean_foodcategory();

/*pre-processing feedback of reviews relation*/
CREATE OR REPLACE FUNCTION clean_feedback () RETURN TRIGGER AS $$
BEGIN
	NEW.feedback = btrim(NEW.feedback);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER clean_feedback_trigger
	BEFORE UPDATE OF feedback OR INSERT
	ON Reviews
	FOR EACH ROW
	EXECUTE FUNCTION clean_feedback();