DO $$
DECLARE
    -- PARAMETER
    type_document_ids UUID[];
    person_ids UUID[];
    file_ids UUID[];

    -- SECURITY
    user_ids UUID[];
    role_ids UUID[];
    module_ids UUID[];
    view_ids UUID[];

    -- INVENTORY
    category_ids UUID[];
    supplier_ids UUID[];
    product_ids UUID[];

    -- SALES
    customer_ids UUID[];
    order_ids UUID[];
    order_item_ids UUID[];

    -- BILLING
    method_payment_ids UUID[];
    invoice_ids UUID[];
    invoice_item_ids UUID[];
    payment_ids UUID[];

BEGIN

-- TYPE DOCUMENT
WITH ins AS (
INSERT INTO type_document(name) VALUES
('Cédula de ciudadanía'),
('Tarjeta de identidad'),
('Cédula de extranjería'),
('Pasaporte'),
('Registro civil'),
('NIT'),
('Documento diplomático'),
('Permiso especial'),
('Documento extranjero'),
('Otro')
RETURNING id_type_document
)
SELECT array_agg(id_type_document) INTO type_document_ids FROM ins;

-- PERSON
WITH ins AS (
INSERT INTO person(name_person,email,type_document_id) VALUES
('Juan Perez','juan@email.com',type_document_ids[1]),
('Ana Gomez','ana@email.com',type_document_ids[1]),
('Carlos Ruiz','carlos@email.com',type_document_ids[1]),
('Laura Diaz','laura@email.com',type_document_ids[1]),
('Pedro Torres','pedro@email.com',type_document_ids[1]),
('Sofia Vargas','sofia@email.com',type_document_ids[1]),
('Luis Herrera','luis@email.com',type_document_ids[1]),
('Maria Castro','maria@email.com',type_document_ids[1]),
('Jorge Rojas','jorge@email.com',type_document_ids[1]),
('Paula Leon','paula@email.com',type_document_ids[1])
RETURNING id_person
)
SELECT array_agg(id_person) INTO person_ids FROM ins;

-- FILE
WITH ins AS (
INSERT INTO file(file_name,file_type,person_id) VALUES
('doc1.pdf','pdf',person_ids[1]),
('doc2.pdf','pdf',person_ids[2]),
('doc3.pdf','pdf',person_ids[3]),
('doc4.pdf','pdf',person_ids[4]),
('doc5.pdf','pdf',person_ids[5]),
('doc6.pdf','pdf',person_ids[6]),
('doc7.pdf','pdf',person_ids[7]),
('doc8.pdf','pdf',person_ids[8]),
('doc9.pdf','pdf',person_ids[9]),
('doc10.pdf','pdf',person_ids[10])
RETURNING id_file
)
SELECT array_agg(id_file) INTO file_ids FROM ins;

-- ROLE
WITH ins AS (
INSERT INTO role(name,description) VALUES
('Administrador','control total'),
('Cajero','gestiona ventas'),
('Vendedor','registra pedidos'),
('Inventario','control stock'),
('Supervisor','supervisa'),
('Gerente','administración'),
('Contador','finanzas'),
('Soporte','soporte técnico'),
('Cliente','usuario cliente'),
('Invitado','acceso limitado')
RETURNING id_role
)
SELECT array_agg(id_role) INTO role_ids FROM ins;

-- MODULE
WITH ins AS (
INSERT INTO module(name) VALUES
('Usuarios'),
('Roles'),
('Productos'),
('Inventario'),
('Pedidos'),
('Facturas'),
('Pagos'),
('Reportes'),
('Clientes'),
('Configuracion')
RETURNING id_module
)
SELECT array_agg(id_module) INTO module_ids FROM ins;

-- VIEW
WITH ins AS (
INSERT INTO view(name_view,route,module_id) VALUES
('Usuarios','/users',module_ids[1]),
('Roles','/roles',module_ids[2]),
('Productos','/products',module_ids[3]),
('Inventario','/inventory',module_ids[4]),
('Pedidos','/orders',module_ids[5]),
('Facturas','/invoice',module_ids[6]),
('Pagos','/payment',module_ids[7]),
('Reportes','/reports',module_ids[8]),
('Clientes','/customers',module_ids[9]),
('Config','/config',module_ids[10])
RETURNING id_view
)
SELECT array_agg(id_view) INTO view_ids FROM ins;

