--INSERT OPERATIONS WITH DIFFERENT TYPES OF INDEXES--

--Switch on auto-explain mode (need for procedures)
SET auto_explain.log_nested_statements = ON;

--STUDENT TABLE
CREATE INDEX btreeindex
    ON public.student USING btree
    (name ASC NULLS LAST)
    WITH (FILLFACTOR=10)
    TABLESPACE pg_default;
	
CREATE INDEX hashstudentsindex
    ON public.student USING hash
    (name)
    WITH (FILLFACTOR=10)
    TABLESPACE pg_default;
	
CREATE INDEX ginstudents ON public.student USING GIN (name);
	
CREATE INDEX giststudents ON public.student USING GIST (name);
	
--(Option 1) Fill student table
do $$
begin
execute (
    select string_agg('insert into student (name, surname, birthdate, phone, primaryskill, createdat, updatedat)
	VALUES (''Jhon'', ''Smith'', ''2004-10-19'', ''770000000'', ''math'', ''2004-10-19'', ''2004-10-19'')',';')
    from generate_series(1,1000)
);
end $$;

--(Option 2) Fill student table
do $$
begin
FOR i IN 1..100000 LOOP
   insert into student (name, surname, birthdate, phone, primaryskill, createdat, updatedat)
	VALUES ('Selma', 'Smith', '2004-10-19', '770000000', 'math', '2004-10-19', '2004-10-19');
END LOOP;
end $$;

DELETE FROM public.student;

--SUBJECT TABLE
CREATE INDEX btreesubj
    ON public.subject USING btree
    (name ASC NULLS LAST)
    WITH (FILLFACTOR=10)
    TABLESPACE pg_default;
	
CREATE INDEX hashsubj
    ON public.subject USING hash
    (name)
    WITH (FILLFACTOR=10)
    TABLESPACE pg_default;
	
CREATE INDEX ginsubject ON public.subject USING GIN (name);
	
CREATE INDEX gistsubject ON public.subject USING GIST (name);

do $$
begin
FOR i IN 1..1000 LOOP
   insert into subject (name, tutor)
	VALUES ('History', 'Grigorovich');
END LOOP;
end $$;

DELETE FROM public.subject;

--EXAM_RESULT TABLE
CREATE INDEX btreeexam_result
    ON public.exam_result USING btree
    (mark ASC NULLS LAST)
    WITH (FILLFACTOR=10)
    TABLESPACE pg_default;
	
CREATE INDEX hashexam_result
    ON public.exam_result USING hash
    (mark)
    WITH (FILLFACTOR=10)
    TABLESPACE pg_default;
	
CREATE INDEX ginexam_result ON public.exam_result USING GIN (mark);
	
CREATE INDEX gistexam_result ON public.exam_result USING GIST (mark);

do $$
begin
FOR i IN 1..1000000 LOOP
   insert into exam_result (mark)
	VALUES (85);
END LOOP;
end $$;

DELETE FROM public.exam_result;


--SELECT OPERATIONS WITH DIFFERENT TYPES SAMPLES--

--Plain select
SELECT * FROM public.student

--Partial match by surname
SELECT * FROM public.student WHERE surname like '%Smith';

--Partial match by phone number
SELECT * FROM public.student WHERE phone like '%770000000';


--TRIGGER THAT UPDATES COLUMN UPDATEDAT WHEN ENTRY IS UPDATED

CREATE FUNCTION upd_timestamp() RETURNS trigger AS $upd_timestamp$
BEGIN
        OLD.updatedat := current_timestamp;
        RETURN NEW;
END;
$upd_timestamp$ LANGUAGE plpgsql;

CREATE TRIGGER qupd_timestamp BEFORE UPDATE ON public.student FOR EACH ROW EXECUTE FUNCTION upd_timestamp();

--TRIGGER THAT RESTRICTS PARTICULAR SYMBOLS IN 'NAME' COLUMN

CREATE OR REPLACE FUNCTION check_name()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $check_name$
BEGIN
   IF NEW.name ~ '^[@,#,$]*$' THEN 
     return new;
   ELSE
     RAISE EXCEPTION 'Restricted symbols in name column detected: $,@ or #';
   END IF;
END;
$check_name$;

CREATE TRIGGER check_name BEFORE INSERT or update on public.student FOR EACH ROW EXECUTE procedure check_name();

--CREATE AND RESTORE DUMP FOR CURRENT STATE OF DB (USE IT IN CMD)

pg_dump -U postgres -h localhost studentsDB > mydb.pgsql
pg_restore -d newstudentsDB mydb.pgsql

--DIFFERENT QUERIES THAT RETURNS AVERAGE MARKS FOR STUDENT

--AVERAGE MARK FOR USER
SELECT "name", surname, AVG (mark)::NUMERIC(10,2) from exam_result INNER JOIN student ON student.id = exam_result.student_id GROUP by name, surname;
--AVERAGE MARK FOR SUBJECT
SELECT "name", AVG (mark)::NUMERIC(10,2) FROM exam_result INNER JOIN subject ON subject.id = exam_result.subject_id GROUP BY name;
--RETURNS STUDENTS, WHO HAVE <= 3 MARKS ("RED ZONE")
SELECT "name", surname FROM exam_result INNER JOIN student ON student.id = exam_result.student_id GROUP BY name, surname HAVING COUNT(mark) <= 3;


