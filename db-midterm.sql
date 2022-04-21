# 2-2 오늘날짜를 알아오는 내장함수를 사용하여 본인의 ‘가입날짜’ 정보를 수정하시오. (연-월-일 형식
# 에 맞게 warning이 발생하지 않도록 작성하시오) 
UPDATE Customer SET joindate = DATE_FORMAT(SYSDATE(), '%Y-%m-%d') WHERE custid = 6;

# DBMS 서버에 설정된 현재 날짜와 시간
SELECT case WEEKDAY(DATE_FORMAT(SYSDATE(), '%Y/%m/%d %H:%i:%s'))
	when '0' then '월요일'
    when '1' then '화요일'
    when '2' then '수요일'
    when '3' then '목요일'
    when '4' then '금요일'
    when '5' then '토요일'
    when '6' then '일요일'
    end as dayofweek;


# 2-3 ) 주문정보가 없는 고객 ID와 이름을 검색하시오
SELECT name, custid from customer where custid not in (select custid from orders);

        
# 2-4) 축구관련 서적 중 정가(price)가 10,000원 이상인 도서의 모든 정보를 검색하시오
select * from book where price >= 10000 AND bookname LIKE '%축구%' ;

# 2-5) 판매가격(saleprice)이 20,000원 이상인 도서를 구매한 고객의 이름을 검색하시오.(JOIN 2점, 인라인 뷰 사용 시 5점)
SELECT cu.name
FROM (
	SELECT custid, name
    FROM Customer c
) cu , Orders o
WHERE cu.custid=o.custid AND o.saleprice >= 20000
GROUP BY o.custid;

#  2-6) 모든 도서의 평균 판매가격(saleprice) 보다 평균 구매액(saleprice)이 높은 고객의 이름을 검색하시오.
SELECT orderid, custid, saleprice
FROM Orders o
WHERE saleprice > 
(
	SELECT AVG(od.saleprice)
    FROM Orders od
);

# 2-7)(2권 이상 주문한 고객에 대하여) 고객별 id, 이름, 총 구입금액을 검색하고 총 주문금액이 많은 순서로 내림차순 정렬하는 쿼리를 작성하시오.

SELECT c.custid, c.name, SUM(saleprice), COUNT(*) '총 구매 권수'
FROM Customer c, Orders o
WHERE c.custid=o.custid
GROUP BY o.custid
HAVING count(*) >= 2
ORDER BY SUM(saleprice) DESC;

/* SELECT c.custid, c.name, SUM(saleprice)
FROM Customer c, Orders o
WHERE c.custid=o.custid AND (
	SELECT COUNT(*)
	FROM Orders od
    GROUP BY od.custid
	HAVING count(*) >= 2
)
ORDER BY SUM(saleprice) DESC;
*/
    
    
# 2-8) 정가(price)가 10,000원이 이하인 도서를 구매한 이력이 있는 고객의 이름을 검색하시오.(join 2점, 부속질의 5점)
SELECT (	
	SELECT name
    FROM Customer
    WHERE Customer.custid=Orders.custid
) '이름' 
FROM Orders, Book b
WHERE b.price <= 10000
GROUP BY Orders.custid;

# 2-9) ) Order 테이블에서 1번 고객이 주문한 도서의 도서명과 출판사를 검색하시오. 
# (Join 연산 2점, IN 연산자 사용 3점, 상관부속질의을 이용한 EXISTS 사용 5점)

SELECT bookname, publisher
FROM Orders o, Book b, customer c
WHERE c.custid=o.custid AND b.bookid=o.bookid AND o.custid=1;

# 2-10) 주문번호, 고객ID, 고객이름, 도서이름, 구매가격(saleprice), 출판사을 확인할 수 있는
# “vw_order_info” view를 생성하시오.
CREATE VIEW vw_order_info(orderid, custid, name, bookname, saleprice, publisher)
AS
SELECT o.orderid, c.custid, c.name, b.bookname, o.saleprice, b.publisher
FROM Orders o, Customer c, Book b
WHERE c.custid=o.custid AND b.bookid=o.bookid;

SELECT * FROM vw_order_info;

# 2-11) “vw_order_info” view에서 고객별 주문 수와 총 구매가격을 검색하시오.
SELECT COUNT(orderid), SUM(saleprice)
FROM vw_order_info
GROUP BY custid;