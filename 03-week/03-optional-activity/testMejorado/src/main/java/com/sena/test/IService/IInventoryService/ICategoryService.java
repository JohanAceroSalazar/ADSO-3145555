package com.sena.test.IService.IInventoryService;

import java.util.List;
import com.sena.test.Dto.InventoryDto.CategoryDto;
import com.sena.test.Entity.Inventory.Category;

public interface ICategoryService {

    public List<Category>findAll();
    public Category findById(int id);
    String update(int id, CategoryDto CategoryDto);
    public List<Category> filterByNameCategory(String name_Category);
    public String save(CategoryDto p);
    public String delete(int id);
}
