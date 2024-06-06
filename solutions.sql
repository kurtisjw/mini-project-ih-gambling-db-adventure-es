USE IRONHACK_GAMBLING;


/*
Pregunta 01: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre Título, Nombre y Apellido y Fecha de Nacimiento para cada uno de los clientes. 
No necesitarás hacer nada en Excel para esta.
*/

SELECT
	Title,
    FirstName,
    LastName,
    DateOfBirth
FROM
    customer;

/*
Pregunta 02: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre el número de clientes en cada grupo de clientes (Bronce, Plata y Oro). Puedo ver visualmente que hay 4 Bronce, 3 Plata y 3 Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?
*/

SELECT CustomerGroup, COUNT(*) AS Number_of_Customers
FROM customer
GROUP BY CustomerGroup;

/*
Pregunta 03: El gerente de CRM me ha pedido que proporcione una lista completa de todos los datos para esos clientes en la tabla de clientes pero necesito añadir el código de moneda de cada jugador para que pueda enviar la oferta correcta en la moneda correcta. Nota que el código de moneda no existe en la tabla de clientes sino en la tabla de cuentas. Por favor, escribe el SQL que facilitaría esto. ¿Cómo lo haría en Excel si tuviera un conjunto de datos mucho más grande?
*/

SELECT customer.*, account.currencyCode
FROM customer
INNER JOIN account ON customer.CustID = account.CustID;

/*
Pregunta 04: Ahora necesito proporcionar a un gerente de producto un informe resumen que muestre, por producto y por día, cuánto dinero se ha apostado en un producto particular. TEN EN CUENTA que las transacciones están almacenadas en la tabla de apuestas y hay un código de producto en esa tabla que se requiere buscar (classid & categoryid) para determinar a qué familia de productos pertenece esto. Por favor, escribe el SQL que proporcionaría el informe. Si imaginas que esto fue un conjunto de datos mucho más grande en Excel, ¿cómo proporcionarías este informe en Excel?
*/

SELECT
	betting.BetDate, product.product,
    SUM(betting.Bet_Amt) AS total_amount_bet
    FROM 
		betting
    INNER JOIN 
		product
    ON
		betting.ClassId = product.ClassID AND betting.CATEGORYID = product.CATEGORYID
	GROUP BY
		betting.BetDate, product.product
	ORDER BY
		betting.BetDate, product.product;
        
/*
Pregunta 05: Acabas de proporcionar el informe de la pregunta 4 al gerente de producto, ahora él me ha enviado un correo electrónico y quiere que se cambie. ¿Puedes por favor modificar el informe resumen para que solo resuma las transacciones que ocurrieron el 1 de noviembre o después y solo quiere ver transacciones de Sportsbook. Nuevamente, por favor escribe el SQL abajo que hará esto. Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?
*/

SELECT
	betting.BetDate, product.product,
    SUM(betting.Bet_Amt) AS total_amount_bet
    FROM 
		betting
    INNER JOIN 
		product
    ON
		betting.ClassId = product.ClassID AND betting.CATEGORYID = product.CATEGORYID
	AND
		betting.BetDate >= '2012-11-01'
	WHERE
		product.product = 'Sportsbook'
	GROUP BY
		betting.BetDate, product.product
	ORDER BY
		betting.BetDate, product.product;
        
/*
Pregunta 06: Como suele suceder, el gerente de producto ha mostrado su nuevo informe a su director y ahora él también quiere una versión diferente de este informe. Esta vez, quiere todos los productos pero divididos por el código de moneda y el grupo de clientes del cliente, en lugar de por día y producto. También le gustaría solo transacciones que ocurrieron después del 1 de diciembre. Por favor, escribe el código SQL que hará esto.
*/

SELECT
		betting.product,
		account.CurrencyCode,
	customer.CustomerGroup,
    SUM(betting.Bet_Amt) AS total_amount_bet
FROM
	betting
JOIN
	account
ON
	betting.AccountNo = account.AccountNo
JOIN
	customer
ON
    account.CustId = customer.CustId
	
	GROUP BY
		account.CurrencyCode, customer.CustomerGroup, betting.product
	ORDER BY
		betting.product, account.CurrencyCode, customer.CustomerGroup;

