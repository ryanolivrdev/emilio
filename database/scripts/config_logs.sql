CREATE OR REPLACE FUNCTION log_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO log (message) VALUES ('INSERT: ' || TG_TABLE_NAME || ' - ' || quote_literal(NEW));
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO log (message) VALUES ('UPDATE: ' || TG_TABLE_NAME || ' - ' || quote_literal(OLD) || ' -> ' || quote_literal(NEW));
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO log (message) VALUES ('DELETE: ' || TG_TABLE_NAME || ' - ' || quote_literal(OLD));
  ELSE
    RAISE WARNING '[log_trigger] - Other action occurred: %, at %',TG_OP,now();
    RETURN NULL;
  END IF;

  RETURN new;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER log_trigger
  AFTER INSERT OR UPDATE OR DELETE ON collection
  FOR EACH ROW EXECUTE PROCEDURE log_trigger();

CREATE TRIGGER log_trigger
  AFTER INSERT OR UPDATE OR DELETE ON copyright
  FOR EACH ROW EXECUTE PROCEDURE log_trigger();

CREATE TRIGGER log_trigger
  AFTER INSERT OR UPDATE OR DELETE ON institution
  FOR EACH ROW EXECUTE PROCEDURE log_trigger();

CREATE TRIGGER log_trigger
  AFTER INSERT OR UPDATE OR DELETE ON location
  FOR EACH ROW EXECUTE PROCEDURE log_trigger();

CREATE TRIGGER log_trigger
  AFTER INSERT OR UPDATE OR DELETE ON occurrence
  FOR EACH ROW EXECUTE PROCEDURE log_trigger();

CREATE TRIGGER log_trigger
  AFTER INSERT OR UPDATE OR DELETE ON specimen
  FOR EACH ROW EXECUTE PROCEDURE log_trigger();

