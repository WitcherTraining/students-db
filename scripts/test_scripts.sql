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
end; $$;

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
	VALUES ('F');
END LOOP;
end $$;

DELETE FROM public.exam_result;


