CREATE TYPE PackageStatus AS ENUM ('AwaitingPayment', 'Processing', 'InTransit', 'Delivered', 'Canceled');

CREATE TABLE "User" 
(
    idUser SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    pw TEXT NOT NULL,
    birthDate DATE NOT NULL,
    active BOOLEAN NOT NULL 
);

CREATE TABLE StockManager 
(
    idUser INTEGER PRIMARY KEY REFERENCES "User" ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Moderator
(
    idUser INTEGER PRIMARY KEY REFERENCES "User" ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE SubmissionManager
(
    idUser INTEGER PRIMARY KEY REFERENCES "User" ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Category
(
    idCategory SERIAL PRIMARY KEY,
    category TEXT UNIQUE NOT NULL
);

CREATE TABLE Color
(
    idColor SERIAL PRIMARY KEY,
    color TEXT UNIQUE NOT NULL
);

CREATE TABLE Size
(
    idSize SERIAL PRIMARY KEY,
    size TEXT UNIQUE NOT NULL
);

CREATE TABLE Photo 
(
    idPhoto SERIAL PRIMARY KEY,
    imagePath TEXT UNIQUE NOT NULL,
    idProduct INTEGER NOT NULL REFERENCES Product ON UPDATE CASCADE
);

CREATE TABLE Product
(
    idProduct SERIAL PRIMARY KEY,
    productName TEXT NOT NULL,
    productDescription TEXT NOT NULL,
    price FLOAT NOT NULL CHECK(price > 0),
    stock INTEGER NOT NULL CHECK(stock >= 0),
    rating FLOAT NOT NULL CHECK(rating >= 0 AND rating <= 5),
    idCategory INTEGER NOT NULL REFERENCES Category ON UPDATE CASCADE
);

CREATE TABLE ProductColor
(
    idProduct INTEGER NOT NULL REFERENCES Product ON UPDATE CASCADE ON DELETE CASCADE,
    idColor INTEGER NOT NULL REFERENCES Color ON UPDATE CASCADE,
    PRIMARY KEY (idProduct, idColor) 
);

CREATE TABLE ProductSize
(
    idProduct INTEGER NOT NULL REFERENCES Product ON UPDATE CASCADE ON DELETE CASCADE,
    idSize INTEGER NOT NULL REFERENCES Size ON UPDATE CASCADE,
    PRIMARY KEY (idProduct, idSize)
);

CREATE TABLE City
(
    idCity SERIAL PRIMARY KEY,
    city TEXT NOT NULL
);

CREATE TABLE DeliveryInfo
(
    idDeliveryInfo SERIAL PRIMARY KEY,
    idCity INTEGER NOT NULL REFERENCES City ON UPDATE CASCADE,
    contact TEXT NOT NULL,
    deliveryAddress TEXT NOT NULL
);

CREATE TABLE Purchase
(
    idPurchase SERIAL PRIMARY KEY,
    idUser INTEGER NOT NULL REFERENCES "User" ON UPDATE CASCADE,
    idDeliInfo INTEGER NOT NULL REFERENCES DeliveryInfo ON UPDATE CASCADE,
    purchaseDate TIMESTAMP WITH TIME zone DEFAULT now() NOT NULL,
    total FLOAT NOT NULL CHECK(total >= 0),
    status PackageStatus NOT NULL
);

CREATE TABLE ProductPurchase
(
    idProduct INTEGER NOT NULL REFERENCES Product ON UPDATE CASCADE,
    idPurchase INTEGER NOT NULL REFERENCES Purchase ON UPDATE CASCADE,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    price FLOAT NOT NULL CHECK(price > 0),
    idSize INTEGER REFERENCES Size ON UPDATE CASCADE,
    idColor INTEGER REFERENCES Color ON UPDATE CASCADE,
    PRIMARY KEY (idProduct, idPurchase)
);

CREATE TABLE Review
(
    idUser INTEGER NOT NULL REFERENCES "User" ON UPDATE CASCADE,
    idProduct INTEGER NOT NULL REFERENCES Product ON UPDATE CASCADE,
    comment TEXT NOT NULL,
    reviewDate TIMESTAMP WITH TIME zone DEFAULT now() NOT NULL,
    rating INTEGER NOT NULL CHECK(rating > 0 AND rating <= 5),
    PRIMARY KEY (idUser, idProduct)
);

CREATE TABLE Cart
(
    idUser INTEGER NOT NULL REFERENCES "User" ON UPDATE CASCADE ON DELETE CASCADE,
    idProduct INTEGER NOT NULL REFERENCES Product ON UPDATE CASCADE,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    PRIMARY KEY (idUser, idProduct)
);

CREATE TABLE Wishlist
(
    idUser INTEGER NOT NULL REFERENCES "User" ON UPDATE CASCADE ON DELETE CASCADE,
    idProduct INTEGER NOT NULL REFERENCES Product ON UPDATE CASCADE,
    PRIMARY KEY (idUser, idProduct)
);

CREATE TABLE FAQ
(
    idQuestion SERIAL PRIMARY KEY,
    question TEXT UNIQUE NOT NULL,
    answer TEXT NOT NULL 
);

CREATE TABLE Poll
(
    idPoll SERIAL PRIMARY KEY,
    pollName TEXT UNIQUE NOT NULL,
    pollDate DATE NOT NULL,
    expiration DATE NOT NULL,
    active BOOLEAN NOT NULL
);

CREATE TABLE Submission
(
    idSubmission SERIAL PRIMARY KEY,
    idUser INTEGER NOT NULL REFERENCES "User" ON UPDATE CASCADE,
    submissionName TEXT NOT NULL,
    idCategory INTEGER NOT NULL REFERENCES Category ON UPDATE CASCADE,
    submissionDescription TEXT NOT NULL,
    picture TEXT NOT NULL,
    submissionDate TIMESTAMP WITH TIME zone DEFAULT now() NOT NULL,
    accepted BOOLEAN NOT NULL,
    votes INTEGER DEFAULT 0 NOT NULL CHECK(votes >= 0),
    winner BOOLEAN NOT NULL,
    idPoll INTEGER NOT NULL REFERENCES Poll ON UPDATE CASCADE
);

CREATE TABLE UserSubVote
(
    idUser INTEGER NOT NULL REFERENCES "User" ON UPDATE CASCADE,
    idSub INTEGER NOT NULL REFERENCES Submission ON UPDATE CASCADE,
    PRIMARY KEY (idUser, idSub)
);





