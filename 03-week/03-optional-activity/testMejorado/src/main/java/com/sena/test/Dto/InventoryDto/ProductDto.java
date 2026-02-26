package com.sena.test.Dto.InventoryDto;

public class ProductDto {
    private int id;
    private String name_product;
    private double price;
    private String description;

    public ProductDto(int id, String name_product, double price, String description) {
        this.id = id;
        this.name_product = name_product;
        this.price = price;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName_product() {
        return name_product;
    }

    public void setName_product(String name_product) {
        this.name_product = name_product;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}