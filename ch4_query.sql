/* 4장 쿼리문 짜기*/
-- view까지


# 4-1
SELECT ABS(-78), ABS(+78);

# 4-2번
SELECT ROUND(4.875, 1);

# 4-3 고객별(이렇게 ~~ 별 은 GROUP BY를 하자)
SELECT custid '고객번호', 
ROUND(AVG(saleprice), -2) '평균주문금액'
FROM Orders
GROUP BY custid;

# 4-4 도서 제목에 야구가 포함된 도서를 농구로 변경한 후 도서 목록
SELECT bookid, REPLACE(bookname, '야구', '농구') AS bookname, publisher, price
FROM Book;
-- mysql 실행순서
/*
1. FROM-필요한 테이블 가져온다
2. WHERE-가져온 테이블에서 조건에 맞춰 행 추출
3. GROUP BY-WHERE로 추린 조건을 그룹 짓는다
4. HAVING-GROUP BY로 짠 그룹에 조건을 건다.
5. SELECT-아래에서 완료된 데이터에 SELECT문을  실행해 원하는 컬럼만 남는다.
6. DISTINCT-중복된 행 제거
7. ORDER BY-만들어진 데이터를 정렬한다.(오름차순/내림차순)
*/
# 4-5 굿스포츠에서 출판한 도서의 제목과 제목의 글자수?
SELECT bookname, CHAR_LENGTH(bookname)
FROM Book
WHERE publisher='굿스포츠';
-- 글자수 세기
/*
한글은 CHAR_LENGTH(컬럼명)으로 한다.
LENGTH는 바이트 수(한글은 2~3바이트)
*/

# 4-6 마당서점의 고객 중 같은 성을 가진 사람이 몇명이나 되는 지 '성' 별 인원수?
SELECT substring(name, 1, 1) '성', count(*) '인원수'
FROM Customer
GROUP BY substring(name, 1, 1);

# 4-7 마당서점은 주문일로부터 10일 후 매출 확정. 각 주문의 확정일자?
SELECT *, DATE_add(orderdate, INTERVAL 10 DAY) AS '확정일자'
FROM Orders;

-- Mysql에서 날짜를 더하고 뺄때 쓰는 함수
/*
DATE_ADD(date, INTERVAL 숫자 계산형식)
*/

# 4-8 마당서점이 2014년 7월 7일에 주문받은 도서의 주문번호, 주문일, 고객번호, 도서번호를 모두 보이시오. 단 주문일은 %Y-%m-%d 형태로 표시
SELECT orderid, orderdate, custid, bookid 
FROM Orders
WHERE orderdate=DATE_FORMAT('2014-07-07', '%Y-%m-%d');

# 4-9 DBMS 서버에 설정된 현재 날짜와 시간, 요일?
SELECT case WEEKDAY(DATE_FORMAT(SYSDATE(), '%Y/%m/%d %H:%i:%s'))
	when '0' then '월요일'
    when '1' then '화요일'
    when '2' then '수요일'
    when '3' then '목요일'
    when '4' then '금요일'
    when '5' then '토요일'
    when '6' then '일요일'
    end as dayofweek;
    
# 4-10 이름, 전화번호가 포함된 고객 목록을 보이시오. 단, 전화번호가 없는 고객은 '연락처없음'으로 표시
SELECT name '이름', IFNULL(phone, '연락처없음') '연락처'
FROM Customer;

# 4-11 고객목록에서 고객번호, 이름, 전화번호를 앞의 두명만 보이시오.
SET @head := 0;

SELECT @head :=@head+1 '순번', custid, name, phone 
FROM Customer
WHERE @head < 2;

# 4-12 마당서점의 고객별 판매액? (고객이름, 고객별 판매액)
SELECT name,  SUM(saleprice)  '고객별 판매액'
FROM Customer, Orders
WHERE Customer.custid = Orders.custid
GROUP BY Orders.custid;

-- 왜 WHERE를 쓸까?
-- FROM으로 가져온 정보는 너무 넓어 범위를 한정짓기 위해!
-- 위처럼 해도 되나, 사실 결과가 '하나의 행'인  스칼라 값이라 스칼라 부속질의 하는게 더 좋음

SELECT (	
	SELECT name
    FROM Customer
    WHERE Customer.custid=Orders.custid
) '이름' ,  SUM(saleprice) '판매액'
FROM Orders
GROUP BY Orders.custid;
-- 부속질의할때 주질의와 부속질의와의 관계를 잘 생각해서, 할 것.
-- 무엇을 주질의로 두고, 무엇을 부속질의로 두면 쿼리가 깔쌈하게 나올지..

# 4-13 Orders 테이블에 각 주문에 맞는 도서이름 입력
SELECT *, 
(
	SELECT bookname
    FROM Book
    WHERE Orders.bookid=Book.bookid
) '도서이름'
FROM Orders;

# 4-14 (고객번호가 2 이하인 고객)의 판매액을 보이시오(고객이름, 고객별 판매액 출력)
       # 요 부분이 from 부속질의 부분!
SELECT (
	SELECT name
    FROM Customer
    WHERE Orders.custid=Customer.custid
) '이름', 
SUM(saleprice) '판매액'
FROM Orders
WHERE Orders.custid<=2
GROUP BY Orders.custid;

