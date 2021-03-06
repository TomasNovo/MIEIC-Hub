DROP TABLE IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS items CASCADE;

DROP TYPE IF EXISTS package_status CASCADE;

DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS color CASCADE;
DROP TABLE IF EXISTS size CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS photo CASCADE;
DROP TABLE IF EXISTS product_color CASCADE;
DROP TABLE IF EXISTS product_size CASCADE;
DROP TABLE IF EXISTS city CASCADE;
DROP TABLE IF EXISTS delivery_info CASCADE;
DROP TABLE IF EXISTS user_delivery_info CASCADE;
DROP TABLE IF EXISTS purchase CASCADE;
DROP TABLE IF EXISTS product_purchase CASCADE;
DROP TABLE IF EXISTS review CASCADE;
DROP TABLE IF EXISTS cart CASCADE;
DROP TABLE IF EXISTS wishlist CASCADE;
DROP TABLE IF EXISTS faq CASCADE;
DROP TABLE IF EXISTS poll CASCADE;
DROP TABLE IF EXISTS submission CASCADE;
DROP TABLE IF EXISTS user_sub_vote CASCADE;
DROP TABLE IF EXISTS password_resets CASCADE;
DROP INDEX IF EXISTS authenticate;
DROP INDEX IF EXISTS id_category;
DROP INDEX IF EXISTS active_poll;
DROP INDEX IF EXISTS sub_id_poll;
DROP INDEX IF EXISTS by_price;
DROP INDEX IF EXISTS search_users;
DROP INDEX IF EXISTS search_products;
DROP TRIGGER IF EXISTS vote_on_design ON user_sub_vote;
DROP TRIGGER IF EXISTS unvote_on_design ON user_sub_vote;
DROP TRIGGER IF EXISTS review_delete ON review;
DROP TRIGGER IF EXISTS review_insert ON review;
DROP TRIGGER IF EXISTS elect_winner ON poll;
DROP TRIGGER IF EXISTS control_submission_vote ON user_sub_vote;
DROP TRIGGER IF EXISTS update_purchase_price_insert ON product_purchase;
DROP TRIGGER IF EXISTS update_purchase_price_delete ON product_purchase;
DROP TRIGGER IF EXISTS calculate_product_purchase_price ON product_purchase;
DROP TRIGGER IF EXISTS update_product_purchase_price ON product;
DROP TRIGGER IF EXISTS delete_user ON users;
DROP FUNCTION IF EXISTS update_product_review();
DROP FUNCTION IF EXISTS update_submission_vote();
DROP FUNCTION IF EXISTS select_winner();
DROP FUNCTION IF EXISTS check_submission_vote();
DROP FUNCTION IF EXISTS update_purchase_total();
DROP FUNCTION IF EXISTS calculate_new_product_purchase_price();
DROP FUNCTION IF EXISTS recalculate_product_purchase_price();
DROP FUNCTION IF EXISTS erase_user();

CREATE TYPE package_status AS ENUM ('awaiting_payment', 'processing', 'in_transit', 'delivered', 'canceled');

CREATE TABLE category
(
    id_category SERIAL PRIMARY KEY,
    category TEXT UNIQUE NOT NULL
);

CREATE TABLE product
(
    id_product SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    product_description TEXT NOT NULL,
    price FLOAT NOT NULL CHECK(price > 0),
    delivery_cost FLOAT NOT NULL CHECK(delivery_cost >= 0) DEFAULT 3.99,
    stock INTEGER NOT NULL CHECK(stock >= 0) DEFAULT 100,
    rating FLOAT NOT NULL CHECK(rating >= 0 AND rating <= 5) DEFAULT 0,
    id_category INTEGER NOT NULL REFERENCES category ON UPDATE CASCADE
);