-- USERS
WITH ins AS (
INSERT INTO users(person_id,username,password) VALUES
(person_ids[1],'user1','1234'),
(person_ids[2],'user2','12345'),
(person_ids[3],'user3','123456'),
(person_ids[4],'user4','1234567'),
(person_ids[5],'user5','12345678'),
(person_ids[6],'user6','87654321'),
(person_ids[7],'user7','7654321'),
(person_ids[8],'user8','654321'),
(person_ids[9],'user9','54321'),
(person_ids[10],'user10','4321')
RETURNING id_user
)
SELECT array_agg(id_user) INTO user_ids FROM ins;

-- USER ROLE
INSERT INTO user_role(user_id,role_id)
SELECT user_ids[i],role_ids[1]
FROM generate_series(1,10) i;

-- ROLE MODULE
INSERT INTO role_module(role_id,module_id)
SELECT role_ids[1],module_ids[i]
FROM generate_series(1,10) i;

-- MODULE VIEW
INSERT INTO module_view(module_id,view_id)
SELECT module_ids[i],view_ids[i]
FROM generate_series(1,10) i;

-- CATEGORY
WITH ins AS (
INSERT INTO category(name_category,description) VALUES
('Bebidas','bebidas calientes'),
('Snacks','comidas rapidas'),
('Postres','dulces'),
('Panaderia','productos pan'),
('Cafe','variedades cafe'),
('Jugos','jugos naturales'),
('Gaseosas','bebidas gaseosas'),
('Sandwich','sandwich'),
('Arepas','arepas'),
('Otros','varios')
RETURNING id_category
)
SELECT array_agg(id_category) INTO category_ids FROM ins;

-- SUPPLIER
WITH ins AS (
INSERT INTO supplier(name_supplier,phone,person_id) VALUES
('Proveedor1','3001111111',person_ids[1]),
('Proveedor2','3002222222',person_ids[2]),
('Proveedor3','3003333333',person_ids[3]),
('Proveedor4','3004444444',person_ids[4]),
('Proveedor5','3005555555',person_ids[5]),
('Proveedor6','3006666666',person_ids[6]),
('Proveedor7','3007777777',person_ids[7]),
('Proveedor8','3008888888',person_ids[8]),
('Proveedor9','3009999999',person_ids[9]),
('Proveedor10','3010000000',person_ids[10])
RETURNING id_supplier
)
SELECT array_agg(id_supplier) INTO supplier_ids FROM ins;

-- PRODUCT
WITH ins AS (
INSERT INTO product(name_product,price,category_id,supplier_id) VALUES
('Tinto',1500,category_ids[1],supplier_ids[1]),
('Cafe con leche',3000,category_ids[5],supplier_ids[1]),
('Empanada',2500,category_ids[2],supplier_ids[2]),
('Arepa queso',3500,category_ids[9],supplier_ids[3]),
('Sandwich',6000,category_ids[8],supplier_ids[4]),
('Jugo naranja',4000,category_ids[6],supplier_ids[5]),
('Gaseosa',3500,category_ids[7],supplier_ids[6]),
('Pan',1000,category_ids[4],supplier_ids[7]),
('Pastel pollo',4500,category_ids[3],supplier_ids[8]),
('Chocolate',3000,category_ids[1],supplier_ids[9])
RETURNING id_product
)
SELECT array_agg(id_product) INTO product_ids FROM ins;

-- INVENTORY
INSERT INTO inventory(quantity,product_id)
SELECT 30, id FROM unnest(product_ids) id;

-- CUSTOMER
WITH ins AS (
INSERT INTO customer(person_id)
SELECT id_person FROM unnest(person_ids) id_person
RETURNING id_customer
)
SELECT array_agg(id_customer) INTO customer_ids FROM ins;

-- ORDERS
WITH ins AS (
INSERT INTO orders(order_date,total,customer_id) VALUES
(NOW(),1500,customer_ids[1]),
(NOW(),3000,customer_ids[2]),
(NOW(),2500,customer_ids[3]),
(NOW(),3500,customer_ids[4]),
(NOW(),6000,customer_ids[5]),
(NOW(),4000,customer_ids[6]),
(NOW(),3500,customer_ids[7]),
(NOW(),1000,customer_ids[8]),
(NOW(),4500,customer_ids[9]),
(NOW(),3000,customer_ids[10])
RETURNING id_order
)
SELECT array_agg(id_order) INTO order_ids FROM ins;