-- 위를 FROM 부속질의인 인라인 뷰로 해보자

SELECT cu.name, sum(saleprice)
FROM (
	SELECT custid, name
    FROM Customer c
    WHERE custid <= 2
) cu , Orders o
WHERE cu.custid=o.custid
GROUP BY o.custid;

/*
	SELECT custid, name
    FROM Customer c
    WHERE custid <= 2
이렇게 인라인 뷰로 들어갈 걸 미리 실행해보고 result보고 주질의에서 필요한 내용이 맞는지 확인해보는게 좋을 거 같다*/

# 4-15 평균 주문금액 이하의 주문에 대해 주문번호와 금액?
SELECT orderid, saleprice '평균주문금액 이하'
FROM Orders
WHERE saleprice <= 
(
	SELECT AVG(saleprice)
    FROM Orders o
);
--------------------------------------------------------
# 중요
# 4-16 ('각 고객'의 평균 주문금액)보다 '큰' 금액의 주문내역에 대해 /주문번호, 고객번호, 금액/을 보이시오
# 서브쿼리먼저 시행되므로! 비교의 대상은 where절의 서브쿼리!

SELECT orderid, custid, saleprice
FROM Orders o
WHERE saleprice > 
(
	SELECT AVG(od.saleprice)
    FROM Orders od
    WHERE o.custid=od.custid
);

# 4-17 -대한민국에 거주하는 고객-에서 -판매한 도서의 총 판매액-?
SELECT SUM(saleprice)
FROM Customer c, Orders o
WHERE c.custid=o.custid AND c.address LIKE "대한민국%";
-- 위 계산결과를 아래처럼 확인해봐도 좋을 거 같다.
SELECT SUM(8000+6000+12000+7000+13000);
-- 위 질의를 where 부속질의로 구하기
SELECT sum(saleprice)
FROM Orders o
WHERE (
	SELECT o.custid
    FROM Customer c
    WHERE c.custid=o.custid AND c.address LIKE "대한민국%"
);

# 4-18 (3번 고객이 주문한 도서의 최고 금액)보다 <더 비싼 도서>를 구입한 주문의 '주문번호'와 '금액'?
SELECT orderid, saleprice
FROM Orders o
WHERE saleprice > (	SELECT MAX(o.saleprice)
	FROM Customer c, Orders o
	WHERE o.custid=c.custid AND c.custid='3');

# 4-19 EXISTS 연산자로 (대한민국에 거주하는 고객)에게 '판매한 도서'의 '총 판매액'?
SELECT SUM(saleprice)
FROM Orders o
WHERE EXISTS (
	SELECT *
    FROM Customer c
    WHERE address LIKE "대한민국%" AND o.custid=c.custid
);
/*
# 뷰
하나 이상의 테이블을 합해 만든 가상의 테이블
# 뷰의 장점
1. 편리성 및 재사용성: 자주 사용되는 join등으로 복잡한 질의를 뷰로 미리 정의해 놓을 수 있음
2. 보안성: 사용자별로 필요한 데이터만 선별해 보여줄 수 있고, 중요한 질의의 경우 질의 내용을 암호화할 수 있음.
3. 독립성: 미리 정의된 뷰를 일반 테이블처럼 사용할 수 있기 때문에 편리하고, 사용자가 필요한 정보만 요구에 맞게 가공해 뷰로 만들어 쓸  수 있음.
# 뷰의 특징
원본 데이터 값에 따라 같이 변함
독립적인 인덱스 생성이 어려움
삽입, 삭제, 갱신 연산에 많은 제약이 따름
*/
use madang;
# 4-20 주소에 '대한민국'을 포함하는 고객들로 구성된 뷰를 만들고 조회. 뷰의 이름은 vw_Customer
CREATE VIEW vw_Customer 
AS
SELECT *
FROM Customer
WHERE address LIKE '대한민국%';

SELECT * FROM vw_Customer;

# 4-21 Orders 테이블에 고객이름과 도서이름을 바로 확인할  수 있즌 뷰를 생성, '김연아' 고객이 구입한 도서의 주문번호, 도서이름, 주문액?
# 뷰 예시!
-- 뷰는 테이블위에 띄운다고 보면 되나?, Orders 테이블 위에 view가 떠있는 모양을 상상함.
-- 따라서 Orders 기본컬럼 + view로 생성한 컬럼
CREATE VIEW test_view(orderid, custid, name, bookid, bookname, saleprice, orderdate)
AS
SELECT o.orderid, c.custid, c.name, b.bookid, b.bookname, o.saleprice, o.orderdate
FROM Orders o, Customer c, Book b
WHERE c.custid=o.custid AND b.bookid=o.bookid;

SELECT * FROM test_view;

# 4-22 생성했던 뷰 vw_Customer는 주소가 대한민국인 고객만 보여줌.
# 이 뷰를 영국을 주소로 가진 고객으로 변경 -> phone 속성은 필요없으므르 포함x
CREATE OR REPLACE VIEW vw_Customer (custid, name, address)
AS 
SELECT custid, name, address
FROM customer
WHERE address LIKE '영국%';

SELECT * FROM  vw_Customer;

# 4-23 앞서 생성한 뷰 삭제
DROP VIEW vw_Customer;