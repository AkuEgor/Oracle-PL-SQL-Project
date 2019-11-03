 select * from cars;
  select * from cus;
   select * from orders;
    select * from tow;
     select * from task;
      select * from parts;
       select * from inst;
 
 ALTER SESSION SET ddl_lock_timeout=900;
 
DROP  TABLE inst;
DROP TABLE parts;
DROP TABLE task;
DROP TABLE tow;
DROP TABLE ORDERS CASCADE CONSTRAINTS;
DROP TABLE cus;
DROP TABLE cars;

CREATE TABLE CARS
(IDCAR  number(4) not null,
  Plates varchar2(10),
  C_MODEL varchar2(10),
  IDOwner number(2) not null,
  P_YEAR number(4),
  Color varchar2(10),
  CONSTRAINT CARS_PK PRIMARY KEY(IDCAR));
  
  create table CUS(
IDOwner number(2),
  PhnNumr number(10),
  DrLse number(4),
  CUS_Name varchar2(8),
  Surname varchar2(8),
  CONSTRAINT CUS_PK PRIMARY KEY(IDOwner));
   
  
  CREATE TABLE ORDERS
(ORDER_ID number,
  OIDCAR number(4),
  OIDowner number(2),
  CodeWork number(4),
  DATES date,
  CONSTRAINT ORDERS_PK PRIMARY KEY(ORDER_ID));

  create table TOW
(WORKCODE number,
  WorkCost number(5,2),
  DESCRIPT varchar2(15),
  CONSTRAINT TOW_PK PRIMARY KEY(WORKCODE));

create table TASK
(TASK_ID NUMBER(10),
ORNUM number(10),
 WRKCODE number(4),
 CONSTRAINT TASK_PK PRIMARY KEY(TASK_ID));
  
  
  create table PARTS
(PIDS number,
  LOC varchar2(10),
  P_NAME VARCHAR2(20),
  Pprice number(10,2),
  Stock number(20),
  CONSTRAINT PIDS_PK PRIMARY KEY(PIDS));
  
  
  create table INST
(INST_ID NUMBER(10),
ORnumB number(10),
  PID number(10),
CONSTRAINT INST_PK PRIMARY KEY(INST_ID));

  
ALTER TABLE ORDERS ADD CONSTRAINT ORDERS_cars_FK 
FOREIGN KEY(OIDCAR) REFERENCES CARS (IDCAR);
  
ALTER TABLE ORDERS ADD CONSTRAINT ORDERS_owner_FK 
FOREIGN KEY(OIDowner) REFERENCES CUS (IDOwner);
 
ALTER TABLE TASK ADD CONSTRAINT TASK_ORDERS_FK 
FOREIGN KEY(ORNUM) REFERENCES ORDERS (ORDER_ID);
 
ALTER TABLE TASK ADD CONSTRAINT TASK_TOW_FK 
FOREIGN KEY (WRKCODE) REFERENCES TOW (WORKCODE);
 
ALTER TABLE INST ADD CONSTRAINT INSTL_ORDERS_FK 
FOREIGN KEY (ORnumB) REFERENCES ORDERS (ORDER_ID);
 
ALTER TABLE INST ADD CONSTRAINT INST_FK 
FOREIGN KEY(PID) REFERENCES PARTS (PIDS); 
  
 
insert into CARS VALUES (20,'OO-00100','Prado 200',1,2017,'BLACK');
insert into CARS VALUES (19,'GF-52969','Saburban',2,2010,'YELLOW');
insert into CARS VALUES (17,'QB-13498','Prius',3,2018,'RED'); 
insert into CARS VALUES (16,'CD-24575','VESTA',4,2015,'GREY'); 
insert into CARS VALUES (15,'LS-75252','ASTRA',5,2010,'BLUE'); 
 
