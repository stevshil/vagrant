-- MySQL Trades
use trades;

drop table if exists Trades;
drop table if exists Stocks;
drop table if exists Markets;


create table Markets (
    ticker      char(12)    not null,
    description varchar(80) not null,
    primary key (ticker)
);

create table Stocks (
    ticker      char(16)    not null,
    symbol      char(4)     not null,
    market      char(12)    not null,
    description varchar(80) not null,
    primary key (ticker),
    foreign key (market) references Markets(ticker)
);

create table Trades (
    id      int           not null auto_increment,
    transid varchar(20)   not null,
    stock   char(16)      not null,
    ptime   timestamp     not null,
    price   numeric(14,4) not null,
    volume  numeric(12,0) not null,
    buysell char(1)       not null,
    state   char(1)       not null default 'P',
    stime   timestamp     not null default CURRENT_TIMESTAMP,
    primary key (id),
    unique (transid),
    foreign key (stock) references  Stocks(ticker),
    CONSTRAINT `buysell` CHECK (status IN ('B', 'S')), -- parsed but not implement in MySQL 5.7
    CONSTRAINT `state` CHECK (status IN ('P', 'M', 'C', 'A', 'D', 'E', 'S', 'R')) -- parsed but not implement in MySQL 5.7
);

insert into Markets values ('FTSE', 'Financial Times Stock Exchange');
insert into Markets values ('NYSE', 'New York Stock Exchange');
insert into Markets values ('NASDAQ', 'National Association of Securities Dealers Automated Quotations');

insert into Stocks values ('FTSE.AA', 'AA', 'FTSE', 'Automobile Association');
insert into Stocks values ('FTSE.BARC', 'BARC', 'FTSE', 'Barclays');
insert into Stocks values ('FTSE.LLOY', 'LLOY', 'FTSE', 'Lloyds');
insert into Stocks values ('FTSE.VM', 'VM', 'FTSE', 'Virgin Money');
insert into Stocks values ('NYSE.C', 'C', 'NYSE', 'Citigroup');
insert into Stocks values ('NYSE.BAC', 'BAC', 'NYSE', 'Bank of America');
insert into Stocks values ('NYSE.JPM', 'JPM', 'NYSE', 'JP Morgan');
insert into Stocks values ('NYSE.ORCL', 'ORCL', 'NYSE', 'Oracle');
insert into Stocks values ('NASDAQ.GOOG', 'GOOG', 'NASDAQ', 'Google');
insert into Stocks values ('NASDAQ.AAPL', 'AAPL', 'NASDAQ', 'Apple');
insert into Stocks values ('NASDAQ.YHOO', 'YHOO', 'NASDAQ', 'Yahoo');
insert into Stocks values ('NASDAQ.IBM', 'IBM', 'NASDAQ', 'IBM');
insert into Stocks values ('NASDAQ.TEAM', 'TEAM', 'NASDAQ', 'Atlassian');