CREATE TABLE photo
(
    id_photo SERIAL PRIMARY KEY,
    image_path TEXT UNIQUE NOT NULL,
    id_product INTEGER REFERENCES product ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE users
(
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL,
    password TEXT NOT NULL,
    birth_date DATE CHECK(birth_date < now()),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    stock_manager BOOLEAN NOT NULL DEFAULT FALSE,
    moderator BOOLEAN NOT NULL DEFAULT FALSE,
    submission_manager BOOLEAN NOT NULL DEFAULT FALSE,
    id_photo INTEGER REFERENCES photo ON DELETE SET DEFAULT ON UPDATE CASCADE DEFAULT 1,
    user_description TEXT NOT NULL DEFAULT 'Hello! Proud MIEIC Hub member here!',
    remember_token VARCHAR
);

CREATE TABLE color
(
    id_color SERIAL PRIMARY KEY,
    color TEXT UNIQUE NOT NULL
);

CREATE TABLE size
(
    id_size SERIAL PRIMARY KEY,
    size TEXT UNIQUE NOT NULL
);

CREATE TABLE product_color
(
    id_product INTEGER NOT NULL REFERENCES product ON UPDATE CASCADE ON DELETE CASCADE,
    id_color INTEGER NOT NULL REFERENCES color ON UPDATE CASCADE,
    PRIMARY KEY (id_product, id_color)
);

CREATE TABLE product_size
(
    id_product INTEGER NOT NULL REFERENCES product ON UPDATE CASCADE ON DELETE CASCADE,
    id_size INTEGER NOT NULL REFERENCES size ON UPDATE CASCADE,
    PRIMARY KEY (id_product, id_size)
);

CREATE TABLE city
(
    id_city SERIAL PRIMARY KEY,
    city TEXT NOT NULL
);

CREATE TABLE delivery_info
(
    id_delivery_info SERIAL PRIMARY KEY,
    id_city INTEGER NOT NULL REFERENCES city ON UPDATE CASCADE,
    contact TEXT NOT NULL,
    delivery_address TEXT NOT NULL
);

CREATE TABLE user_delivery_info
(
    id_delivery_info INTEGER NOT NULL REFERENCES delivery_info ON UPDATE CASCADE,
    id_user INTEGER NOT NULL REFERENCES users ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (id_delivery_info, id_user)
);

CREATE TABLE purchase
(
    id_purchase SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL REFERENCES Users ON UPDATE CASCADE ON DELETE NO ACTION,
    id_deli_info INTEGER NOT NULL REFERENCES delivery_info ON UPDATE CASCADE,
    purchase_date TIMESTAMP WITH TIME zone DEFAULT now() NOT NULL,
    total FLOAT NOT NULL CHECK(total >= 0),
    status package_status NOT NULL
);

CREATE TABLE product_purchase
(
    id_product INTEGER NOT NULL REFERENCES product ON UPDATE CASCADE,
    id_purchase INTEGER NOT NULL REFERENCES purchase ON UPDATE CASCADE,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    price FLOAT NOT NULL CHECK(price > 0),
    id_size INTEGER REFERENCES size ON UPDATE CASCADE,
    id_color INTEGER REFERENCES color ON UPDATE CASCADE,
    PRIMARY KEY (id_product, id_purchase)
);

CREATE TABLE review
(
    id_user INTEGER NOT NULL REFERENCES users ON UPDATE CASCADE ON DELETE NO ACTION,
    id_product INTEGER NOT NULL REFERENCES product ON UPDATE CASCADE ON DELETE CASCADE,
    comment TEXT NOT NULL,
    review_date TIMESTAMP WITH TIME zone DEFAULT now() NOT NULL,
    rating INTEGER NOT NULL CHECK(rating > 0 AND rating <= 5),
    PRIMARY KEY (id_user, id_product)
);

CREATE TABLE cart
(
    id_cart SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL REFERENCES users ON UPDATE CASCADE ON DELETE CASCADE,
    id_product INTEGER NOT NULL REFERENCES product ON UPDATE CASCADE,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    id_color INTEGER NOT NULL REFERENCES color ON UPDATE CASCADE,
    id_size INTEGER NOT NULL REFERENCES size ON UPDATE Cascade
);

CREATE TABLE wishlist
(
    id_user INTEGER NOT NULL REFERENCES users ON UPDATE CASCADE ON DELETE CASCADE,
    id_product INTEGER NOT NULL REFERENCES product ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (id_user, id_product)
);

CREATE TABLE faq
(
    id_question SERIAL PRIMARY KEY,
    question TEXT UNIQUE NOT NULL,
    answer TEXT NOT NULL
);

CREATE TABLE poll
(
    id_poll SERIAL PRIMARY KEY,
    poll_name TEXT UNIQUE NOT NULL,
    poll_date DATE DEFAULT now() NOT NULL,
    expiration DATE NOT NULL,
    active BOOLEAN NOT NULL
);

CREATE TABLE submission
(
    id_submission SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL REFERENCES users ON UPDATE CASCADE ON DELETE NO ACTION,
    submission_name TEXT NOT NULL,
    id_category INTEGER NOT NULL REFERENCES category ON UPDATE CASCADE,
    submission_description TEXT NOT NULL,
    picture TEXT NOT NULL,
    submission_date TIMESTAMP WITH TIME zone DEFAULT now() NOT NULL,
    accepted BOOLEAN NOT NULL,
    votes INTEGER DEFAULT 0 NOT NULL CHECK(votes >= 0),
    winner BOOLEAN NOT NULL,
    id_poll INTEGER REFERENCES poll ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE user_sub_vote
(
    id_user INTEGER NOT NULL REFERENCES users ON UPDATE CASCADE ON DELETE NO ACTION,
    id_sub INTEGER NOT NULL REFERENCES submission ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (id_user, id_sub)
);

CREATE TABLE password_resets
(
	email TEXT PRIMARY KEY,
	token TEXT,
	created_at TIMESTAMP WITH TIME zone
);

-- Indexes

CREATE INDEX authenticate ON users USING hash(name);
CREATE INDEX id_category ON product USING hash(id_category);
CREATE INDEX sub_id_poll ON submission(id_poll);
CLUSTER submission USING sub_id_poll;
CREATE INDEX by_price ON product(price);
CLUSTER product USING by_price;
CREATE INDEX search_products ON product USING GIST (to_tsvector('english', product_name || ' ' || product_description));

-- Triggers

CREATE FUNCTION update_submission_vote() RETURNS TRIGGER AS $BODY$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE submission
        SET votes =
        (
            SELECT count(*)
            FROM user_sub_vote
            WHERE NEW.id_sub = user_sub_vote.id_sub
        )
        WHERE submission.id_submission = NEW.id_sub;
        RETURN NEW;
    ELSEIF TG_OP = 'DELETE' THEN
        UPDATE submission
        SET votes =
        (
            SELECT count(*)
            FROM user_sub_vote
            WHERE OLD.id_sub = user_sub_vote.id_sub
        )
        WHERE submission.id_submission = OLD.id_sub;
        RETURN OLD;
    END IF;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER vote_on_design
AFTER INSERT ON user_sub_vote
FOR EACH ROW
EXECUTE PROCEDURE update_submission_vote();

CREATE TRIGGER unvote_on_design
AFTER DELETE ON user_sub_vote
FOR EACH ROW
EXECUTE PROCEDURE update_submission_vote();

CREATE FUNCTION update_product_review() RETURNS TRIGGER AS $BODY$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE product
        SET rating =
        (
            SELECT AVG(review.rating)
            FROM review, product
            WHERE review.id_product = product.id_product AND review.id_product = NEW.id_product
        )
        WHERE NEW.id_product = product.id_product;
        RETURN NEW;
    ELSEIF TG_OP = 'DELETE' THEN
        IF 
        (
            SELECT count(*)
            FROM review, product 
            WHERE review.id_product = product.id_product 
            AND review.id_product = OLD.id_product
        )
        = 0
        THEN
        UPDATE product
        SET rating = 0
        WHERE OLD.id_product = product.id_product;
        ELSE
        UPDATE product
        SET rating =
        (
            SELECT AVG(review.rating)
            FROM review, product
            WHERE review.id_product = product.id_product AND review.id_product = OLD.id_product
        )
        WHERE OLD.id_product = product.id_product;
        END IF;
        RETURN OLD;
    END IF;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER review_insert
AFTER INSERT OR UPDATE ON review
FOR EACH ROW
EXECUTE PROCEDURE update_product_review();

CREATE TRIGGER review_delete
AFTER DELETE ON review
FOR EACH ROW
EXECUTE PROCEDURE update_product_review();

CREATE FUNCTION check_submission_vote() RETURNS TRIGGER AS $BODY$
BEGIN
    IF EXISTS
    (
        SELECT poll.id_poll
        FROM poll, submission, user_sub_vote
        WHERE NEW.id_sub = submission.id_submission AND submission.id_poll = poll.id_poll
        AND poll.active IS FALSE
    )
    THEN RAISE EXCEPTION  'Users can no longer vote on an inactive/expired poll';
    END IF;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER control_submission_vote
BEFORE INSERT ON user_sub_vote
FOR EACH ROW
EXECUTE PROCEDURE check_submission_vote();

CREATE FUNCTION select_winner() RETURNS TRIGGER AS $BODY$
BEGIN
    IF NEW.active IS FALSE THEN
        UPDATE submission
        SET winner = TRUE
        WHERE submission.id_poll = NEW.id_poll AND submission.votes =
        (
            SELECT MAX(submission.votes)
            FROM submission, poll
            WHERE poll.id_poll = NEW.id_poll AND poll.id_poll = submission.id_poll
        );
    END IF;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER elect_winner
AFTER UPDATE ON poll
FOR EACH ROW
EXECUTE PROCEDURE select_winner();

CREATE FUNCTION update_purchase_total() RETURNS TRIGGER AS $BODY$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE purchase
        SET total =
        (
            SELECT sum(products_price)
            FROM
            (
                SELECT product_purchase.quantity * product_purchase.price AS products_price
                FROM product, purchase, product_purchase
                WHERE NEW.id_purchase = purchase.id_purchase AND NEW.id_product = product.id_product
                AND product_purchase.id_purchase = NEW.id_purchase AND product_purchase.id_product = NEW.id_product
            ) AS products_actual_price
        )
        WHERE NEW.id_purchase = purchase.id_purchase;
        RETURN NEW;
    ELSEIF TG_OP = 'DELETE' THEN
        UPDATE purchase
        SET total =
        (
            SELECT sum(products_price)
            FROM
            (
                SELECT product_purchase.quantity * product_purchase.price AS products_price
                FROM product, purchase, product_purchase
                WHERE OLD.id_purchase = purchase.id_purchase AND OLD.id_product = product.id_product
                AND product_purchase.id_purchase = OLD.id_purchase AND product_purchase.id_product = OLD.id_product
            ) AS products_actual_price
        )
        WHERE OLD.id_purchase = purchase.id_purchase;
        RETURN OLD;
    END IF;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER update_purchase_price_insert
AFTER INSERT OR UPDATE ON product_purchase
FOR EACH ROW
EXECUTE PROCEDURE update_purchase_total();

CREATE TRIGGER update_purchase_price_delete
AFTER DELETE ON product_purchase
FOR EACH ROW
EXECUTE PROCEDURE update_purchase_total();

CREATE FUNCTION calculate_new_product_purchase_price() RETURNS TRIGGER AS $BODY$
BEGIN
    UPDATE product_purchase
    SET price =
    (
        SELECT product.price + product.delivery_cost as total_product_price
        FROM product, product_purchase
        WHERE product.id_product = product_purchase.id_product
        AND product_purchase.id_product = NEW.id_product
        AND product_purchase.id_purchase = NEW.id_purchase
    )
    WHERE product_purchase.id_product = NEW.id_product
    AND product_purchase.id_purchase = NEW.id_purchase;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER new_product_purchase_price
AFTER INSERT ON product_purchase
FOR EACH ROW
EXECUTE PROCEDURE calculate_new_product_purchase_price();

CREATE FUNCTION recalculate_product_purchase_price() RETURNS TRIGGER AS $BODY$
BEGIN
    UPDATE product_purchase
    SET price =
    (
        SELECT product.price + product.delivery_cost as total_product_price
        FROM product, product_purchase
        WHERE product.id_product = product_purchase.id_product
        AND product.id_product = NEW.id_product
        LIMIT 1
    )
    WHERE product_purchase.id_product = NEW.id_product;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_purchase_price
AFTER UPDATE ON product
FOR EACH ROW
EXECUTE PROCEDURE recalculate_product_purchase_price();

CREATE FUNCTION erase_user() RETURNS TRIGGER AS $BODY$
DECLARE
    next_id INTEGER := nextval(pg_get_serial_sequence('users', 'id'));
    new_name TEXT := 'John Doe' || MD5(OLD.name);
BEGIN
    INSERT INTO users (id, name, email, password, birth_date, active, stock_manager, moderator, submission_manager,
    id_photo, user_description)
    VALUES (next_id, new_name , 'mieichubsupport@gmail.com','123masfiasfnakslfmas', '1994-01-01', FALSE, FALSE, FALSE,
    FALSE, 1, 'Just a regular user, nothing to see here...');

    UPDATE review
    SET id_user = next_id
    WHERE review.id_user = OLD.id;

    UPDATE submission
    SET id_user = next_id
    WHERE submission.id_user = OLD.id;

    UPDATE user_sub_vote
    SET id_user = next_id
    WHERE user_sub_vote.id_user = OLD.id;

    UPDATE purchase
    SET id_user = next_id
    WHERE purchase.id_user = OLD.id;

    RETURN OLD;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER delete_user
BEFORE DELETE ON users
FOR EACH ROW
EXECUTE PROCEDURE erase_user();

-- Table: category
INSERT INTO category (category) VALUES ('Apparel');
INSERT INTO category (category) VALUES ('Phone Case');
INSERT INTO category (category) VALUES ('Sticker');
INSERT INTO category (category) VALUES ('Poster');
INSERT INTO category (category) VALUES ('Ticket');
INSERT INTO category (category) VALUES ('Mouse Pad');
INSERT INTO category (category) VALUES ('Mug');

-- Table: product

    -- Apparel
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('MIEIC Hoodie', 'Black hoodie for MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Sudo Rm Hoodie', 'Funny hoodie allusive to LINUX commands. For MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Hard Code Hoodie', 'Funny hoodie allusive to Hard Rock Caffe. For MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('StarCode Hoodie', 'Funny hoodie allusive to Starbucks Caffe. For MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('MIEIC Jacket', 'Black jacket for MIEIC students. 100% poliester.', 19.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Mouse Hoodie', 'Hoodie with a mouse for MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Loading Hoodie', 'Funny hoodie with loading bar. For MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Floppy Disk Hoodie', 'Hoodie with a floppy disk. For MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('E HTML Jacket', 'Jacket with loading and E instead the classic 5 on HTML logo. For MIEIC students. 100% poliester.', 19.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('FEUP Hoodie 2', 'Hoodie for FEUP students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Fernando Pessoa Hoodie', 'Hoodie for MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Programmer Hoodie', 'Grey hoodie for MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Semi Colon Hoodie', 'Hoodie for MIEIC students. 100% poliester.', 14.99, 2.99, 50, 0, 1);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Author Jacket', 'Jacket for MIEIC students. 100% poliester.', 19.99, 2.99, 50, 0, 1);

    --Phone Cases
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Programmer Case', 'Case related to programmers. Water resistant.', 9.99, 1.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Love Programming Case', 'Case related to programmers. Water resistant.', 9.99, 1.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Viva La Programacion Case', 'Case related to programmers. Water resistant.', 9.99, 1.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('GitKraken Case', 'Case related to programmers. Water resistant.', 9.99, 1.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('It is a feature Case', 'Case related to programmers. Water resistant.', 9.99, 1.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Debugging Stages Case', 'Case related to programmers. Water resistant.', 9.99, 1.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Hello World Case', 'Case related to programmers. Water resistant.', 9.99, 1.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Coffee to Code Case', 'Case related to programmers. Water resistant.', 9.99, 1.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Just Code It Case', 'Case related to programmers. Water resistant.', 9.99, 2.99, 50, 0, 2);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Awsome Case', 'Case related to programmers. Water resistant.', 9.99, 2.99, 50, 0, 2);

    --Posters
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Today Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Anonymous1 Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Anonymous2 Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Hackerman Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('TensionRelease Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('In Code We Trust Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Keep Calm Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('I Love Coding Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('SETUP Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Eat Sleep Code Repeat Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Semi Colon Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Super Bock Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('World Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('No coffee No code Poster', 'A3 poster related to programmers', 9.99, 2.99, 50, 0, 4);

    --Stickers
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('FEUP Sticker', 'Laptop Sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Unexpected Sticker', 'Laptop sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Coffee Sticker', 'Laptop Sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Home Sticker', 'Laptop sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('HTML Sticker', 'Laptop Sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Blackbelt Sticker', 'Laptop sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Nike Sticker', 'Laptop sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Titanic Sticker', 'Laptop sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('False Sticker', 'Laptop sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Java Sticker', 'Laptop sticker.', 2.99, 0.99, 50, 0, 3);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Combo Stickers', 'Laptop stickers.', 14.99, 0.99, 50, 0, 3);


    --Tickets
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('HTML Ticket', 'Ticket for workshop to learn to code in HTML.', 1.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('CSS Ticket', 'Ticket for workshop to learn to code in  CSS.', 0.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Java Ticket', 'Ticket for workshop to learn to code in JAVA.', 4.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('C/C++ Ticket', 'Ticket for workshop to learn to code in C/C++.', 4.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Python Ticket', 'Ticket for workshop to learn to code in Python.', 1.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('SQL Ticket', 'Ticket for workshop to learn to code in SQL.', 1.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Dr.Scheme Ticket', 'Ticket for workshop to learn to code in Dr.Scheme.', 0.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Google Talks', 'Ticket for lecture with Google engineer.', 9.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('PPIN Talks', 'Ticket for lecture to learn about personal and interpersonal proficiency.', 0.99, 0.99, 50, 0, 5);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('PHP Ticket', 'Ticket for workshop to learn to code in PHP', 1.99, 0.99, 50, 0, 5);
    --Mouse Pads
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('MIEIC Mouse Pad', 'Mouse pad for MIEIC students.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('FEUP Mouse Pad', 'Mouse pad for FEUP students', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Go Away I am Coding Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Errors Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Breaking Bad Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Eat Sleep Code Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Not A Bug Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Not A Robot Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Ninja Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Trust Me Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Best Programmer Ever Mouse Pad', 'Funny mouse pad. For programmers.', 9.99, 1.99, 50, 0, 6);

    --Mugs
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Development Process Mug', 'Mug for MIEIC students.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Binary Mug', 'Mug for FEUP students.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('I am A Programmer Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('CSS Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Debug Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Why Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Gamer Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Offline Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Break Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Coffee Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Errors Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Sleep Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);
INSERT INTO product (product_name, product_description, price, delivery_cost, stock, rating, id_category) VALUES ('Go Away Mug', 'Funny mug. For programmers.', 9.99, 1.99, 50, 0, 7);

-- Table: photo

--Users
INSERT INTO photo (image_path, id_product) VALUES ('img/users/default.png', NULL);
INSERT INTO photo (image_path, id_product) VALUES ('img/users/Eduardo-Silva.jpg', NULL);
INSERT INTO photo (image_path, id_product) VALUES ('img/users/Tomás Novo.png', NULL);
INSERT INTO photo (image_path, id_product) VALUES ('img/users/Joana Ramos.png', NULL);
INSERT INTO photo (image_path, id_product) VALUES ('img/users/Miguel Carvalho.jpg', NULL);

    --Apparel
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/inph.jpg', 1);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoddie_sudo_rm.jpg', 2);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoddie_sudo_rm_single.jpg', 2);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_1_red.jpg', 3);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_1_red_single.jpg', 3);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_2.jpg', 4);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_2_single.jpg', 4);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_2_smiley.jpg', 5);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_2_smiley_single.jpg', 5);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_3.jpg', 6);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_3_single.jpg', 6);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_5.jpg', 7);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_6.jpg', 8);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_10.jpg', 9);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/hoodie_example.jpg', 10);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/nando.jpg', 11);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/programmer.jpg', 12);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/programmer2.jpg', 13);
INSERT INTO photo (image_path, id_product) VALUES ('img/apparel/author_jacket.jpg', 14);

    --Cases
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/programmer.jpg', 15);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/loveprogramming.jpg', 16);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/programacion.png', 17);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/gitkraken.jpeg', 18);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/feature.jpeg', 19);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/debug.jpg', 20);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/hello.jpeg', 21);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/coffee.jpeg', 22);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/justcodeit.jpeg', 23);
INSERT INTO photo (image_path, id_product) VALUES ('img/cases/awsome.jpg', 24);

    --Posters
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/today.jpg', 25);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/anonymous1.jpg', 26);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/anonymous2.jpg', 27);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/hackerman.jpg', 28);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/release.jpg', 29);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/in code.jpg', 30);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/keep calm.jpg', 31);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/lovecoding.jpg', 32);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/SETUP.jpg', 33);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/eat.jpg', 34);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/semi.jpg', 35);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/super.jpg', 36);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/world.jpg', 37);
INSERT INTO photo (image_path, id_product) VALUES ('img/posters/nocoffee.jpeg', 38);

    --Stickers
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/feup.jpg', 39);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/unexpected.jpg', 40);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/coffee.jpg', 41);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/home.png', 42);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/html.jpg', 43);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/blackbelt.jpg', 44);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/nike.jpg', 45);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/titanic.jpg', 46);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/true.jpg', 47);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/java.png', 48);
INSERT INTO photo (image_path, id_product) VALUES ('img/stickers/stickers.jpg', 49);

    --Tickets
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket.png', 50);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket2.png', 51);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket3.png', 52);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket4.png', 53);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket5.png', 54);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket6.png', 55);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket7.png', 56);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket8.png', 57);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket9.png', 58);
INSERT INTO photo (image_path, id_product) VALUES ('img/tickets/ticket10.png', 59);

    --Mouse Pads
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/feup.jpg', 60);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/feup2.jpg', 61);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/goAway.png', 62);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/more.jpg', 63);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/breaking.jpg', 64);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/eat.jpg', 65);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/feature.jpg', 66);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/robot.jpg', 67);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/ninja.jpg', 68);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/trust me.jpeg', 69);
INSERT INTO photo (image_path, id_product) VALUES ('img/mousepads/bestever.jpg', 70);

    --Mugs
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/process.jpeg', 71);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/binary.jpeg', 72);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/programmer.jpg', 73);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/css.jpg', 74);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/debug.jpg', 75);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/why.jpg', 76);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/gamer.jpg', 77);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/offline.jpg', 78);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/break.jpg', 79);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/coffee.jpg', 80);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/errors.jpg', 81);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/sleep.jpg', 82);
INSERT INTO photo (image_path, id_product) VALUES ('img/mugs/goaway.png', 83);
-- Table: user