insert into CUS VALUES (1,10001,4513,'John','Dylan');
insert into CUS VALUES (2,20002,9058,'Kendrek','Kriko');
insert into CUS VALUES (3,30003,6784,'Danila','Poper'); 
insert into CUS VALUES (4,40004,9274,'POOPKA','MUMBA'); 
insert into CUS VALUES (5,50005,1037,'KARISH','PHIL'); 
 
insert into ORDERS VALUES (001,20,1,888,TO_DATE('05-06-2018', 'DD-MM-YYYY'));
insert into ORDERS VALUES (002,19,2,777,TO_DATE('29-01-2018', 'DD-MM-YYYY'));
insert into ORDERS VALUES (003,17,3,666,TO_DATE('20-12-2018', 'DD-MM-YYYY')); 
insert into ORDERS VALUES (004,16,4,555,TO_DATE('01-07-2018', 'DD-MM-YYYY')); 
insert into ORDERS VALUES (005,15,5,444,TO_DATE('16-06-2018', 'DD-MM-YYYY')); 
 
insert into TOW VALUES (888,290.50,'Caster');
insert into TOW VALUES (777,643.43,'new_liquid');
insert into TOW VALUES (666,411.84,'rebuild'); 
insert into TOW VALUES (555,89.24,'new window'); 
insert into TOW VALUES (444,411.83,'engine check'); 
 
insert into TASK VALUES (10,001,888);
insert into TASK VALUES (20,002,777);
insert into TASK VALUES (30,003,666); 
insert into TASK VALUES (40,004,555); 
insert into TASK VALUES (50,005,444); 
 
insert into PARTS VALUES (601,'BERLIN','TURBO',182.00,1);
insert into PARTS VALUES (602,'MINSK','CRANCK SHAFT',78.50,4);
insert into PARTS VALUES (603,'PARIS','RIMS',314.99,9); 
insert into PARTS VALUES (604,'WARSAW','LOCK',284.27,7); 
insert into PARTS VALUES (605,'GDANSK','CARBONFIBER',234.89,3); 

insert into INST VALUES (10,001,601);
insert into INST VALUES (20,002,602);
insert into INST VALUES (30,003,603);
insert into INST VALUES (40,004,604);
insert into INST VALUES (50,005,605);







        --Function--
--=== this function returns value of parts cost + work cost of a specific order ===--
CREATE OR REPLACE FUNCTION TOTAL_WORK_COST(
ORDERS_ID NUMBER
)
RETURN NUMBER
IS
TOTAL_COST NUMBER;
CURSOR C1 IS
SELECT P.PPRICE+T.WORKCOST
FROM ORDERS O, PARTS P, TOW T, INST I, TASK D
WHERE P.PIDS = I.PID AND I.ORNUMB = O.ORDER_ID AND T.WORKCODE = D.WRKCODE 
AND D.ORNUM = O.ORDER_ID AND O.ORDER_ID = ORDERS_ID;
BEGIN
OPEN C1;
FETCH C1 INTO TOTAL_COST;
CLOSE C1;
RETURN TOTAL_COST;
END;
/


SET SERVEROUTPUT ON;
BEGIN
DBMS_OUTPUT.PUT_LINE(TOTAL_WORK_COST(2));
END;
/



 --=== Procedures ===--
 --=== Increasing work cost by certain %, if rased too much error will apear. ===-- 
CREATE OR REPLACE PROCEDURE CHANGE_WORK_COST(
p_percentage IN NUMBER
) 
IS
new_cost TOW.WORKCOST%TYPE;
new_ID TOW.WORKCODE%TYPE;
high_cost EXCEPTION;
CURSOR C1 IS
SELECT WORKCOST, WORKCODE FROM TOW;
BEGIN
OPEN C1;
LOOP
FETCH C1 INTO new_cost, new_ID;
new_cost := new_cost + new_cost/100 *p_percentage;
IF new_cost > 1000 THEN
RAISE high_cost;
END IF;
EXIT WHEN C1%NOTFOUND;
UPDATE TOW
SET WORKCOST = new_cost
WHERE WORKCODE = new_ID;
DBMS_OUTPUT.PUT_LINE('Percentage: ' || p_percentage || '   WORKCODE: ' || new_ID ||  '    New Cost: ' || new_cost);
END LOOP;
CLOSE C1;
 EXCEPTION
     WHEN high_cost THEN
     DBMS_OUTPUT.PUT_LINE('TOO EXPENSIVE');
