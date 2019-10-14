#!/bin/bash
if ! rpm -qa | grep deltarpm | grep -v grep >/dev/null
then
        yum -y install deltarpm
fi

yum -y update

if ! ( yum grouplist | sed -n '/Installed environment/,/Available environment/p' | grep KDE >/dev/null 2>&1 )
then
	yum -y groupinstall "KDE Plasma Workspaces"
	# Add MySQL here (or maria DB, and start it
	yum -y install mariadb mariadb-libs mariadb-server
fi

if ! grep student /etc/passwd >/dev/null 2>&1
then
	useradd -m student
	(sleep 5; echo "secret"; sleep 2; echo "secret") | passwd student
fi

if ! grep AutoLoginEnable /etc/gdm/custom.conf >/dev/null 2>&1
then

echo "[daemon]
AutomaticLoginEnable=true
AutomaticLogin=student

[security]

[xdmcp]

[greeter]

[chooser]

[debug]

" >/etc/gdm/custom.conf

fi

service mariadb start
chkconfig mariadb on

cd /home/student

mysql -u root <<_END_
CREATE DATABASE IF NOT EXISTS classes;
use classes;

create table student
(
	id integer not null unique,
	name	char(15),
	iq	decimal(3,0) null,	
	major	char(15)	null,
	primary key (id),
	check (iq >= 60 and iq <= 200)
); 

create table teacher
(
	id	integer not null unique,
	name	char(15),
	salary	decimal(6,0) null,
	dep	char(15)	null,	
	primary key (id),
	check (salary >= 0 and salary <= 200000)
); 

create table class
(
	id	integer not null unique,
	name	char(25),
	dep	char(15)	null,
	loc	char(15)	null,
	primary key (id)
); 

create table assign
(
	studid	integer not null, 
	teachid	integer not null, 
	classid	integer not null, 
	grade	decimal(2,1) null,
	primary key(studid, teachid, classid),
	foreign key (studid) references student(id),
	foreign key (teachid) references teacher(id),
	foreign key (classid) references class(id),
	check (grade >= 0 and grade <=4)
);

INSERT INTO student (id,name,iq,major) VALUES(1,'Bill',130,'PHYSICS');
INSERT INTO student (id,name,iq,major) VALUES(2,'Joe',110,'PSYCHOLOGY');
INSERT INTO student (id,name,iq,major) VALUES(3,'Bob',120,'PHILOSOPHY');
INSERT INTO student (id,name,iq,major) VALUES(4,'John',100,'PSYCHOLOGY');
INSERT INTO student (id,name,iq,major) VALUES(5,'Peter',100,'ENGINEERING');
INSERT INTO student (id,name,iq,major) VALUES(6,'Mary',150,'ENGINEERING');

INSERT INTO teacher (id,name,dep,salary) VALUES(1,'SPOCK','ENGINEERING',100000);
INSERT INTO teacher (id,name,dep,salary) VALUES(2,'PLATO','PHILOSOPHY',65000);
INSERT INTO teacher (id,name,dep,salary) VALUES(3,'FEYNMAN','PHYSICS',150000);
INSERT INTO teacher (id,name,dep,salary) VALUES(4,'FREUD','PSYCHOLOGY',70000);

INSERT INTO class (id,name,dep,loc) VALUES(1,'Intro to Physics','PHYSICS','Seaver Hall');
INSERT INTO class (id,name,dep,loc) VALUES(2,'The Id and the Uber-Id','PSYCHOLOGY', 'Bldg 10');
INSERT INTO class (id,name,dep,loc) VALUES(3,'Transporters Today','ENGINEERING','Science Bldg');
INSERT INTO class (id,name,dep,loc) VALUES(4,'Intro to Philosophy','PHILOSOPHY','Emerson');
INSERT INTO class (id,name,dep,loc) VALUES(5,'Intro to Computers','ENGINEERING','Bldg 10');

INSERT INTO assign (studid,teachid,classid,grade) VALUES(1,3,1,4.0);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(1,2,4,3.5);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(1,1,3,4.0);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(2,4,2,3.5);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(2,2,4,2.5);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(3,2,4,2.0);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(3,1,5,3.5);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(4,4,2,3.0);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(5,1,3,2.5);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(5,1,5,3.0);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(5,4,2,2.5);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(6,3,1,4.0);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(6,4,2,4.0);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(6,1,3,4.0);
INSERT INTO assign (studid,teachid,classid,grade) VALUES(6,2,4,4.0);

GRANT ALL PRIVILEGES ON *.* TO 'student'@'%' WITH GRANT OPTION;
_END_

if ! (systemctl get-default | grep graphical.target >/dev/null 2>&1)
then
	systemctl set-default graphical.target
	systemctl disable firewalld
	systemctl stop firewalld
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
	init 6
fi
