package com.sena.test.Imple.InventoryService;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.sena.test.Dto.InventoryDto.CategoryDto;
import com.sena.test.Entity.Inventory.Category;
import com.sena.test.IRepository.IInventoryRepository.CategoryRepository;
import com.sena.test.IService.IInventoryService.ICategoryService;

@Service
public class CategoryServiceImple implements ICategoryService{

    @Autowired
    private CategoryRepository repo;

    @Override
    public List<Category>findAll(){
        return repo.findAll();
    }

    @Override
    public Category findById(int id){
        return repo.findById(id).orElse(null);
    }

    @Override
    public String update(int id, CategoryDto categoryDto){
        Category category = repo.findById(id).orElse(null);

        if(category == null){
            return "Categoria no encontrada";
        }

        category.setName_category(categoryDto.getName_category());
        category.setDescription(categoryDto.getDescription());

        repo.save(category);

        return "Categoria guardada correctamente";
    }

    public Category dtoToEntity(CategoryDto categoryDto){
        return new Category(
            categoryDto.getId(),
            categoryDto.getName_category(),
            categoryDto.getDescription()
        );
    }

    public Category entityToDto(Category category){
        return new Category(
            category.getId(),
            category.getName_category(),
            category.getDescription()
        );
    }

    @Override
    public List<Category> filterByNameCategory(String name_Category){
        return repo.filterByNameCategory(name_Category);
    }

    @Override
    public String save(CategoryDto p){
        Category category = dtoToEntity(p);
        repo.save(category);
        return "La Categoria se guardo exitosamente";
    }

    @Override
    public String delete(int id){
        repo.deleteById(id);
        return null;
    }
}