END;
/


set serveroutput on;
DECLARE
BEGIN
CHANGE_WORK_COST(20);
END;
/

select * from TOW;




 --=== Adding a new car with 2 exceptions:  ===-- 
 --=== 1) car needs to be manufactured atlest since 2000  ===-- 
 --=== 2) there should be a specific plates number patern ( __-_____ ) ===-- 
CREATE OR REPLACE PROCEDURE ADD_CAR(
N_IDCAR IN NUMBER,
N_PLATES IN VARCHAR2,
N_C_MODEL IN VARCHAR,
N_IDOWNER IN NUMBER,
N_P_YEAR IN NUMBER,
N_COLOR IN VARCHAR2
)
IS
low_year EXCEPTION;
e_unknown_plates EXCEPTION;
BEGIN
    IF N_P_YEAR < 2000 THEN
    RAISE low_year;
    ELSIF N_PLATES  NOT LIKE  '__-_____' THEN
    RAISE e_unknown_plates;      
        END IF;
        dbms_output.put_line('New car was inserted successfully');
INSERT INTO CARS
    (
    IDCAR,
    PLATES,
    C_MODEL,
    IDOWNER,
    P_YEAR,
    COLOR
    )
 VALUES(
    N_IDCAR,
    N_PLATES,
    N_C_MODEL,
    N_IDOWNER,
    N_P_YEAR,
    N_COLOR
    );
    EXCEPTION
     WHEN low_year THEN
     DBMS_OUTPUT.PUT_LINE('YOUR car was manufactured before 2000, we do not work with cars of this age.');
     WHEN e_unknown_plates THEN
     DBMS_OUTPUT.PUT_LINE('Plate number is unknown ');
END;
/


SET SERVEROUTPUT ON; 
EXEC ADD_CAR(14,'AB-20100','Cayman',6,1999,'grey');
EXEC ADD_CAR(14,'NP67P ','Cayman',6,2001,'grey');
EXEC ADD_CAR(29,'AB-20100','Cayman',6,2005,'grey');


 
--=== this Procedure rases price for parts depending on its location + 2 exceptions ===-- 
CREATE OR REPLACE PROCEDURE TAXES_RASE(
PID IN NUMBER, n_newprice OUT NUMBER
)
IS
n_loc PARTS.LOC%TYPE;
n_pprice PARTS.PPRICE%TYPE;
n_raise NUMBER(3,2);
BEGIN
    SELECT LOC, PPRICE INTO n_loc, n_pprice FROM PARTS WHERE PIDS = PID;
    CASE
      WHEN n_loc = 'BERLIN' THEN
      n_raise := .6;
      WHEN n_loc = 'MINSK' THEN
      n_raise := .3;
      WHEN n_loc  = 'PARIS' THEN
      n_raise := .7;
      WHEN n_loc  = 'WARSAW' THEN
      n_raise := .8;
      WHEN n_loc  = 'GDANSK' THEN
      n_raise := .3;
    END CASE;
    n_newprice := n_pprice + n_pprice*n_raise;
    UPDATE PARTS
    SET PPRICE = n_newprice
    WHERE PIDS = PID;  
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No parts matches the given location');
      WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('More than one part  given at the same  location');      
END;
/


set serveroutput on;

DECLARE
p_newprice NUMBER;
BEGIN
TAXES_RASE(603,p_newprice);
DBMS_OUTPUT.PUT_LINE('new price is : ' || p_newprice);
END;

select * from parts