-- Regular users

INSERT INTO users VALUES (
  DEFAULT,
  'John Doe',
  'john@example.com',
  '$2y$10$HfzIhGCCaxqyaIdGgjARSuOKAcm1Uy82YfLuNaajn6JrjLWy9Sj/W'
); -- Password is 1234. Generated using (Bcrypt) Hash::make('1234')



INSERT INTO users (name, email, password) VALUES('Chandler Bing', 'lbaw1825@gmail.com', '$2y$10$kOQHd3CIu4.UQRQ6OzcjouJQTF7GLUdd9g.sGRVDghn6kvDOEcjcW');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, id_photo, user_description) VALUES ('Miguel Carvalho', 'up201605757@fe.up.pt','$2y$12$7M1rWpEnZg/qj6AfT2JXue1BfDG/IixigKNs7WUkMcA.VNKp20NAi', '1998-12-25', TRUE, TRUE, TRUE, TRUE, 5, 'Owner of MIEIC Hub');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, id_photo, user_description) VALUES ('Eduardo Silva', 'up201603135@fe.up.pt','$2y$12$L1d1H1PllySA.y43Dks4depIIEk4fGMQDRzZOP01dJ8VsErmyx.0a', '1998-01-22', TRUE, TRUE, TRUE, TRUE, 2, 'Co-Founder of MIEIC Hub');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, id_photo, user_description) VALUES ('Tomás Novo', 'up201604503@fe.up.pt','A9709902614CB2D8F66D811D4032B79FBD311AA73E9D0FE41A9B9B93464CC6FB', '1998-07-31', TRUE, TRUE, TRUE, TRUE, 3, 'The best ! Co-founder of MIEIC Hub');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, id_photo, user_description) VALUES ('Joana Ramos', 'up201605017@fe.up.pt', '$2y$12$xrvhzVNl6zN8KKa19n/gj.NZMnFGkT9ftRrrhe7L7T9roqAm6FvMK', '1998-11-02', TRUE, TRUE, TRUE, TRUE, 4, 'Co-Founder of MIEIC Hub');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Zé Luís', 'up201287644@fe.up.pt', 'DA34262C62CDE67274D3452AECCCE39676A73249800FA9316532D8B8F2E5055B', '1994-02-11', TRUE, FALSE, FALSE, FALSE, 'MEEEC student at 2nd grade. Love music !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Susana Castro', 'up201503453@fe.up.pt', '5B8346507DDFD4AEF39C12521ECA6ED82689C7090A3E7312F0BA3D17421BB3B2', '1997-04-15', TRUE, FALSE, FALSE, FALSE, ' Quemistry student, the one who knocks !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('José António', 'up201703443@fe.up.pt', 'C86FD59FBCE597E2534E56EACE209EF7139529BC5B1624AD700673FDCA88B33D', '1998-02-11', TRUE, FALSE, FALSE, FALSE, 'I love computers !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Rolando Escada Abaixo', 'up201304453@fe.up.pt', '46445B968117080EB11361F904342868D5A19B69291B876901FA7C6BCA65F5FA', '1994-03-21', TRUE, FALSE, FALSE, FALSE, 'CIVIL < INFORMATICA !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Andreia Ramalho', 'up201603853@fe.up.pt', 'CB5738AFA52AB674CAC31008B17016033E0C165D75A07AD67133D05E468DD3AF', '1993-12-13', TRUE, FALSE, FALSE, FALSE, 'MIEIC Student !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('João Saraiva', 'up201703453@fe.up.pt', 'C86FD59FBCE597E2534E56EACE209EF7139529BC5B1624AD700673FDCA88B33D', '1996-02-10', TRUE, FALSE, FALSE, FALSE, 'MIEIC Student AT 1ST grade !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Luísa Josefa', 'up201406753@fe.up.pt', '5B8346507DDFD4AEF39C12521ECA6ED82689C7090A3E7312F0BA3D17421BB3B2', '1999-03-31', TRUE, FALSE, FALSE, FALSE, 'MIEIC Student');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Alfredo Granjão', 'up201706173@fe.up.pt', 'EDF755F83215D530C9BD95767A13BB7BD5BDB8F5D5108ACEFCD605A00FBEE1F1', '1995-02-11', TRUE, FALSE, FALSE, FALSE, 'MIEIC Student 5th grade! SOU FINALISTAAAA');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Ada Beliza', 'up201302123@fe.up.pt', 'CB5738AFA52AB674CAC31008B17016033E0C165D75A07AD67133D05E468DD3AF', '1996-03-09', TRUE, FALSE, FALSE, FALSE, 'MIEIC student at 3rd grade !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Zebedeu Garcia', 'user11@fe.up.pt', 'EAAC49260A132A794309878B2CBB31FAB67DA5E4893487FBCC829C625E734FA0', '1998-11-07', TRUE, FALSE, FALSE, FALSE, 'The 11th best !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Anacleto Miquelino', 'user12@fe.up.pt', 'HB5738AFA52AB674CAC31008B17016033E0C165D75A07AD67133D05E468DD3AF', '1997-10-01', TRUE, FALSE, FALSE, FALSE, 'The 12th best !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Joana Silva', 'user13@fe.up.pt', 'C86FD59FBCE597E2534E56EACE209EF7139529BC5B1624AD700673FDCA88B33D', '1997-07-03', TRUE, FALSE, FALSE, FALSE, 'The 13th best !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('João Ferreia', 'user14@fe.up.pt', '46445B968117080EB11361F904342868D5A19B69291B876901FA7C6BCA65F5FA', '1993-08-11', TRUE, FALSE, FALSE, FALSE, 'The 14th best !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Amadeu Prazeres', 'user15@fe.up.pt', 'A9709902614CB2D8F66D811D4032B79FBD311AA73E9D0FE41A9B9B93464CC6FB', '1992-04-16', TRUE, FALSE, FALSE, FALSE, 'The 15th best !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Nuno Lopes', 'user16@fe.up.pt', '5B8346507DDFD4AEF39C12521ECA6ED82689C7090A3E7312F0BA3D17421BB3B2', '1998-03-22', TRUE, FALSE, FALSE, FALSE, 'MIEIC student at 3rd grade and loving it');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Alexandra Mendes', 'user17@fe.up.pt', 'EAAC49260A132A794309878B2CBB31FAB67DA5E4893487FBCC829C625E734FA0', '1999-01-30', TRUE, FALSE, FALSE, FALSE, 'MIEIC MIEIC MIEIC');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Carolina Soares', 'user18@fe.up.pt', 'DA34262C62CDE67274D3452AECCCE39676A73249800FA9316532D8B8F2E5055B', '1994-09-27', TRUE, FALSE, FALSE, FALSE, 'MIEIC student. 3rd grade');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Christopher Abreu', 'user19@fe.up.pt', 'CB5738AFA52AB674CAC31008B17016033E0C165D75A07AD67133D05E468DD3AF', '1996-10-23', TRUE, FALSE, FALSE, FALSE, 'MIEIC student');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Tiago Cardoso', 'user20@fe.up.pt', '46445B968117080EB11361F904342868D5A19B69291B876901FA7C6BCA65F5FA', '1994-11-22', TRUE, FALSE, FALSE, FALSE, 'I love programming <3');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('João Franco', 'user21@fe.up.pt', 'EAAC49260A132A794309878B2CBB31FAB67DA5E4893487FBCC829C625E734FA0', '1993-12-21', TRUE, FALSE, FALSE, FALSE, 'MIEIC student');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Rui Alves', 'user22@fe.up.pt', 'A9709902614CB2D8F66D811D4032B79FBD311AA73E9D0FE41A9B9B93464CC6FB', '1997-01-26', TRUE, FALSE, FALSE, FALSE, 'MIEIC student at 2nd grade ! !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Francisco Ferreira', 'user23@fe.up.pt', 'CB5738AFA52AB674CAC31008B17016033E0C165D75A07AD67133D05E468DD3AF', '1998-02-16', TRUE, FALSE, FALSE, FALSE, 'MIEIC student');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('João Amaral', 'user24@fe.up.pt', '5B8346507DDFD4AEF39C12521ECA6ED82689C7090A3E7312F0BA3D17421BB3B2', '1997-03-15', TRUE, FALSE, FALSE, FALSE, 'SOU O MAIOR');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Pedro Padrão', 'user25@fe.up.pt', 'EDF755F83215D530C9BD95767A13BB7BD5BDB8F5D5108ACEFCD605A00FBEE1F1', '1995-04-25', TRUE, FALSE, FALSE, FALSE, 'EAT SLEEP CODE REPEAT');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('João Martins', 'user26@fe.up.pt', 'DA34262C62CDE67274D3452AECCCE39676A73249800FA9316532D8B8F2E5055B', '1998-05-22', TRUE, FALSE, FALSE, FALSE, 'MIEICHub is awsome ahahah !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Diogo Cadavez', 'user27@fe.up.pt', 'CB5738AFA52AB674CAC31008B17016033E0C165D75A07AD67133D05E468DD3AF', '1998-06-26', TRUE, FALSE, FALSE, FALSE, 'MIEIC student');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('José Carlos', 'user28@fe.up.pt', 'EAAC49260A132A794309878B2CBB31FAB67DA5E4893487FBCC829C625E734FA0', '1998-07-30', TRUE, FALSE, FALSE, FALSE, 'Just a regular MIEIC student !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Filipe Martins', 'user29@fe.up.pt', 'A9709902614CB2D8F66D811D4032B79FBD311AA73E9D0FE41A9B9B93464CC6FB', '1996-08-21', TRUE, FALSE, FALSE, FALSE, 'Just ended 1st grade on MIEIC !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Luís Freitas', 'user30@fe.up.pt', '46445B968117080EB11361F904342868D5A19B69291B876901FA7C6BCA65F5FA', '1999-04-12', TRUE, FALSE, FALSE, FALSE, 'Just another MIEIC student!');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Nuno Fernandes', 'user31@fe.up.pt', '5B8346507DDFD4AEF39C12521ECA6ED82689C7090A3E7312F0BA3D17421BB3B2', '1993-12-21', TRUE, FALSE, FALSE, FALSE, 'Never a bug, always a feature !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Luís Lombo', 'user32@fe.up.pt', 'DA34262C62CDE67274D3452AECCCE39676A73249800FA9316532D8B8F2E5055B', '1993-01-26', TRUE, FALSE, FALSE, FALSE, 'MIEIC student at 3rd grade !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Pedro Nunes', 'user33@fe.up.pt', 'C86FD59FBCE597E2534E56EACE209EF7139529BC5B1624AD700673FDCA88B33D', '1992-02-16', TRUE, FALSE, FALSE, FALSE, 'FORÇA FOCO E FÉ');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Jorge Rodrigues', 'user34@fe.up.pt', 'EDF755F83215D530C9BD95767A13BB7BD5BDB8F5D5108ACEFCD605A00FBEE1F1', '1993-03-15', TRUE, FALSE, FALSE, FALSE, 'O caminho faz-se caminhando !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Manuel Prata', 'user35@fe.up.pt', 'A9709902614CB2D8F66D811D4032B79FBD311AA73E9D0FE41A9B9B93464CC6FB', '1990-04-25', TRUE, FALSE, FALSE, FALSE, 'MIEIC student');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Ângela Pereira', 'user36@fe.up.pt', '5B8346507DDFD4AEF39C12521ECA6ED82689C7090A3E7312F0BA3D17421BB3B2', '1991-05-22', TRUE, FALSE, FALSE, FALSE, 'MIEIC student 2nd grade');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Cavaco Silva', 'user37@fe.up.pt', 'EDF755F83215D530C9BD95767A13BB7BD5BDB8F5D5108ACEFCD605A00FBEE1F1', '1992-06-26', TRUE, FALSE, FALSE, FALSE, 'MIEIC student 4th grade');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Ricardo Pereira', 'user38@fe.up.pt', 'D10AD22165F21254074DA55C9E5FEE50A2D1DD16286B6B0EAD1698AA6AFB930F', '1993-07-30', TRUE, FALSE, FALSE, FALSE, 'FINALISTA MIEIC !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('André Almeida', 'user39@fe.up.pt', 'C86FD59FBCE597E2534E56EACE209EF7139529BC5B1624AD700673FDCA88B33D', '1994-08-21', TRUE, FALSE, FALSE, FALSE, 'FINALISTA MIEIC OLEEEEEEEE !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Maria Rito', 'user40@fe.up.pt', 'A9709902614CB2D8F66D811D4032B79FBD311AA73E9D0FE41A9B9B93464CC6FB', '1995-04-12', TRUE, FALSE, FALSE, FALSE, 'SOU FINALISTA LALALALALA !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Sara Morais', 'user41@fe.up.pt', '46445B968117080EB11361F904342868D5A19B69291B876901FA7C6BCA65F5FA', '1992-11-21', TRUE, FALSE, FALSE, FALSE, '3ano MIEIC. Possuo um projeto semelhante desenvolvido em LBAW !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Maria Beatriz', 'user42@fe.up.pt', '5B8346507DDFD4AEF39C12521ECA6ED82689C7090A3E7312F0BA3D17421BB3B2', '1993-11-26', TRUE, FALSE, FALSE, FALSE, 'FINALISTA MIEIC OLE OLE OLE');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Bruno Guerra', 'user43@fe.up.pt', 'DA34262C62CDE67274D3452AECCCE39676A73249800FA9316532D8B8F2E5055B', '1995-03-16', TRUE, FALSE, FALSE, FALSE, 'MIEIC. 4th');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Gonçalo Raposo', 'user44@fe.up.pt', 'D10AD22165F21254074DA55C9E5FEE50A2D1DD16286B6B0EAD1698AA6AFB930F', '1994-02-15', TRUE, FALSE, FALSE, FALSE, 'Adoro programar e odeio falar inglês por isso escrevi a descrição em português!');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Tiago Oliveira', 'user45@fe.up.pt', 'A9709902614CB2D8F66D811D4032B79FBD311AA73E9D0FE41A9B9B93464CC6FB', '1990-04-28', TRUE, FALSE, FALSE, FALSE, 'Just another one MIEIC student...');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Raul Pires', 'user46@fe.up.pt', 'D10AD22165F21254074DA55C9E5FEE50A2D1DD16286B6B0EAD1698AA6AFB930F', '1991-05-12', TRUE, FALSE, FALSE, FALSE, 'FEUP É INCRÍVEL');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Isabel Graça', 'user47@fe.up.pt', 'C86FD59FBCE597E2534E56EACE209EF7139529BC5B1624AD700673FDCA88B33D', '1992-12-16', TRUE, FALSE, FALSE, FALSE, 'Adoro a FEUP e o MIEIC !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Cristiano Reinaldo', 'user48@fe.up.pt', 'DA34262C62CDE67274D3452AECCCE39676A73249800FA9316532D8B8F2E5055B', '1995-07-31', TRUE, FALSE, FALSE, FALSE, 'FINALISTA MIEIC SIGAAAAAAAA TRABALHAR');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Lionel Messias', 'user49@fe.up.pt', 'A9709902614CB2D8F66D811D4032B79FBD311AA73E9D0FE41A9B9B93464CC6FB', '1997-02-22', TRUE, FALSE, FALSE, FALSE, 'MIEIC student at 3rd grade !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Kylian Mdoipé', 'user50@fe.up.pt', 'D10AD22165F21254074DA55C9E5FEE50A2D1DD16286B6B0EAD1698AA6AFB930F', '1999-03-05', TRUE, FALSE, FALSE, FALSE, 'Love programming stuff');

    --Stock Manager
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Luís Alexandre', 'sm1@fe.up.pt', '$2y$12$DkDudH79cKCtEmiDZ7YexuBUtZ1Wnixf0zYniXqdNDBUotdH4xEFS', '1998-03-30', TRUE, TRUE, FALSE, FALSE, 'Proudly a StockManager at MIEICHUB');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Inês Faustino', 'sm2@fe.up.pt', '544F96FB9F4647141FA50A040D37712E67EC374EAAB231193B5FB56E8EA774F0', '1996-04-21', TRUE, TRUE, FALSE, FALSE, 'Best StockManager is here !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Leonor Silva', 'sm3@fe.up.pt', '544F96FB9F4647141FA50A040D37712E67EC374EAAB231193B5FB56E8EA774F0', '1999-06-12', TRUE, TRUE, FALSE, FALSE, ' Out of stock, only this amazing stock manager !!');

    --Moderator
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('João Alves', 'm1@fe.up.pt', '$2y$12$j8j.DrgtTmUEw1uawuMhpOf8qWpVORJXPwjGQ4msib.krPJy16aFm', '1995-07-30', TRUE, FALSE, TRUE, FALSE, 'I moderate a lot !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Adolfo Dias', 'm2@fe.up.pt', 'CFDE2CA5188AFB7BDD0691C7BEF887BABA78B709AADDE8E8C535329D5751E6FE', '1997-08-21', TRUE, FALSE, TRUE, FALSE, 'Proudly a moderator at MIEICHUB !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Tiago Castro', 'm3@fe.up.pt', 'CFDE2CA5188AFB7BDD0691C7BEF887BABA78B709AADDE8E8C535329D5751E6FE', '1993-05-12', TRUE, FALSE, TRUE, FALSE, 'Loving to be a mod !');

    --Submission Manager
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Diamantino da Silva', 'subm1@fe.up.pt', '$2y$12$.pHURel8kKr9Z6RbVJ/Ih.ESx4xpnG9N/kJe66ocZ/836iJFIUNXm', '1998-04-02', TRUE, FALSE, FALSE, TRUE, 'Always up for new submissions');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Joaquim Fausto', 'subm2@fe.up.pt', '940DA794CFFFF6CBC494C0AA767E7AF19F5C053466E45F1651CC47FFEDB2340B', '1996-08-22', TRUE, FALSE, FALSE, TRUE, 'Proudly a submission manager at MIEICHUB ! !');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Quim Possível', 'subm3@fe.up.pt', '940DA794CFFFF6CBC494C0AA767E7AF19F5C053466E45F1651CC47FFEDB2340B', '1997-01-02', TRUE, FALSE, FALSE, TRUE, 'Need a SubmissionManager ? Call me ahahah');

    --Admins
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Bruna Sousa', 'admin1@fe.up.pt', '8C6976E5B5410415BDE908BD4DEE15DFB167A9C873FC4BB8A81F6F2AB448A918', '1998-02-02', TRUE, TRUE, TRUE, TRUE, 'GOD OF MIEICHUB');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Antero Ferreira', 'admin2@fe.up.pt', '8C6976E5B5410415BDE908BD4DEE15DFB167A9C873FC4BB8A81F6F2AB448A918', '1994-05-12', TRUE, TRUE, TRUE, TRUE, 'Being an admin is ez');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Pedro Viveiros', 'admin3@fe.up.pt', '8C6976E5B5410415BDE908BD4DEE15DFB167A9C873FC4BB8A81F6F2AB448A918', '1997-11-22', TRUE, TRUE, TRUE, TRUE, 'Best admin ahahah');
INSERT INTO users (name, email, password, birth_date, active, stock_manager, moderator, submission_manager, user_description) VALUES ('Jorge Novo', 'admin4@fe.up.pt', '8C6976E5B5410415BDE908BD4DEE15DFB167A9C873FC4BB8A81F6F2AB448A918', '1998-10-30', TRUE, TRUE, TRUE, TRUE, 'Best admin here ahahah');


