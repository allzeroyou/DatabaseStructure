-- 3장 연습문제
# 1 마당서점의 고객이 요구하는 다음 질문에 대한 sql 작성
# 1)
USE madang;

/*
SELECT bookname
FROM Book
WHERE 'bookid' = 1;
*/
-- 위의 쿼리문의 결과 아무것도 나오지 않음 => <WHERE 컬럼명>할때 컬럼명에는 따옴표를 붙이지 말 것!

SELECT bookname
FROM Book
WHERE bookid = 1;

# 2)
SELECT bookname
FROM Book
WHERE price >= 20000;

# 3)
SELECT SUM(saleprice) '총 구매액'
FROM Orders
WHERE Orders.custid = 1
GROUP BY Orders.custid;

 # 4)
SELECT COUNT(bookid) '총 도서의 수'
FROM Orders
WHERE Orders.custid = 1
GROUP BY Orders.custid;

# 5)
SELECT COUNT(DISTINCT Book.publisher)
FROM Orders, Customer, Book
WHERE Orders.custid = Customer.custid AND Orders.bookid = Book.bookid AND Customer.name = '박지성' 
GROUP BY Orders.custid;

# 6)
SELECT bookname, saleprice, (price-saleprice) '정가-판매가격'
FROM Orders o, Customer c, Book b
WHERE o.custid=c.custid AND o.bookid=b.bookid AND c.name='박지성';

# 7)
SELECT bookname '박지성이 구매안한 도서'
FROM Book
WHERE bookname
NOT IN (SELECT bookname
FROM Customer c, Orders o, Book b
WHERE o.custid=c.custid AND o.bookid=b.bookid AND c.name='박지성');


# 2. 마당서점의 운영자와 경영자가 요구하는 다음 질문에 대한 sql문 작성

# 2-1)
SELECT COUNT(bookid)
FROM Book;

# 2-2)
SELECT COUNT(DISTINCT publisher)
FROM Book;

# 2-3)
SELECT name, address
FROM Customer;

# 2-4)
SELECT orderid 
FROM Orders
WHERE orderdate >= '2014-07-04' AND orderdate <= '2014-07-07';

# 2-5)
SELECT orderid
FROM Orders
WHERE orderdate < '2014-07-04' OR orderdate > '2014-07-07';

# 2-6)
SELECT name, address
FROM Customer
WHERE name LIKE '김%';

# 2-7)
SELECT name, address
FROM Customer
WHERE name LIKE '김%' AND name LIKE '%아';

# 2-8)
SELECT name '주문하지 않은 고객'
FROM Customer
WHERE name
NOT IN
(SELECT name
FROM Orders o, Customer c
WHERE o.custid=c.custid);

# 2-9)
SELECT SUM(saleprice) '주문 총액', ROUND(AVG(saleprice),-1) '주문 평균 금액'
FROM Orders
WHERE saleprice;

# 2-10)
SELECT name, SUM(saleprice)
FROM Orders o, Customer c
WHERE c.custid = o.custid
GROUP BY o.custid;

# 2-11)
SELECT name, bookname
FROM Orders o, Customer c, Book b
WHERE c.custid=o.custid AND o.bookid=b.bookid;
-- 고객별로는 어떻게 보여주지..?

# 2-12)
SELECT MAX(price-saleprice) '가격-판매가격 차이가 가장 큼'
FROM Book b, Orders o, Customer c
WHERE o.custid=c.custid AND o.bookid=b.bookid;

# 2-13)
SELECT name, ROUND(AVG(saleprice),-1) '도서 판매액 평균'
FROM Orders o, Customer c
WHERE o.custid=c.custid
GROUP BY o.custid
HAVING AVG(saleprice) > (SELECT AVG(saleprice) FROM Orders); 