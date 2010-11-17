-- Drop existing tables, in an order that maintains referential integrity
drop table bag_doc_note;
drop table bag_doc_tag;
drop table bag_doc;
drop table user_tag;
drop table user;

-- Create new tables
create table user (
    userID varchar(20) primary key, 
    password varchar(20), 
    lastLogin datetime, 
    email varchar(80), 
    resultsPerPage int, 
    resultsSort varchar(20), 
    bagSort varchar(20)
);

create table user_tag (
    userID varchar(20),
    tagName varchar(20),
    primary key (userID, tagName),
    foreign key (userID) references user (userID)
        on delete cascade
        on update cascade
);

create table bag_doc (
    userID varchar(20),
    objectID varchar(12),
    bagged datetime,
    primary key (userID, objectID),
    foreign key (userID) references user (userID)
        on delete cascade
        on update cascade
);

create table bag_doc_note (
    userID varchar(20),
    objectID varchar(12),
    note text,
    index (userID, objectID),
    foreign key (userID, objectID) references bag_doc (userID, objectID)
        on delete cascade
        on update cascade
);

create table bag_doc_tag (
    userID varchar(20),
    objectID varchar(12),
    tagName varchar(20),
    primary key (userID, objectID, tagName),
    foreign key (userID, objectID) references bag_doc (userID, objectID)
        on delete cascade
        on update cascade,
    index (userID, tagName),
    foreign key (userID, tagName) references user_tag (userID, tagName)
        on delete cascade
        on update cascade
);

/*
-- Add some test data to try things out
insert into user (userID, password) values ('foo', 'foopw');
insert into user (userID, password) values ('bar', 'barpw');

insert into user_tag values ('foo', 'tag 1');
insert into user_tag values ('foo', 'tag 2');
insert into user_tag values ('bar', 'tag 1');

insert into bag_doc values ('foo', 'object1', now());
insert into bag_doc values ('foo', 'object2', now());
insert into bag_doc values ('bar', 'object1', now());
insert into bag_doc values ('bar', 'object3', now());

insert into bag_doc_note values('foo', 'object1', 'This is foo note #1a');
insert into bag_doc_note values('foo', 'object1', 'This is foo note #1b');
insert into bag_doc_note values('foo', 'object2', 'This is foo note #2a');
insert into bag_doc_note values('foo', 'object2', 'This is foo note #2b');
insert into bag_doc_note values('bar', 'object1', 'This is bar note #1');
insert into bag_doc_note values('bar', 'object3', 'This is bar note #3');

insert into bag_doc_tag values('foo', 'object1', 'tag 1');
insert into bag_doc_tag values('foo', 'object1', 'tag 2');
insert into bag_doc_tag values('bar', 'object1', 'tag 1');
insert into bag_doc_tag values('bar', 'object3', 'tag 1');
*/


/*
-- Merge data from two users. Similar to process by which a temporary (session-based)
-- bookbag would be merged into a permanent bag when user logs in.
insert into user (userID, password) values ('merged', 'mergedpw');

insert ignore into user_tag select 'merged', tagName from user_tag where userID='foo';
insert ignore into user_tag select 'merged', tagName from user_tag where userID='bar';

insert ignore into bag_doc select 'merged', objectID, bagged from bag_doc where userID='foo';
insert ignore into bag_doc select 'merged', objectID, bagged from bag_doc where userID='bar';

insert into bag_doc_note select 'merged', objectID, note from bag_doc_note where userID='foo';
insert into bag_doc_note select 'merged', objectID, note from bag_doc_note where userID='bar';

insert ignore into bag_doc_tag select 'merged', objectID, tagName from bag_doc_tag where userID='foo';
insert ignore into bag_doc_tag select 'merged', objectID, tagName from bag_doc_tag where userID='bar';
*/