-- Table: faq
INSERT INTO faq (question, answer) VALUES ('How can I buy a product ?', '  To buy a product, you need to click "Products" in the navigation bar to show the products dropdown.
  There, you can choose the type of the product that you want. You can also search for a product in the
  search bar of the navigation bar. When you get to one of this pages, you can choose one of the products.
  In that specific product page, you can buy the item immediately or you can add it to your cart and buy
  it later. Both of these actions can be accomplished through two buttons present on that page.');

INSERT INTO faq (question, answer) VALUES ('How can I create an account ?', 'To create an account, you need to press the User icon in the navigation bar, followed by the option Sign-up
in the dropdown that appeared.');


INSERT INTO faq (question, answer) VALUES ('How can I add a product to my wishlist ?', 'To add a product to your wishlist, you have to be logged in. In the products page you should press the button
"Add to wishlist."');

INSERT INTO faq (question, answer) VALUES ('How can I create a design ?', 'If you want to submit your own design, you have to be logged int and then press the "Submit your design"
button on the navigation bar. There you have to fill the various fields regarding your desing and then submit it.');

INSERT INTO faq (question, answer) VALUES ('How can I vote on a desing ?','To vote on a design, you have to log in and then click on the "Upcomig"button on the navigation bar.
There you have several polls of designs made by other users. To vote on a design, you should press the heart
button that appears on the product that you put the cursor on. Your vote is registed when that button gains
color.');

-- Table: size
INSERT INTO size (size) VALUES ('XS');
INSERT INTO size (size) VALUES ('S');
INSERT INTO size (size) VALUES ('M');
INSERT INTO size (size) VALUES ('L');
INSERT INTO size (size) VALUES ('XL');


-- Table: color
INSERT INTO color (color) VALUES ('Black');
INSERT INTO color (color) VALUES ('Grey');
INSERT INTO color (color) VALUES ('White');
INSERT INTO color (color) VALUES ('Red');

INSERT INTO product_color (id_product, id_color) VALUES (1, 1);
INSERT INTO product_color (id_product, id_color) VALUES (1, 2);
INSERT INTO product_color (id_product, id_color) VALUES (1, 3);
INSERT INTO product_color (id_product, id_color) VALUES (1, 4);

INSERT INTO product_size (id_product, id_size) VALUES (1, 1);
INSERT INTO product_size (id_product, id_size) VALUES (1, 2);
INSERT INTO product_size (id_product, id_size) VALUES (1, 3);
INSERT INTO product_size (id_product, id_size) VALUES (1, 4);
INSERT INTO product_size (id_product, id_size) VALUES (1, 5);
INSERT INTO product_size (id_product, id_size) VALUES (2, 1);
INSERT INTO product_size (id_product, id_size) VALUES (2, 2);
INSERT INTO product_size (id_product, id_size) VALUES (2, 3);
INSERT INTO product_size (id_product, id_size) VALUES (2, 4);
INSERT INTO product_size (id_product, id_size) VALUES (2, 5);
INSERT INTO product_size (id_product, id_size) VALUES (3, 1);
INSERT INTO product_size (id_product, id_size) VALUES (3, 2);
INSERT INTO product_size (id_product, id_size) VALUES (3, 3);
INSERT INTO product_size (id_product, id_size) VALUES (3, 4);
INSERT INTO product_size (id_product, id_size) VALUES (4, 3);
INSERT INTO product_size (id_product, id_size) VALUES (4, 4);
INSERT INTO product_size (id_product, id_size) VALUES (4, 5);
INSERT INTO product_size (id_product, id_size) VALUES (5, 1);
INSERT INTO product_size (id_product, id_size) VALUES (5, 2);
INSERT INTO product_size (id_product, id_size) VALUES (5, 3);
INSERT INTO product_size (id_product, id_size) VALUES (7, 1);
INSERT INTO product_size (id_product, id_size) VALUES (7, 2);
INSERT INTO product_size (id_product, id_size) VALUES (7, 3);
INSERT INTO product_size (id_product, id_size) VALUES (8, 3);
INSERT INTO product_size (id_product, id_size) VALUES (8, 4);
INSERT INTO product_size (id_product, id_size) VALUES (8, 5);
INSERT INTO product_size (id_product, id_size) VALUES (9, 1);
INSERT INTO product_size (id_product, id_size) VALUES (9, 2);
INSERT INTO product_size (id_product, id_size) VALUES (10, 1);
INSERT INTO product_size (id_product, id_size) VALUES (10, 3);
INSERT INTO product_size (id_product, id_size) VALUES (11, 3);
INSERT INTO product_size (id_product, id_size) VALUES (12, 1);
INSERT INTO product_size (id_product, id_size) VALUES (12, 2);
INSERT INTO product_size (id_product, id_size) VALUES (12, 3);
INSERT INTO product_size (id_product, id_size) VALUES (12, 4);
INSERT INTO product_size (id_product, id_size) VALUES (12, 5);

-- Table: wishlist
INSERT INTO wishlist (id_user,  id_product) VALUES (1, 1);
INSERT INTO wishlist (id_user,  id_product) VALUES (1, 3);
INSERT INTO wishlist (id_user,  id_product) VALUES (1, 13);
INSERT INTO wishlist (id_user,  id_product) VALUES (6, 3);
INSERT INTO wishlist (id_user,  id_product) VALUES (6, 5);
INSERT INTO wishlist (id_user,  id_product) VALUES (6, 6);
INSERT INTO wishlist (id_user,  id_product) VALUES (2, 50);
INSERT INTO wishlist (id_user,  id_product) VALUES (10, 32);
INSERT INTO wishlist (id_user,  id_product) VALUES (10, 31);
INSERT INTO wishlist (id_user,  id_product) VALUES (10, 2);
INSERT INTO wishlist (id_user,  id_product) VALUES (10, 1);
INSERT INTO wishlist (id_user,  id_product) VALUES (11, 1);
INSERT INTO wishlist (id_user,  id_product) VALUES (13, 40);
INSERT INTO wishlist (id_user,  id_product) VALUES (14, 64);
INSERT INTO wishlist (id_user,  id_product) VALUES (14, 74);
INSERT INTO wishlist (id_user,  id_product) VALUES (15, 48);
INSERT INTO wishlist (id_user,  id_product) VALUES (22, 13);
INSERT INTO wishlist (id_user,  id_product) VALUES (22, 14);
INSERT INTO wishlist (id_user,  id_product) VALUES (22, 15);
INSERT INTO wishlist (id_user,  id_product) VALUES (30, 77);
INSERT INTO wishlist (id_user,  id_product) VALUES (31, 75);
INSERT INTO wishlist (id_user,  id_product) VALUES (33, 47);
INSERT INTO wishlist (id_user,  id_product) VALUES (33, 15);
INSERT INTO wishlist (id_user,  id_product) VALUES (37, 5);
INSERT INTO wishlist (id_user,  id_product) VALUES (35, 9);
INSERT INTO wishlist (id_user,  id_product) VALUES (30, 4);
INSERT INTO wishlist (id_user,  id_product) VALUES (32, 3);
INSERT INTO wishlist (id_user,  id_product) VALUES (35, 1);
INSERT INTO wishlist (id_user,  id_product) VALUES (41, 80);
INSERT INTO wishlist (id_user,  id_product) VALUES (40, 56);
INSERT INTO wishlist (id_user,  id_product) VALUES (42, 33);
INSERT INTO wishlist (id_user,  id_product) VALUES (42, 72);
INSERT INTO wishlist (id_user,  id_product) VALUES (43, 60);
INSERT INTO wishlist (id_user,  id_product) VALUES (43, 40);
INSERT INTO wishlist (id_user,  id_product) VALUES (43, 10);

-- Table: cart
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (1, 1, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (1, 2, 2, 2, 2);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (2, 33, 3, 4, 3);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (2, 30, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (4, 40, 4, 2, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (7, 64, 1, 4, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (28, 74, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (26, 48, 3, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (26, 13, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (1, 14, 3, 5, 2);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (40, 15, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (34, 77, 4, 3, 4);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (24, 75, 1, 3, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (28, 47, 2, 2, 2);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (13, 15, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (14, 1, 1, 4, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (15, 13, 2, 3, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (37, 1, 2, 3, 3);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (35, 12, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (7, 1, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (5, 31, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (2, 36, 2, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (4, 42, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (12, 50, 3, 3, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (27, 54, 3, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (33, 55, 4, 3, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (32, 1, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (33, 1, 2, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (14, 22, 1, 1, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (15, 1, 2, 4, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (14, 23, 1, 5, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (7, 33, 1, 1, 2);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (3, 1, 1, 3, 1);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (3, 2, 2, 2, 2);
INSERT INTO cart (id_user, id_product, id_color, id_size, quantity) VALUES (3, 3, 3, 1, 2);

-- Table: city
INSERT INTO city (city) VALUES ('Viseu');
INSERT INTO city (city) VALUES ('Porto');
INSERT INTO city (city) VALUES ('Aveiro');
INSERT INTO city (city) VALUES ('Lisboa');
INSERT INTO city (city) VALUES ('Samil');
INSERT INTO city (city) VALUES ('Santarem');
INSERT INTO city (city) VALUES ('Braga');
INSERT INTO city (city) VALUES ('Ranhados');
INSERT INTO city (city) VALUES ('Faro');
INSERT INTO city (city) VALUES ('Fatima');
INSERT INTO city (city) VALUES ('Viana do Castelo');

-- Table: delivery_info
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (1, '967112935', 'Rua de Viseu, lote 1');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '922376127', 'Rua de Paranhos, 276');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '922322271', 'Quinta do Jose, 3, 2D');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '962111127', 'Rua dos Santos, 17');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (4, '965374811', 'Rua das Garrafas, 11, 3 direito');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (4, '966653748', 'Rua de Lisboa, 1');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (3, '922234522', 'Rua em Aveiro, lote 77, Aveiro');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (5, '914646463', 'Rua do Tomas, lote 69');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (7, '911113242', 'Rua tres, lote 3');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (8, '966969696', 'Quinta dos tomilhos, lt 12, 2o direto');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '926969696', 'Avenida da Liberdade, lt 150');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '969696773', 'Rua Joao Pedro, 111');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (1, '962222222', 'Urbanizacao Ze Chilo, lote 35, 2 direito');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (3, '932426722', 'Avenida de Lisboa, lt 150');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (7, '912326722', 'Avenida de Faro, lt 10');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '924366722', 'Avenida Soares, lt 110, 1 direito');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (1, '966666312', 'Avenida da Liberdade, lt 1');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (3, '914262679', 'Rua da Liberdade, lt 11');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (1, '923223329', 'Rua do Céu, lt 111');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (4, '911113329', 'Rua do Pão, lt 211, rdc');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '962133329', 'Rua Arménio Seixas, lt 2');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (6, '967977618', 'Rua Miguel Pinheiro, lt 9');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (8, '927977618', 'Rua Nova, lt 7');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (8, '937977618', 'Rua Velha, lt 77');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (3, '937927618', 'Rua B, lt 7');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (4, '917277618', 'Rua das Gaivotas, lt 7, 3 esquerdo');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (1, '938277618', 'Rua das Cerejas, lt 9');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (4, '931117618', 'Rua das Palaçoulas, lt 25');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '912347618', 'Rua das Lapouças, lt 225');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (3, '934445618', 'Rua das Ceroulas, lt 14');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (5, '934445618', 'Rua do Queijo, lt 10, rdc d');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '911125618', 'Rua do Seixo, lt 110');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (4, '966125618', 'Rua do Aleixo, lt 115');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (6, '911129918', 'Rua do Teixeira, lt 580');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '938978781', 'Rua de Samil, lt 87');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (4, '966111121', 'Rua de Contumil, lt 187');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (2, '936111121', 'Rua das Janelas, lt 10, primeiro direito');
INSERT INTO delivery_info (id_city, contact, delivery_address) VALUES (1, '937111121', 'Rua das Paredes, lt 110');

-- Table: purchase
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (1, 1, '2019-02-03 12:40:24', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (2, 2, '2019-01-05 03:22:05', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:22:05', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 3, '2019-03-30 15:10:10', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 4, '2019-02-01 19:34:22', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (22, 4, '2019-01-02 20:56:12', 1, 'canceled');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (33, 6, '2019-02-09 07:32:43', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (36, 7, '2019-03-14 12:41:56', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-01-29 11:12:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (30, 9, '2019-02-13 10:06:33', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (6, 10, '2019-01-05 14:54:45', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (8, 11, '2019-03-06 17:44:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (10, 3, '2019-02-12 18:33:43', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (31, 12, '2019-01-10 14:12:36', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (1, 1, '2019-02-20 12:06:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (35, 14, '2019-03-10 11:16:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (2, 2, '2019-02-11 10:16:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (4, 15, '2019-02-14 14:16:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (2, 2, '2019-01-14 12:16:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (8, 11, '2019-03-06 17:44:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (6, 10, '2019-02-06 12:24:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 13:34:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (55, 16, '2019-01-16 11:40:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (7, 17, '2019-01-16 11:40:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (4, 15, '2019-02-14 14:17:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (16, 18, '2019-01-12 13:11:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (23, 19, '2019-02-11 19:30:30', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 13:34:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (22, 4, '2019-02-01 19:34:22', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (63, 20, '2019-02-01 20:44:22', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (18, 21, '2019-03-04 22:41:21', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (39, 22, '2019-01-04 12:11:28', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (16, 18, '2019-01-12 13:11:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (4, 15, '2019-02-14 14:17:36', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (4, 15, '2019-02-14 14:17:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-03-01 11:17:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (57, 24, '2019-02-01 12:17:39', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (59, 25, '2019-01-01 10:11:22', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (44, 26, '2019-01-11 14:21:46', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-03-01 11:17:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (47, 27, '2019-01-21 18:13:12', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (54, 28, '2019-02-26 11:12:12', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (40, 29, '2019-03-06 01:02:02', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (52, 30, '2019-01-02 04:02:02', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-03-06 06:02:12', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 13:34:58', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (39, 22, '2019-01-04 12:11:30', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (19, 32, '2019-02-14 02:01:30', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (47, 27, '2019-01-21 18:13:16', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (1, 1, '2019-02-20 12:06:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (8, 11, '2019-03-06 17:44:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (31, 33, '2019-02-16 10:40:05', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 34, '2019-02-22 02:06:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (15, 35, '2019-03-12 04:16:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (47, 27, '2019-01-21 18:13:16', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-03-06 06:02:12', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (30, 9, '2019-01-13 10:06:33', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (45, 36, '2019-03-06 16:02:12', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (8, 11, '2019-03-06 17:44:57', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 34, '2019-02-22 02:06:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (5, 37, '2019-01-21 02:16:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 34, '2019-02-22 02:06:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (5, 37, '2019-01-21 02:16:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (2, 2, '2019-01-05 03:22:05', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (5, 37, '2019-01-21 02:16:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (5, 37, '2019-01-21 02:16:30', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (6, 10, '2019-02-06 12:24:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (6, 10, '2019-02-06 12:24:58', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (6, 10, '2019-02-06 12:27:00', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (6, 10, '2019-02-06 12:28:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (6, 10, '2019-02-06 12:34:50', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (8, 11, '2019-03-06 17:44:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (8, 11, '2019-03-06 17:44:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (8, 11, '2019-03-06 17:44:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (8, 11, '2019-03-06 17:44:55', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (52, 30, '2019-01-02 04:02:02', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (52, 30, '2019-01-02 04:02:02', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (52, 30, '2019-01-02 04:02:02', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (52, 30, '2019-01-02 04:02:02', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (47, 27, '2019-01-21 18:13:16', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (47, 27, '2019-01-21 18:13:16', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (47, 27, '2019-01-21 18:13:16', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (47, 27, '2019-01-21 18:13:16', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (31, 12, '2019-01-10 14:12:36', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (31, 12, '2019-01-10 14:12:36', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (31, 12, '2019-01-10 14:12:36', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (31, 12, '2019-01-10 14:12:36', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (31, 12, '2019-01-10 14:12:36', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (31, 12, '2019-01-10 14:12:36', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (10, 3, '2019-02-03 15:14:10', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (10, 3, '2019-01-30 15:17:10', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (10, 3, '2019-02-26 15:24:10', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (10, 3, '2019-03-05 15:15:10', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (10, 3, '2019-03-22 15:56:10', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (10, 3, '2019-03-10 16:23:10', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-03-01 11:17:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-02-01 12:19:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-01-01 13:18:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-02-11 14:14:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-02-01 15:12:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-02-03 16:07:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-02-16 17:17:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (60, 23, '2019-03-01 18:27:39', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 14:14:28', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 15:24:28', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 16:04:32', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 17:54:45', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 18:44:51', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 19:34:58', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 20:24:52', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (13, 15, '2019-01-06 21:14:56', 1, 'in_transit');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-03-06 06:02:57', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-03-06 06:02:47', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-03-06 06:02:38', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-02-06 01:44:20', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-02-14 08:02:21', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-02-26 06:02:10', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-02-06 06:02:22', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (21, 31, '2019-02-16 06:02:12', 1, 'delivered');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-01-29 11:12:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-01-29 11:15:36', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-01-29 11:17:37', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-01-29 11:20:34', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-01-29 11:43:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-03-02 11:35:21', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-01-29 11:52:05', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-02-19 11:57:10', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-02-19 11:57:31', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (37, 8, '2019-02-19 11:57:36', 1, 'processing');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:25:15', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:27:25', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:28:17', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:30:46', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:35:33', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:40:25', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:43:02', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:49:55', 1, 'awaiting_payment');
INSERT INTO purchase (id_user, id_deli_info, purchase_date, total, status) VALUES (3, 2, '2019-01-05 03:49:55', 1, 'awaiting_payment');

-- Table: product_purchase
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (4, 6, 1, 1, 2, 3);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (15, 1, 2, 1, 4, 2);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (52, 14, 1, 1, 1, 2);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (11, 13, 1, 1, 3, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (11, 12, 2, 1, 2, 2);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (15, 10, 1, 1, 3, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (30, 2, 1, 1, 3, 2);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (66, 8, 3, 1, 3, 4);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (69, 9, 1, 1, 1, 3);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (7, 7, 1, 1, 4, 3);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (9, 11, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (34, 15, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (32, 16, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (51, 17, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (56, 18, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (43, 19, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (18, 20, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (63, 21, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (71, 22, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (31, 23, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (6, 24, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (58, 25, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (31, 26, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (32, 27, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (6, 28, 1, 1, 3, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (57, 29, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (8, 30, 1, 1, 2, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (43, 31, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (51, 32, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (46, 33, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (20, 34, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (50, 35, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (12, 36, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (69, 37, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (71, 38, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (38, 39, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (43, 40, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (71, 41, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (34, 42, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (74, 43, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (62, 44, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (17, 45, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (18, 46, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (27, 47, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (55, 48, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (78, 49, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (18, 50, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (49, 51, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (17, 52, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (44, 53, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (20, 54, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (3, 55, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (43, 56, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (47, 57, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (67, 58, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (29, 59, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (27, 60, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (31, 61, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (4, 62, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (35, 63, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (74, 64, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (5, 65, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (13, 64, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (16, 65, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (39, 66, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (75, 67, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (46, 68, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (10, 69, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (37, 70, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (38, 71, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (40, 72, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (30, 73, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (49, 74, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (63, 75, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (72, 76, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (29, 77, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (47, 78, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (66, 79, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (71, 80, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (53, 81, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (73, 82, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (68, 83, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (79, 84, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (42, 85, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (38, 86, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (72, 86, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (60, 87, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (9, 88, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (82, 89, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (48, 90, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (19, 91, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (73, 92, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (30, 93, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (66, 94, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (62, 95, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (47, 96, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (81, 97, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (11, 98, 1, 1, 2, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (27, 99, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (27, 100, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (70, 101, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (80, 102, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (19, 103, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (81, 104, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (64, 105, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (2, 106, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (74, 107, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (4, 108, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (64, 109, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (55, 110, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (34, 111, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (56, 112, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (54, 113, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (43, 114, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (48, 115, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (50, 116, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (53, 117, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (24, 118, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (76, 119, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (77, 120, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (72, 121, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (18, 122, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (59, 123, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (34, 124, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (21, 125, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (33, 126, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (36, 127, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (28, 128, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (25, 129, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (58, 130, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (41, 131, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (45, 132, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (14, 133, 1, 1, 1, 1);
INSERT INTO product_purchase (id_product, id_purchase, quantity, price, id_size, id_color) VALUES (83, 134, 1, 1, 1, 1);


-- Table: review
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (1,1, 'Great hoodie. Beautiful. MIEIC is awsome','2019-04-08 15:40:24', 4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (2,4, 'Liked the hoodie.','2019-03-05 07:22:05', 3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (10,15, 'Funny phone case ! The water resistant is amazing. I recommend !','2019-04-05 18:10:10', 4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (22,70, 'Funny mousepad. But not very resistent','2019-04-06 14:34:22', 2);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (22,52, 'Totally worth this workshop. I learned so much.','2019-03-04 21:56:12', 4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (33,11, 'This hoodie is amazing and confortable','2019-04-19 07:32:43', 4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (36,11, 'Nice hoodie to wear in winter and represent the programmers.','2019-03-19 12:41:56', 4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,15, 'Liked this case so much ! And it is resistent','2019-04-29 13:12:31', 4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (30,26, 'My room is incredible with this poster ! Amazing.','2019-04-29 16:12:31', 5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (6,30, 'I offered this poster to my roommate and he loved it','2019-04-02 13:22:31', 5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (8,66, 'Nice mousepad but came with defect','2019-04-03 18:22:31', 3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (10,69, 'Funny mousepad, I really recommend it !','2019-04-06 02:22:31', 4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (31,7, 'I wear this hoodie almost everyday. Nice to use while programming','2019-04-09 07:22:31', 4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (1,9, 'Liked this jacket a lot. I recommend it','2019-04-19 17:22:31', 4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (35,34,'Very nice poster to put where we want','2019-03-10 21:23:03', 5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (2,32,'Loved this poster.','2019-03-14 11:54:04',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (4,51,'Amazing workshop. Loved it !','2019-01-22 04:20:50',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (2,56,'Very nice workshop ! Please do more of these events !','2019-03-03 18:42:19',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (8,43,'I loved this sticker','2019-04-08 06:39:09',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (6,18,'Meeeeh','2019-03-25 03:42:17',2.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,63,'Loved this pad ! 10/10','2019-04-11 21:21:38',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (55,71,'Another amazing product by you lads !','2019-03-22 12:40:18',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (7,31,'This Poster + room = great','2019-04-26 16:43:17', 3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (4,6,'The design is cool, I like it a lot','2019-03-09 14:21:20',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (58,16,'It is a CASE to say this product is great','2019-04-27 01:18:43',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (23,31,'Great poster. Great quality. 8/10','2019-03-27 21:59:10',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,32,'Quality of product on my opinion: 8/10','2019-03-24 03:02:27',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (22,6,'The design is amazing !','2019-04-18 10:44:52',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (63,57,'This workshop was really worth it','2019-04-07 22:20:48',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (18,8,'Very cool hoodie','2019-04-14 16:59:13',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (39,43,'My pc + this sticker =  GG','2019-04-05 17:20:24',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (16,51,'Not expensive and really worth. I recommend !','2019-04-29 10:28:15',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (4,46,'Love the sticker but I sticked it bad :c ','2019-04-06 20:19:31',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (4,20,'This case is really worth to buy','2019-03-24 13:53:12',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,50,'Another great workshop guys. Keep going !','2019-04-03 12:11:24',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (57,12,'Great hoodie !','2019-03-21 14:27:47',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (59,69,'Great mouse with great design in a great price with great material. You guys are great !','2019-04-22 10:52:46',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (44,71,'This mug is cool. Happilly I bought it','2019-03-21 05:23:45',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,38,'This poster in my room gives it a special touch','2019-04-20 05:51:32',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (47,43,'Great sticker ! But not much resistent','2019-04-07 01:53:02',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (54,71,'I recommend a lot this product. Really cheap and great ','2019-03-15 05:16:49',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (40,34,'I have this poster next to Mia Kunis poster on PULP FICTION. My life is complete','2019-03-27 06:58:53',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (52,74,'Great mug for a morning coffee !','2019-03-19 22:20:29',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,62,'Like this mousepad a lot','2019-03-23 23:58:42',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,17,'This case is very resistent, I can confirm xD Recommend !','2019-04-25 10:03:16',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (39,18,'All my 3 cases of MIEICHub are great. I recommend a lot their cases','2019-04-15 06:17:53',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (19,27,'Amazing poster to put on top of your bed.','2019-03-29 15:38:51',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (47,55,'Great workshop ! Loved it. ','2019-04-14 20:27:40',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (1,78,'Love this game and love this mug ahahah !','2019-03-16 23:24:44',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (8,18,'In this CASE, I recommend this product ahahah','2019-04-16 16:25:48',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (31,49,'More stickers for my MIEICHub collection !','2019-03-01 04:36:11',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,17,'Cool design I think','2019-03-02 15:49:25',3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (15,44,'When I saw this sticker I knew I had to get it','2019-04-25 02:01:22',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (47,20,'Case design: 8/10 - Resistence: 7/10','2019-04-03 03:44:04',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,3,'Your apparel is awsome ! I will expect new products','2019-04-12 19:44:15',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (30,43,'It sticks like a glove ahahahah','2019-03-10 10:21:59',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (45,47,'I like this sticker a lot ! Just great !','2019-04-17 08:57:33',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (8,67,'Cute mouse pad','2019-03-16 10:44:13',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,29,'Love your poster guys, I have 3 of them !','2019-04-05 10:44:18',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (5,27,'Great poster 10/10','2019-04-01 03:49:28',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,31,'Great poster. Please make a Poster Malone poster','2019-04-25 02:52:40',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (5,4,'Another great product by you guys ! Thanks','2019-04-03 15:46:18',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (2,35,'Love this poster. I have like 15 posters in my room and 6 are from you guys ! Keep going ! ','2019-04-02 16:22:54',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (5,5,'Amazing jacket for winter. WINTER IS COMING  ahahah','2019-04-12 22:07:20',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (5,74,'Love this ! Amazing bought.','2019-03-16 09:08:35',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (6,16,'Not expensive and resistent. I recommend','2019-04-03 05:09:42',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (6,75,'Just another great product. Keep improving','2019-04-02 12:11:16',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (6,13,'10/10 ;)','2019-03-20 23:51:27',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (6,39,'It looks perfect on my PC :)','2019-04-11 07:14:47',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (6,46,'Another sticker fot my collection ahahaha ','2019-03-20 07:34:21',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (8,40,'I like a lot of this sticker.','2019-03-04 08:48:02',3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (8,10,'I love hoodies and this one I bought affraid of getting scammed but it is amazing','2019-04-26 16:04:20',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (8,37,'Fine poster','2019-04-02 02:27:47',3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (8,38,'Great poster, really happy with it','2019-03-14 07:08:16',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (52,49,'Funny stickers ahahah','2019-03-17 09:09:09',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (52,30,'I love this poster so much ahahah','2019-03-27 20:33:43',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (52,72,'Another great product !','2019-04-05 22:54:36',2);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (52,63,'I have bought withou doubts an amazing mouse pad !','2019-04-01 03:44:36',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (47,71,'Loved this product','2019-04-03 03:14:06',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (47,66,'I have 5 mousepads. This is my favorite of all','2019-03-17 06:13:30',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (47,29,'Love your posters !','2019-03-22 06:20:30',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (47,47,'Sticker are so fun. Buy this one , I recommend it','2019-04-23 16:34:54',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (31,53,'Great workshop althought it was cold in the room','2019-03-22 21:49:14',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (31,73,'Great great great great','2019-04-04 23:01:40',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (31,68,'Great for gaming !','2019-03-08 16:32:47',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (33,79,'Just another great product. Keep going !','2019-04-02 13:47:56',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (31,42,'My PC is getting amazing with all your stickers :)','2019-03-18 00:44:52',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (31,38,'Loved this poster, for real !','2019-04-02 06:14:53',1);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (10,72,'Bravo guys. Bravo','2019-03-17 01:37:43',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (10,60,'Great mousepad, I strongly recommend it for gaming','2019-04-07 04:29:49',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (10,9,'The 6th apparel item of MIEICHub. Certainly not the last','2019-04-13 16:58:11',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (10,82,'10/10 ','2019-03-16 20:45:21',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (10,48,'Nice sticker','2019-04-16 06:07:27',3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (10,19,'Cool but should have design for IPhone :(','2019-03-03 15:05:12',3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,73,'Great !!!!','2019-03-20 14:14:04',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,30,'Your poster are just incredible. Congratulations','2019-04-14 21:31:30',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,66,'I love this mousepad !','2019-04-17 06:13:30',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,62,'Very soft mousepad.','2019-03-22 07:40:17',1);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,47,'Another sticker for my laptop !','2019-04-24 04:09:02',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,81,'Nice product','2019-03-23 19:14:28',3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,11,'I wear this hoodie a lot. I recommend it a lot too','2019-04-28 22:21:27',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (60,27,'Good enough','2019-04-12 10:25:59',3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,27,'Good enough too','2019-03-19 04:13:43',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,70,'Liked it !','2019-03-17 06:01:17',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,80,'Loved it !','2019-04-08 04:52:41',2);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,19,'Great case !','2019-04-18 15:49:34',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,81,'10/10','2019-03-14 22:49:09',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,64,'This mousepad is very cool','2019-04-07 02:29:35',1);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,2,'I wear this hoodie a lot. More of these please!','2019-04-10 07:30:47',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (13,74,'Very original ! Good job','2019-03-25 20:39:03',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,4,'Great hoodie with great quality','2019-03-28 03:19:23',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,64,'Funny mouse pad I think','2019-04-06 18:48:45',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,55,'The 2nd workshop I go. Loved it ! MORE MORE MORE','2019-04-05 18:17:07',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,34,'Your posters are so fun xD','2019-04-12 13:29:04',3);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,56,'Really intuitive and learned a lot !','2019-03-28 02:23:06',4.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,54,'One of best things I have done ever. Great workshop','2019-04-21 09:01:04',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,43,'Another great sticker ahah','2019-04-24 05:08:15',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (21,48,'Just sticked it. Amazing','2019-04-08 14:13:51',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,50,'Great workshop guys','2019-03-21 12:27:29',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,53,'Another great workshop ! Better than the other ! Keep going ','2019-04-20 12:09:22',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,24,'Nice Case','2019-04-16 13:26:22',3.5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,76,'Great product','2019-03-18 13:18:12',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,77,'Like so much of this product','2019-04-09 13:13:31',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,72,'Amazing product. I recommend it','2019-04-12 05:17:35',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,18,'Strong case ! Loved it','2019-04-12 13:26:55',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,59,'Great workshop ! I expect one of LARAVEL on the future !','2019-04-17 20:35:34',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,22,'Great case !!','2019-04-17 20:35:34',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (37,21,' Another great case !!','2019-04-17 20:35:34',4);

INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,33,' SET UP FOR THIS POSTEEEERS !!','2019-04-17 20:35:34',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,36,' SUPER BOCK is amazing ahahah  !!','2019-04-17 20:35:34',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,28,' I feel like hackerman now ahahh !!','2019-04-17 20:35:34',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,25,' Great poster ! Congrats','2019-04-17 20:35:34',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,58,'Loved this PPIN Workshop !!','2019-04-17 20:35:34',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,41,' Ahaha I love coffee and this sticker !!','2019-04-17 20:35:34',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,45,' JUST DO IT SHIA LABEOUF ahah funny sticker !!','2019-04-17 20:35:34',5);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,14,' Nice jacket! Loved it','2019-04-17 20:35:34',4);
INSERT INTO review (id_user, id_product, comment, review_date, rating) VALUES (3,83,' Great mug !!','2019-04-17 20:35:34',4);


-- Table: poll
INSERT INTO poll(poll_name, poll_date, expiration, active) VALUES ('Hoodies 2019', '2019-03-01', '2019-07-15', TRUE);
INSERT INTO poll(poll_name, poll_date, expiration, active) VALUES ('Mugs 2019', '2019-05-03', '2019-09-17', TRUE);
INSERT INTO poll(poll_name, poll_date, expiration, active) VALUES ('Pads 2019', '2019-03-02', '2019-07-16', TRUE);
INSERT INTO poll(poll_name, poll_date, expiration, active) VALUES ('Various 2019', '2019-03-02', '2019-07-16', TRUE);

-- Table: submission
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (3, 'Awsome Hoodie', 1, 'Hoodie just for awsomes', 'img/submissions/awsomeHoodie.jpg', '2019-01-08', TRUE, 0, FALSE, 1);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (12, 'Feature Mug', 4, 'No bugs, only features mug !', 'img/submissions/feature.jpg', '2019-06-06', TRUE, 0, FALSE, 2);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (27, 'CSS Mug', 4, 'Funny mug about css', 'img/submissions/css.jpeg', '2019-01-06', TRUE, 0, FALSE, 2);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (7, 'Quiet Sticker', 2, 'Silence, a programmer is working', 'img/submissions/quiet.png', '2019-01-01', TRUE, 0, FALSE, 4);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (14, 'MyMachine Mug', 4, 'It works on my machine !', 'img/submissions/myMachine.jpg', '2019-02-04', TRUE, 0, FALSE, 2);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (16, 'Math Pad', 5, 'Good with Math !', 'img/submissions/math.jpeg', '2019-02-11', TRUE, 0, FALSE, 3);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (9, 'Coding Case', 6, 'Brackets phone case', 'img/submissions/coding.jpg', '2019-01-12', TRUE, 0, FALSE, 4);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (32, 'Coders Case', 6, 'Coder gonna code !', 'img/submissions/coders.jpg', '2019-01-02', FALSE, 0, FALSE, NULL);

INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (1, 'Cloud Sticker', 2, 'Binary sticker with cloud', 'img/submissions/cloud.jpg', '2019-01-04', TRUE, 0, FALSE, 4);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (7, 'Love Case', 6, 'I love you case', 'img/submissions/love.jpeg', '2019-02-13', TRUE, 0, FALSE, 4);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (4, 'Feature Poster', 3, 'Features ftw', 'img/submissions/feature.jpeg', '2019-02-07', TRUE, 0, FALSE, 4);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (2, 'Friends Pad', 5, 'Pivot mixed with Friends mouse pad', 'img/submissions/friends.jpg', '2019-01-13', TRUE, 0, FALSE, 3);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (30, 'Keep Calm Poster', 3, 'Keep calm poster', 'img/submissions/loveprogramming.png', '2019-06-07', FALSE, 0, FALSE, 4);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (33, 'Challenge Accepted Pad', 1, 'Will you accept it ?', 'img/submissions/challenge.jpeg', '2019-02-12', FALSE, 0, FALSE, NULL);

INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (10, 'Black Belt Hoodie', 1, 'Black belt in programming', 'img/submissions/blackbelt.jpeg', '2019-05-15', TRUE, 0, FALSE, 1);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (7, 'Eat Sleep Code Hoodie', 1, 'Eat. Sleep. Code. Repeat.', 'img/submissions/esc.jpg', '2019-02-17', TRUE, 0, FALSE, 1);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (10, 'Coffee to Code Hoodie', 1, 'Best conversion', 'img/submissions/coffee.jpg', '2019-03-05', TRUE, 0, FALSE, 1);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (2, 'Binary Poster', 3, '011101010110010', 'img/submissions/binary.jpg', '2019-02-13', TRUE, 0, FALSE, 4);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (23, 'Still Alive Case', 6, 'While alive: sleep eat code repeat !', 'img/submissions/stillAlive.jpg', '2019-01-25', TRUE, 0, FALSE, 4);
INSERT INTO submission(id_user, submission_name, id_category, submission_description, picture, submission_date, accepted, votes, winner, id_poll) VALUES (45, 'Code Pad', 5, 'I write code', 'img/submissions/code.jpg', '2019-02-25', FALSE, 0, FALSE, 3);

-- Table: user_sub_vote
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (10, 2);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (15, 3);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (20, 4);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (23, 7);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (45, 15);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (11, 12);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (7, 7);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (3, 15);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (12, 13);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (2, 20);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (17, 1);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (29, 6);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (41, 7);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (20, 13);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (37, 9);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (29, 8);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (25, 7);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (36, 18);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (41, 19);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (39, 12);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (19, 2);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (5, 2);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (2, 3);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (1, 4);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (11, 7);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (9, 17);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (15, 16);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (23, 6);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (47, 5);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (36, 15);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (33, 8);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (28, 11);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (15, 1);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (44, 3);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (22, 2);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (33, 2);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (31, 5);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (47, 8);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (45, 9);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (30, 19);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (20, 17);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (10, 3);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (16, 1);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (43, 13);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (49, 20);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (45, 14);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (33, 1);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (38, 5);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (28, 6);
INSERT INTO user_sub_vote (id_user, id_sub) VALUES (18, 7);
