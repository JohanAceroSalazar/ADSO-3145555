CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE DATABASE coffe_shop;

CREATE TABLE type_document (
    id_type_document UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE person (
    id_person UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_person VARCHAR(100),
    email VARCHAR(150),
    type_document_id UUID REFERENCES type_document(id_type_document),


    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE file (
    id_file UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100),
    person_id UUID REFERENCES person(id_person),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE Table users(
    id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id UUID REFERENCES person(id_person),
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(250) NOT NULL,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE role (
    id_role UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE module (
    id_module UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE Table view(
    id_view UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_view VARCHAR(100) NOT NULL,
    ROUTE VARCHAR(150),
    module_id UUID REFERENCES module(id_module),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE user_role(
    id_user_role UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id_user),
    role_id UUID REFERENCES role(id_role),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE role_module(
    id_role_module UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID REFERENCES role(id_role),
    module_id UUID REFERENCES module(id_module),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE module_view(
    id_module_view UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID REFERENCES module(id_module),
    view_id UUID REFERENCES view(id_view),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE category(
    id_category UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_category VARCHAR(100) NOT NULL,
    description TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE supplier (
    id_supplier UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_supplier VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    person_id UUID REFERENCES person(id_person),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE product (
    id_product UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_product VARCHAR(150) NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    category_id UUID REFERENCES category(id_category),
    supplier_id UUID REFERENCES supplier(id_supplier),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE inventory (
    id_inventory UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quantity INT,
    product_id UUID REFERENCES product(id_product),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE customer (
    id_customer UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    person_id UUID REFERENCES person(id_person),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE orders (
    id_order UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_date TIMESTAMPTZ DEFAULT NOW(),
    total NUMERIC(12,2),
    customer_id UUID REFERENCES customer(id_customer),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE order_item (
    id_order_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quantity INTEGER NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    order_id UUID REFERENCES orders(id_order),
    product_id UUID REFERENCES product(id_product),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE method_payment (
    id_method_payment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE invoice (
    id_invoice UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_date TIMESTAMPTZ DEFAULT NOW(),
    total NUMERIC(12,2),
    customer_id UUID REFERENCES customer(id_customer),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE invoice_item (
    id_invoice_item UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quantity INTEGER NOT NULL,
    price NUMERIC(12,2) NOT NULL,
    invoice_id UUID REFERENCES invoice(id_invoice),
    product_id UUID REFERENCES product(id_product),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);

CREATE TABLE payment (
    id_payment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    amount NUMERIC(12,2) NOT NULL,
    payment_date TIMESTAMPTZ DEFAULT NOW(),
    invoice_id UUID REFERENCES invoice(id_invoice),
    method_payment_id UUID REFERENCES method_payment(id_method_payment),

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    created_by UUID,
    updated_by UUID,
    deleted_by UUID,
    status BOOLEAN DEFAULT TRUE
);