CREATE VIEW view_product_info AS
SELECT 
p.id_product, 
p.name_product, 
p.price, 
c.name_category,
s.name_supplier
FROM product p
JOIN category c ON p.category_id = c.id_category
JOIN supplier s ON p.supplier_id = s.id_supplier;

SELECT * FROM view_product_info;

CREATE VIEW view_orders_customers AS
SELECT
o.id_order,
o.order_date,
o.total,
p.name_person AS customer_name
FROM orders o
JOIN customer c ON o.customer_id = c.id_customer
JOIN person p ON c.person_id = p.id_person;

SELECT * FROM view_orders_customers;

CREATE VIEW view_invoice_payments AS
SELECT
    i.id_invoice,
    i.invoice_date,
    i.total,
    mp.name AS payment_method
FROM invoice i
JOIN payment p ON i.id_invoice = p.invoice_id
JOIN method_payment mp ON p.method_payment_id = mp.id_method_payment;

SELECT * FROM view_invoice_payments;