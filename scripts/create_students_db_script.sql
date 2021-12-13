CREATE DATABASE "studentsDB"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

CREATE TABLE student (
  id BIGINT NOT NULL,
  name VARCHAR(255) NULL,
  surname VARCHAR(255) NULL,
  birthDate timestamp NULL,
  phone VARCHAR(255) NULL,
  primarySkill VARCHAR(255) NULL,
  createdAt timestamp NULL,
  updatedAt timestamp NULL,
  CONSTRAINT pk_student PRIMARY KEY (id)
);

CREATE TABLE subject (
  id BIGINT NOT NULL,
  name VARCHAR(255),
  tutor VARCHAR(255),
  CONSTRAINT pk_subject PRIMARY KEY (id)
);

CREATE TABLE exam_result (
  id BIGINT NOT NULL,
  student_id BIGINT,
  subject_id BIGINT,
  mark VARCHAR(255),
  CONSTRAINT pk_exam_result PRIMARY KEY (id)
);

ALTER TABLE exam_result ADD CONSTRAINT FK_EXAM_RESULT_ON_STUDENT FOREIGN KEY (student_id) REFERENCES student (id);

ALTER TABLE exam_result ADD CONSTRAINT FK_EXAM_RESULT_ON_SUBJECT FOREIGN KEY (subject_id) REFERENCES subject (id);