/*
Pregunta 07: Nuestro equipo VIP ha pedido ver un informe de todos jugadores independientemente de si han hecho algo en el marco de tiempo completo o no. 
En nuestro ejemplo, es posible que no todos los jugadores hayan estado activos. 
Por favor, escribe una consulta SQL que muestre a todos los jugadores Título, Nombre y Apellido y un resumen de su cantidad de apuesta para el período completo de noviembre.
*/

SELECT c.Title, c.FirstName, c.LastName, SUM(b.Bet_Amt) total_bet_amount
FROM customer c
JOIN account a 	ON c.CustID = a.CustID
JOIN betting b on a.AccountNo = b.AccountNo and b.BetDate BETWEEN '12-11-01' and '12-11-30'
GROUP BY C.Title,c.FirstName, c.LastName
ORDER BY c.LastName desc;

/*
Pregunta 08: Nuestros equipos de marketing y CRM quieren medir el número de jugadores que juegan más de un producto. 
¿Puedes por favor escribir 2 consultas, una que muestre el número de productos por jugador y otra que muestre jugadores que juegan tanto en Sportsbook como en Vegas?
*/

-- 1

SELECT c.Title, c.FirstName, c.LastName, count(distinct p.product) AS Number_of_Products
FROM customer c
JOIN account a ON c.CustID = a.CustID
JOIN betting b ON a.accountno = b.accountno
JOIN product p ON b.classID = p.classID and b.categoryID = p.categoryID
WHERE p.product IS NOT NULL
GROUP BY c.title, c.firstname, c.lastname
ORDER by c.lastname desc;

-- 2

SELECT 
    c.Title, c.FirstName, c.LastName
FROM
    customer c
        JOIN
    account a ON c.CustID = a.CustID
        JOIN
    betting b1 ON a.accountno = b1.accountno
        JOIN
    product p1 ON b1.classID = p1.classID
        AND b1.categoryID = p1.categoryID
        JOIN
    betting b2 ON a.accountno = b2.accountno
        JOIN
    product p2 ON b2.classID = p2.classID
        AND b2.categoryID = p2.categoryID
WHERE
    p1.product = 'Sportsbook'
        AND p2.product = 'Vegas'
GROUP BY c.title , c.firstname , c.lastname
ORDER BY c.lastname DESC;


/*
Pregunta 09: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo juegan un producto, 
por favor escribe código SQL que muestre a los jugadores que solo juegan en sportsbook, usa bet_amt > 0 como la clave. 
Muestra cada jugador y la suma de sus apuestas para ambos productos.
*/

SELECT c.Title, c.FirstName, c.LastName, SUM(b.bet_Amt) AS Total_Bet_Amount
FROM customer c
JOIN account a ON c.CustID = a.CustID
JOIN betting b ON a.accountno = b.accountno
JOIN product p ON b.classID = p.classID and b.categoryID = p.categoryID
WHERE p.product = 'Sportsbook' AND b.bet_Amt >= 0
AND NOT EXISTS (
        SELECT 1
        FROM betting b2
        JOIN product p2 ON b2.ClassID = p2.ClassID AND b2.CategoryID = p2.CategoryID
        WHERE b2.AccountNo = b.AccountNo
        AND p2.product <> 'Sportsbook'
        AND b2.Bet_Amt > 0
    )
GROUP BY 
    c.Title, c.FirstName, c.LastName;

/*
Pregunta 10: La última pregunta requiere que calculemos y determinemos el producto favorito de un jugador. 
Esto se puede determinar por la mayor cantidad de dinero apostado. Por favor, escribe una consulta que muestre el producto favorito de cada jugador
*/

SELECT c.Title, c.FirstName, c.LastName, p.product, sum(b.bet_Amt) AS Total_Bet_Amount,
row_number() over (partition by c.FirstName, c.LastName order by sum(b.bet_amt) desc) AS rn
from customer c
inner join account a on (c.CustId = a.CustId)
inner join betting b on (a.AccountNo = b.AccountNo)
inner join product p on (p.ClassId = b.ClassId and p.CategoryId = b.CategoryId)
group by c.Title, c.FirstName, C. LastName, p.product
order by c.LastName asc;
