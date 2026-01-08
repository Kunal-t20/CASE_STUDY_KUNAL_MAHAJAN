show databases;
CREATE DATABASE DB;
USE DB;
CREATE TABLE companies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE warehouses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_warehouses_company
        FOREIGN KEY (company_id) REFERENCES companies(id)
);
    

CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2),
    is_bundle BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_products_company
        FOREIGN KEY (company_id) REFERENCES companies(id)
);


CREATE TABLE suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255),
    phone VARCHAR(50)
);


CREATE TABLE product_suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,

    CONSTRAINT fk_ps_product
        FOREIGN KEY (product_id) REFERENCES products(id),

    CONSTRAINT fk_ps_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);


CREATE TABLE inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,

    CONSTRAINT fk_inv_product
        FOREIGN KEY (product_id) REFERENCES products(id),

    CONSTRAINT fk_inv_warehouse
        FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),

    CONSTRAINT uniq_product_warehouse UNIQUE (product_id, warehouse_id)
);


CREATE TABLE inventory_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inventory_id BIGINT NOT NULL,
    change_amount INT NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_history_inventory
        FOREIGN KEY (inventory_id) REFERENCES inventory(id)
);


CREATE TABLE product_bundles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bundle_product_id BIGINT NOT NULL,
    child_product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,

    CONSTRAINT fk_bundle_parent
        FOREIGN KEY (bundle_product_id) REFERENCES products(id),

    CONSTRAINT fk_bundle_child
        FOREIGN KEY (child_product_id) REFERENCES products(id)
);
