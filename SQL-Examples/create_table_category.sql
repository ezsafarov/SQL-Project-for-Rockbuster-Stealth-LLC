-- Create the category table with constraints
CREATE TABLE category (
    category_id INTEGER NOT NULL DEFAULT nextval('category_category_id_seq'::regclass),
    name TEXT COLLATE pg_catalog."default" NOT NULL,
    last_update TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    CONSTRAINT category_pkey PRIMARY KEY (category_id)
);