-- ORDER ITEM
WITH inserted AS (
INSERT INTO order_item (quantity, price, order_id, product_id) VALUES
(1, 1500.00, order_ids[1], product_ids[1]),   -- tinto
(1, 3000.00, order_ids[2], product_ids[2]),   -- café con leche
(1, 2500.00, order_ids[3], product_ids[3]),   -- empanada
(1, 3500.00, order_ids[4], product_ids[4]),   -- arepa con queso
(1, 6000.00, order_ids[5], product_ids[5]),   -- sandwich
(1, 4000.00, order_ids[6], product_ids[6]),   -- jugo natural
(1, 3500.00, order_ids[7], product_ids[7]),   -- gaseosa
(1, 1000.00, order_ids[8], product_ids[8]),   -- pan
(1, 4500.00, order_ids[9], product_ids[9]),   -- pastel
(1, 3000.00, order_ids[10], product_ids[10])  -- chocolate
RETURNING id_order_item
)
SELECT array_agg(id_order_item) INTO order_item_ids FROM inserted;

-- METHOD PAYMENT
WITH ins AS (
INSERT INTO method_payment(name) VALUES
('Efectivo'),
('Tarjeta'),
('Transferencia'),
('Nequi'),
('Daviplata'),
('QR'),
('PayPal'),
('Credito'),
('Debito'),
('Otro')
RETURNING id_method_payment
)
SELECT array_agg(id_method_payment) INTO method_payment_ids FROM ins;

-- INVOICE
WITH inserted AS (
INSERT INTO invoice (invoice_date, total, customer_id) VALUES
(NOW(), 3000.00, customer_ids[1]),
(NOW(), 3000.00, customer_ids[2]),
(NOW(), 7500.00, customer_ids[3]),
(NOW(), 3500.00, customer_ids[4]),
(NOW(), 12000.00, customer_ids[5]),
(NOW(), 4000.00, customer_ids[6]),
(NOW(), 7000.00, customer_ids[7]),
(NOW(), 4000.00, customer_ids[8]),
(NOW(), 4500.00, customer_ids[9]),
(NOW(), 3000.00, customer_ids[10])
RETURNING id_invoice
)
SELECT array_agg(id_invoice) INTO invoice_ids FROM inserted;

-- INVOICE ITEM
WITH inserted AS (
INSERT INTO invoice_item (quantity, price, invoice_id, product_id) VALUES
(2, 1500.00, invoice_ids[1], product_ids[1]),   -- tinto
(1, 3000.00, invoice_ids[2], product_ids[2]),   -- café con leche
(3, 2500.00, invoice_ids[3], product_ids[3]),   -- empanada
(1, 3500.00, invoice_ids[4], product_ids[4]),   -- arepa con queso
(2, 6000.00, invoice_ids[5], product_ids[5]),   -- sandwich
(1, 4000.00, invoice_ids[6], product_ids[6]),   -- jugo
(2, 3500.00, invoice_ids[7], product_ids[7]),   -- gaseosa
(4, 1000.00, invoice_ids[8], product_ids[8]),   -- pan
(1, 4500.00, invoice_ids[9], product_ids[9]),   -- pastel
(1, 3000.00, invoice_ids[10], product_ids[10])  -- chocolate
RETURNING id_invoice_item
)
SELECT array_agg(id_invoice_item) INTO invoice_item_ids FROM inserted;

-- PAYMENT
WITH inserted AS (
INSERT INTO payment (amount, payment_date, invoice_id, method_payment_id) VALUES
(3000.00, NOW(), invoice_ids[1], method_payment_ids[1]),
(3000.00, NOW(), invoice_ids[2], method_payment_ids[2]),
(7500.00, NOW(), invoice_ids[3], method_payment_ids[1]),
(3500.00, NOW(), invoice_ids[4], method_payment_ids[3]),
(12000.00, NOW(), invoice_ids[5], method_payment_ids[1]),
(4000.00, NOW(), invoice_ids[6], method_payment_ids[2]),
(7000.00, NOW(), invoice_ids[7], method_payment_ids[1]),
(4000.00, NOW(), invoice_ids[8], method_payment_ids[3]),
(4500.00, NOW(), invoice_ids[9], method_payment_ids[1]),
(3000.00, NOW(), invoice_ids[10], method_payment_ids[2])
RETURNING id_payment
)
SELECT array_agg(id_payment) INTO payment_ids FROM inserted;

RAISE NOTICE 'Datos insertados correctamente';

END $$;