--=== This Procedure gives us full sum of all parts at EACH location ===--
Create or replace procedure price_sum_loc AS 

Cursor C2
is select P.LOC, SUM(P.PPRICE)
from PARTS P
group by P.LOC
order by P.LOC;
total_sum number(5);
nloc varchar2(20);

BEGIN  
    OPEN C2;
    LOOP
    FETCH C2 INTO nloc, total_sum;
    EXIT WHEN C2%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Income from ' || nloc || ' tickets: ' || total_sum);    
    END LOOP;
    CLOSE C2;
END;
/


set serveroutput on;
EXECUTE price_sum_loc;

                        --=== Triggers ===--

--=== Trigger which executes procedure ===--
--=== This trigger fires data added/deleted from table PARTS, and then executes procedure ===--
CREATE OR REPLACE TRIGGER new_price_sum_loc
AFTER INSERT OR DELETE on parts
BEGIN
    IF INSERTING THEN
        dbms_output.put_line('After inserting, parts list looks like:');   
    ELSIF DELETING THEN
        dbms_output.put_line('After deleting, parts list looks like:');
    END IF;   
    price_sum_loc;
END;
/

ALTER TRIGGER new_price_sum_loc ENABLE;
SET SERVEROUTPUT ON;

insert into PARTS VALUES (610,'BERLIN','glass',478.00,2);





--=== This trigger inserts todays date if date was not specified ===--
CREATE OR REPLACE TRIGGER NT8
BEFORE INSERT OR UPDATE
ON ORDERS
FOR EACH ROW
DECLARE X DATE := sysdate;
BEGIN
    IF :NEW.DATES IS NULL THEN
       :NEW.DATES := X ;
    END IF;
END;



insert into CARS VALUES (55,'OO-00100','Prado 200',9,2017,'BLACK');
insert into CUS VALUES (9,10001,4513,'John','Dylan');
insert into ORDERS (ORDER_ID,OIDCAR,OIDowner,CodeWork) VALUES (111,55,9,898); 

select * from orders



--=== This Trigger inserts new id's to each new row added to cars table ===--
CREATE OR REPLACE TRIGGER TR1
BEFORE INSERT
ON CARS
FOR EACH ROW
BEGIN
SELECT NVL(MAX(IDCAR)+10,10) INTO :NEW.IDCAR FROM CARS;
END;
/



INSERT INTO CARS VALUES (76,'AB-20100','Cayman',10,1999,'grey');
SELECT * FROM cars;
drop trigger tr1





--=== This Trigger checks if new car that added is at lest 2001 manufactured ===-- 
CREATE OR REPLACE TRIGGER NT2
BEFORE INSERT OR UPDATE
ON CARS
FOR EACH ROW
BEGIN
 IF :NEW.P_YEAR < 2000 THEN
        RAISE_APPLICATION_ERROR(-20010,'WE DONT WORK WITH VEHICLES THAT OLD');
    ELSIF :NEW.P_YEAR > 2001 THEN
        DBMS_OUTPUT.PUT_LINE('WE WOULD LIKE TO HELP YOU');
    END IF;   
END;

INSERT INTO CARS (IDCAR,P_YEAR) VALUES (33,1999);






--=== This Trigger fires after new data was added, and gives output as amount of orders ===--
CREATE OR REPLACE TRIGGER NT4
AFTER INSERT
ON ORDERS
DECLARE
    X INT;
BEGIN
    SELECT COUNT(ORDER_ID) INTO X FROM ORDERS;
    DBMS_OUTPUT.PUT_LINE('NEW ORDER/S HAS/HAVE BEEN ADDED. WE HAVE ' || X || ' ORDERS.');
END;


insert into CARS VALUES (55,'OO-00100','Prado 200',9,2017,'BLACK');
insert into CUS VALUES (9,10001,4513,'John','Dylan');
insert into ORDERS (ORDER_ID,OIDCAR,OIDowner,CodeWork) VALUES (111,55,9,898);

