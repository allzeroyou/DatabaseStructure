/* 4장 sql 고급
내장 함수*/

-- 숫자 함수
-- 1. ABS 함수 : 절댓값을 구하는 함수이다.
-- 질의) -78과 +78의 절댓값을 구하시오.
SELECT ABS(-78), ABS(+78);

-- 2. ROUND 함수 : 반올림한 값을 구하는 함수. 
-- 질의) 4.875를 소수 첫째 자리까지 반올림한 값?
SELECT ROUND(4.875, 1);

-- 3. 숫자함수의 연산: 숫자 함수는 입력 값으로 직접 숫자를 입력할 수 있지만 열 이름을 사용할 수도 있다. 또한 여러 함수를 복합적으로 사용 가능.
-- 고객별 평균 주문 금액을 백원 단위로 반올림한 값을 구하시오.


-- 문자함수: CHAR, VARCHAR의 데이터 타입을 대상으로 단일 문자나 문자열을 가공한 결과를 반환
-- REPLACE 함수: 문자열을 치환하는 함수
-- 질의) 도서제목에 야구가 포함된 도서를 농구로 변환한 후 도서 목록을 보이시오.
SELECT bookid, REPLACE(bookname, '야구', '농구'), publisher, price FROM Book;

-- LENGTH, CHAR_LENGTH 함수
-- LENGTH()는 바이트수를 가져오는 함수. 알파벳은 1바이트, 한글은 3바이트임
-- CHAR_LENGTH 함수는 문자의 수를 가져오는 함수로 알파벳과 한글 모두 결과를 1로 반환함. 세는 단위가 바이트가 아닌 '문자'임 (공백도 하나의 문자로 간주)
-- 질의) 굿스포츠에서 출판한 도서의 제목과 제목의 문자 수, 바이트 수를 보이시오
SELECT bookname, CHAR_LENGTH(bookname) '문자 수', LENGTH(bookname) '바이트 수'
FROM Book
WHERE publisher = '굿스포츠';

-- SUBSTR 함수: 문자열 중 특정 위치에서 시작해 지정한 길이 만큼의 문자열 반환
-- 마당서점의 고객 중에서 같은 성을 가진 사람이 몇명이나 되는지 성별 인원수를 구하시오.

-- 날짜, 시간 함수
-- 날짜형 데이터는 '-'와 '+'을 사용해 원하는 날짜로부터 이전(-)과 이후(+) 계산 가능
-- 예를 들어 날짜형 데이터 mydate 값이 '2019년 7월 1일'이라면 5일 전은 'INTERVAL -5 DAY', 5일 후는 'INTERVAL 5 DAY'이다.
-- SELECT ADDDATE('2019-07-01', INTERVAL -5 DAY) AFTER5, ADDDATE('2019-07-01', INTERVAL 5 DAY) AFTER5;

-- 질의) 마당서점은 주문일로부터 10일 후 매출 확정. 각 주문의 확정일자를 구하시오.
SELECT orderid, custid, bookid, saleprice, orderdate, ADDDATE(orderdate, INTERVAL 10 DAY) '주문확정일' FROM Orders;

-- STR_TO_DATE 함수, DATE_FORMAT 함수
-- STR_TO_DATE는 char(문자열)로 저장된 날짜를 DATE 형으로 변환하는 함수
-- STR_FORMAT는 날짜형을 문자형으로 저장.

-- 마당서점이 2014년 7월 7일에 주문받은 도서의 주문번호, 주문일, 고객번호, 도서번호를 모두 보이시오.
SELECT orderid '주문번호', orderdate '주문일', custid '고객번호', bookid '도서번호'
FROM Orders
WHERE orderdate = DATE_FORMAT('20140707', '%Y-%m-%d');

-- SYSDATE 함수: Mysql 데이터베이스에 설정된 현재 날짜와 시간 반환
SELECT SYSDATE(), date_format(SYSDATE(), '%Y-%m-%d');

