package com.sena.test.Dto.InventoryDto;

public class CategoryDto {
    private int id;
    private String name_category;
    private String description;

    public CategoryDto(int id, String name_category, String description) {
        this.id = id;
        this.name_category = name_category;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName_category() {
        return name_category;
    }

    public void setName_category(String name_category) {
        this.name_category = name_category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}