-- NULL 값 처리
-- NULL 값이란 아직 지정되지 않은 값. 비교 연산자로 비교 불가.

-- IFNULL 함수: null 값을 다른 값으로 대치해 연산하거나 다른 값으로 출력하는 함수
-- 이름, 전화번호가 포함된 고객목록을 보이시오. 단 전화번호가 없는 고객은 '연락처없음'을 표시
SELECT name '이름', IFNULL(phone, '연락처없음') '전화번호' FROM Customer;

-- 행번호 출력: mysql에서 변수를 사용해 처리하는 방법있음. 변수는 이름앞에 @ 기호를 붙이며 치환문에는 SET과 := 기호 사용
-- 고객목록에서 고객번호, 이름, 전화번호를 앞의 두명만 보이시오.
SET @cnt:=0;

SELECT (@cnt := @cnt+1) '순번', custid, name, phone FROM Customer
WHERE @cnt<2;

-- 부속질의
-- 1. 스칼라 부속질의(SELECT 부속질의)
-- 부속질의의 결과 값을 단일 행, 단일 열의 스칼라 값으로 반환. 만약 결과 값이 다중 행, 열이라면 에러 출력
-- 주질의, 부속질의 관계는 상관, 비상관 모두 가능

-- 질의) 마당서점의 고객별 판매액을 보이시오(고객이름과 판매액 출력)
SELECT (SELECT name FROM Customer cs WHERE cs.custid=od.custid) '고객이름', SUM(saleprice) 'total'
FROM Orders od
GROUP BY od.custid;

-- Orders 테이블에 각 주문에 맞는 도서이름 입력
UPDATE Orders
SET bname=(SELECT bookname FROM Book b WHERE Orders.bookid=b.bookid);

SELECT * FROM Orders;

-- 인라인 뷰(FROM 부속질의)
-- 인라인 뷰는 FROM 절에서 사용되는 부속질의. 뷰는 기존 테이블로부터 일시적으로 만들어진 가상의 테이블
-- FROM 절에 테이블 이름 대신 인라인 뷰 부속질의를 사용하면 보통의 테이블과 같은 형태로 사용 가능.

-- 가상 테이블인 뷰 형태로 제공되기 때문에 상관 부속질의는 불가. 상관 부속질의란 주질의의 특정 컬럼 값을 부속질의가 상속받아 사용하는 형태.
-- 질의) 고객번호가 2 이하인 고객의 판매액을 보이시오(고객이름과 고객별 판매액 출력)
SELECT cs.name '고객이름', SUM(od.saleprice) '판매액'
From (SELECT custid, name FROM Customer WHERE custid <= 2) cs, Orders od
WHERE cs.custid = od.custid
GROUP BY cs.name;

-- 중첩질의 (WHERE 부속질의)
-- nested query는 WHERE 절에서 사용되는 부속질의이다. 보통 데이터를 선택하는 조건 혹은 술어와 같이 사용되는 where 절이라서 중첩질의를 술어 부속질의라고도 부른다.
-- 중첩질의는 주질의에 사용된 자료 집합의 조건을 WHERE 절에 서술한다. 
-- 주질의의 자료 집합에서 한 행씩 가져와 부속질의를 수행, 연산 결과에 따라 WHERE 절의 조건이 참인지 거짓인지 확인해 참일 경우 주질의의 해당 행을 출력.

-- 질의) 평균 주문 금액 이하의 주문에 대한 주문번호와 금액을 보이시오.
SELECT orderid, saleprice FROM Orders WHERE saleprice <= (SELECT AVG(saleprice) FROM Orders); 

-- 질의) 각 고객의 평균 주문금액보다 큰 금액의 주문 내역에 대해 주문번호, 고객번호, 금액 보이시오.
SELECT orderid, custid, saleprice FROM Orders WHERE saleprice > (SELECT AVG(saleprice) FROM Orders);



